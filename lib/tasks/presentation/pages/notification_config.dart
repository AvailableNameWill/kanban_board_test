import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/components/build_text_field.dart';
import 'package:kanban_board_test/components/custom_app_bar.dart';
import 'package:kanban_board_test/components/widgets.dart';
import 'package:kanban_board_test/tasks/data/local/model/notification_model.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/notification_bloc.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';
import 'package:kanban_board_test/utils/util.dart';

class NotificationConfig extends StatefulWidget {
  const NotificationConfig({super.key});

  @override
  State<NotificationConfig> createState() => _NotificationConfigState();
}

class _NotificationConfigState extends State<NotificationConfig> {

  TextEditingController contentController = TextEditingController();
  TextEditingController timeLapseController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  NotificationModel notificationModel = NotificationModel(id: '', title: '', content: '', timeLapse: '');
  String notificationId = 'kI7HjXBV8oQUomnc7aao';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: kWhiteColor,
          appBar: const CustomAppBar(
              showBackArrow: false,
              title: 'Configurar notificaciones'
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: BlocConsumer<NotificationBloc, NotificationState>(
                    listener: (context, notificationState){
                      if (notificationState is AddNotificationFailure){
                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(notificationState.error, kRed));
                      }
                      if (notificationState is UpdateNotificationFailure){
                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(notificationState.error, kRed));
                      }
                      if (notificationState is AddNotificationSuccess){
                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Notificacion agregada correctamente', Colors.green));
                      }
                      if (notificationState is UpdateNotificationSuccess){
                        ScaffoldMessenger.of(context).showSnackBar(getSnackBar('Informacion de la notificacion actualizada correctamente', Colors.green));
                        Navigator.pop(context);
                      }
                    }, builder: (context, state){
                      return ListView(
                        children: [
                          const SizedBox(height: 5),
                          buildText(
                              'Ingrese el titulo de las notificaciones',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip
                          ),
                          const SizedBox(height: 5),
                          BuildTextField(
                              hint: 'Titulo',
                              controller: titleController,
                              fillColor: kWhiteColor,
                              inputType: TextInputType.text,
                              onChange: (value){}
                          ),
                          const SizedBox(height: 5),
                          buildText(
                              'Ingrese el contenido de las notificaciones',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip
                          ),
                          const SizedBox(height: 5),
                          BuildTextField(
                              hint: 'Contenido',
                              controller: contentController,
                              fillColor: kWhiteColor,
                              inputType: TextInputType.text,
                              onChange: (value){}
                          ),
                          const SizedBox(height: 5),
                          buildText(
                              'Ingrese el tiempo de espera para enviar las notificaciones',
                              kBlackColor,
                              textMedium,
                              FontWeight.bold,
                              TextAlign.start,
                              TextOverflow.clip
                          ),
                          const SizedBox(height: 5),
                          BuildTextField(
                              hint: 'Tiempo de espera',
                              controller: timeLapseController,
                              fillColor: kWhiteColor,
                              inputType: TextInputType.text,
                              onChange: (value){}
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
                                      final content = contentController.text.trim();
                                      final timeLapse = timeLapseController.text.trim();
                                      final title = titleController.text.trim();
                                      notificationModel = NotificationModel(id: notificationId, content: content, timeLapse: timeLapse, title: title);
                                      context.read<NotificationBloc>().add(UpdateNotificationEvent(
                                          notificationModel: notificationModel)
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
                    },
                ),
            ),
          ),
        ),
    );
  }
}
