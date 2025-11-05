import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Profesores',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Materias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Horarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Asistencia',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Consultas',
        ),
      ],
    );
  }
}