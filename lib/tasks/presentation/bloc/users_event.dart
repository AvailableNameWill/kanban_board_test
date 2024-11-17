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

class UpdateUserEvent extends UsersEvent{
  final UserModel userModel;

  UpdateUserEvent({ required this.userModel });
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