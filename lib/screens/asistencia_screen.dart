import 'package:flutter/material.dart';
import '../models/asistencia.dart';
import '../models/horario.dart';
import '../models/profesor.dart';
import '../models/materia.dart';
import '../database/database_helper.dart';

class AsistenciaScreen extends StatefulWidget {
  @override
  _AsistenciaScreenState createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Asistencia> _asistencias = [];
  List<Horario> _horarios = [];
  List<Profesor> _profesores = [];
  List<Materia> _materias = [];

  // Controladores para el formulario
  final TextEditingController _fechaController = TextEditingController();
  int? _selectedHorario;
  bool _asistenciaValue = true;

  @override
  void initState() {
    super.initState();
    _cargarData();
  }

  Future<void> _cargarData() async {
    await _cargarAsistencias();
    await _cargarHorarios();
    await _cargarProfesores();
    await _cargarMaterias();
  }

  Future<void> _cargarAsistencias() async {
    final asistencias = await _databaseHelper.getAsistencias();
    setState(() {
      _asistencias = asistencias;
    });
  }

  Future<void> _cargarHorarios() async {
    final horarios = await _databaseHelper.getHorarios();
    setState(() {
      _horarios = horarios;
    });
  }

  Future<void> _cargarProfesores() async {
    final profesores = await _databaseHelper.getProfesores();
    setState(() {
      _profesores = profesores;
    });
  }

  Future<void> _cargarMaterias() async {
    final materias = await _databaseHelper.getMaterias();
    setState(() {
      _materias = materias;
    });
  }

  void _showAddAsistenciaDialog() {
    _limpiarForm();
    _fechaController.text = _getCurrentDate();

    showDialog(
      context: context,
      builder: (dialogContext) {

        bool asistenciaValue = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Registrar Asistencia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedHorario,
                      decoration: InputDecoration(labelText: 'Horario'),

                      isExpanded: true,

                      items: _horarios.map((horario) {
                        return DropdownMenuItem<int>(
                          value: horario.nhorario,

                          child: Text(
                            _getHorarioMostrarText(horario),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _selectedHorario = value;
                      },
                      validator: (value) => value == null ? 'Seleccione un horario' : null,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _fechaController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: _showDatePicker,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Asistencia:', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 16),
                        Switch(
                          value: asistenciaValue,
                          onChanged: (value) {
                            setDialogState(() {
                              asistenciaValue = value;
                            });
                          },
                        ),
                        Text(asistenciaValue ? 'Presente' : 'Ausente'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addAsistencia(asistenciaValue);
                  },
                  child: Text('Registrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditAsistenciaDialog(Asistencia asistencia) {
    _selectedHorario = asistencia.nhorario;
    _fechaController.text = asistencia.fecha;
    bool valorAsistencia = asistencia.asistencia;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Asistencia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedHorario,
                decoration: InputDecoration(labelText: 'Horario'),
                isExpanded: true,
                items: _horarios.map((horario) {
                  return DropdownMenuItem(
                    value: horario.nhorario,
                    child: Text(_getHorarioMostrarText(horario),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHorario = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _showDatePicker,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Asistencia:'),
                  SizedBox(width: 16),
                  Switch(
                    value: valorAsistencia,
                    onChanged: (value) {
                      setState(() {
                        valorAsistencia = value;
                      });
                    },
                  ),
                  Text(valorAsistencia ? 'Presente' : 'Ausente'),
                ],
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
            onPressed: () => _updateAsistencia(asistencia),
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _addAsistencia(bool asiste) async {
    if (_selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione un horario')),
      );
      return;
    }

    if (_fechaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese una fecha')),
      );
      return;
    }

    final asistencia = Asistencia(
      nhorario: _selectedHorario!,
      fecha: _fechaController.text,
      asistencia: asiste,
    );

    await _databaseHelper.insertAsistencia(asistencia);
    _cargarAsistencias();
    Navigator.pop(context);
    _limpiarForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Asistencia registrada exitosamente')),
    );
  }

  void _updateAsistencia(Asistencia asistencia) async {
    if (_selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione un horario')),
      );
      return;
    }

    if (_fechaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor ingrese una fecha')),
      );
      return;
    }

    final updatedAsistencia = Asistencia(
      idasistencia: asistencia.idasistencia,
      nhorario: _selectedHorario!,
      fecha: _fechaController.text,
      asistencia: asistencia.asistencia,
    );

    await _databaseHelper.updateAsistencia(updatedAsistencia);
    _cargarAsistencias();
    Navigator.pop(context);
    _limpiarForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Asistencia actualizada exitosamente')),
    );
  }

  void _deleteAsistencia(int idasistencia) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de que desea eliminar este registro de asistencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _databaseHelper.deleteAsistencia(idasistencia);
              _cargarAsistencias();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Asistencia eliminada exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _limpiarForm() {
    _fechaController.clear();
    _selectedHorario = null;
    _asistenciaValue = true;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  String _getHorarioMostrarText(Horario horario) {
    final profesor = _profesores.firstWhere(
          (p) => p.nprofesor == horario.inprofesor,
      orElse: () => Profesor(nprofesor: '', nombre: 'No encontrado', carrera: ''),
    );

    final materia = _materias.firstWhere(
          (m) => m.nmat.toString() == horario.invat,
      orElse: () => Materia(descripcion: 'No encontrada'),
    );

    return '${profesor.nombre} - ${materia.descripcion} - ${horario.hora}';
  }

  String _getAsistenciaDetalles(Asistencia asistencia) {
    final horario = _horarios.firstWhere(
          (h) => h.nhorario == asistencia.nhorario,
      orElse: () => Horario(
        inprofesor: '',
        invat: '',
        hora: 'No encontrado',
        edificio: '',
        salon: '',
      ),
    );

    final profesor = _profesores.firstWhere(
          (p) => p.nprofesor == horario.inprofesor,
      orElse: () => Profesor(nprofesor: '', nombre: 'No encontrado', carrera: ''),
    );

    final materia = _materias.firstWhere(
          (m) => m.nmat.toString() == horario.invat,
      orElse: () => Materia(descripcion: 'No encontrada'),
    );

    return 'Prof: ${profesor.nombre} - Materia: ${materia.descripcion} - Hora: ${horario.hora}';
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
                  'Registro de Asistencia',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 30),
                  onPressed: _showAddAsistenciaDialog,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _asistencias.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay registros de asistencia',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presione el botón + para registrar asistencia',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _asistencias.length,
                itemBuilder: (context, index) => Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _asistencias[index].asistencia
                          ? Colors.green
                          : Colors.red,
                      child: Icon(
                        _asistencias[index].asistencia
                            ? Icons.check
                            : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Fecha: ${_asistencias[index].fecha}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getAsistenciaDetalles(_asistencias[index])),
                        Text(
                          'Asistencia: ${_asistencias[index].asistencia ? 'PRESENTE' : 'AUSENTE'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _asistencias[index].asistencia
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditAsistenciaDialog(_asistencias[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAsistencia(_asistencias[index].idasistencia!),
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
    _fechaController.dispose();
    super.dispose();
  }
}