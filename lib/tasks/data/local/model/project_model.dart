import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel{
  String id; //Id del proyecto
  String title; //Titulo del proyecto
  String description;//Descripcion del proyecto
  DateTime? start_date_time;//Fecha de inico del proyecto
  DateTime? stop_date_time;//Fecha del fin del proyecto
  String color;
  bool completed;//Variable para indicar si la tarea se ha o no se ha completado

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.start_date_time,
    required this.stop_date_time,
    required this.color,
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
      'color': color,
    };
  }


  //Metodo para crear una lista de tipo ProjectModel en formato Json, este se usa para recibir datos
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
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
      color: json['color'] as String
    );
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        completed: data['completed'] ?? false,
        start_date_time: data['start_date_time'] != null
            ? DateTime.parse(data['start_date_time'])
            : null,
        stop_date_time: data['stop_date_time'] != null
            ? DateTime.parse(data['stop_date_time'])
            : null,
        color: doc['color'] as String
    );
  }

  @override
  String toString() {
    return 'TaskModel{id: $id, title: $title, description: $description, '
        'start_date_time: $start_date_time, stop_date_time: $stop_date_time, '
        'color: $color, completed: $completed}';
  }
}

/*
*
Recuperar color de Firebase
* String hexColor = firestoreDocument['color']; // Supón que esto es '#FF5733FF'.

// Quitar el símbolo '#' si está presente
if (hexColor.startsWith('#')) {
  hexColor = hexColor.substring(1);
}

// Convertir el valor hexadecimal a un objeto Color
Color color = Color(int.parse(hexColor, radix: 16));

*
* */