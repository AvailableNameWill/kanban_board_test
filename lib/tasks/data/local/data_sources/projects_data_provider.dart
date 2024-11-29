import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';

class ProjectsDataProvider{
  final FirebaseFirestore firestore;
  //ProjectsDataProvider();
  ProjectsDataProvider( this.firestore );

  Future<List<ProjectModel>> getProjects() async{
    List<ProjectModel> projects = [];
    try{
      final querySnapshot = await firestore.collection('projects').get();
      for(var doc in querySnapshot.docs){
        String hexColor = doc['color'];
        if(hexColor.startsWith('#')){
          hexColor = hexColor.substring(1);
        }
       projects.add(ProjectModel(
         id: doc.id,
         title: doc['title'],
         description: doc['description'],
         start_date_time: (doc['start_date_time'] as Timestamp).toDate(),
         stop_date_time: (doc['stop_date_time'] as Timestamp).toDate(),
         completed: doc['completed'],
         color: hexColor,
       ));
      }
      if(projects != null){
        projects.sort((a,b){
          if(a.completed == b.completed){
            return 0;
          }else if (a.completed){
            return 1;
          }else{
            return -1;
          }
        });
      }
      return projects;
    }catch(exception){
      print('Error en la carga: ' + exception.toString());
      throw Exception(handleException(exception));
    }
  }

  Future<List<ProjectModel>> sortProjects(int sortOption) async{
    try{
      List<ProjectModel> projects = await getProjects();
      switch(sortOption){
        case 0:
          projects.sort((a,b){
            if(a.start_date_time!.isAfter(b.start_date_time!)){
              return 1;
            }else if(a.start_date_time!.isBefore(b.start_date_time!)){
              return -1;
            }
            return 0;
          });
          break;
        case 1:
          projects.sort((a,b){
            if(!a.completed && b.completed){
              return 1;
            }else if(a.completed && !b.completed){
              return -1;
            }
            return 0;
          });
          break;
        case 2:
          projects.sort((a,b){
            if(a.completed == b.completed){
              return 0;
            }else if(a.completed){
              return 1;
            }else{
              return -1;
            }
          });
          break;
      }
      return projects;
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<void> createProject(ProjectModel projectModel) async {
    try{
      await firestore.collection('projects').add(projectModel.toJson());
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<List<ProjectModel>> updateProject(ProjectModel projectModel) async{
    try{
      await firestore.collection('projects').doc(projectModel.id).update(projectModel.toJson());
      return await getProjects();
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<List<ProjectModel>> deleteProject(ProjectModel projectModel) async{
    try{
      await firestore.collection('projects').doc(projectModel.id).delete();
      return await getProjects();
    }catch(exception){
      throw Exception(handleException(exception));
    }
  }

  Future<List<ProjectModel>> searchProjects(String keywords) async{
    final List<ProjectModel> projects = await getProjects();
    final searchText = keywords.toLowerCase();
    return projects.where((project){
      final titleMatches = project.title!.toLowerCase().contains(searchText);
      final descriptionMatches = project.description!.toLowerCase().contains(searchText);
      return titleMatches || descriptionMatches;
    }).toList();
  }
}

/*
*
// Convertir el valor hexadecimal a un objeto Color
Color color = Color(int.parse(hexColor, radix: 16));
*
* */