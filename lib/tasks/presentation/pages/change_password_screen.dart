import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../components/build_text_field.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/widgets.dart';
import '../../../routes/pages.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../data/local/model/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/users_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatNewPasswordController = TextEditingController();
  TextEditingController actualPasswordController = TextEditingController();
  String? userEmail;

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
                        if (authState is PasswordUpdateSuccess){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Contraseña actualizada correctamente', Colors.green));
                          Navigator.pop(context);
                        }
                      }, builder: (context, state) {
                    return ListView(
                            children: [
                              const SizedBox(height: 5),
                              buildText(
                                  'Ingrese su nueva contraseña',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.bold,
                                  TextAlign.start,
                                  TextOverflow.clip),
                              const SizedBox(
                                height: 5,
                              ),
                              BuildTextField(
                                  hint: 'Nueva contraseña',
                                  controller: newPasswordController,
                                  inputType: TextInputType.text,
                                  fillColor: kWhiteColor,
                                  onChange: (value) {},
                                  obscureText: true,
                              ),
                              const SizedBox( height: 5 ),
                                buildText(
                                    'Repita la nueva contraseña',
                                    kBlackColor,
                                    textMedium,
                                    FontWeight.bold,
                                    TextAlign.start,
                                    TextOverflow.clip),
                                const SizedBox( height: 5 ),
                                BuildTextField(
                                  hint: "Nueva contraseña",
                                  controller: repeatNewPasswordController,
                                  inputType: TextInputType.text,
                                  fillColor: kWhiteColor,
                                  obscureText: true,
                                  onChange: (value) {},
                                ),
                              const SizedBox(height: 5),
                              buildText(
                                  'Contraseña actual',
                                  kBlackColor,
                                  textMedium,
                                  FontWeight.bold,
                                  TextAlign.start,
                                  TextOverflow.clip),
                              const SizedBox(height: 5),
                                BuildTextField(
                                  hint: 'Contraseña con la que inicia sesion actualmente',
                                  controller: actualPasswordController,
                                  inputType: TextInputType.text,
                                  fillColor: kWhiteColor,
                                  onChange: (value) {},
                                  obscureText: true,
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
                                        onPressed: () { Navigator.pop(context); },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: buildText(
                                              'Cancelar',
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
                                          context.read<AuthBloc>().add(UpdatePasswordEvent(
                                              currentPassword: actualPasswordController.text.trim(),
                                              newPassword: newPasswordController.text.trim(),
                                              repeatNewPassword: repeatNewPasswordController.text.trim()
                                            )
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: buildText(
                                              'Actualizar',
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
                  ),
              )
            )
        );
  }
}
