import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kanban_board_test/tasks/data/local/model/user_model.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

import '../model/secure_storage_service.dart';
import '../model/shared_preferences_service.dart';

class UserDataProvider{
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final SecureStorageService service;
  final SharedPreferencesService sharedPreferencesService;

  UserDataProvider(this.firestore, this.auth, this.service, this.sharedPreferencesService);

  Future<List<UserModel>> getUsers() async{
    List<UserModel> users = [];

    try{
      final querySnapshot = await firestore.collection('users').where('status', isEqualTo: 'enabled').get();

      for(var doc in querySnapshot.docs){
        users.add(UserModel(
            id: doc.id,
            name: doc['name'],
            userType: doc['userType'],
            status: doc['status']
          ));
      }

      /*Ordenar los usuarios*/
      /*users.sort((a, b) => a.name.compareTo(b.name));*/
      print('usuarios' + users.length.toString());
      return users;
    }catch(exception){
      print('user data provider error: ' + exception.toString());
      throw Exception(handleException(exception));
    }
  }

  Future<Map<String, String>> getUserNamesMap() async{
    try{
      final querySnapshot = await firestore.collection('users').where('status', isEqualTo: 'enabled').get();
      final Map<String, String> userNames = {};

      for (var doc in querySnapshot.docs){
        final uid = doc.id;
        final uName = doc['name'];
        userNames[uid] = uName;
      }

      return userNames;
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }

  /*Future<List<UserModel>> sortUsers(int sortOption) async{
    /* Ver como ordenar los usuarios (si se le agregan mas campos a la tabla usuarios) */
  }*/

  Future<String> createUser(UserModel userModel, String email, String password) async {
    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      /*await firestore.collection('users').doc(uid).set({
        'name' : userModel.name,
        'userType' : userModel.userType
      });*/
      return uid;
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<void> addUserToFireStore(String uid, UserModel userModel) async {
    try{
      await firestore.collection('users').doc(uid).set({
        'name': userModel.name,
        'userType': userModel.userType,
        'status': userModel.status,
      });
    }catch(exception){
      print('Error al agregar usuario a FireStore');
      throw Exception(handleException(exception.toString()));
    }
  }

  /*
  *
  Contraseña, EMAIL, nombre, tipo de usuario
  * Cambiar pass-email en auth provider
  * Cambiar name y userType en Firestore 'users'
  * Solo el administrador puede camiar el tipo de usuario y el correo
  * Nombre y contraseña pueden ser cambiadas por los Empleados
  *
  * */

  Future<void> updateUserInFirestore(UserModel userModel) async {
    try {
      await firestore.collection('users').doc(userModel.id).update(userModel.toJson());
    } catch (exception) {
      print('Error al actualizar en Firestore');
      throw Exception(handleException(exception));
    }
  }

  Future<void> updateAuthUser(String? newEmail, String? newPassword, String? currentPassword) async {
    try {
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        if (newEmail != null && newEmail.trim().isNotEmpty && newEmail != currentUser.email) {
          await currentUser.verifyBeforeUpdateEmail(newEmail);
        }
        if ( newPassword != null && currentPassword != null && newPassword.trim().isNotEmpty && currentPassword.trim().isNotEmpty) {
          //reautenticar el usuario antes de cambiar la contraseña
          final credential = EmailAuthProvider.credential(email: currentUser.email!, password: currentPassword);
          await currentUser.reauthenticateWithCredential(credential);
          await currentUser.updatePassword(newPassword);
        }
      }
    } catch (exception) {
      print('Error al actualizar en Auth');
      throw Exception(handleException(exception));
    }
  }

  Future<List<UserModel>> updateUserInfo(UserModel userModel) async {
    try{
      await firestore.collection('users').doc(userModel.id).update(userModel.toJson());
      print('Usuario actualizado correctamente');
      return await getUsers();
    }catch(error){
      print('Error en el metodo de actualizar usuarios');
      throw handleException(error.toString());
    }
  }

  Future<List<UserModel>> updateUser(UserModel userModel, String newEmail, String newPassword, String currentPassword) async{
    try{
      await updateUserInFirestore(userModel);
      await updateAuthUser(newEmail, newPassword, currentPassword);
      return await getUsers();
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<List<UserModel>> deleteUser(UserModel userModel) async {
    try{
      await firestore.collection('users').doc(userModel.id).delete();
      return await getUsers();
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<List<UserModel>> searchUsers(String keywords) async{
    final List<UserModel> users = await getUsers();

    final searchText = keywords.toLowerCase();

    return users.where((user){
      final nameMatches = user.name.toLowerCase().contains(searchText);
      /*Agregar otras opciones si se le agregan mas campos a la coleccion Users*/
      return nameMatches;
    }).toList();
  }

  Future<void> updateUserLocalInfo(String name, String userType) async {
    try{
      sharedPreferencesService.updateUserName(name);
      sharedPreferencesService.updateUserType(userType);
    }catch(exception){
      throw handleException(exception.toString());
    }
  }
}

/*
*
Los metodos para cambiar email y contraseña en Firebase envian un correo al email del usuario que desea hacer el cambio
* Cambiar la pantalla, poner un boton para el cambio de contraseña, cambiar los metodos
* El metodo 'updatePassword ocupa que el usuario haya iniciado sesion recientemente, en ese caso es necesario reautenticar
* al usuario antes de proceder con este metodo, asi se quita el boton y se dejan los TextFields
* Enviar un UserModel a la pantalla de info del usuario o crear el UserModel en la pantalla, al momento de actualizar cambiar
* los datos del UserModel que se quieran cambiar
* Cargar los valores del UserModel en el TextFieldController de nombre, asignar el valor de userType a una variable y
* dejarlo como valor predeterminado en el DropDownButton, tomar el email del usuario y asignarlo como valor de
* TextFieldController de email, la contraseña no
*
* */