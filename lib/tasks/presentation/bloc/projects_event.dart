part of 'projects_bloc.dart';

@immutable
sealed class ProjectsEvent{}

class AddNewProjectEvent extends ProjectsEvent{
  final ProjectModel projectModel;
  AddNewProjectEvent({ required this.projectModel });
}

class FetchProjectEvent extends ProjectsEvent{}

class SortProjectEvent extends ProjectsEvent{
  final int sortOption;
  SortProjectEvent({  required this.sortOption});
}

class UpdateProjectEvent extends ProjectsEvent{
  final ProjectModel projectModel;
  UpdateProjectEvent({ required this.projectModel });
}

class DeleteProjectEvent extends ProjectsEvent{
  final ProjectModel projectModel;
  DeleteProjectEvent({ required this.projectModel });
}

class SearchProjectEvent extends ProjectsEvent{
  final String keyWords;
  SearchProjectEvent({ required this.keyWords });
}