import 'package:flutter/material.dart';
import 'package:kanban_board_test/routes/pages.dart';
import 'package:kanban_board_test/splash_screen.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/tasks/presentation/pages/admin_modify_user_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/change_password_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/home_page.dart';
import 'package:kanban_board_test/tasks/presentation/pages/login.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_proyect_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_task_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_user_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/notification_config.dart';
import 'package:kanban_board_test/tasks/presentation/pages/reset_password.dart';
import 'package:kanban_board_test/tasks/presentation/pages/tasks_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/update_project_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/update_task_screen.dart';

import '../page_not_found.dart';
import '../tasks/data/local/model/user_model.dart';

Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Pages.initial:
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
    case Pages.home:
      return MaterialPageRoute(
        builder: (context) => const HomePage(),
      );
    case Pages.loginPage:
      return MaterialPageRoute(
        builder: (context) => const Login(),
      );
    case Pages.createNewTask:
      return MaterialPageRoute(
        builder: (context) => const NewTaskScreen(),
      );
    case Pages.updateTask:
      final args = routeSettings.arguments as Map<String, dynamic>;
      final taskModel = args['taskModel'] as TaskModel;
      final userType = args['userType'] as String;
      return MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskModel: taskModel, userType: userType),
      );
    case Pages.createNewProject:
      return MaterialPageRoute(
        builder: (context) => const NewProjectScreen(),
      );
    case Pages.updateProject:
      final args = routeSettings.arguments as ProjectModel;
      return MaterialPageRoute(
        builder: (context) => UpdateProjectScreen(projectModel: args)
      );
    case Pages.adminModifyUserScreen:
      final args = routeSettings.arguments as UserModel;
      return MaterialPageRoute(
          builder: (context) => AdminModifyUserScreen(userModel: args)
      );
    case Pages.createNewUser:
      return MaterialPageRoute(
        builder: (context) => const NewUserScreen(),
      );
    case Pages.changePasswordScreen:
      return MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      );
    case Pages.resetPassword:
      return MaterialPageRoute(
          builder: (context) => const ResetPassword(),
      );
    case Pages.notificationConfig:
      return MaterialPageRoute(
          builder: (context) => const NotificationConfig(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const PageNotFound(),
      );
  }
}