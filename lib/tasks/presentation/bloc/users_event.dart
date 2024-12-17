part of 'users_bloc.dart';

@immutable
sealed class UsersEvent{}

class AddNewUserEvent extends UsersEvent{
  final String email;
  final String password;
  final UserModel userModel;

  AddNewUserEvent({required this.userModel, required this.email, required this.password});
}

class FetchUserEvent extends UsersEvent{}

class SortUserEvent extends UsersEvent{
  final int sortOption;

  SortUserEvent({ required this.sortOption });
}

class UpdateUserInfoEvent extends UsersEvent{
  final UserModel userModel;

  UpdateUserInfoEvent({ required this.userModel});
}

class UpdateUserLocalInfoEvent extends UsersEvent{
  final String name;
  final String userType;

  UpdateUserLocalInfoEvent({ required this.name, required this.userType });
}

class DeleteUserEvent extends UsersEvent {
  final UserModel userModel;

  DeleteUserEvent({required this.userModel});
}

class SearchUserEvent extends UsersEvent{
  final String keywords;

  SearchUserEvent({required this.keywords });
}

class RequireReauthenticationEvent extends UsersEvent{
  final String uid;
  final UserModel userModel;

  RequireReauthenticationEvent({ required this.uid, required this.userModel });
}

class CompleteUserCreationEvent extends UsersEvent{
  final String uid;
  final UserModel userModel;

  CompleteUserCreationEvent({ required this.uid, required this.userModel });
}

class LoadUserNames extends UsersEvent{}