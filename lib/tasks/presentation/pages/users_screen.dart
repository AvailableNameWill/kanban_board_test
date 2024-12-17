import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kanban_board_test/components/custom_app_bar.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/shared_preferences_service.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/projects_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:kanban_board_test/components/build_text_field.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/users_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/widget/task_item_view.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/font_sizes.dart';
import '../widget/users_item_view.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController searchController = TextEditingController();
  bool _isExpanded = false;
  bool _updateWindowOpened = false;
  SharedPreferencesService spService = SharedPreferencesService();
  String? userName = '';
  String? userType = '';

  void _toggleButtons() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void initState() {
    _loadUserName();
    context.read<UsersBloc>().add(FetchUserEvent());
    //context.read<UsersBloc>().add(LoadUserNames());
    super.initState();
  }

  void _loadUserName() async {
    final name = await spService.getUserName();
    final type = await spService.getUserType();

    setState(() {
      userName = name;
      userType = type;
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
                ),
                body: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: BlocConsumer<UsersBloc, UsersState>(
                            listener: (context, state) {
                          if (state is LoadUserFailure) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(getSnackBar(state.error, kRed));
                          }

                          if (state is AddUserFailure ||
                              state is UpdateUserFailure) {
                            context.read<UsersBloc>().add(FetchUserEvent());
                          }
                        }, builder: (context, state) {
                          if (state is UsersLoading) {
                            print('Users loading in users screen');
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }

                          if (state is LoadUserFailure) {
                            print('Failure in usersceen');
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
                          /*if(state is UsersLoaded){
                            context.read<UsersBloc>().add(FetchUserEvent());
                          }*/

                          if (state is UsersLoaded && state.users != null) {
                            //context.read<TasksBloc>().add(FetchTaskEvent());
                            //context.read<UsersBloc>().add(LoadUserNames());
                            print('Users loaded in users screen');
                            return state.users != null
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
                                            context.read<UsersBloc>().add(
                                                SearchUserEvent(
                                                    keywords: value));
                                          }),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Expanded(
                                          child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: state.users!.length,
                                        itemBuilder: (context, index) {
                                          final user = state.users![index];
                                          return UserItemView(
                                            userModel: user
                                          );
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                          print('users stats' + state.toString());
                          return Container(
                            child: Text('No sucede nada'),
                          );
                        }))),
                floatingActionButton: userType == 'Administrador'
                    ? Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          if (_isExpanded)
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: _toggleButtons,
                                child: Container(
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                            ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isExpanded) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        'Agregar Tarea',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'add_task_u',
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                                context, Pages.createNewTask)
                                            .then((_) {
                                          context
                                              .read<UsersBloc>()
                                              .add(LoadUserNames());
                                        });
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
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        "Agregar proyecto",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'add_pro_u',
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                                context, Pages.createNewProject)
                                            .then((_) {
                                          context
                                              .read<UsersBloc>()
                                              .add(LoadUserNames());
                                        });
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
                                      child: Text(
                                        'Agregar Usuario',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'add_user_u',
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                                context, Pages.createNewUser)
                                            .then((_) {
                                          context
                                              .read<UsersBloc>()
                                              .add(LoadUserNames());
                                        });
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
                                  heroTag: 'main_fab_u',
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    _isExpanded
                                        ? Icons.close
                                        : Icons.add_circle,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      )
                    : null)));
  }
}

/*
*
Si el tiempo de la tarea o el proyecto se paso, bloquearlos o no mostrarlos en la lista o bloquear el checkbox
* y mostrar un mensaje que diga que la fecha ya paso o ya expiro
*
* */
