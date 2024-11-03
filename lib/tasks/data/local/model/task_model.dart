import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  String id;
  String title;
  String description;
  //String? project_id;
  //String? user_id;
  DateTime? start_date_time;
  DateTime? stop_date_time;
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'start_date_time': start_date_time != null ? Timestamp.fromDate(start_date_time!) : null,
      'stop_date_time': stop_date_time != null ? Timestamp.fromDate(stop_date_time!) : null,
    };
  }


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
