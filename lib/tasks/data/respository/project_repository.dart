import 'package:kanban_board_test/tasks/data/local/data_sources/projects_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';

class ProjectRepository{
  final ProjectsDataProvider projectsDataProvider;

  ProjectRepository({ required this.projectsDataProvider });

  Future<List<ProjectModel>> getProjects() async{
    return await projectsDataProvider.getProjects();
  }

  Future<void> createNewProject(ProjectModel projectModel) async{
    return await projectsDataProvider.createProject(projectModel);
  }

  Future<List<ProjectModel>> updateProject(ProjectModel projectModel) async{
    return await projectsDataProvider.updateProject(projectModel);
  }

  Future<List<ProjectModel>> deleteProject(ProjectModel projectModel) async{
    return await projectsDataProvider.deleteProject(projectModel);
  }

  Future<List<ProjectModel>> sortProjects(int sortOption) async{
    return await projectsDataProvider.sortProjects(sortOption);
  }

  Future<List<ProjectModel>> searchProject(String search) async{
    return await projectsDataProvider.searchProjects(search);
  }
}