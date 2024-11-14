import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/shared_preferences_service.dart';
import 'package:flutter/foundation.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

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
}