part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent{}

class AddNewNotificationEvent extends NotificationEvent{
  final NotificationModel notificationModel;

  AddNewNotificationEvent({ required this.notificationModel });
}

class FetchNotificationEvent extends NotificationEvent{}

class UpdateNotificationEvent extends NotificationEvent{
  final NotificationModel notificationModel;

  UpdateNotificationEvent({ required this.notificationModel });
}

class DeleteNotificationEvent extends NotificationEvent{
  final NotificationModel notificationModel;

  DeleteNotificationEvent({ required this.notificationModel });
}