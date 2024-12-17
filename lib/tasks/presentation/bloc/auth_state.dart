part of 'auth_bloc.dart';

@immutable
sealed class AuthState{}

/* AuthInitial: Estado inicial. */
class AuthInitial extends AuthState{}

/* AuthLoading: Estado mientras se realiza alguna acción de autenticación. */
class AuthLoading extends AuthState{}

/* LoginSuccess: Estado de éxito después de un inicio de sesión exitoso. */
class LoginSuccess extends AuthState{}

/* LogoutSuccess: Estado de éxito después de un cierre de sesión exitoso. */
class LogoutSuccess extends AuthState{}

/* AuthFailure: Estado de fallo en caso de que haya un error. */
class AuthFailure extends AuthState{
  final String error;

  AuthFailure({ required this.error });
}

class DeleteAuthUserSuccess extends AuthState{}

class DeleteAuthUserFailure extends AuthState{
  final String error;
  DeleteAuthUserFailure({ required this.error });
}

/* SessionActive: Estado cuando hay una sesión activa. */
class SessionActive extends AuthState{
  final String userId;

  SessionActive({ required this.userId });
}

/* SessionInactive: Estado cuando no hay una sesión activa. */
class SessionInactive extends AuthState{}

class ResetPasswordSuccess extends AuthState{}

class ResetPasswordFailure extends AuthState{
  String error;

  ResetPasswordFailure({ required this.error });
}

class userRauthenticationRequired extends AuthState{}

class ReauthenticationSuccess extends AuthState{
  final UserCredential userCredential;

  ReauthenticationSuccess({ required this.userCredential });
}

class PasswordUpdateSuccess extends AuthState{}

class PasswordUpdateFailure extends AuthState{
  final String error;

  PasswordUpdateFailure({ required this.error });
}

class UpdateEmailInitial extends AuthState{}

class UpdateEmailLoading extends AuthState{}

class UpdateEmailSuccess extends AuthState{}

class UpdateEmailFailure extends AuthState{
  final String error;

  UpdateEmailFailure({ required this.error });
}