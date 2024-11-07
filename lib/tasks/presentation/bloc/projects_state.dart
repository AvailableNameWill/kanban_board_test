part of 'projects_bloc.dart';

@immutable
sealed class ProjectsState{}

final class FetchProjectSuccess extends ProjectsState{
  final List<ProjectModel> projects;
  final bool isSearching;
  FetchProjectSuccess({ required this.projects, this.isSearching = false });
}

final class AddProjectSuccess extends ProjectsState{}

final class LoadProjectFailure extends ProjectsState{
  final String error;
  LoadProjectFailure({ required this.error });
}

final class AddProjectFailure extends ProjectsState{
  final String error;
  AddProjectFailure({ required this.error });
}

final class ProjectLoading extends ProjectsState{}

final class UpdateProjectFailure extends ProjectsState{
  final String error;
  UpdateProjectFailure({ required this.error });
}

final class UpdateProjectSuccess extends ProjectsState{}