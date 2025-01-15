import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/model/notification_model.dart';
import '../../data/respository/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState>{
  final NotificationRepository notificationRepository;

  NotificationBloc( {required this.notificationRepository}) : super(FetchNotificationSuccess(notification: const[])){
    on<AddNewNotificationEvent>(_addNotification);
    on<FetchNotificationEvent>(_fetchNotification);
    on<UpdateNotificationEvent>(_updateNotification);
    on<DeleteNotificationEvent>(_deleteNotification);
  }

  _addNotification(AddNewNotificationEvent event, Emitter<NotificationState> emit) async{
    try{
      if (event.notificationModel.title.trim().isEmpty || event.notificationModel.title == null){
        return emit(AddNotificationFailure(error: 'El titulo de la notificacion no puede estar vacio'));
      }
      if (event.notificationModel.content.trim().isEmpty || event.notificationModel.content == null){
        return emit(AddNotificationFailure(error: 'El contenido de la notificacion no puede estar vacio'));
      }
      if (event.notificationModel.timeLapse.trim().isEmpty || event.notificationModel.timeLapse == null){
        return emit(AddNotificationFailure(error: 'El contenido de la notificacion no puede estar vacio'));
      }

      await notificationRepository.createNotification(event.notificationModel);
      return emit(AddNotificationSuccess());
    }catch(exception){
      emit(AddNotificationFailure(error: exception.toString()));
    }
  }

  void _fetchNotification(FetchNotificationEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationsLoading());
    try{
      final notification = await notificationRepository.getNotification();
      return emit(FetchNotificationSuccess(notification: notification));
    }catch(exception){
      emit(FetchNotificationFailure(error: exception.toString()));
    }
  }

  _updateNotification(UpdateNotificationEvent event, Emitter<NotificationState> emit) async {
    try{
      if (event.notificationModel.content.trim().isEmpty || event.notificationModel.content == null){
        return emit(UpdateNotificationFailure(error: 'El contenido de la notificacion no puede estar vacio'));
      }
      if (event.notificationModel.timeLapse.trim().isEmpty || event.notificationModel.timeLapse == null){
        return emit(UpdateNotificationFailure(error: 'El contenido de la notificacion no puede estar vacio'));
      }
      emit(NotificationsLoading());
      final notification = await notificationRepository.updateNotification(event.notificationModel);
      emit(UpdateNotificationSuccess());
      return emit(FetchNotificationSuccess(notification: notification));
    }catch(exception){
      emit(UpdateNotificationFailure(error: exception.toString()));
    }
  }

  _deleteNotification(DeleteNotificationEvent event, Emitter<NotificationState> emit) async{
    emit(NotificationsLoading());
    try{
      final notification = await notificationRepository.deleteNotification(event.notificationModel);
      return emit(FetchNotificationSuccess(notification: notification));
    }catch(exception){
      emit(DeleteNotificationFailure(error: exception.toString()));
    }
  }
}