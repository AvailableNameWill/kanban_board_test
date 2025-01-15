part of 'notification_bloc.dart';

@immutable
sealed class NotificationState{}

final class FetchNotificationSuccess extends NotificationState{
  final List<NotificationModel> notification;
  final bool isSearching;

  FetchNotificationSuccess({ required this.notification, this.isSearching = false });
}

final class AddNotificationSuccess extends NotificationState{}

final class DeleteNotificationSuccess extends NotificationState{}

final class UpdateNotificationSuccess extends NotificationState{}

final class FetchNotificationFailure extends NotificationState{
  final String error;

  FetchNotificationFailure({ required this.error });
}

final class AddNotificationFailure extends NotificationState{
  final String error;

  AddNotificationFailure({ required this.error });
}

final class DeleteNotificationFailure extends NotificationState{
  final String error;

  DeleteNotificationFailure({ required this.error });
}

final class UpdateNotificationFailure extends NotificationState{
  final String error;

  UpdateNotificationFailure({ required this.error });
}

final class NotificationsLoading extends NotificationState{}

