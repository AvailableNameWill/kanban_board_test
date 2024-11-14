//id,nombre
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel{
  String id;
  String name;
  String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.userType
  });

  Map<String, dynamic> toJson(){
    return {
      'name' : name,
      'userType' : userType
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        userType:  json['userType'] as String
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
        id: doc.id,
        name: data['name'] ?? '',
        userType: data['userType'] ?? '',
    );
  }
}