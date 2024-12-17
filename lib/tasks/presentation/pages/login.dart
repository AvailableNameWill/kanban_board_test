import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/components/build_text_field.dart';
import 'package:kanban_board_test/components/custom_app_bar.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/auth_bloc.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';
import 'package:kanban_board_test/utils/util.dart';

import '../../../routes/pages.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent
        ),
        child: Scaffold(
          backgroundColor: kWhiteColor,
          appBar: const CustomAppBar(
            title: 'Login',
            showBackArrow: false,
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: FocusScope.of(context).unfocus,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state){
                    if(state is AuthFailure){
                      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(state.error, kRed));
                    }
                    if(state is LoginSuccess){
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Pages.home,
                            (route) => false,
                      );
                    }
                  }, builder: (context, state){
                    return ListView(
                      children: [
                        buildText(
                            'Correo Electronico',
                            kBlackColor,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip
                        ),
                        const SizedBox(height: 10),
                        BuildTextField(
                            hint: 'email@email.com',
                            inputType: TextInputType.emailAddress,
                            onChange: (value){},
                            controller: emailController,
                        ),
                        const SizedBox(height: 10),
                        buildText(
                            'Contraseña',
                            kBlackColor,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip
                        ),
                        const SizedBox(height: 10),
                        BuildTextField(
                            hint: '********',
                            inputType: TextInputType.emailAddress,
                            onChange: (value){},
                            controller: passwordController,
                            obscureText: true,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 20,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                alignment: Alignment.centerLeft,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap
                              ),
                              onPressed: (){
                                Navigator.of(context).pushNamed(Pages.resetPassword);
                              },
                              child: Text(
                                'Has olvidado tu contraseña?',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.left,
                              ),
                          )
                        ),
                        const SizedBox(height: 10),
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
                                    context.read<AuthBloc>().add(
                                        LoginEvent(
                                          email: emailController.text,
                                          password: passwordController.text,
                                          ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: buildText(
                                        'Ingresar',
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
                  },
              ),
            ),
          ),
        ),
    );
  }
}
