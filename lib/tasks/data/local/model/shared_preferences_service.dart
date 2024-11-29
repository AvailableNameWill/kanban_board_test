import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService{
  Future<void> saveUserInfo(String name, String userType) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('userType', userType);
  }

  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final userType = prefs.getString('userType');
    return {'name' : name, 'userType' : userType};
  }

  Future<String?> getUserName() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  Future<String?> getUserType() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  Future<void> deleteUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('userType');
  }
}