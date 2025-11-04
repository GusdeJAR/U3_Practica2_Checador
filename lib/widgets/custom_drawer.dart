import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onSelectItem;

  const CustomDrawer({required this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, color: Colors.blue[800], size: 30),
                ),
                SizedBox(height: 10),
                Text(
                  'Sistema de Asistencia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Escuela X',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
          _buildDrawerItem(Icons.people, 'Profesores', 1),
          _buildDrawerItem(Icons.book, 'Materias', 2),
          _buildDrawerItem(Icons.schedule, 'Horarios', 3),
          _buildDrawerItem(Icons.assignment, 'Asistencia', 4),
          _buildDrawerItem(Icons.analytics, 'Consultas', 5),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onSelectItem(index),
    );
  }
}