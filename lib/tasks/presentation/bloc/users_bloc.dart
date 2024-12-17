import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/data/respository/user_repository.dart';
import 'package:kanban_board_test/tasks/data/local/model/user_model.dart';

part 'users_event.dart';

part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState>{
  final UserRepository userRepository;
  
  UsersBloc(this.userRepository) : super(FetchUserSuccess(users: const [])){
    on<AddNewUserEvent>(_addNewUser);
    on<FetchUserEvent>(_fetchUsers);
    on<UpdateUserInfoEvent>(_updateUser);
    on<DeleteUserEvent>(_deleteUser);
    //on<SortUserEvent>(_sortUsers);
    on<SearchUserEvent>(_searchUsers);
    on<CompleteUserCreationEvent>(_completeUserCreation);
    on<LoadUserNames>(_onLoadUserNames);
    on<UpdateUserLocalInfoEvent>(_updateUserLocalInfo);
  }
  
  _addNewUser(AddNewUserEvent event, Emitter<UsersState> emit) async{
    try{
      if(event.userModel.name.trim().isEmpty){
        return emit(AddUserFailure(error: 'El nombre del usuario no puede estar vacio'));
      }
      if(event.userModel.userType.trim().isEmpty || event.userModel.userType == null){
        return emit(AddUserFailure(error: 'Debe seleccionar el tipo de usuario'));
      }
      final uid = await userRepository.createNewUser(event.userModel, event.email, event.password,);
      emit(ReauthenticationRequired(uid: uid, userModel: event.userModel));
      /*emit(AddUserSuccess());
      final users = await userRepository.getUsers();
      return emit(FetchUserSuccess(users: users));*/
    }catch(exception){
      print('Error al agregar usuario BLoC');
      emit(AddUserFailure(error: exception.toString()));
    }
  }

  _completeUserCreation(CompleteUserCreationEvent event, Emitter<UsersState> emit) async {
    try{
      await userRepository.addUserToFireStore(event.uid, event.userModel);
      emit(AddUserSuccess());
      final users = await userRepository.getUsers();
      emit(FetchUserSuccess(users: users));
    }catch(exception){
      emit(AddUserFailure(error: exception.toString()));
    }
  }

  void _fetchUsers(FetchUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    print('Getting users');
    try{
      final users = await userRepository.getUsers();
      if (state is UsersLoaded && (state as UsersLoaded).userNames.isNotEmpty){
        final currentNames = (state as UsersLoaded).userNames.isNotEmpty ? (state as UsersLoaded).userNames : await userRepository.getUserNamesMap();
        return emit(UsersLoaded(users: users, userNames: currentNames));
      }else{
        final userNames = await userRepository.getUserNamesMap();
        return emit(UsersLoaded(userNames: userNames, users: users));
      }
      /*print('usersBloc' + users.length.toString());
      return emit(UsersLoaded(users: users, userNames: {}));*/
    }catch(exception){
      emit(LoadUserFailure(error: exception.toString()));
      print('Load users Failure in users bloc' + exception.toString());
    }
  }

  void _onLoadUserNames(LoadUserNames event, Emitter<UsersState> emit) async{
    emit(UsersLoading());
    try{
      final userNames = await userRepository.getUserNamesMap();
      if (state is UsersLoaded && (state as UsersLoaded).users != null){
        final users = state is UsersLoaded ?(state as UsersLoaded).users : await userRepository.getUsers();
        return emit(UsersLoaded(userNames: userNames, users: users));
      }else{
        final users = await userRepository.getUsers();
        return emit(UsersLoaded(userNames: userNames, users: users));
      }
      /*final currentUsers = state is UsersLoaded ? (state as UsersLoaded).users : null;
      emit(UsersLoaded(users: currentUsers, userNames: userNames));*/
    }catch(error){
      emit(LoadUserFailure(error: error.toString()));
    }
  }
  
  _updateUser(UpdateUserInfoEvent event, Emitter<UsersState> emit) async{
    try{
      if(event.userModel.name.trim().isEmpty){
        emit(UpdateUserFailure(error: 'El nombre no puede estar vacio'));
        return;
      }
      if(event.userModel.userType.trim().isEmpty || event.userModel.userType == null){
        emit(UpdateUserFailure(error: 'Debe seleccionar el tipo de usuario'));
        return;
      }
      final users = await userRepository.updateUserInfo(event.userModel);
      //await userRepository.updateUserLocalInfo(event.userModel.name, event.userModel.userType);
      emit(UpdateUserSuccess());
      emit(UsersInitial());
    }catch(exception){
      emit(UpdateUserFailure(error: exception.toString()));
    }
  }
  
  _updateUserLocalInfo(UpdateUserLocalInfoEvent event, Emitter<UsersState> emit) async {
    try{
      if(event.name.isEmpty || event.name == null){
        emit(UpdateUserLocalInfoFailure(error: 'No hay nombre de usuario!'));
      }
      if (event.userType.isEmpty || event.userType == null){
        emit(UpdateUserLocalInfoFailure(error: 'No hay tipo de usuario!'));
      }
      await userRepository.updateUserLocalInfo(event.name, event.userType);
      emit(UpdateUserLocalInfoSuccess());
    }catch(exception){
      emit(UpdateUserLocalInfoFailure(error: exception.toString()));
    }
  }
  
  _deleteUser(DeleteUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try{
      final users = await userRepository.deleteUser(event.userModel);
      final userNames = await userRepository.getUserNamesMap();
      return emit(DeleteUserSuccess());
    }catch(exception){
      emit(DeleteUserFailure(error: exception.toString()));
    }
  }

  /*_sortUsers(SortUserEvent event, Emitter<UsersState> emit) async {
    final users = await userRepository.sortUsers(event.sortOption);
    return emit(FetchUserSuccess(users: users));
  }*/

  _searchUsers(SearchUserEvent event, Emitter<UsersState> emit) async{
    final users = await userRepository.searchUser(event.keywords);
    if (state is UsersLoaded && (state as UsersLoaded).userNames.isNotEmpty){
      final currentNames = (state as UsersLoaded).userNames.isNotEmpty ? (state as UsersLoaded).userNames : await userRepository.getUserNamesMap();
      return emit(UsersLoaded(users: users, userNames: currentNames));
    }else{
      final userNames = await userRepository.getUserNamesMap();
      return emit(UsersLoaded(userNames: userNames, users: users));
    }
    return emit(FetchUserSuccess(users: users, isSearching: true));
  }
}