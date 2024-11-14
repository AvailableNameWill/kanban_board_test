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
}