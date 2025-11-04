import 'package:flutter/material.dart';
import '../models/profesor.dart';
import '../database/database_helper.dart';

class ProfesoresScreen extends StatefulWidget {
  @override
  _ProfesoresScreenState createState() => _ProfesoresScreenState();
}

class _ProfesoresScreenState extends State<ProfesoresScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Profesor> _profesores = [];
  final TextEditingController _nprofesorController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();

  // Variables para controlar el modo de edición
  bool _isEditing = false;
  String _currentEditingId = '';

  @override
  void initState() {
    super.initState();
    _loadProfesores();
  }

  Future<void> _loadProfesores() async {
    final profesores = await _databaseHelper.getProfesores();
    setState(() {
      _profesores = profesores;
    });
  }

  void _showAddProfesorDialog() {
    _clearForm();
    _isEditing = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Profesor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ej: Juan Pérez García',
                ),
              ),
              TextField(
                controller: _carreraController,
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  hintText: 'Ej: Ingeniería en Sistemas',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _addProfesor,
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditProfesorDialog(Profesor profesor) {
    _nprofesorController.text = profesor.nprofesor;
    _nombreController.text = profesor.nombre;
    _carreraController.text = profesor.carrera;
    _isEditing = true;
    _currentEditingId = profesor.nprofesor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Profesor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nprofesorController,
                decoration: InputDecoration(
                  labelText: 'ID Profesor',
                  enabled: false, // No se puede editar el ID
                ),
              ),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ej: Juan Pérez García',
                ),
              ),
              TextField(
                controller: _carreraController,
                decoration: InputDecoration(
                  labelText: 'Carrera',
                  hintText: 'Ej: Ingeniería en Sistemas',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _updateProfesor,
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _addProfesor() async {
    if (_nombreController.text.isEmpty ||
        _carreraController.text.isEmpty) {
      _showErrorSnackBar('Por favor complete todos los campos');
      return;
    }
    final ultimoProfesor = await _databaseHelper.getUltimoProfesor();
    int nuevoIdNumerico = 1;

    if (ultimoProfesor != null) {
      final ultimoId = int.tryParse(ultimoProfesor.nprofesor);
      if (ultimoId != null) {
        nuevoIdNumerico = ultimoId + 1;
      }
    }
    final String nuevoNProfesor = nuevoIdNumerico.toString();


    final profesor = Profesor(
      nprofesor: nuevoNProfesor,
      nombre: _nombreController.text.trim(),
      carrera: _carreraController.text.trim(),
    );

    try {
      await _databaseHelper.insertProfesor(profesor);
      _loadProfesores();
      Navigator.pop(context);
      _clearForm();
      _showSuccessSnackBar('Profesor agregado exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al agregar profesor: $e');
    }
  }

  void _updateProfesor() async {
    if (_nombreController.text.isEmpty || _carreraController.text.isEmpty) {
      _showErrorSnackBar('Por favor complete todos los campos');
      return;
    }

    final profesor = Profesor(
      nprofesor: _currentEditingId,
      nombre: _nombreController.text.trim(),
      carrera: _carreraController.text.trim(),
    );

    try {
      await _databaseHelper.updateProfesor(profesor);
      _loadProfesores();
      Navigator.pop(context);
      _clearForm();
      _showSuccessSnackBar('Profesor actualizado exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al actualizar profesor: $e');
    }
  }

  void _deleteProfesor(String nprofesor) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de que desea eliminar este profesor? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar el diálogo de confirmación

              try {
                await _databaseHelper.deleteProfesor(nprofesor);
                _loadProfesores();
                _showSuccessSnackBar('Profesor eliminado exitosamente');
              } catch (e) {
                _showErrorSnackBar('Error al eliminar profesor: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _nprofesorController.clear();
    _nombreController.clear();
    _carreraController.clear();
    _isEditing = false;
    _currentEditingId = '';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestión de Profesores',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 30),
                  onPressed: _showAddProfesorDialog,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _profesores.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay profesores registrados',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presione el botón + para agregar un profesor',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _profesores.length,
                itemBuilder: (context, index) => Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, color: Colors.blue[800]),
                    ),
                    title: Text(
                      _profesores[index].nombre,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_profesores[index].carrera),
                        Text(
                          'ID: ${_profesores[index].nprofesor}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditProfesorDialog(_profesores[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProfesor(_profesores[index].nprofesor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nprofesorController.dispose();
    _nombreController.dispose();
    _carreraController.dispose();
    super.dispose();
  }
}