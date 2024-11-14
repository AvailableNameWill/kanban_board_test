part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent{}

/* LoginEvent: Se usa cuando el usuario intenta iniciar sesión. Incluye email, password, username, y userType. */
class LoginEvent extends AuthEvent{
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });
}

/* LogoutEvent: Se utiliza cuando el usuario intenta cerrar sesión. */
class LogoutEvent extends AuthEvent{}

/* CheckSessionEvent: Comprueba si existe una sesión guardada en SecureStorageService. */
class CheckSessionStarted extends AuthEvent{}

class ResetPasswordEvent extends AuthEvent{
  final String email;

  ResetPasswordEvent({required this.email});
}

class ReauthenticateAdminEvent extends AuthEvent{
  final String password;

  ReauthenticateAdminEvent({ required this.password });
}