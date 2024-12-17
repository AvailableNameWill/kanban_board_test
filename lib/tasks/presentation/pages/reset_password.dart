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

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  TextEditingController resetEmailController = TextEditingController();
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
                        if(authState is ResetPasswordFailure){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(authState.error, kRed));
                        }
                        if (authState is ResetPasswordSuccess){
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                              'Se le ha enviado un correo para restaurar su contraseña',
                              Colors.green));
                          Navigator.pop(context);
                        }
                      }, builder: (context, state) {
                    return ListView(
                      children: [
                        const SizedBox(height: 5),
                        buildText(
                            'Has olvidado tu contraseña?',
                            Colors.blue,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip
                        ),
                        const SizedBox(height: 20),
                        buildText(
                            'Ingresa el correo electronico vinculado a tu cuenta',
                            Colors.blue,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BuildTextField(
                          hint: 'Email',
                          controller: resetEmailController,
                          inputType: TextInputType.emailAddress,
                          fillColor: kWhiteColor,
                          onChange: (value) {},
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
                                        'Salir',
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
                                    context.read<AuthBloc>().add(ResetPasswordEvent(email: resetEmailController.text.trim()));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: buildText(
                                        'Enviar',
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
