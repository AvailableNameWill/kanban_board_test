import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id; //ID de la tarea
  String title; // Titulo de la tarea
  String description; //Descripcion de la tarea
  //String? project_id; //ID del proyecto al que esta ligada la tarea
  //String? user_id; //ID del usuario que esta ligado a la tarea
  DateTime? start_date_time; //Fecha de inicio de la tarea
  DateTime? stop_date_time; //Fecha de fin de la tarea
  bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.start_date_time,
    required this.stop_date_time,
    //this.project_id,
    //this.user_id,
    this.completed = false,
  });

  //Metodo para crear una lista de tipo ProjectModel en formato Json, este se usa para enviar datos
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'start_date_time': start_date_time != null ? Timestamp.fromDate(start_date_time!) : null,
      'stop_date_time': stop_date_time != null ? Timestamp.fromDate(stop_date_time!) : null,
    };
  }

  //Metodo para crear una lista de tipo ProjectModel en formato Json, este se usa para recibir datos
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completed: json['completed'] as bool,
      start_date_time: json['start_date_time'] != null
        ? DateTime.parse(json['start_date_time'])
        : null,
      stop_date_time: json['stop_date_time'] != null
        ? DateTime.parse(json['stop_date_time'])
        : null,
    );
  }

  //Metodo para recibir los datos desde FireStore
  factory TaskModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      completed: data['completed'] ?? false,
      start_date_time: data['start_date_time'] != null
        ? DateTime.parse(data['start_date_time'])
        : null,
      stop_date_time: data['stop_date_time'] != null
        ? DateTime.parse(data['stop_date_time'])
        : null
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, description: $description, '
        'startDateTime: $start_date_time, stopDateTime: $stop_date_time, '
        'completed: $completed}';
  }
}
