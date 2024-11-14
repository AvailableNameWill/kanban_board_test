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
    on<UpdateUserEvent>(_updateUser);
    on<DeleteUserEvent>(_deleteUser);
    //on<SortUserEvent>(_sortUsers);
    on<SearchUserEvent>(_searchUsers);
    on<CompleteUserCreationEvent>(_completeUserCreation);
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
    try{
      final users = await userRepository.getUsers();
      return emit(FetchUserSuccess(users: users));
    }catch(exception){
      emit(LoadUserFailure(error: exception.toString()));
    }
  }
  
  _updateUser(UpdateUserEvent event, Emitter<UsersState> emit) async{
    try{
      if(event.userModel.name.trim().isEmpty){
        emit(UpdateUserFailure(error: 'El nombre no puede estar vacio'));
      }
      if(event.userModel.userType.trim().isEmpty || event.userModel.userType == null){
        emit(UpdateUserFailure(error: 'Debe seleccionar el tipo de usuario'));
      }
      emit(UsersLoading());
      final users = await userRepository.updateUser(event.userModel);
      emit(UpdateUserSuccess());
      return emit(FetchUserSuccess(users: users));
    }catch(exception){
      emit(UpdateUserFailure(error: exception.toString()));
    }
  }
  
  _deleteUser(DeleteUserEvent event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try{
      final users = await userRepository.deleteUser(event.userModel);
      return emit(FetchUserSuccess(users: users));
    }catch(exception){
      emit(LoadUserFailure(error: exception.toString()));
    }
  }

  /*_sortUsers(SortUserEvent event, Emitter<UsersState> emit) async {
    final users = await userRepository.sortUsers(event.sortOption);
    return emit(FetchUserSuccess(users: users));
  }*/

  _searchUsers(SearchUserEvent event, Emitter<UsersState> emit) async{
    final users = await userRepository.searchUser(event.keywords);
    return emit(FetchUserSuccess(users: users, isSearching: true));
  }
}