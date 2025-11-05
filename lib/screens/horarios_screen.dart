import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/horario.dart';
import '../database/database_helper.dart';
import '../models/profesor.dart';
import '../models/materia.dart';

class HorariosScreen extends StatefulWidget {
  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Horario> _horarios = [];
  List<Profesor> _profesores = [];
  List<Materia> _materias = [];
  final formatoMascaraHora = MaskTextInputFormatter(
      mask: '##:##',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );


  // Controladores para el formulario
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _edificioController = TextEditingController();
  final TextEditingController _salonController = TextEditingController();
  String? _selectedProfesor;
  String? _selectedMateria;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadHorarios();
    await _loadProfesores();
    await _loadMaterias();
  }

  Future<void> _loadHorarios() async {
    final horarios = await _databaseHelper.getHorarios();
    setState(() {
      _horarios = horarios;
    });
  }

  Future<void> _loadProfesores() async {
    final profesores = await _databaseHelper.getProfesores();
    setState(() {
      _profesores = profesores;
    });
  }

  Future<void> _loadMaterias() async {
    final materias = await _databaseHelper.getMaterias();
    setState(() {
      _materias = materias;
    });
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    // Obtenemos la hora actual del controlador si ya existe, o usamos la hora actual.
    TimeOfDay horaInicial = TimeOfDay.now();
    if (_horaController.text.isNotEmpty) {
      try {
        final parts = _horaController.text.split(':');
        horaInicial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (e) {
        // Si el formato es inválido, simplemente usa la hora actual.
      }
    }

    // Muestra el selector de tiempo.
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      // Opcional: para forzar el formato de 24 horas y mejorar la consistencia.
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    // Si el usuario selecciona una hora (no presiona 'Cancelar').
    if (horaSeleccionada != null) {
      // Formateamos el resultado para que tenga siempre dos dígitos (ej. 09:05).
      final String horaFormateada =
          '${horaSeleccionada.hour.toString().padLeft(2, '0')}:${horaSeleccionada.minute.toString().padLeft(2, '0')}';

      // Actualizamos el controlador del TextField.
      setState(() {
        _horaController.text = horaFormateada;
      });
    }
  }

  void _showAddHorarioDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Horario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProfesor,
                decoration: InputDecoration(labelText: 'Profesor'),
                isExpanded: true,

                items: _profesores.map((profesor) {
                  return DropdownMenuItem(
                    value: profesor.nprofesor,
                    child: Text(
                      profesor.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfesor = value;
                  });
                },
              ),

              SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedMateria,
                decoration: InputDecoration(labelText: 'Materia'),

                isExpanded: true,

                items: _materias.map((materia) {
                  return DropdownMenuItem(
                    value: materia.nmat.toString(),
                    child: Text(
                      materia.descripcion,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMateria = value;
                  });
                },
              ),

              SizedBox(height: 8),

              TextField(
                controller: _horaController,
                readOnly: true, // El usuario no puede escribir.
                decoration: InputDecoration(
                  labelText: 'Hora',
                  hintText: 'Seleccione una hora',
                  // Un ícono para indicar que es un campo de tiempo.
                  suffixIcon: Icon(Icons.access_time_outlined),
                ),
                onTap: () {
                  // Llama a nuestro método cuando el usuario toca el campo.
                  _seleccionarHora(context);
                },
              ),

              SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _edificioController,
                      decoration: InputDecoration(labelText: 'Edificio'),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _salonController,
                      decoration: InputDecoration(labelText: 'Salón'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
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
            onPressed: _addHorario,
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }


  void _showEditHorarioDialog(Horario horario) {
    _horaController.text = horario.hora;
    _edificioController.text = horario.edificio;
    _salonController.text = horario.salon;
    _selectedProfesor = horario.inprofesor;
    _selectedMateria = horario.invat;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Horario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProfesor,
                decoration: InputDecoration(labelText: 'Profesor'),
                isExpanded: true,
                items: _profesores.map((profesor) {
                  return DropdownMenuItem(
                    value: profesor.nprofesor,
                    child: Text(profesor.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),

                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfesor = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedMateria,
                decoration: InputDecoration(labelText: 'Materia'),
                isExpanded: true,
                items: _materias.map((materia) {
                  return DropdownMenuItem(
                    value: materia.nmat.toString(),
                    child: Text(materia.descripcion,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMateria = value;
                  });
                },
              ),
              TextField(
                controller: _horaController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Hora',
                  suffixIcon: Icon(Icons.access_time_outlined),
                ),
                onTap: () {
                  _seleccionarHora(context);
                },
              ),
              TextField(
                controller: _edificioController,
                decoration: InputDecoration(labelText: 'Edificio'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _salonController,
                decoration: InputDecoration(labelText: 'Salón'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
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
            onPressed: () => _updateHorario(horario),
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _addHorario() async {
    if (_selectedProfesor == null || _selectedMateria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione profesor y materia')),
      );
      return;
    }

    final horario = Horario(
      inprofesor: _selectedProfesor!,
      invat: _selectedMateria!,
      hora: _horaController.text,
      edificio: _edificioController.text,
      salon: _salonController.text,
    );

    await _databaseHelper.insertHorario(horario);
    _loadHorarios();
    Navigator.pop(context);
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Horario agregado exitosamente')),
    );
  }

  void _updateHorario(Horario horario) async {
    if (_selectedProfesor == null || _selectedMateria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor seleccione profesor y materia')),
      );
      return;
    }

    final updatedHorario = Horario(
      nhorario: horario.nhorario,
      inprofesor: _selectedProfesor!,
      invat: _selectedMateria!,
      hora: _horaController.text,
      edificio: _edificioController.text,
      salon: _salonController.text,
    );

    await _databaseHelper.updateHorario(updatedHorario);
    _loadHorarios();
    Navigator.pop(context);
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Horario actualizado exitosamente')),
    );
  }

  void _deleteHorario(int nhorario) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Está seguro de que desea eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _databaseHelper.deleteHorario(nhorario);
              _loadHorarios();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Horario eliminado exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _horaController.clear();
    _edificioController.clear();
    _salonController.clear();
    _selectedProfesor = null;
    _selectedMateria = null;
  }

  String _getProfesorNombre(String nprofesor) {
    final profesor = _profesores.firstWhere(
          (p) => p.nprofesor == nprofesor,
      orElse: () => Profesor(nprofesor: '', nombre: 'No encontrado', carrera: ''),
    );
    return profesor.nombre;
  }

  String _getMateriaDescripcion(String nmat) {
    final materia = _materias.firstWhere(
          (m) => m.nmat.toString() == nmat,
      orElse: () => Materia(descripcion: 'No encontrada'),
    );
    return materia.descripcion;
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
                  'Gestión de Horarios',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 30),
                  onPressed: _showAddHorarioDialog,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _horarios.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay horarios registrados',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Presione el botón + para agregar un horario',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _horarios.length,
                itemBuilder: (context, index) => Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.schedule, color: Colors.blue[800]),
                    ),
                    title: Text(
                      'Hora: ${_horarios[index].hora}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Profesor: ${_getProfesorNombre(_horarios[index].inprofesor)}'),
                        Text('Materia: ${_getMateriaDescripcion(_horarios[index].invat)}'),
                        Text('Edificio: ${_horarios[index].edificio} - Salon: ${_horarios[index].salon}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditHorarioDialog(_horarios[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteHorario(_horarios[index].nhorario!),
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
    _horaController.dispose();
    _edificioController.dispose();
    _salonController.dispose();
    super.dispose();
  }
}