import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/model/task_model.dart';
import '../../data/respository/task_repository.dart';

part 'tasks_event.dart';

part 'tasks_state.dart';

//La clase encargada de manejar la logica de la aplicacion, el BLoC consta de eventos y estados,
//los eventos que anuncian los cambios realizados y los estados que manejan el estado de las ventanas de la app
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final TaskRepository taskRepository;

  TasksBloc(this.taskRepository) : super(FetchTasksSuccess(tasks: const [])) {
    //Se registran los controladores de eventos
    on<AddNewTaskEvent>(_addNewTask);
    on<FetchTaskEvent>(_fetchTasks);
    on<UpdateTaskEvent>(_updateTask);
    on<DeleteTaskEvent>(_deleteTask);
    on<SortTaskEvent>(_sortTasks);
    on<SearchTaskEvent>(_searchTasks);
  }

  //Este metodo maneja la creacion de las tareas, tiene como parametros un evento y un estado
  _addNewTask(AddNewTaskEvent event, Emitter<TasksState> emit) async {
    //Se emite un evento que indica que la carga a la BD se ha iniciado
    emit(TasksLoading());
    try {
      //Si el titulo esta vacio se emite un evento que indica error al crear la tarea
      if (event.taskModel.title.trim().isEmpty) {
        return emit(AddTaskFailure(error: 'Task title cannot be blank'));
      }//Si la descripcion esta vacia se emite un evento de error
      if (event.taskModel.description.trim().isEmpty) {
        return emit(AddTaskFailure(error: 'Task description cannot be blank'));
      }//Si la fecha de inicio esta vacia se emite un evento de error
      if (event.taskModel.start_date_time == null) {
        return emit(AddTaskFailure(error: 'Missing task start date'));
      }//Si la fecha de fin esta vaciase emite un evento de error
      if (event.taskModel.stop_date_time == null) {
        return emit(AddTaskFailure(error: 'Missing task stop date'));
      }//Se llama al metodo para crear las tareas de la clase taskRepository
      await taskRepository.createNewTask(event.taskModel);
      emit(AddTasksSuccess());//Se emite un evento de exito al crear la tarea
      final tasks = await taskRepository.getTasks();//Se crea una lista de tareas actualizada con la ultima tarea agregada
      return emit(FetchTasksSuccess(tasks: tasks));//Se devuelve un estado de exito junto con la nueva lista
    } catch (exception) {//Captura de excepcion
      emit(AddTaskFailure(error: exception.toString()));
    }
  }

  //Maneja la carga de las tareas desde la BD, emite un tres estados uno cuando se esta cargando, otro cuando las tareas
  //se han cargado con exito y otro cuando hay un error
  void _fetchTasks(FetchTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await taskRepository.getTasks();
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(LoadTaskFailure(error: exception.toString()));
    }
  }

  _updateTask(UpdateTaskEvent event, Emitter<TasksState> emit) async {
    try {
      if (event.taskModel.title.trim().isEmpty) {
        return emit(UpdateTaskFailure(error: 'Task title cannot be blank'));
      }
      if (event.taskModel.description.trim().isEmpty) {
        return emit(
            UpdateTaskFailure(error: 'Task description cannot be blank'));
      }
      if (event.taskModel.start_date_time == null) {
        return emit(UpdateTaskFailure(error: 'Missing task start date'));
      }
      if (event.taskModel.stop_date_time == null) {
        return emit(UpdateTaskFailure(error: 'Missing task stop date'));
      }
      emit(TasksLoading());
      final tasks = await taskRepository.updateTask(event.taskModel);
      emit(UpdateTaskSuccess());
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(UpdateTaskFailure(error: exception.toString()));
    }
  }

  _deleteTask(DeleteTaskEvent event, Emitter<TasksState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await taskRepository.deleteTask(event.taskModel);
      return emit(FetchTasksSuccess(tasks: tasks));
    } catch (exception) {
      emit(LoadTaskFailure(error: exception.toString()));
    }
  }

  _sortTasks(SortTaskEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.sortTasks(event.sortOption);
    return emit(FetchTasksSuccess(tasks: tasks));
  }

  _searchTasks(SearchTaskEvent event, Emitter<TasksState> emit) async {
    final tasks = await taskRepository.searchTasks(event.keywords);
    return emit(FetchTasksSuccess(tasks: tasks, isSearching: true));
  }
}