part of 'users_bloc.dart';

@immutable
sealed class UsersState{}

final class FetchUserSuccess extends UsersState{
  final List<UserModel> users;
  final bool isSearching;

  FetchUserSuccess({ required this.users, this.isSearching = false});
}

final class AddUserSuccess extends UsersState{}

final class LoadUserFailure extends UsersState{
  final String error;

  LoadUserFailure({ required this.error });
}

final class AddUserFailure extends UsersState{
  final String error;
  AddUserFailure({ required this.error });
}

final class UsersLoading extends UsersState{}

final class UpdateUserFailure extends UsersState{
  final String error;

  UpdateUserFailure({ required this.error });
}

final class UpdateUserSuccess extends UsersState{}

final class ReauthenticationRequired extends UsersState{
  final String uid;
  final UserModel userModel;

  ReauthenticationRequired({ required this.uid, required this.userModel });
}
