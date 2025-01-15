import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kanban_board_test/tasks/data/local/model/notification_model.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

class NotificationsDataProvider{
  final FirebaseFirestore firestore;

  NotificationsDataProvider(this.firestore);

  Future<List<NotificationModel>> getNotifications() async{
    List<NotificationModel> notifications = [];
    try{
      final querySnapshot = await firestore.collection('notification').get();

      for(var doc in querySnapshot.docs){
        notifications.add(NotificationModel(
            id: doc.id,
            title: doc['title'],
            content: doc['content'],
            timeLapse: doc['timeLapse']
          )
        );
      }

      return notifications;
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }

  Future<void> createNotification(NotificationModel model) async{
    try{
      await firestore.collection('notification').add(model.toJson());
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }

  Future<List<NotificationModel>> updateNotification(NotificationModel model) async{
    try{
      await firestore.collection('notification').doc(model.id).update(model.toJson());
      return await getNotifications();
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }

  Future<List<NotificationModel>> deleteNotification(NotificationModel model) async{
    try{
      await firestore.collection('notification').doc(model.id).delete();
      return await getNotifications();
    }catch(exception){
      throw Exception(handleException(exception.toString()));
    }
  }
}