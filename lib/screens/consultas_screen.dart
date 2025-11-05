import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class ConsultasScreen extends StatefulWidget {
  @override
  _ConsultasScreenState createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends State<ConsultasScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> _resultados = [];
  final TextEditingController _horaController = TextEditingController(text: '08:00');
  final TextEditingController _edificioController = TextEditingController(text: 'UD');
  final TextEditingController _fechaController = TextEditingController(text: '2024-02-08');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Consultas Avanzadas'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Por Hora/Edificio'),
              Tab(text: 'Asistencia por Fecha'),
              Tab(text: 'Resumen Asistencia'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildConsulta1(),
            _buildConsulta2(),
            _buildConsulta3(),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    TimeOfDay horaInicial = TimeOfDay.now();
    if (_horaController.text.isNotEmpty) {
      try {
        final parts = _horaController.text.split(':');
        if (parts.length == 2) {
          horaInicial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } catch (e) {
      }
    }

    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horaSeleccionada != null) {
      final String horaFormateada =
          '${horaSeleccionada.hour.toString().padLeft(2, '0')}:${horaSeleccionada.minute.toString().padLeft(2, '0')}';

      setState(() {
        _horaController.text = horaFormateada;
      });
    }
  }

  Widget _buildConsulta1() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _horaController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    hintText: 'Seleccione una hora',
                    suffixIcon: Icon(Icons.access_time_outlined),
                  ),
                  onTap: () {
                    _seleccionarHora(context);
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _edificioController,
                  decoration: InputDecoration(labelText: 'Edificio'),
                  keyboardType: TextInputType.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_horaController.text.isEmpty || _edificioController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, complete ambos campos para buscar.')),
                );
                return;
              }
              final resultados = await _databaseHelper.getProfesoresPorHoraEdificio(
                _horaController.text,
                _edificioController.text,
              );
              setState(() {
                _resultados = resultados;
              });
            },
            child: Text('Buscar Profesores'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildResultadosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsulta2() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _fechaController,
            decoration: InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_fechaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Por favor, complete el campo para buscar.')),
                );
                return;
              }
              final resultados = await _databaseHelper.getAsistenciaPorFecha(_fechaController.text);
              setState(() {
                _resultados = resultados;
              });
            },
            child: Text('Buscar Asistencias'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildResultadosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsulta3() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final resultados = await _databaseHelper.getResumenAsistencia('2025-01-01', '2025-12-31');
              setState(() {
                _resultados = resultados;
              });
            },
            child: Text('Generar Resumen Anual'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: _buildResultadosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadosList() {
    if (_resultados.isEmpty) {
      return Center(child: Text('No hay resultados'));
    }

    return ListView.builder(
      itemCount: _resultados.length,
      itemBuilder: (context, index) {
        final item = _resultados[index];
        return Card(
          child: ListTile(
            title: Text(item['nombre'] ?? 'Sin nombre'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.entries.map((entry) {
                if (entry.key != 'nombre') {
                  return Text('${entry.key}: ${entry.value}');
                }
                return SizedBox();
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}