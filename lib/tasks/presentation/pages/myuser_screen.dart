import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:kanban_board_test/tasks/presentation/pages/login.dart';
import 'package:kanban_board_test/tasks/presentation/widget/task_item_view.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/font_sizes.dart';
import '../../data/local/model/user_model.dart';
import '../bloc/auth_bloc.dart';

class MyUserScreen extends StatefulWidget {
  const MyUserScreen({super.key});

  @override
  State<MyUserScreen> createState() => _MyUserScreenState();
}

/*
*
TextBox para: nombre, contraseña, email
* DropDown para userType
* Label - TextField / DropDown
* Boton para guardar
*
* */

class _MyUserScreenState extends State<MyUserScreen> {
  TextEditingController searchController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final newEmailController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isExpanded = false;
  bool _updateWindowOpened = false;
  SharedPreferencesService spService = SharedPreferencesService();
  SecureStorageService ssService = SecureStorageService();
  String? selectedType = '';
  String? userName = '';
  String? userType = '';
  String? uid = '';
  String? userEmail = '';
  String? status = 'enabled';
  final List<String> userOptions = ["Administrador", "Empleado",];
  UserModel userModel = UserModel(id: 'id', name: 'name', userType: 'userType', status: 'enabled');

  void _toggleButtons(){
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _loadUserName() async {
    final name = await spService.getUserName();
    final type = await spService.getUserType();
    final id = await ssService.getUid();
    final email = await ssService.getEmail();
    setState(() {
      userName = name;
      userType = type;
      uid = id;
      userEmail = email;
      userNameController.text = userName!;
    });
  }

  @override
  void initState() {
    _loadUserName();
    context.read<TasksBloc>().add(FetchTaskEvent());
    super.initState();
  }

  bool isValidEmail(String email){
    String emailPattern = r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
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
              title: 'Mi usuario',
            ),
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, authState) {
                        if(authState is AuthFailure){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(authState.error, kRed));
                        }
                        if(authState is UpdateEmailSuccess){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                              'Se ha enviado un mensaje de confirmacion a su nuevo correo electronico. Revise su bandeja de entrada o SPAM '
                                  'y valide el nuevo email. Si no se valida no podra iniciar sesion con el nuevo correo.',
                              kPrimaryColor
                            )
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                                (Route<dynamic> route) => false,
                          );
                        }
                        if (authState is DeleteAuthUserFailure){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(authState.error, kRed));
                        }
                        if (authState is DeleteAuthUserSuccess){
                          final name = userNameController.text.trim();
                          userModel = UserModel(
                              id: uid!,
                              name: name.isNotEmpty ? name : 'Usuario',
                              userType: userType!,
                              status: status!
                          );
                          context.read<UsersBloc>().add(DeleteUserEvent(userModel: userModel));
                        }
                      }, builder: (context, state) {
                    return BlocConsumer<UsersBloc, UsersState>(
                      listener: (context, userState){
                        if (userState is UpdateUserFailure){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(userState.error, kRed));
                        }
                        if (userState is UpdateUserSuccess){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Usuario actualizado correctamente',
                              kPrimaryColor)
                          );
                          _loadUserName();
                          final name = userNameController.text.trim();
                          context.read<UsersBloc>().add(UpdateUserLocalInfoEvent(name: name, userType: userType!));
                        }
                        if (userState is DeleteUserFailure){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Error al eliminar el usuario!',
                              kPrimaryColor)
                          );
                        }
                        if (userState is DeleteUserSuccess){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                              'Se ha eliminado su usuario correctamente',
                              kPrimaryColor),
                          );
                          context.read<AuthBloc>().add(
                            LogoutEvent(),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                                (Route<dynamic> route) => false,
                          );
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
                                  userType == 'Administrador' ? 'Seleccione el tipo de usuario' : 'Tipo de usuario',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.bold,
                                  TextAlign.start,
                                  TextOverflow.clip),
                            const SizedBox(height: 5),
                            if (userType == 'Administrador')
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
                                      userType = value;
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
                              if (userType == 'Empleado')
                              BuildTextField(
                              hint: userType!,
                              controller: null,
                              inputType: TextInputType.emailAddress,
                              fillColor: kWhiteColor,
                              onChange: (value) {},
                              enabled: false,
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
                                        Navigator.pushNamed(
                                            context,
                                            Pages.changePasswordScreen
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: buildText(
                                            'Cambiar clave',
                                            kWhiteColor,
                                            textMedium,
                                            FontWeight.w600,
                                            TextAlign.center,
                                            TextOverflow.clip),
                                      )),
                                ),
                                const SizedBox(width: 20),
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
                                        _showChangeEmailDialog(context, context.read<AuthBloc>());
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: buildText(
                                            'Cambiar email',
                                            kWhiteColor,
                                            textMedium,
                                            FontWeight.w600,
                                            TextAlign.center,
                                            TextOverflow.clip),
                                      )),
                                ),
                              ],
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
                                        context.read<AuthBloc>().add(
                                          LogoutEvent(),
                                        );

                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => const Login()),
                                            (Route<dynamic> route) => false,
                                        );
                                        //Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: buildText(
                                            'Cerrar sesion',
                                            kRed,
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
                                        final name = userNameController.text.trim();
                                        userModel = UserModel(id: uid!, name: name!, userType: userType!, status: status!);
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
                            const SizedBox(height: 5),
                            SizedBox(
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
                                    _showDeleteUserAccountDialog(context, context.read<AuthBloc>());
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: buildText(
                                        'Borrar cuenta',
                                        kRed,
                                        textMedium,
                                        FontWeight.w600,
                                        TextAlign.center,
                                        TextOverflow.clip),
                                  )),
                            ),
                          ],
                        );
                      }
                    );
                  }),)
            )
        )
    );
  }

  Future<void> _showChangeEmailDialog(BuildContext context, AuthBloc authBloc){
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Cambiar correo electronico'),
            content: TextFormField(
              controller: newEmailController,
              decoration: const InputDecoration(labelText: 'Ingrese su nuevo correo electronico'),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (){ Navigator.of(context).pop(); },
                  child: const Text('Cancelar')
              ),
              TextButton(
                  onPressed: (){
                    final newEmail = newEmailController.text.trim();
                    if (newEmail.isNotEmpty){
                      authBloc.add(UpdateEmailEvent(newEmail: newEmail));
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

  Future<void> _showDeleteUserAccountDialog(BuildContext context, AuthBloc authBloc){
    confirmPasswordController.clear();
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: const Text('Eliminar su cuenta'),
            content: TextFormField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Ingrese su contraseña para eliminar su cuenta'),
              obscureText: true,
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: (){ Navigator.of(context).pop(); },
                  child: const Text('Cancelar')
              ),
              TextButton(
                  onPressed: (){
                    final password = confirmPasswordController.text.trim();
                    if (password.isNotEmpty || password != null){
                      authBloc.add(DeleteAuthUserEvent(email: userEmail!, password: password));
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
* Crear un metodo que valide los campos, guardar los valores de los TextEdittingController en variables. Luego validar las
* variables, validar que el email introducido sea un email valido, que userName no este vacio, las contraseñas tienen que
* tener un tamaño arriba de 8 y la vieja y nueva contraseña no pueden ser las mismas
* crear una instancia de UserModel y darle los valores de las variables, el uid se guarda en la variable del mismo nombre.
Si el tiempo de la tarea o el proyecto se paso, bloquearlos o no mostrarlos en la lista o bloquear el checkbox
* y mostrar un mensaje que diga que la fecha ya paso o ya expiro
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