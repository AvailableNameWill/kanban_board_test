import 'package:flutter/material.dart';
import 'package:kanban_board_test/routes/pages.dart';
import 'package:kanban_board_test/splash_screen.dart';
import 'package:kanban_board_test/tasks/data/local/model/project_model.dart';
import 'package:kanban_board_test/tasks/data/local/model/task_model.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_proyect_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_task_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/tasks_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/update_task_screen.dart';

import '../page_not_found.dart';

Route onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Pages.initial:
      return MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      );
    case Pages.home:
      return MaterialPageRoute(
        builder: (context) => const TasksScreen(),
      );
    case Pages.createNewTask:
      return MaterialPageRoute(
        builder: (context) => const NewTaskScreen(),
      );
    case Pages.updateTask:
      final args = routeSettings.arguments as TaskModel;
      return MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskModel: args),
      );
    case Pages.createNewProject:
      return MaterialPageRoute(
        builder: (context) => const NewProjectScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const PageNotFound(),
      );
  }
}