import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/shared_preferences_service.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

class AuthDataProvider{
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final SecureStorageService service;
  final SharedPreferencesService sharedPreferencesService;

  AuthDataProvider( this.auth, this.firestore, this.service, this.sharedPreferencesService );

  Future<UserCredential> signIn(String email, String password) async {
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user?.uid ?? '';
      String? token = await userCredential.user?.getIdToken();

      if(uid.isNotEmpty){
        Map<String, String> userInfo = await _getUserInfoFromFireStore(uid);

        await service.saveUserSession(uid, token ?? '', email);

        await sharedPreferencesService.saveUserInfo(userInfo['name'] ?? '', userInfo['userType'] ?? '');
      }
      return userCredential;
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<void> updatePassword(String newPassword, String currentPassword) async{
    try{
      final currentUser = auth.currentUser;
      if (currentUser != null){
        final credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);

        await currentUser.updatePassword(newPassword);
        print('Actualizacion de contraseña exitosa');
      }else{
        throw handleException('Usuario no autenticado');
      }
    }catch(error){
      print('Error en metodo de actualizar contraseña: ' + error.toString());
      throw handleException(error.toString());
    }
  }

  /*
  * Titulo: Email enviado
  * Mensaje: Se ha enviado un mensaje de confirmacion a su nuevo correo electronico. Revise su bandeja de entrada o SPAM
  * y valide el nuevo email. Si no se valida no podra iniciar sesion con el nuevo correo.
  * */
  Future<void> updateEmail(String newEmail) async{
    try {
      final currentUser = auth.currentUser;
      currentUser?.verifyBeforeUpdateEmail(newEmail);
      auth.signOut();
      print('email de actualizacion enviado!!!');
      //Cerrar la ventana y redirigir al login
    }catch(error){
      print('Error en el metodo de actualizar email' + error.toString());
      throw handleException(error.toString());
    }
  }

  Future<void> signOut() async{
    try{
      await auth.signOut();
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<bool> checkSession() async{
    try{
      final session = await service.getUserSession();
      final uid = session['uid'];
      final token = session['token'];

      final currentUser = auth.currentUser;

      return uid != null && token != null && currentUser != null && currentUser.uid == uid;
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<void> resetPassword(String email) async{
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<Map<String, String>> _getUserInfoFromFireStore(String id) async {
    try{
      DocumentSnapshot snapshot = await firestore.collection('users').doc(id).get();
      if(snapshot.exists){
        String name = snapshot.get('name');
        String userType = snapshot.get('userType');
        return { 'name' : name, 'userType' : userType };
      }else{
        throw Exception(handleException('Usuario no encontrado'));
      }
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }



  Future<UserCredential> reauthenticateAdmin(String password) async{
    try{
      final String email = await service.getEmail();
      final String? token = await service.getToken();
      if(email.isEmpty){
        throw Exception(handleException('Error con los datos del administrador'));
      }

      print(email);
      print(password);
      print(token);

      auth.signOut();

      //final AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

      final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    }catch(exception){
      print('Error de reautenticacion');
      throw Exception(handleException(exception.toString()));
    }
  }

  Future<void> deleteAuthUser(String email, String password) async{
    try{
      auth.signOut();
      final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      final currentUser = auth.currentUser;
      await currentUser!.delete();
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }
}