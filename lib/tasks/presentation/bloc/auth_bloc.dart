import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/shared_preferences_service.dart';
import 'package:flutter/foundation.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../data/respository/auth_repository.dart';


part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final AuthRepository authRepository;
  final SharedPreferencesService sharedPreferencesService;
  final SecureStorageService secureStorageService;

  AuthBloc({ required this.authRepository, required this.sharedPreferencesService, required this.secureStorageService })
  : super (AuthInitial()){
    on<LoginEvent>(_login);
    on<LogoutEvent>(_logout);
    on<CheckSessionStarted>(_checkSession);
    on<ResetPasswordEvent>(_resetPassword);
    on<ReauthenticateAdminEvent>(_mapReauthenticateAdminEventToState);
    on<UpdatePasswordEvent>(_updatePassword);
    on<UpdateEmailEvent>(_updateEmail);
    on<DeleteAuthUserEvent>(_deleteAuthUser);
  }

  Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try{
      if(event.email.trim().isEmpty){
        return emit(AuthFailure(error: 'El campo de correo electronico no puede estar vacio'));
      }
      if(event.password.trim().isEmpty){
        return emit(AuthFailure(error: 'La contraseña no puede estar vacia'));
      }
      final userCredential = await authRepository.signIn(event.email, event.password);

      final user = userCredential.user;

      if (user == null){
        throw Exception(handleException('No se puede identificar el usuario'));
      }

      emit(LoginSuccess());

    }catch(error){
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try{
      await authRepository.signOut();

      await secureStorageService.deleteUserSession();
      await sharedPreferencesService.deleteUserInfo();

      emit(LogoutSuccess());
    }catch(error){
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _checkSession(CheckSessionStarted event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try{
      final sessionActive = await authRepository.checkSession();

      if(sessionActive){
        emit(SessionActive(userId: 'userId'));
      }else{
        emit(SessionInactive());
      }
    }catch(error){
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _resetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async{
    emit(AuthLoading());
    try{
      await authRepository.resetPassword(event.email);
      emit(ResetPasswordSuccess());
    }catch(error){
      emit(AuthFailure(error: error.toString()));
    }
  }

  Future<void> _mapReauthenticateAdminEventToState( ReauthenticateAdminEvent event, Emitter<AuthState> emit) async {
    if(event.password.isEmpty){
      emit(AuthFailure(error: 'La contraseña no puede estar vacia'));
      return;
    }

    try{
      emit(AuthLoading());
      final userCredential = await authRepository.reauthenticateAdmin(event.password);
      emit(ReauthenticationSuccess(userCredential: userCredential));
    }catch(exception){
      print('Error de reautenticacion en BLoC');
      emit(AuthFailure(error: 'Error al reautenticar al administrador. Error: $exception'));
    }
  }

  Future<void> _updatePassword(UpdatePasswordEvent event, Emitter<AuthState> emit) async{
    try{
      emit(AuthLoading());
      final validateErrors = _validatePassword(currentPassword: event.currentPassword, newPassword: event.newPassword, repeatNewPassword: event.repeatNewPassword);
      if (validateErrors != null){
        emit(AuthFailure(error: validateErrors));
        return;
      }
      await authRepository.updatePassword(event.newPassword, event.currentPassword);
      emit(PasswordUpdateSuccess());
    }catch(exception){
      emit(AuthFailure(error: exception.toString()));
    }
  }
  
  Future<void> _updateEmail(UpdateEmailEvent event, Emitter<AuthState> emit) async{
    try{
      if(!isValidEmail(event.newEmail)){
        emit(UpdateEmailFailure(error: 'Correo electronico invalido!'));
        return;
      }
      emit(UpdateEmailLoading());
      await authRepository.updateEmail(event.newEmail);
      emit(UpdateEmailSuccess());
    }catch(exception){
      emit(UpdateEmailFailure(error: exception.toString()));
    }
  }

  Future<void> _deleteAuthUser(DeleteAuthUserEvent event, Emitter<AuthState> emit) async{
    try{
      final int length = await authRepository.getUsersLength();
      if (!isValidEmail(event.email) || event.email.isEmpty || event.email == null){
        emit(DeleteAuthUserFailure(error: 'Correo electronico invalido!'));
        return;
      }
      if (event.password.isEmpty || event.password == null || event.password.length < 8){
        emit(DeleteAuthUserFailure(error: 'Contraseña invalida!'));
        return;
      }
      if (length <= 1){
        emit(DeleteAuthUserFailure(error: 'Usted es el unico administrador, agregue otro administrador antes de continuar '
            'con la eliminacion de su cuenta'));
        return;
      }
      await authRepository.deleteAuthUser(event.email, event.password);
      emit(DeleteAuthUserSuccess());
    }catch(error){
      emit(DeleteAuthUserFailure(error: error.toString()));
    }
  }

  String? _validatePassword({ required String currentPassword, required String newPassword, required String repeatNewPassword }){
    if (currentPassword.isEmpty || newPassword.isEmpty || repeatNewPassword.isEmpty){
      return 'Todos los campos son obligatorios!';
    }
    if (newPassword.length < 8){
      return 'La nueva contraseña debe de tener una longitud minima de 8 caracteres!';
    }
    if (newPassword != repeatNewPassword){
      return 'Las contraseñas no coinciden';
    }
    if (newPassword == currentPassword){
      return 'La nueva contraseña no puede ser igual a la contraseña actual';
    }
    return null;
  }
}