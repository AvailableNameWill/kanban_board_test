import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kanban_board_test/tasks/data/local/model/user_model.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

class UserDataProvider{
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  UserDataProvider(this.firestore, this.auth);

  Future<List<UserModel>> getUsers() async{
    List<UserModel> users = [];

    try{
      final querySnapshot = await firestore.collection('users').get();

      for(var doc in querySnapshot.docs){
        users.add(UserModel(
            id: doc.id,
            name: doc['name'],
            userType: doc['userType']
          ));
      }

      /*Ordenar los usuarios*/
      print(users.length);
      return users;
    }catch(exception){
      print('user data provider error: ' + exception.toString());
      throw Exception(handleException(exception));
    }
  }

  Future<Map<String, String>> getUserNamesMap() async{
    try{
      final querySnapshot = await firestore.collection('users').get();
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
        'userType': userModel.userType
      });
    }catch(exception){
      print('Error al agregar usuario a FireStore');
      throw Exception(handleException(exception.toString()));
    }
  }

  Future<List<UserModel>> updateUser(UserModel userModel) async{
    try{
      await firestore.collection('users').doc(userModel.id).update(userModel.toJson());
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
}