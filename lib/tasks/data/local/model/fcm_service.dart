import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

class FCMService{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getToken() async{
    try{
      String? token = await _firebaseMessaging.getToken();
      return token;
    }catch(error){
      throw handleException(error.toString());
    }
  }

  Future<void> verifyAndUpdateToken(String userId) async{
    try{
      String? newToken = await getToken();
      if (newToken != null){
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        String? currentToken = (userDoc.data() as Map<String, dynamic>?)?['fcmToken'];
        print('Token verified');
        if (currentToken != newToken){
          await FirebaseFirestore.instance.collection('users').doc(userId).update({'fcmToken' : newToken});
          print('Token updated');
        }
      }
    }catch(error){
      throw handleException(error.toString());
    }
  }
}