import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/data/respository/project_repository.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';

part 'projects_event.dart';

part 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState>{
  final ProjectRepository projectRepository;

  ProjectsBloc(this.projectRepository) : super(FetchProjectSuccess(projects: const[])){
    on<AddNewProjectEvent>(_addNewProject);
    on<FetchProjectEvent>(_fetchProjects);
    on<UpdateProjectEvent>(_updateProjects);
    on<DeleteProjectEvent>(_deleteProject);
    on<SortProjectEvent>(_sortProjects);
    on<SearchProjectEvent>(_searchProjects);
  }

  _addNewProject(AddNewProjectEvent event, Emitter<ProjectsState> emit) async{
    emit(ProjectLoading());
    try{
      if(event.projectModel.title!.trim().isEmpty){
        return emit(AddProjectFailure(error: 'El titulo no puede estar vacio'));
      }
      if(event.projectModel.description!.trim().isEmpty){
        return emit(AddProjectFailure(error: 'La descripcion no puede estar vacia'));
      }
      if(event.projectModel.start_date_time == null){
        return emit(AddProjectFailure(error: 'No se ha agregado una fecha de inicio'));
      }
      if(event.projectModel.stop_date_time == null){
        return emit(AddProjectFailure(error: 'No se ha agregado una fecha de fin'));
      }
      if(event.projectModel.color == '#FFFFFFFF'){
        return emit(AddProjectFailure(error: 'Elija un color para el proyecto'));
      }
      await projectRepository.createNewProject(event.projectModel);
      emit(AddProjectSuccess());
      final projects = await projectRepository.getProjects();
      return emit(FetchProjectSuccess(projects: projects));
    }catch(exception){
      emit(AddProjectFailure(error: exception.toString()));
    }
  }

  void _fetchProjects(FetchProjectEvent event, Emitter<ProjectsState> emit) async{
    emit(ProjectLoading());
    try{
      final projects = await projectRepository.getProjects();
      return emit(FetchProjectSuccess(projects: projects));
    }catch(exception){
      emit(LoadProjectFailure(error: exception.toString()));
      print(exception.toString());
    }
  }

  _updateProjects(UpdateProjectEvent event, Emitter<ProjectsState> emit) async{
    try{
      if(event.projectModel.title!.trim().isEmpty){
        return emit(UpdateProjectFailure(error: 'El titulo no puede estar vacio'));
      }
      if(event.projectModel.description!.trim().isEmpty){
        return emit(UpdateProjectFailure(error: 'La descripcion no puede estar vacia'));
      }
      if(event.projectModel.start_date_time == null){
        return emit(UpdateProjectFailure(error: 'No se ha agregado una fecha de inicio'));
      }
      if(event.projectModel.stop_date_time == null){
        return emit(UpdateProjectFailure(error: 'No se ha agregado una fecha de fin'));
      }
      emit(ProjectLoading());
      final projects = await projectRepository.updateProject(event.projectModel);
      emit(UpdateProjectSuccess());
      return emit(FetchProjectSuccess(projects: projects));
    }catch(exception){
      emit(UpdateProjectFailure(error: exception.toString()));
    }
  }

  _deleteProject(DeleteProjectEvent event, Emitter<ProjectsState> emit) async{
    emit(ProjectLoading());
    try{
      final projects = await projectRepository.deleteProject(event.projectModel);
      return emit(FetchProjectSuccess(projects: projects));
    }catch(exception){
      emit(LoadProjectFailure(error: exception.toString()));
    }
  }

  _sortProjects(SortProjectEvent event, Emitter<ProjectsState> emit) async{
    final projects = await projectRepository.sortProjects(event.sortOption);
    return emit(FetchProjectSuccess(projects: projects));
  }

  _searchProjects(SearchProjectEvent event, Emitter<ProjectsState> emit) async{
    final projects = await projectRepository.searchProject(event.keyWords);
    return emit(FetchProjectSuccess(projects: projects, isSearching: true));
  }
}