import 'package:flutter/material.dart';
import 'package:kanban_board_test/tasks/presentation/bloc/projects_bloc.dart';
import 'package:kanban_board_test/tasks/presentation/pages/myuser_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_proyect_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/new_user_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/projects_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/tasks_screen.dart';
import 'package:kanban_board_test/tasks/presentation/pages/users_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TasksScreen(),
    const ProjectsScreen(),
    const UsersScreen(),
    const MyUserScreen()
  ];

  void _onTabTapped(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tareas'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Proyectos'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Usuarios'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Mi usuario'
          )
        ],
      ),
    );
  }
}
