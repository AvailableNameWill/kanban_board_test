import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/components/custom_app_bar.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/shared_preferences_service.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:kanban_board_test/components/build_text_field.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/users_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/pages/login.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/widgets.dart';
import '../../../utils/font_sizes.dart';
import '../../data/local/model/user_model.dart';
import '../bloc/auth_bloc.dart';

class AdminModifyUserScreen extends StatefulWidget {
  final UserModel userModel;
  const AdminModifyUserScreen({super.key, required this.userModel});

  @override
  State<AdminModifyUserScreen> createState() => _AdminModifyUserScreenState();
}

class _AdminModifyUserScreenState extends State<AdminModifyUserScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final newEmailController = TextEditingController();
  bool _isExpanded = false;
  SharedPreferencesService spService = SharedPreferencesService();
  SecureStorageService ssService = SecureStorageService();
  String? selectedType = '';
  String? userName = '';
  String? userType = '';
  String? uid = '';
  String? adminId = '';
  final adminUserType = '';
  String? userEmail = '';
  final List<String> userOptions = ["Administrador", "Empleado",];
  UserModel userModel = UserModel(id: 'id', name: 'name', userType: 'userType', status: 'enabled');

  void _toggleButtons(){
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _loadUserName() async {
    /*final name = await spService.getUserName();
    final type = await spService.getUserType();
    final id = await ssService.getUid();
    final email = await ssService.getEmail();*/
    final name = widget.userModel.name;
    final type = widget.userModel.userType;
    final id = widget.userModel.id;
    final aid = await ssService.getUid();
    print('Passed id: ' + id);
    print('saved id: ' + aid);
    setState(() {
      /*userName = name;
      userType = type;
      uid = id;
      userEmail = email;
      userNameController.text = userName!;*/
      userName = name;
      userType = type;
      uid = id;
      adminId = aid;
      userNameController.text = userName!;
    });
  }

  @override
  void initState() {
    _loadUserName();
    context.read<TasksBloc>().add(FetchTaskEvent());
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
              showBackArrow: false,
              title: 'Modificar usuario',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocConsumer<UsersBloc, UsersState>(
                        listener: (context, userState){
                          if (userState is UpdateUserFailure){
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar(userState.error, kRed));
                          }
                          if (userState is UpdateUserSuccess){
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Usuario actualizado correctamente',
                                kPrimaryColor)
                            );
                            final name = userNameController.text.trim();
                            if (widget.userModel.id == adminId){
                              context.read<UsersBloc>().add(UpdateUserLocalInfoEvent(name: name, userType: userType!));
                            }
                            Navigator.pop(context);
                          }
                        },
                        builder: (context, userState){
                          return ListView(
                            children: [
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
                                  hint: userNameController.text.isEmpty ? "Nombre de usuario" : userNameController.text.toString(),
                                  controller: userNameController,
                                  inputType: TextInputType.text,
                                  fillColor: kWhiteColor,
                                  onChange: (value) {}),
                              const SizedBox(height: 5),
                              buildText(
                                  'Seleccione el tipo de usuario',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.bold,
                                  TextAlign.start,
                                  TextOverflow.clip),
                              const SizedBox(height: 5),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton2<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      userType ?? 'Seleccione un usuario',
                                      style: const TextStyle( fontSize: 16, color: kBlackColor),
                                    ),
                                    items: userOptions.map((user) => DropdownMenuItem<String>(
                                      value: user,
                                      child: Text(
                                        user, style: const TextStyle(fontSize: 16),
                                      ),
                                    )).toList(),
                                    value: userType!.isNotEmpty ? userType : null,
                                    onChanged: (value){
                                      setState(() {
                                        if (widget.userModel.id == adminId){print('admin logged in'); userType = 'Administrador'; }
                                        else { userType = value; }
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
                                        iconEnabledColor: kBlackColor
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
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
                                          final name = userNameController.text.trim();
                                          userModel = UserModel(id: uid!, name: name!, userType: userType!, status: 'enabled');
                                          context.read<UsersBloc>().add(UpdateUserInfoEvent(userModel: userModel));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: buildText(
                                              'Guardar',
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
                        }
                    )
                  )
            )
        )
    );
  }
}