import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService{
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveUserSession(String uid, String token, String email) async{
    await _storage.write(key: 'uid', value: uid);
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'email', value: email);
  }

  Future<Map<String, String?>> getUserSession() async {
    final uid = await _storage.read(key: 'uid');
    final token = await _storage.read(key: 'token');
    final email = await _storage.read(key: 'email');
    return {'uid' : uid, 'token' : token, 'email' : email};
  }

  Future<void> deleteUserSession() async{
    await _storage.delete(key: 'uid');
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'email');
  }

  Future<String> getEmail() async{
    return await _storage.read(key: 'email') ?? '';
  }

  Future<String?> getToken() async{
    return await _storage.read(key: 'token');
  }

  Future<String> getUid() async{
    return await _storage.read(key: 'uid') ?? '';
  }

  Future<void> updateEmail (String email) async {
    await _storage.write(key: 'email', value: email);
  }
}