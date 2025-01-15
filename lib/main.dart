import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_board_test/tasks/data/local/data_sources/auth_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/data_sources/notifications_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/data_sources/projects_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/data_sources/users_data_provider.dart';
import 'package:kanban_board_test/tasks/data/local/model/fcm_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/secure_storage_service.dart';
import 'package:kanban_board_test/tasks/data/local/model/shared_preferences_service.dart';
import 'package:kanban_board_test/tasks/data/respository/auth_repository.dart';
import 'package:kanban_board_test/tasks/data/respository/notification_repository.dart';
import 'package:kanban_board_test/tasks/data/respository/project_repository.dart';
import 'package:kanban_board_test/tasks/data/respository/user_repository.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/auth_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/notification_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/projects_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/users_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kanban_board_test/routes/app_router.dart';
import 'package:kanban_board_test/routes/pages.dart';
import 'package:kanban_board_test/tasks/data/local/data_sources/tasks_data_provider.dart';
import 'package:kanban_board_test/tasks/data/respository/task_repository.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:kanban_board_test/utils/color_palette.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'bloc_state_observer.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Bloc para gestionar el estado de la aplicacion, dentro de la clase BlocStateObserver se encuentran
  //todos los metodos para gestionar los estados
  Bloc.observer = BlocStateObserver();
  //Aqui se guardan los datos de la aplicacion (por los momentos)
  //SharedPreferences preferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBckgroundHanlder);

  await _initializeFCM();

  createNotificationChannel();
  initializeLocalNotifications();
  setupFirebaseMessagingListeners();

  runApp(MyApp());
}

Future<void> _firebaseMessagingBckgroundHanlder(RemoteMessage message) async{
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> _initializeFCM() async{
  try{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized){
      print('Permiso de notificacion concedido');
      String? token = await messaging.getToken();
      if (token != null){
        print('FCM token: $token');
      }else{
        print('No se pudo obtener el token');
      }
    }else{
      print('Permiso de notificaciones denegado');
    }
  }catch(error){
    print('Error inicializando FCM: $error');
  }
}

void setupFirebaseMessagingListeners(){
  FirebaseMessaging.onMessage.listen((RemoteMessage message){
    print('Mensaje recibido en Foreground: ${message.notification?.title}, ${message.notification?.body}');

    showNotification(message.notification);
  });
}

void showNotification(RemoteNotification? notification){
  if (notification != null){
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'main_channel',
        'Main Channel',
        icon: '@mipmap/tenlooicon',
        importance: Importance.high,
        priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidNotificationDetails);

    flutterLocalNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        platformDetails
    );
  }
}

void initializeLocalNotifications(){
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/tenlooicon96');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void createNotificationChannel(){
  const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      'main_channel',
      'Main Channel',
      description: 'Canal principal para notificaciones de la app',
      importance: Importance.high,
  );

  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(androidNotificationChannel);
}

class MyApp extends StatelessWidget {
  //final SharedPreferences preferences;
  //const MyApp({super.key, required this.preferences});
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Widget que recibe una clase que maneja la interaccion con una fuente de datos, le pasa todos los datos de la fuente
    //de datos a los todos los widgets hijos
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TaskRepository>(
          create: (context) =>//La clase que maneja los datos, recibe una instancia de Firebase, que es donde se
          //almacenan los datos
          TaskRepository(taskDataProvider: TaskDataProvider(FirebaseFirestore.instance)),
        ),
        RepositoryProvider<ProjectRepository>(
          create: (context) => ProjectRepository(
            projectsDataProvider: ProjectsDataProvider(FirebaseFirestore.instance)
          ),
        ),
        RepositoryProvider<UserRepository>(
            create: (context) => UserRepository(
                userDataProvider: UserDataProvider(
                    FirebaseFirestore.instance,
                    FirebaseAuth.instance,
                    SecureStorageService(),
                    SharedPreferencesService(),
                )
            ),
        ),
        RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository(
              authDataProvider: AuthDataProvider(
                  FirebaseAuth.instance,
                  FirebaseFirestore.instance,
                  SecureStorageService(),
                  SharedPreferencesService(),
                  FCMService(),
              ),
            ),
        ),
        RepositoryProvider<NotificationRepository>(
            create: (context) => NotificationRepository(
                notificationsDataProvider: NotificationsDataProvider(
                    FirebaseFirestore.instance,
                ),
            ),
        ),
      ],
        child: MultiBlocProvider( //El BLoC provider maneja todos los eventos de la clase BLoC, la clase encargada de manejar
          //el estado de las ventanas de la aplicacion, avisa cuando se ha realizado un cambio para que estos cambios se
          //reflejen
            providers: [
              BlocProvider<TasksBloc>(
                create: (context) => TasksBloc(context.read<TaskRepository>()),
              ),
              BlocProvider<ProjectsBloc>(
                create: (context) => ProjectsBloc(context.read<ProjectRepository>()),
              ),
              BlocProvider<UsersBloc>(
                  create: (context) => UsersBloc(context.read<UserRepository>()),
              ),
              BlocProvider<AuthBloc>(
                  create: (context) => AuthBloc(
                      authRepository: context.read<AuthRepository>(),
                      sharedPreferencesService: SharedPreferencesService(),
                      secureStorageService: SecureStorageService()
                  )..add(CheckSessionStarted()),
              ),
              BlocProvider<NotificationBloc>(
                  create: (context) => NotificationBloc(
                    notificationRepository: context.read<NotificationRepository>(),
                  ),
              ),
            ],
            child: MaterialApp(
              title: 'Task Manager',
              debugShowCheckedModeBanner: false,
              initialRoute: Pages.initial,
              onGenerateRoute: onGenerateRoute,
              theme: ThemeData(
                fontFamily: 'Sora',
                visualDensity: VisualDensity.adaptivePlatformDensity,
                canvasColor: Colors.transparent,
                colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
                useMaterial3: true,
              ),
            )));
  }
}