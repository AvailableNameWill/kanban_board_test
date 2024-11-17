import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kanban_board_test/components/custom_app_bar.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:kanban_board_test/components/build_text_field.dart';
import 'package:kanban_board_test/tasks/presentation/widget/task_item_view.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/font_sizes.dart';
import '../../data/local/model/shared_preferences_service.dart';
import '../bloc/projects_bloc.dart';
import '../widget/project_item_view.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  TextEditingController searchController = TextEditingController();
  bool _isExpanded = false;
  SharedPreferencesService spService = SharedPreferencesService();
  String? userName = '';

  void _toggleButtons(){
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void initState() {
    context.read<ProjectsBloc>().add(FetchProjectEvent());
    _loadUserName();
    super.initState();
  }

  void _loadUserName() async {
    final name = await spService.getUserName();

    setState(() {
      userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: kWhiteColor,
              appBar: CustomAppBar(
                title: userName!,
                showBackArrow: false,
                actionWidgets: [
                  PopupMenuButton<int>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 1,
                    onSelected: (value) {
                      switch (value) {
                        case 0:
                          {
                            context
                                .read<ProjectsBloc>()
                                .add(SortProjectEvent(sortOption: 0));
                            break;
                          }
                        case 1:
                          {
                            context
                                .read<ProjectsBloc>()
                                .add(SortProjectEvent(sortOption: 1));
                            break;
                          }
                        case 2:
                          {
                            context
                                .read<ProjectsBloc>()
                                .add(SortProjectEvent(sortOption: 2));
                            break;
                          }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/calender.svg',
                                width: 15,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              buildText(
                                  'Sort by date',
                                  kBlackColor,
                                  textSmall,
                                  FontWeight.normal,
                                  TextAlign.start,
                                  TextOverflow.clip)
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/task_checked.svg',
                                width: 15,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              buildText(
                                  'Completed tasks',
                                  kBlackColor,
                                  textSmall,
                                  FontWeight.normal,
                                  TextAlign.start,
                                  TextOverflow.clip)
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/task.svg',
                                width: 15,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              buildText(
                                  'Pending tasks',
                                  kBlackColor,
                                  textSmall,
                                  FontWeight.normal,
                                  TextAlign.start,
                                  TextOverflow.clip)
                            ],
                          ),
                        ),
                      ];
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SvgPicture.asset('assets/svgs/filter.svg'),
                    ),
                  ),
                ],
              ),
              body: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: BlocConsumer<ProjectsBloc, ProjectsState>(
                          listener: (context, state) {
                            if (state is LoadProjectFailure) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(getSnackBar(state.error, kRed));
                            }

                            if (state is AddProjectFailure || state is UpdateProjectFailure) {
                              context.read<ProjectsBloc>().add(FetchProjectEvent());
                            }
                          }, builder: (context, state) {
                        if (state is ProjectLoading) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }

                        if (state is LoadProjectFailure) {
                          return Center(
                            child: buildText(
                                state.error,
                                kBlackColor,
                                textMedium,
                                FontWeight.normal,
                                TextAlign.center,
                                TextOverflow.clip),
                          );
                        }

                        if (state is FetchProjectSuccess) {
                          return state.projects.isNotEmpty || state.isSearching
                              ? Column(
                            children: [
                              BuildTextField(
                                  hint: "Search recent task",
                                  controller: searchController,
                                  inputType: TextInputType.text,
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: kGrey2,
                                  ),
                                  fillColor: kWhiteColor,
                                  onChange: (value) {
                                    context.read<ProjectsBloc>().add(
                                        SearchProjectEvent(keyWords: value));
                                  }),
                              const SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: state.projects.length,
                                    itemBuilder: (context, index) {
                                      return ProjectItemView(
                                          projectModel: state.projects[index]);
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return const Divider(
                                        color: kGrey3,
                                      );
                                    },
                                  ))
                            ],
                          )
                              : Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/svgs/tasks.svg',
                                  height: size.height * .20,
                                  width: size.width,
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                buildText(
                                    'Schedule your tasks',
                                    kBlackColor,
                                    textBold,
                                    FontWeight.w600,
                                    TextAlign.center,
                                    TextOverflow.clip),
                                buildText(
                                    'Manage your task schedule easily\nand efficiently',
                                    kBlackColor.withOpacity(.5),
                                    textSmall,
                                    FontWeight.normal,
                                    TextAlign.center,
                                    TextOverflow.clip),
                              ],
                            ),
                          );
                        }
                        return Container();
                      }))),
              floatingActionButton: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  if(_isExpanded)
                    Positioned.fill(
                      child: GestureDetector(
                          onTap: _toggleButtons,
                          child: Container(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(_isExpanded) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text('Agregar Tarea', style: TextStyle(fontSize: 16, color: Colors.white),),
                            ),
                            FloatingActionButton(
                              heroTag: 'add_task_p',
                              backgroundColor: Colors.white,
                              onPressed: (){
                                Navigator.pushNamed(context, Pages.createNewTask);
                              },
                              child: const Icon(
                                Icons.add_circle,
                                color: kPrimaryColor,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text("Agregar proyecto", style: TextStyle(fontSize: 16, color: Colors.white),),
                            ),
                            FloatingActionButton(
                              heroTag: 'add_pro_p',
                              backgroundColor: Colors.white,
                              onPressed: (){
                                Navigator.pushNamed(context, Pages.createNewProject);
                              },
                              child: const Icon(
                                Icons.add_circle,
                                color: kPrimaryColor,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text('Agregar Usuario', style: TextStyle(fontSize: 16, color: Colors.white),),
                            ),
                            FloatingActionButton(
                              heroTag: 'add_user_p',
                              backgroundColor: Colors.white,
                              onPressed: (){
                                Navigator.pushNamed(context, Pages.createNewUser);
                              },
                              child: const Icon(
                                Icons.add_circle,
                                color: kPrimaryColor,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                      Container(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: _toggleButtons,
                          heroTag: 'main_fab_p',
                          backgroundColor: Colors.white,
                          child: Icon(_isExpanded ? Icons.close : Icons.add_circle, color: kPrimaryColor,),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )));
  }
}