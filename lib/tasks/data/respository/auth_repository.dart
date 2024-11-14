import 'package:firebase_auth/firebase_auth.dart';
import 'package:kanban_board_test/tasks/data/local/data_sources/auth_data_provider.dart';

class AuthRepository{
  final AuthDataProvider authDataProvider;

  AuthRepository({ required this.authDataProvider });

  Future<UserCredential> signIn(String email, String password){
    return authDataProvider.signIn(email, password);
  }

  Future<void> signOut() {
    return authDataProvider.signOut();
  }

  Future<bool> checkSession (){
    return authDataProvider.checkSession();
  }

  Future<void> resetPassword(String email){
    return authDataProvider.resetPassword(email);
  }

  Future<UserCredential> reauthenticateAdmin(String password){
    return authDataProvider.reauthenticateAdmin(password);
  }
}