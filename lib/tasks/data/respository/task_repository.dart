import 'package:kanban_board_test/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';

//Esta clase se encarga de llamar todos los metodos de tasks_data_provider (la clase que se encarga del CRUD)
//en el main, recibe un objeto de tipo TasksDataProvider como parametro, esta clase a su vez se usa como parametro
//del widget RepositoryProvider
class TaskRepository{
  final TaskDataProvider taskDataProvider;

  TaskRepository({required this.taskDataProvider});

  Future<List<TaskModel>> getTasks() async {
    return await taskDataProvider.getTasks();
  }

  Future<void> createNewTask(TaskModel taskModel) async {
    return await taskDataProvider.createTask(taskModel);
  }

  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    return await taskDataProvider.updateTask(taskModel);
  }

  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    return await taskDataProvider.deleteTask(taskModel);
  }

  Future<List<TaskModel>> sortTasks(int sortOption) async {
    return await taskDataProvider.sortTasks(sortOption);
  }

  Future<List<TaskModel>> searchTasks(String search) async {
    return await taskDataProvider.searchTasks(search);
  }

}