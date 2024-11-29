import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/utils/exception_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/util.dart';
import '../../data/local/model/shared_preferences_service.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';
import '../bloc/users_bloc.dart';

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel taskModel;
  final String userType;

  const UpdateTaskScreen({super.key, required this.taskModel, required this.userType});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController project  = TextEditingController();
  TextEditingController user = TextEditingController();
  bool _goBack = false;
  SharedPreferencesService spService = SharedPreferencesService();
  SecureStorageService ssService = SecureStorageService();
  String? userName = '';
  String userId = '';

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  String? selectedProject = '';
  String? selectedUser = '';
  String? proyectColor = '#FFFFFFFF';
  DateTime? _projectEnd;
  DateTime? _projectStart;
  ProjectModel _projectModel = ProjectModel(id: null, title: null, description: null, start_date_time: null, stop_date_time: null, color: null);

  void _loadUserName() async {
    final name = await spService.getUserName();
    final type = await spService.getUserType();
    final id = await ssService.getUid();

    setState(() {
      userName = name;
      userId = id;
    });
  }

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;

      if (start != null){
        _rangeStart = DateTime(start.year, start.month, start.day, 12, 0, 0);
      }else{
        _rangeStart = null;
      }

      if (end != null){
        _rangeEnd = DateTime(end.year, end.month, end.day, 12, 0, 0);
      }else{
        _rangeEnd = null;
      }
    });
  }

  Future<bool?> _showBackDialog() async {
      return showDialog<bool>(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Esta seguro que desea salir?'),
            content: const Text('Los cambios realizados no se guardaran'),
            actions: <Widget>[
              TextButton(
                  onPressed: (){
                    context.read<TasksBloc>().add(UpdateWindowOpenedEvent());
                    Navigator.pop(context, false);
                  },
                  child: const Text('No, seguir editando')
              ),
              TextButton(
                  onPressed: (){
                    context.read<TasksBloc>().add(UpdateWindowOpenedEvent());
                    Navigator.pop(context, true);
                  },
                  child: const Text('Si, salir')
              ),
            ],
          );
        }
    );
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    title.text = widget.taskModel.title;
    description.text = widget.taskModel.description;
    _selectedDay = _focusedDay;
    selectedProject = widget.taskModel.project_id;
    selectedUser = selectedUser = widget.taskModel.user_id != null && widget.taskModel.user_id!.isNotEmpty ? widget.taskModel.user_id : null;
    _rangeStart = widget.taskModel.start_date_time;
    _rangeEnd = widget.taskModel.stop_date_time;
    proyectColor = widget.taskModel.color;
    _projectEnd = null;
    _projectStart = null;
    context.read<UsersBloc>().add(FetchUserEvent());
    _loadUserName();
    //context.read<TasksBloc>().add(UpdateWindowOpenedEvent());
    super.initState();
  }

  bool validateTaskDateWithProject(BuildContext context, ProjectModel model){
    bool datePassed = false;
    _projectEnd = model.stop_date_time;
    _projectStart = model.start_date_time;

    if ( (_projectEnd != null && _projectStart != null) && (_rangeStart != null && _rangeStart!.isAfter(_projectEnd!))){
      _rangeStart = _projectStart;
      _rangeEnd = _projectEnd;
      print('Fecha inicial de la tarea supera a la fecha final del proyecto');
      datePassed = true;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La fecha de inicio de la tarea es posterior a la fecha final del proyecto.'),
        backgroundColor: kRed,
      ));
      return datePassed;
    }

    if( _projectEnd != null && (_rangeEnd != null && _rangeEnd!.isAfter(_projectEnd!))){
      _rangeEnd = _projectEnd;
      datePassed = true;
      print('Fecha final de la tarea supera a la fecha final del proyecto');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La fecha final de la tarea es posterior a la fecha final del proyecto.'),
        backgroundColor: kRed,
      ));
      return datePassed;
    }
    return datePassed;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async{
        if(didPop){
          return;
        }
        final bool shouldPop = await _showBackDialog() ?? false;
        if(context.mounted && shouldPop){
          Navigator.pop(context);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
              backgroundColor: kWhiteColor,
              appBar: const CustomAppBar(
                showBackArrow: false,
                title: 'Update Task',
              ),
              body: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: BlocConsumer<TasksBloc, TasksState>(
                          listener: (context, state) {
                            if (state is UpdateTaskFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  getSnackBar(state.error, kRed));
                            }
                            if (state is UpdateTaskSuccess) {
                              Navigator.pop(context);
                            }
                          }, builder: (context, state) {
                        return ListView(
                          children: [
                            TableCalendar(
                              calendarFormat: _calendarFormat,
                              startingDayOfWeek: StartingDayOfWeek.monday,
                              availableCalendarFormats: const {
                                CalendarFormat.month: 'Month',
                                CalendarFormat.week: 'Week',
                              },
                              rangeSelectionMode: RangeSelectionMode.toggledOn,
                              focusedDay: _focusedDay,
                              firstDay: DateTime.utc(2023, 1, 1),
                              lastDay: DateTime.utc(2030, 1, 1),
                              onPageChanged: (focusDay) {
                                _focusedDay = focusDay;
                              },
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              rangeStartDay: _rangeStart,
                              rangeEndDay: _rangeEnd,
                              onFormatChanged: (format) {
                                if (_calendarFormat != format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                }
                              },
                              onRangeSelected: (start, end, focusDay){
                                if (widget.userType != 'Administrador'){
                                  return;
                                }
                                _onRangeSelected(start, end, focusDay);
                              },
                              enabledDayPredicate: (day){

                                if (widget.userType != 'Administrador'){
                                  return false;
                                }

                                final today = DateTime.now();
                                final todayNormalized = DateTime(today.year, today.month, today.day);
                                final dayNormalized = DateTime(day.year, day.month, day.day);
                                return dayNormalized.isAtSameMomentAs(todayNormalized) || dayNormalized.isAfter(todayNormalized);
                              },
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(.1),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                              child: buildText(
                                  _rangeStart != null && _rangeEnd != null
                                      ? 'Task starting at ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                                      : 'Select a date range',
                                  kPrimaryColor,
                                  textSmall,
                                  FontWeight.w400,
                                  TextAlign.start,
                                  TextOverflow.clip),
                            ),
                            const SizedBox(height: 5),
                            buildText(
                                'Title',
                                kBlackColor,
                                textMedium,
                                FontWeight.bold,
                                TextAlign.start,
                                TextOverflow.clip),
                            const SizedBox(
                              height: 5,
                            ),
                            BuildTextField(
                                hint: "Task Title",
                                controller: title,
                                inputType: TextInputType.text,
                                fillColor: kWhiteColor,
                                onChange: (value) {}),
                            const SizedBox(
                              height: 5,
                            ),
                            buildText(
                                'Select project',
                                kBlackColor,
                                textMedium,
                                FontWeight.bold,
                                TextAlign.start,
                                TextOverflow.clip),
                            const SizedBox(
                              height: 5,
                            ),
                            BlocBuilder<ProjectsBloc, ProjectsState>(
                              builder: (context, projectState){
                                if(projectState is FetchProjectSuccess){
                                  final projects = projectState.projects;
                                  print('selected project: ' + selectedProject!);
                                  if(selectedProject != null && selectedProject!.isNotEmpty){
                                    print('selected project2: ' + selectedProject!);
                                    try{
                                      _projectModel = projects.firstWhere((project) => project.id == selectedProject);
                                    }catch(error){
                                      print('No hay proyectos');
                                    }
                                  }
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Text(selectedProject ?? "Seleccione un proyecto",
                                        style: const TextStyle(fontSize: 16, color: kBlackColor),),
                                      items: projects.map((project) {
                                        return DropdownMenuItem<String>(
                                          value: project.id,
                                          child: Text(
                                            project.title ?? 'Titulo',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        );
                                      }).toList(),
                                      value: (selectedProject != null && selectedProject!.isNotEmpty && projects.any((project) => project.id == selectedProject))
                                        ? selectedProject
                                        : null,
                                      onChanged: (widget.userType == 'Administrador')
                                          ? (value){
                                        setState(() {
                                          selectedProject = value;
                                          final _selectedProject = projects.firstWhere((project) => project.id == value);
                                          proyectColor = _selectedProject.color;
                                          _projectStart = _selectedProject.start_date_time;
                                          _projectEnd = _selectedProject.stop_date_time;
                                          validateTaskDateWithProject(context, _selectedProject);
                                        });
                                      }
                                      : null,
                                      buttonStyleData: ButtonStyleData(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: widget.userType == 'Administrador' ? kGrey1 : kRed),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight: 200,
                                        elevation: 8,
                                        decoration: BoxDecoration(
                                          color: kWhiteColor,
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      iconStyleData: const IconStyleData(
                                        icon: Icon(Icons.arrow_drop_down),
                                        iconSize: 24,
                                        iconEnabledColor: kBlackColor,
                                      ),
                                    ),
                                  );
                                } else if (projectState is ProjectLoading){
                                  return CircularProgressIndicator();
                                }else{
                                  return Text('Error al cargar los proyectos');
                                }
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            buildText(
                                widget.userType == 'Administrador' ? 'Seleccione un usuario' : 'Seleccionar tarea',
                                kBlackColor,
                                textMedium,
                                FontWeight.bold,
                                TextAlign.start,
                                TextOverflow.clip),
                            const SizedBox(
                              height: 5,
                            ),
                            BlocBuilder<UsersBloc, UsersState>(
                              builder: (context, userState){
                                if(userState is FetchUserSuccess){
                                  print('users fetched');
                                  try{
                                    final users = userState.users;
                                    print('username: ' + userName!);
                                    final filteredUsers = (widget.userType == 'Empleado' && (selectedUser == null || selectedUser!.isEmpty || selectedUser == userId))
                                      ? users.where((user) => user.name == userName).toList()
                                      : users;

                                    final dropDownItems = [
                                      const DropdownMenuItem<String>(
                                        value: "",
                                        child: Text(
                                          'Ninguno',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      ...filteredUsers.map((user){
                                        return DropdownMenuItem<String>(
                                          value: user.id,
                                          child: Text(
                                            user.name,
                                            style: const TextStyle(fontSize: 16),
                                          )
                                        );
                                      }).toList(),
                                    ];

                                    /*if (widget.userType == 'Empleado'){
                                      dropDownItems.insert(
                                        0,
                                        const DropdownMenuItem<String>(
                                          value: "",
                                          child: Text(
                                            'Ninguno',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        )
                                      );
                                    }*/
                                    print("Usuarios cargados: ${users.map((user) => user.name).toList()}");
                                    return DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                        isExpanded: true,
                                        hint: Text(selectedUser ?? "Seleccione un usuario",
                                          style: const TextStyle(fontSize: 16, color: kBlackColor),),
                                        items: dropDownItems,
                                        value: filteredUsers.any((user) => user.id == selectedUser) ? selectedUser : null,
                                        onChanged: (value){
                                          setState(() {
                                            selectedUser = value;
                                          });
                                        },
                                        buttonStyleData: ButtonStyleData(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: kGrey1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 200,
                                          elevation: 8,
                                          decoration: BoxDecoration(
                                            color: kWhiteColor,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        iconStyleData: const IconStyleData(
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 24,
                                          iconEnabledColor: kBlackColor,
                                        ),
                                      ),
                                    );
                                  }catch(error){
                                    print('error: ' + error.toString());
                                    throw Exception(handleException(error.toString()));
                                  }
                                } else if (userState is UsersLoading){
                                  print('cargando usuarios');
                                  return CircularProgressIndicator();
                                }else if(userState is LoadUserFailure){
                                  print('Error al cargar los usuarios');
                                  return Text('Error al cargar los usuarios');
                                }else{
                                  print('error inesperado');
                                  return Text('Error inesperado');
                                }
                              },
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            buildText(
                                'Description',
                                kBlackColor,
                                textMedium,
                                FontWeight.bold,
                                TextAlign.start,
                                TextOverflow.clip),
                            const SizedBox(
                              height: 5,
                            ),
                            BuildTextField(
                                hint: "Task Description",
                                controller: description,
                                inputType: TextInputType.multiline,
                                fillColor: kWhiteColor,
                                onChange: (value) {}),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: size.width,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        kPrimaryColor),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Adjust the radius as needed
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    //print('selecteduser' + selectedUser!);
                                    if (selectedProject != null){
                                      bool datePassed = validateTaskDateWithProject(context, _projectModel);
                                      if(datePassed) return;
                                    }
                                    var taskModel = TaskModel(
                                        id: widget.taskModel.id,
                                        title: title.text,
                                        description: description.text,
                                        completed: widget.taskModel.completed,
                                        project_id: selectedProject,
                                        user_id: selectedUser,
                                        start_date_time: _rangeStart,
                                        stop_date_time: _rangeEnd,
                                        color: proyectColor,
                                    );
                                    context.read<TasksBloc>().add(
                                        UpdateTaskEvent(taskModel: taskModel));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: buildText(
                                        'Update',
                                        kWhiteColor,
                                        textMedium,
                                        FontWeight.w600,
                                        TextAlign.center,
                                        TextOverflow.clip),
                                  )),
                            ),
                          ],
                        );
                      }))))),
    );
  }
}

/*
*
Agregar un boton para que los empleados puedan dar sugerencias de cambio para la tarea, el boton abrira un modal o dialogo
* en el que habra un TextField en el que el empleado podra escribir la sugerencia o queja
Bloquear la seleccion de fechas en el calendario para actualizar tareas y proyectos (solo empleados)
*
El FAB no debe de ser visible para el usuario ('empleado')
*
El usuario no puede modificar el nombre o la descripcion de la tarea
* */