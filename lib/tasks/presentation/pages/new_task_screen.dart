import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/projects_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../../data/local/model/project_model.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';
import '../bloc/users_bloc.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

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

  final List<String> projectOptions = ["ProjectA", "ProjectB", "ProjectC"];
  final List<String> userOptions = ["User1", "User2", "User3"];

  @override
  void initState() {
    _selectedDay = _focusedDay;
    context.read<UsersBloc>().add(FetchUserEvent());
    _projectEnd = null;
    _projectStart = null;
    super.initState();
  }

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
      setState(() {
        _selectedDay = null;
        _focusedDay = focusDay;

        if(start != null){
          _rangeStart = DateTime(start.year, start.month, start.day, 12, 0, 0);
        }else{
          _rangeStart = null;
        }

        if(end != null){
          _rangeEnd = DateTime(end.year, end.month, end.day, 12, 0, 0);
        }else{
          _rangeEnd = null;
        }
      });
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
            backgroundColor: kWhiteColor,
            appBar: const CustomAppBar(
              title: 'Create New Task',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<TasksBloc, TasksState>(
                        listener: (context, state) {
                          if (state is AddTaskFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(state.error, kRed));
                          }
                          if (state is AddTasksSuccess) {
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
                            onRangeSelected: _onRangeSelected,
                            enabledDayPredicate: (day){
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

                                return DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text(selectedProject ?? "Seleccione un proyecto",
                                      style: const TextStyle(fontSize: 16, color: kBlackColor),),
                                    items: projects.map((project) {
                                      return DropdownMenuItem<String>(
                                          value: project.id,
                                          child: Text(
                                            project.title != null
                                            ? project.title!
                                            : 'Error al cargar el titulo',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                      );
                                    }).toList(),
                                    value: selectedProject!.isNotEmpty ? selectedProject : null,
                                    onChanged: (value){
                                      setState(() {
                                        selectedProject = value;
                                        print(selectedProject);
                                        final _selectedProject = projects.firstWhere((project) => project.id == value);
                                        proyectColor = _selectedProject.color;
                                        _projectStart = _selectedProject.start_date_time;
                                        _projectEnd = _selectedProject.stop_date_time;
                                        _projectModel = _selectedProject;
                                        validateTaskDateWithProject(context, _selectedProject);
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
                              'Select User',
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
                              if(userState is UsersLoaded && userState.users != null){
                                final users = userState.users;
                                print("Usuarios cargados: ${users!.map((user) => user.name).toList()}");
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text(selectedUser ?? "Seleccione un usuario",
                                      style: const TextStyle(fontSize: 16, color: kBlackColor),),
                                    items: users.map((user) {
                                      return DropdownMenuItem<String>(
                                        value: user.id,
                                        child: Text(
                                          user.name,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                    value: users.any((user) => user.id == selectedUser) ? selectedUser : null,
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
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                      backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          kWhiteColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Cancel',
                                          kBlackColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
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
                                      if (selectedProject != null){
                                        print('selected project no es null');
                                        bool datePassed = validateTaskDateWithProject(context, _projectModel);
                                        if (datePassed) return;
                                      }else{
                                        print('nada new ts');
                                      }

                                      final String taskId = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      var taskModel = TaskModel(
                                          id: taskId,
                                          title: title.text,
                                          description: description.text,
                                          project_id: selectedProject,
                                          user_id: selectedUser,
                                          start_date_time: _rangeStart,
                                          stop_date_time: _rangeEnd,
                                          sugerencias: '',
                                          color: proyectColor);
                                      context.read<TasksBloc>().add(
                                          AddNewTaskEvent(
                                              taskModel: taskModel));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: buildText(
                                          'Save',
                                          kWhiteColor,
                                          textMedium,
                                          FontWeight.w600,
                                          TextAlign.center,
                                          TextOverflow.clip),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      );
                    }))
            )
        )
    );
  }
}