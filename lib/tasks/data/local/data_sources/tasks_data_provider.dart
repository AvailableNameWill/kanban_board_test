import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

import '../../../../utils/constants.dart';

//Clase encargada de manejar el CRUD de tareas, aqui se realizan todos los query a la BD
class TaskDataProvider {
  //List<TaskModel> tasks = [];
  //Instancia de firestore, la BD del proyecto
  final FirebaseFirestore firestore;
  //SharedPreferences? prefs;

  //Constructor de la clase, recibe como parametro la instancia de CloudFireStore
  TaskDataProvider(this.firestore);
  //TaskDataProvider(this.prefs, this.firestore);

  //Metodo para cargar todas las tareas
  Future<List<TaskModel>> getTasks() async {
    //Lista de tipo TaskModel
    List<TaskModel> tasks = [];
    try {
      //final List<String>? savedTasks = prefs!.getStringList(Constants.taskKey);
      //Se hace una consulta a la BD
      final querySnapshots = await firestore.collection('tasks').get();
      //Se llena la lista con objetos TaskModel de la BD
      for (var doc in querySnapshots.docs){
        tasks.add(TaskModel(
          id: doc.id,
          title: doc['title'],
          description: doc['description'],
          start_date_time: (doc['start_date_time'] as Timestamp).toDate(),
          stop_date_time: (doc['stop_date_time'] as Timestamp).toDate(),
          completed: doc['completed']
        ));
      }
      /*final tasks = querySnapshots.docs.map((doc){
        return TaskModel.fromJson(doc.data());
      }).toList();*/
      if (tasks != null) {
        /*tasks = savedTasks
            .map((taskJson) => TaskModel.fromJson(json.decode(taskJson)))
            .toList();*/
        //Se ordena la lista, las tareas aun no completadas se colocan al inicio de la lista
        tasks.sort((a, b) {
          if (a.completed == b.completed) {
            return 0;
          } else if (a.completed) {
            return 1;
          } else {
            return -1;
          }
        });
      }
      return tasks;
    }catch(e){
      print( ' get ' + e.toString());
      throw Exception(handleException(e));
    }
  }

  //Metodo para ordenar la lista
  Future<List<TaskModel>> sortTasks(int sortOption) async {
    try{
      //Se capturan todas las tareas
      List<TaskModel> tasks = await getTasks();
      switch (sortOption) {
        case 0:
          tasks.sort((a, b) {
            // Sort by date, si la fecha de inicio de 'a' es despues de b entonces se coloca a 'a' despues de b
            if (a.start_date_time!.isAfter(b.start_date_time!)) {
              return 1;
            } else if (a.start_date_time!.isBefore(b.start_date_time!)) {//caso contrario a va antes que b
              return -1;
            }
            return 0;
          });
          break;
        case 1:
        //sort by completed tasks,
          tasks.sort((a, b) {
            //Si la tarea 'b' esta completada esta va antes que a
            if (!a.completed && b.completed) {
              return 1;
            } else if (a.completed && !b.completed) {
              return -1;
            }
            return 0;
          });
          break;
        case 2:
        //sort by pending tasks
          tasks.sort((a, b) {
            if (a.completed == b.completed) {
              return 0;
            } else if (a.completed) {
              return 1;
            } else {
              return -1;
            }
          });
          break;
      }
      return tasks;
    }catch(e){
      print(' sort ' + e.toString());
      throw Exception(handleException(e));
    }
  }

  //Metodo para crear una tarea
  Future<void> createTask(TaskModel taskModel) async {
    try {
      /*tasks.add(taskModel);
      final List<String> taskJsonList =
      tasks.map((task) => json.encode(task.toJson())).toList();
      await prefs!.setStringList(Constants.taskKey, taskJsonList);*/
      await firestore.collection('tasks').add(taskModel.toJson());
    } catch (exception) {
      print(exception.toString());
      throw Exception(handleException(exception));
    }
  }

  //Metodo para actualizar una tarea
  Future<List<TaskModel>> updateTask(TaskModel taskModel) async {
    try {
      /*tasks[tasks.indexWhere((element) => element.id == taskModel.id)] =
          taskModel;
      tasks.sort((a, b) {
        if (a.completed == b.completed) {
          return 0;
        } else if (a.completed) {
          return 1;
        } else {
          return -1;
        }
      });
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);*/
      await firestore.collection('tasks').doc(taskModel.id).update(taskModel.toJson());
      return await getTasks();
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  //Metodo para eliminar una tarea
  Future<List<TaskModel>> deleteTask(TaskModel taskModel) async {
    try {
      /*tasks.remove(taskModel);
      final List<String> taskJsonList = tasks.map((task) =>
          json.encode(task.toJson())).toList();
      prefs!.setStringList(Constants.taskKey, taskJsonList);*/
      await firestore.collection('tasks').doc(taskModel.id).delete();
      return await getTasks();
    } catch (exception) {
      throw Exception(handleException(exception));
    }
  }

  //Metodo para buscar tareas o filtrarlas
  Future<List<TaskModel>> searchTasks(String keywords) async {
    //Se carga la lista
    final List<TaskModel> tasks = await getTasks();
    //se convierten los caracteres del parametro keywords a minusculas
    final searchText = keywords.toLowerCase();
    //Se devuelven las tareas donde el titulo o descripcion de la tarea que tenga coincidencias con el parametro
    return tasks.where((task){
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
    /*return matchedTasked.where((task) {
      final titleMatches = task.title.toLowerCase().contains(searchText);
      final descriptionMatches = task.description.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();*/
  }
}