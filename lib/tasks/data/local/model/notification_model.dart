import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String id;
  String title;
  String content;
  String timeLapse;

  NotificationModel({ required this.id, required this.content, required this.timeLapse, required this.title });

  Map<String, dynamic> toJson(){
    return {
      'title': title,
      'content': content,
      'timeLapse': timeLapse,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json){
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timeLapse: json['timeLapse'] as String,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: doc['title'],
      content: doc['content'] ?? '',
      timeLapse: doc['timeLapse'] ?? '',
    );
  }

  @override
  String toString(){
    return 'NotificationModel{id: $id, title: $title, content: $content, timeLapse: $timeLapse';
  }
}