import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/auth_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/projects_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/users_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/custom_app_bar.dart';
import '../../../utils/color_palette.dart';
import '../../data/local/model/user_model.dart';
import '../bloc/tasks_bloc.dart';
import '../../../components/build_text_field.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedType = '';
  final List<String> userOptions = ["Administrador", "Empleado",];

  @override
  void initState() {
    super.initState();
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
              title: 'Crear usuario',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocConsumer<UsersBloc, UsersState>(
                        listener: (context, state) {
                          if(state is ReauthenticationRequired){
                            _showPasswordDialog(context, context.read<AuthBloc>(), state.uid, state.userModel);
                          }
                          if (state is AddUserFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(state.error, kRed));
                          }
                          if (state is AddUserSuccess) {
                            Navigator.pop(context);
                          }
                        }, builder: (context, state) {
                      return BlocListener<AuthBloc, AuthState>(
                        listener: (context, state){
                          if(state is ReauthenticationSuccess){
                            final userBloc = context.read<UsersBloc>();
                            final requiredState = userBloc.state;
                            if(requiredState is ReauthenticationRequired){
                              userBloc.add(CompleteUserCreationEvent(
                                uid: requiredState.uid,
                                userModel: requiredState.userModel
                              ));
                            }else if(state is AuthFailure){
                              ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Error al autenticar al usuario', kRed));
                            }
                          }
                        },
                        child: ListView(
                          children: [
                            const SizedBox(height: 5),
                            buildText(
                                'Correo',
                                kBlackColor,
                                textMedium,
                                FontWeight.bold,
                                TextAlign.start,
                                TextOverflow.clip),
                            const SizedBox(
                              height: 5,
                            ),
                            BuildTextField(
                                hint: "Correo electronico del usuario",
                                controller: email,
                                inputType: TextInputType.text,
                                fillColor: kWhiteColor,
                                onChange: (value) {}),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            buildText(
                                'Contraseña',
                                kBlackColor,
                                textMedium,
                                FontWeight.bold,
                                TextAlign.start,
                                TextOverflow.clip),
                            const SizedBox(
                              height: 5,
                            ),
                            BuildTextField(
                                hint: "Contraseña del usuario",
                                controller: password,
                                inputType: TextInputType.text,
                                fillColor: kWhiteColor,
                                obscureText: true,
                                onChange: (value) {}),
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
                                hint: "Nombre del usuario",
                                controller: name,
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
                                  selectedType ?? 'Seleccione un usuario',
                                  style: const TextStyle( fontSize: 16, color: kBlackColor),
                                ),
                                items: userOptions.map((user) => DropdownMenuItem<String>(
                                  value: user,
                                  child: Text(
                                    user, style: const TextStyle(fontSize: 16),
                                  ),
                                )).toList(),
                                value: selectedType!.isNotEmpty ? selectedType : null,
                                onChanged: (value){
                                  setState(() {
                                    selectedType = value;
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
                                        if(selectedType == null || selectedType!.isEmpty){
                                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                                            'Debe seleccionar el tipo de usuario',
                                            kRed
                                          ));
                                          return;
                                        }

                                        final String uid = DateTime.now().millisecondsSinceEpoch.toString();
                                        var userModel = UserModel(
                                            id: uid,
                                            name: name.text.trim(),
                                            userType: selectedType!,
                                            status: 'enabled'
                                        );

                                        context.read<UsersBloc>().add(
                                          AddNewUserEvent(
                                              userModel: userModel,
                                              email: email.text.trim(),
                                              password: password.text.trim()
                                          ),
                                        );
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
                        ),
                      );
                    }),)
            )
        )
    );
  }

  /*
  *
  BlocListener<AuthBloc, AuthState>(
  listener: (context, authState) {
    if (authState is ReauthenticationSuccess) {
      final usersBloc = context.read<UsersBloc>();
      final requiredState = usersBloc.state;
      if (requiredState is ReauthenticationRequired) {
        usersBloc._completeUserCreation(requiredState.uid, requiredState.userModel);
      }
    } else if (authState is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(authState.error, kRed));
    }
  },
  ...
),
  *
  * */
  /*final String taskId = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        var userModel = UserModel(
                                            id: taskId,
                                            name: name.text,
                                            userType: selectedType!);
                                        context.read<UsersBloc>().add(
                                            AddNewUserEvent(
                                                userModel: userModel,
                                              email: email.text.trim(),
                                              password: password.text.trim()),);*/

  Future<void> _showPasswordDialog(BuildContext context, AuthBloc authBloc, String uid, UserModel userModel){

    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Ingrese su contraseña para verificar que es usted'),
            content: TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'contraseña'),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (){ Navigator.of(context).pop(); },
                  child: const Text('Cancelar')
              ),
              TextButton(
                  onPressed: (){
                    final password = passwordController.text.trim();
                    if (password.isNotEmpty){
                      authBloc.add(ReauthenticateAdminEvent(password: password));
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Confirmar')
              ),
            ],
          );
        }
    );
  }
}

/*
*
NewUserScreen
*
* */