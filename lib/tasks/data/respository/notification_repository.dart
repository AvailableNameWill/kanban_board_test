import 'package:kanban_board_test/tasks/data/local/data_sources/notifications_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/model/notification_model.dart';

class NotificationRepository{
  final NotificationsDataProvider notificationsDataProvider;

  NotificationRepository({ required this.notificationsDataProvider });

  Future<List<NotificationModel>> getNotification() async{
    return await notificationsDataProvider.getNotifications();
  }

  Future<void> createNotification(NotificationModel model) async{
    return await notificationsDataProvider.createNotification(model);
  }

  Future<List<NotificationModel>> updateNotification(NotificationModel model) async{
    return await notificationsDataProvider.updateNotification(model);
  }

  Future<List<NotificationModel>> deleteNotification(NotificationModel model) async{
    return await notificationsDataProvider.deleteNotification(model);
  }
}