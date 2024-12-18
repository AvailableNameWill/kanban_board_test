import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/util.dart';
import '../bloc/projects_bloc.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class UpdateProjectScreen extends StatefulWidget {
  final ProjectModel projectModel;

  const UpdateProjectScreen({super.key, required this.projectModel});

  @override
  State<UpdateProjectScreen> createState() => _UpdateProjectScreenState();
}

class _UpdateProjectScreenState extends State<UpdateProjectScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  Color _selectedColor = Colors.white;

  _onRangeSelected(DateTime? start, DateTime? end, DateTime focusDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusDay;

      if (start != null){
        _rangeStart = DateTime(start.year, start.month, start.day, 12, 0, 0);
      }else{
        _rangeStart = null;
      }

      if (end !=null){
        _rangeEnd = DateTime(end.year, end.month, end.day, 12, 0, 0);
      }else{
        _rangeEnd = null;
      }
    });
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    title.text = widget.projectModel.title != null ? widget.projectModel.title! : 'Titulo';
    description.text = widget.projectModel.description! ?? 'Descripcion';
    _selectedDay = _focusedDay;
    _rangeStart = widget.projectModel.start_date_time;
    _rangeEnd = widget.projectModel.stop_date_time;
    _selectedColor = Color(int.parse(widget.projectModel.color!, radix: 16));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
            backgroundColor: kWhiteColor,
            appBar: const CustomAppBar(
              title: 'Actualizar proyecto',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<ProjectsBloc, ProjectsState>(
                        listener: (context, state) {
                          if (state is UpdateProjectFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(state.error, kRed));
                          }
                          if (state is UpdateProjectSuccess) {
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
                                    ? 'El proyecto empieza ${formatDate(dateTime: _rangeStart.toString())} - ${formatDate(dateTime: _rangeEnd.toString())}'
                                    : 'Seleccione un rango para las fechas',
                                kPrimaryColor,
                                textSmall,
                                FontWeight.w400,
                                TextAlign.start,
                                TextOverflow.clip),
                          ),
                          const SizedBox(height: 5),
                          buildText(
                              'Nombre',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 5,
                          ),
                          BuildTextField(
                              hint: "Nombre del proyecto",
                              controller: title,
                              inputType: TextInputType.text,
                              fillColor: kWhiteColor,
                              onChange: (value) {}),
                          const SizedBox(
                            height: 5,
                          ),
                          buildText(
                              'Descripcion',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip),
                          const SizedBox(
                            height: 5,
                          ),
                          BuildTextField(
                              hint: "Descripcion del proyecto",
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
                                  var projectModel = ProjectModel(
                                      id: widget.projectModel.id,
                                      title: title.text,
                                      description: description.text,
                                      completed: widget.projectModel.completed,
                                      start_date_time: _rangeStart,
                                      stop_date_time: _rangeEnd,
                                      color: widget.projectModel.color);
                                  context.read<ProjectsBloc>().add(
                                      UpdateProjectEvent(projectModel: projectModel));
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
                    })))));
  }

  void _openColorPicker(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Selecciona un color'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: _selectedColor,
                onColorChanged: (Color color){
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar')
              ),
            ],
          );
        }
    );
  }

  String colorToHex(Color color){
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
  
}