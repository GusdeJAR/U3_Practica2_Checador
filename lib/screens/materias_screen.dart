import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../database/database_helper.dart';

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Materia> _materias = [];
  final TextEditingController _descripcionController = TextEditingController();

  // Variables para controlar el modo de edición
  bool _isEditing = false;
  int? _currentEditingId;

  @override
  void initState() {
    super.initState();
    _loadMaterias();
  }

  Future<void> _loadMaterias() async {
    final materias = await _databaseHelper.getMaterias();
    setState(() {
      _materias = materias;
    });
  }

  void _showAddMateriaDialog() {
    _clearForm();
    _isEditing = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Materia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción de la Materia',
                  hintText: 'Ej: Matemáticas Avanzadas',
                ),
                maxLines: 2,
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
            onPressed: _addMateria,
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditMateriaDialog(Materia materia) {
    _descripcionController.text = materia.descripcion;
    _isEditing = true;
    _currentEditingId = materia.nmat;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Materia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ID: ${materia.nmat}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción de la Materia',
                  hintText: 'Ej: Matemáticas Avanzadas',
                ),
                maxLines: 2,
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
            onPressed: _updateMateria,
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _addMateria() async {
    if (_descripcionController.text.isEmpty) {
      _showErrorSnackBar('Por favor ingrese la descripción de la materia');
      return;
    }

    final materia = Materia(
      descripcion: _descripcionController.text.trim(),
    );

    try {
      await _databaseHelper.insertMateria(materia);
      _loadMaterias();
      Navigator.pop(context);
      _clearForm();
      _showSuccessSnackBar('Materia agregada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al agregar materia: $e');
    }
  }

  void _updateMateria() async {
    if (_descripcionController.text.isEmpty) {
      _showErrorSnackBar('Por favor ingrese la descripción de la materia');
      return;
    }

    final materia = Materia(
      nmat: _currentEditingId,
      descripcion: _descripcionController.text.trim(),
    );

    try {
      await _databaseHelper.updateMateria(materia);
      _loadMaterias();
      Navigator.pop(context);
      _clearForm();
      _showSuccessSnackBar('Materia actualizada exitosamente');
    } catch (e) {
      _showErrorSnackBar('Error al actualizar materia: $e');
    }
  }

  void _deleteMateria(int nmat) async {
    // Verificar si la materia está siendo usada en horarios
    final horarios = await _databaseHelper.getHorarios();
    final materiaEnUso = horarios.any((horario) => horario.invat == nmat.toString());

    if (materiaEnUso) {
      _showErrorSnackBar('No se puede eliminar la materia porque está asignada en horarios');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de que desea eliminar esta materia? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar el diálogo de confirmación

              try {
                await _databaseHelper.deleteMateria(nmat);
                _loadMaterias();
                _showSuccessSnackBar('Materia eliminada exitosamente');
              } catch (e) {
                _showErrorSnackBar('Error al eliminar materia: $e');
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
    _descripcionController.clear();
    _isEditing = false;
    _currentEditingId = null;
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
                  'Gestión de Materias',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 30),
                  onPressed: _showAddMateriaDialog,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _materias.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay materias registradas',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presione el botón + para agregar una materia',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _materias.length,
                itemBuilder: (context, index) => Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: Icon(Icons.book, color: Colors.orange[800]),
                    ),
                    title: Text(
                      _materias[index].descripcion,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'ID: ${_materias[index].nmat}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditMateriaDialog(_materias[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMateria(_materias[index].nmat!),
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
    _descripcionController.dispose();
    super.dispose();
  }
}