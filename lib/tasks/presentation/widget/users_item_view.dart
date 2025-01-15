import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kanban_board_test/tasks/data/local/model/user_model.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/users_bloc.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/util.dart';
import '../../data/local/model/secure_storage_service.dart';
import '../../data/local/model/shared_preferences_service.dart';
import '../../data/local/model/task_model.dart';
import '../bloc/tasks_bloc.dart';

class UserItemView extends StatefulWidget {
  final UserModel userModel;
  VoidCallback? onUpdateTaskScreenOpen;
  bool? updateScreenOpened;
  UserItemView({
    super.key,
    required this.userModel,
    this.onUpdateTaskScreenOpen,
    this.updateScreenOpened = false,
  });

  @override
  State<UserItemView> createState() => _UserItemViewState();
}

class _UserItemViewState extends State<UserItemView> {
  //late Color color;
  //bool hasUser = false;
  String userId = '';
  String? authUserType = '';
  SecureStorageService ssService = SecureStorageService();
  SharedPreferencesService spService = SharedPreferencesService();

  @override
  void initState() {
    _loadUserName();
    super.initState();
  }

  void _loadUserName() async {
    final id = await ssService.getUid();
    final type = await spService.getUserType();

    setState(() {
      userId = id;
      authUserType = type;
      //hasUser = validateTaskHasUser();
    });
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
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: buildText(
                            widget.userModel.userType,
                            kBlackColor,
                            textMedium,
                            FontWeight.w500,
                            TextAlign.start,
                            TextOverflow.clip)),
                        PopupMenuButton<int>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: kWhiteColor,
                          elevation: 1,
                          onSelected: (value) async {
                            switch (value) {
                              /*case 0:
                                {
                                  print('Update task window opened');
                                  await Navigator.pushNamed(context, Pages.adminModifyUserScreen,
                                    arguments: widget.userModel
                                  );
                                  break;
                                }*/
                              case 0:
                                {
                                  await Navigator.pushNamed(context, Pages.adminModifyUserScreen,
                                      arguments: widget.userModel
                                  );
                                  break;
                                }
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              if (authUserType == 'Administrador')
                                PopupMenuItem<int>(
                                  value: 0,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svgs/edit.svg',
                                        width: 20,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      buildText(
                                          'Modificar usuario',
                                          kBlackColor,
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
                    const SizedBox(height: 5,)
                  ],
                ),
              ),
              const SizedBox(width: 10,),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.userModel.name), //Colocar la sugerencia aqui
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDeleteUserDialog(BuildContext context, UserModel userModel) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar eliminacion de usuario'),
          content: Text('¿Estas seguro de que deseas eliminar al usuario ${userModel.name}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar')
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Eliminar')
            ),
          ],
        ),
    );
    if (confirm == true){
      //userModel.status = 'disabled';
      context.read<UsersBloc>().add(DeleteUserEvent(userModel: userModel));
    }
  }
}
/*
*
Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text('User ID'),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.all(Radius.circular(2))),
              width: double.infinity,
              child: const Center(child: Text('Project Name')),
            ),
          ],
        ),
*
* */

/*bool validateTaskHasUser(){
    print('UserId: ' + userId);
    print('Task uid: ' + widget.taskModel.user_id!);
    if(widget.userType == 'Administrador') {return false;}
    if (widget.taskModel.user_id == userId || widget.taskModel.user_id == '' || widget.taskModel.user_id!.isEmpty || widget.taskModel.user_id == null){
      print('false');
      return false;
    }
    print('true');
    //}
    return true;
  }*/
/*Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.circular(2))),
                height: 100,
                child: const Center(child: Text('')),
              ),*/
/*Checkbox(
                  value: widget.taskModel.completed,
                  onChanged: (value) {
                    var taskModel = TaskModel(
                        id: widget.taskModel.id,
                        title: widget.taskModel.title,
                        description: widget.taskModel.description,
                        project_id: widget.taskModel.project_id,
                        user_id: widget.taskModel.user_id,
                        completed: !widget.taskModel.completed,
                        start_date_time: widget.taskModel.start_date_time,
                        stop_date_time: widget.taskModel.stop_date_time);
                    context.read<TasksBloc>().add(
                        UpdateTaskEvent(taskModel: taskModel));
                  }),*/