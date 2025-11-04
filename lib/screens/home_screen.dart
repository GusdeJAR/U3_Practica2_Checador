import 'package:flutter/material.dart';
import 'profesores_screen.dart';
import 'materias_screen.dart';
import 'horarios_screen.dart';
import 'asistencia_screen.dart';
import 'consultas_screen.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/bottom_nav_bar.dart';
import '../database/database_helper.dart';
import '../models/profesor.dart';
import '../models/materia.dart';
import '../models/horario.dart';
import '../models/asistencia.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Datos para el dashboard
  int _totalProfesores = 0;
  int _totalMaterias = 0;
  int _asistenciasHoy = 0;
  int _faltasHoy = 0;
  List<Map<String, dynamic>> _proximasClases = [];
  List<Map<String, dynamic>> _clasesDeHoy = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await _loadTotales();
    await _loadAsistenciasHoy();
    await _loadProximasClases();
    await _loadClasesDeHoy();
  }

  Future<void> _loadTotales() async {
    final profesores = await _databaseHelper.getProfesores();
    final materias = await _databaseHelper.getMaterias();

    setState(() {
      _totalProfesores = profesores.length;
      _totalMaterias = materias.length;
    });
  }

  Future<void> _loadAsistenciasHoy() async {
    final hoy = _getCurrentDate();
    final asistencias = await _databaseHelper.getAsistencias();

    final asistenciasHoy = asistencias.where((a) => a.fecha == hoy && a.asistencia).length;
    final faltasHoy = asistencias.where((a) => a.fecha == hoy && !a.asistencia).length;

    setState(() {
      _asistenciasHoy = asistenciasHoy;
      _faltasHoy = faltasHoy;
    });
  }

  Future<void> _loadProximasClases() async {
    final horarios = await _databaseHelper.getHorarios();
    final profesores = await _databaseHelper.getProfesores();
    final materias = await _databaseHelper.getMaterias();

    List<Map<String, dynamic>> proximas = [];

    for (var horario in horarios.take(5)) {
      final profesor = profesores.firstWhere(
            (p) => p.nprofesor == horario.inprofesor,
        orElse: () => Profesor(nprofesor: '', nombre: 'Profesor', carrera: ''),
      );

      final materia = materias.firstWhere(
            (m) => m.nmat.toString() == horario.invat,
        orElse: () => Materia(descripcion: 'Materia'),
      );

      proximas.add({
        'materia': materia.descripcion,
        'profesor': profesor.nombre,
        'hora': horario.hora,
        'edificio': horario.edificio,
        'salon': horario.salon,
        'tiempoRestante': 'En ${_generarTiempoRandom()} min',
      });
    }

    setState(() {
      _proximasClases = proximas;
    });
  }

  Future<void> _loadClasesDeHoy() async {
    final hoy = _getCurrentDate();
    final asistencias = await _databaseHelper.getAsistencias();
    final horarios = await _databaseHelper.getHorarios();
    final profesores = await _databaseHelper.getProfesores();
    final materias = await _databaseHelper.getMaterias();

    List<Map<String, dynamic>> clasesHoy = [];

    final asistenciasHoy = asistencias.where((a) => a.fecha == hoy);

    for (var asistencia in asistenciasHoy) {
      final horario = horarios.firstWhere(
            (h) => h.nhorario == asistencia.nhorario,
        orElse: () => Horario(
          inprofesor: '',
          invat: '',
          hora: '',
          edificio: '',
          salon: '',
        ),
      );

      final profesor = profesores.firstWhere(
            (p) => p.nprofesor == horario.inprofesor,
        orElse: () => Profesor(nprofesor: '', nombre: 'Profesor', carrera: ''),
      );

      final materia = materias.firstWhere(
            (m) => m.nmat.toString() == horario.invat,
        orElse: () => Materia(descripcion: 'Materia'),
      );

      clasesHoy.add({
        'materia': materia.descripcion,
        'profesor': profesor.nombre,
        'hora': horario.hora,
        'edificio': horario.edificio,
        'asistio': asistencia.asistencia,
      });
    }

    setState(() {
      _clasesDeHoy = clasesHoy;
    });
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int _generarTiempoRandom() {
    return 15 + (DateTime.now().millisecondsSinceEpoch % 45);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema de Asistencia'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: CustomDrawer(
        onSelectItem: (index) {
          Navigator.pop(context);

          if (index == 5) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ConsultasScreen()),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 4
          ? FloatingActionButton(
        onPressed: () {
          _showAsistenciaBottomSheet(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      )
          : null,
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return ProfesoresScreen();
      case 2:
        return MateriasScreen();
      case 3:
        return HorariosScreen();
      case 4:
        return AsistenciaScreen();
      case 5:
        return ConsultasScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return DashboardContent(
      totalProfesores: _totalProfesores,
      totalMaterias: _totalMaterias,
      asistenciasHoy: _asistenciasHoy,
      faltasHoy: _faltasHoy,
      proximasClases: _proximasClases,
      clasesDeHoy: _clasesDeHoy,
      onRefresh: _loadDashboardData,
    );
  }

  void _showAsistenciaBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Registrar Asistencia - Hoy (${_getCurrentDate()})',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _clasesDeHoy.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No hay clases programadas para hoy',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _clasesDeHoy.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _clasesDeHoy[index]['asistio'] == true
                          ? Colors.green
                          : _clasesDeHoy[index]['asistio'] == false
                          ? Colors.red
                          : Colors.grey,
                      child: Icon(
                        _clasesDeHoy[index]['asistio'] == true
                            ? Icons.check
                            : _clasesDeHoy[index]['asistio'] == false
                            ? Icons.close
                            : Icons.question_mark,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(_clasesDeHoy[index]['materia'] ?? 'Materia'),
                    subtitle: Text('${_clasesDeHoy[index]['profesor'] ?? 'Profesor'} - ${_clasesDeHoy[index]['hora'] ?? 'Hora'}'),
                    trailing: _clasesDeHoy[index]['asistio'] == null
                        ? ElevatedButton(
                      onPressed: () {
                        // Lógica para registrar asistencia
                      },
                      child: Text('Registrar'),
                    )
                        : Text(
                      _clasesDeHoy[index]['asistio'] == true ? 'Presente' : 'Ausente',
                      style: TextStyle(
                        color: _clasesDeHoy[index]['asistio'] == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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
}

class DashboardContent extends StatelessWidget {
  final int totalProfesores;
  final int totalMaterias;
  final int asistenciasHoy;
  final int faltasHoy;
  final List<Map<String, dynamic>> proximasClases;
  final List<Map<String, dynamic>> clasesDeHoy;
  final VoidCallback onRefresh;

  const DashboardContent({
    Key? key,
    required this.totalProfesores,
    required this.totalMaterias,
    required this.asistenciasHoy,
    required this.faltasHoy,
    required this.proximasClases,
    required this.clasesDeHoy,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Tarjetas de estadísticas (2x2 grid)
            _buildStatsGrid(),
            SizedBox(height: 20),

            // Resumen del día
            _buildResumenHoy(),
            SizedBox(height: 20),

            // Próximas clases
            _buildNextClasses(),
            SizedBox(height: 20), // Espacio extra al final
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        // Primera fila
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Total Profesores', totalProfesores.toString(), Icons.people, Colors.blue),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildStatCard('Asistencias Hoy', asistenciasHoy.toString(), Icons.check_circle, Colors.green),
            ),
          ],
        ),
        SizedBox(height: 10),
        // Segunda fila
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Materias', totalMaterias.toString(), Icons.book, Colors.orange),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildStatCard('Faltas Hoy', faltasHoy.toString(), Icons.cancel, Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenHoy() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Colors.blue),
                SizedBox(width: 8),
                Text('Resumen del Día', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            if (clasesDeHoy.isEmpty)
              _buildEmptyState('No hay clases hoy', Icons.event_busy)
            else
              Column(
                children: clasesDeHoy.take(3).map((clase) => _buildClaseItem(clase)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextClasses() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                SizedBox(width: 8),
                Text('Próximas Clases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            if (proximasClases.isEmpty)
              _buildEmptyState('No hay próximas clases', Icons.schedule)
            else
              Column(
                children: proximasClases.map((clase) => _buildProximaClaseItem(clase)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClaseItem(Map<String, dynamic> clase) {
    final bool? asistio = clase['asistio'];

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: asistio == true
                ? Colors.green
                : asistio == false
                ? Colors.red
                : Colors.grey,
            child: Icon(
              asistio == true
                  ? Icons.check
                  : asistio == false
                  ? Icons.close
                  : Icons.schedule,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clase['materia'] ?? 'Materia',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${clase['profesor'] ?? 'Profesor'} • ${clase['hora'] ?? 'Hora'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            asistio == true
                ? 'Presente'
                : asistio == false
                ? 'Ausente'
                : 'Pendiente',
            style: TextStyle(
              color: asistio == true
                  ? Colors.green
                  : asistio == false
                  ? Colors.red
                  : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximaClaseItem(Map<String, dynamic> clase) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue[100],
            child: Icon(Icons.school, color: Colors.blue[800], size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clase['materia'] ?? 'Materia',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${clase['profesor'] ?? 'Profesor'} • ${clase['hora'] ?? 'Hora'} • ${clase['edificio'] ?? 'Edificio'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              clase['tiempoRestante'] ?? 'Próxima',
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}