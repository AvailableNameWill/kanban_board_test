import 'package:kanban_board_test/tasks/data/local/data_sources/users_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/model/user_model.dart';

class UserRepository{
  final UserDataProvider userDataProvider;

  UserRepository({ required this.userDataProvider });

  Future<List<UserModel>> getUsers() async{
    return await userDataProvider.getUsers();
  }

  Future<Map<String, String>> getUserNamesMap(){
    return userDataProvider.getUserNamesMap();
  }
  Future<String> createNewUser(UserModel userModel, String email, String password) async{
    return await userDataProvider.createUser(userModel, email, password);
  }

  Future<void> addUserToFireStore(String uid, UserModel userModel) async {
    return await userDataProvider.addUserToFireStore(uid, userModel);
  }

  Future<void> updateUserInfo(UserModel userModel) async{
    return await userDataProvider.updateUserInFirestore(userModel);
  }

  Future<void> updateUserLocalInfo(String name, String userType) async {
    return await userDataProvider.updateUserLocalInfo(name, userType);
  }

  Future<List<UserModel>> deleteUser(UserModel userModel) async{
    return await userDataProvider.deleteUser(userModel);
  }

  /*Future<List<UserModel>> sortUsers(int sortOption) async{
    return await userDataProvider.sortUsers(sortOption);
  }*/

  Future<List<UserModel>> searchUser(String search) async{
    return await userDataProvider.searchUsers(search);
  }
}