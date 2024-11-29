import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kanban_board_test/bloc_state_observer.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/routes/pages.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/projects_bloc.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';
import 'package:kanban_board_test/utils/util.dart';

class ProjectItemView extends StatefulWidget {
  final ProjectModel projectModel;
  final String userType;
  const ProjectItemView({super.key, required this.projectModel, required this.userType});

  @override
  State<ProjectItemView> createState() => _ProjectItemViewState();
}

class _ProjectItemViewState extends State<ProjectItemView> {

  late Color color;

  @override
  void initState() {
    color = Color(int.parse(widget.projectModel.color ?? '#FFFFFF', radix: 16));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(2))),
                height: 100,
                child: const Center(child: Text('')),
              ),
              Checkbox(
                  value: widget.projectModel.completed,
                  onChanged: (value){
                    var projectModel = ProjectModel(
                        id: widget.projectModel.id,
                        title: widget.projectModel.title,
                        description: widget.projectModel.description,
                        completed: !widget.projectModel.completed,
                        start_date_time: widget.projectModel.start_date_time,
                        stop_date_time: widget.projectModel.stop_date_time,
                        color: '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}'
                    );
                    context.read<ProjectsBloc>().add(
                      UpdateProjectEvent(projectModel: projectModel));
                  }),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: buildText(
                          widget.projectModel.title ?? 'Titulo',
                          kBlackColor,
                          textMedium,
                          FontWeight.w500,
                          TextAlign.start,
                          TextOverflow.clip),),
                        PopupMenuButton<int>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: kWhiteColor,
                          elevation: 1,
                          onSelected: (value){
                            switch(value){
                              case 0: Navigator.pushNamed(context, Pages.updateProject, arguments: widget.projectModel);
                              break;
                              case 1: context.read<ProjectsBloc>().add(
                                DeleteProjectEvent(projectModel: widget.projectModel)
                              );
                              break;
                            }
                          },
                          itemBuilder: (BuildContext context){
                            return[
                              PopupMenuItem<int>(
                                  value: 0,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svgs/edit.svg',
                                      width: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    buildText('Editar proyecto',
                                        kBlackColor, 
                                        textMedium, 
                                        FontWeight.normal, 
                                        TextAlign.start, 
                                        TextOverflow.clip)
                                  ],
                                ),
                              ),
                              if (widget.userType == 'Administrador')
                              PopupMenuItem<int>(
                                  value: 1, 
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svgs/delete.svg',
                                        width: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      buildText('Borrar proyecto', 
                                          kRed, 
                                          textMedium, 
                                          FontWeight.normal, 
                                          TextAlign.start, 
                                          TextOverflow.clip)
                                    ],
                                  ),
                              ),
                            ];
                          },
                          child: SvgPicture.asset('assets/svgs/vertical_menu.svg'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    buildText(widget.projectModel.description ?? 'Descripcion',
                        kGrey1,
                        textSmall,
                        FontWeight.normal,
                        TextAlign.start,
                        TextOverflow.clip),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(.1),
                          borderRadius: const BorderRadius.all(Radius.circular(5))
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/svgs/calender.svg', width: 12,),
                          const SizedBox(width: 10),
                          Expanded(
                            child: buildText('${formatDate(dateTime: widget.projectModel.start_date_time.toString())} - ${formatDate(dateTime: widget.projectModel
                                .stop_date_time.toString())}',
                                kBlackColor,
                                textTiny,
                                FontWeight.w400,
                                TextAlign.start,
                                TextOverflow.clip),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10)
            ],
          ),
        )
      ],
    );
  }
}
