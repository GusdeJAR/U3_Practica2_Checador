import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/materia.dart';
import '../models/profesor.dart';
import '../models/horario.dart';
import '../models/asistencia.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'asistencia.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla MATERIA
    await db.execute('''
      CREATE TABLE materia(
        nmat INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT NOT NULL
      )
    ''');

    // Tabla PROFESOR
    await db.execute('''
      CREATE TABLE profesor(
        nprofesor TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        carrera TEXT NOT NULL
      )
    ''');

    // Tabla HORARIO
    await db.execute('''
      CREATE TABLE horario(
        nhorario INTEGER PRIMARY KEY AUTOINCREMENT,
        inprofesor TEXT,
        invat TEXT,
        hora TEXT NOT NULL,
        edificio TEXT NOT NULL,
        salon TEXT NOT NULL,
        FOREIGN KEY (inprofesor) REFERENCES profesor(nprofesor),
        FOREIGN KEY (invat) REFERENCES materia(nmat)
      )
    ''');

    // Tabla ASISTENCIA
    await db.execute('''
      CREATE TABLE asistencia(
        idasistencia INTEGER PRIMARY KEY AUTOINCREMENT,
        nhorario INTEGER,
        fecha TEXT NOT NULL,
        asistencia BOOLEAN NOT NULL,
        FOREIGN KEY (nhorario) REFERENCES horario(nhorario)
      )
    ''');
  }

  // CRUD para MATERIA
  Future<int> insertMateria(Materia materia) async {
    final db = await database;
    return await db.insert('materia', materia.toMap());
  }

  Future<List<Materia>> getMaterias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('materia');
    return List.generate(maps.length, (i) => Materia.fromMap(maps[i]));
  }

  Future<int> updateMateria(Materia materia) async {
    final db = await database;
    return await db.update(
      'materia',
      materia.toMap(),
      where: 'nmat = ?',
      whereArgs: [materia.nmat],
    );
  }

  Future<int> deleteMateria(int nmat) async {
    final db = await database;
    return await db.delete(
      'materia',
      where: 'nmat = ?',
      whereArgs: [nmat],
    );
  }

  // CRUD para PROFESOR
  Future<int> insertProfesor(Profesor profesor) async {
    final db = await database;
    return await db.insert('profesor', profesor.toMap());
  }

  Future<List<Profesor>> getProfesores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('profesor');
    return List.generate(maps.length, (i) => Profesor.fromMap(maps[i]));
  }

  Future<Profesor?> getUltimoProfesor() async {
    final db = await database;
    // Hacemos una consulta para obtener todos los profesores,
    // los ordenamos por 'nprofesor' de forma descendente (los más altos primero)
    // y tomamos solo el primer resultado (LIMIT 1).
    final List<Map<String, dynamic>> maps = await db.query(
      'profesor',
      orderBy: 'CAST(nprofesor AS INTEGER) DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Profesor.fromMap(maps.first);
    }
    // Si no hay ningún profesor, devuelve null.
    return null;
  }

  Future<int> updateProfesor(Profesor profesor) async {
    final db = await database;
    return await db.update(
      'profesor',
      profesor.toMap(),
      where: 'nprofesor = ?',
      whereArgs: [profesor.nprofesor],
    );
  }

  Future<int> deleteProfesor(String nprofesor) async {
    final db = await database;
    return await db.delete(
      'profesor',
      where: 'nprofesor = ?',
      whereArgs: [nprofesor],
    );
  }

  // CRUD para HORARIO
  Future<int> insertHorario(Horario horario) async {
    final db = await database;
    return await db.insert('horario', horario.toMap());
  }

  Future<List<Horario>> getHorarios() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('horario');
    return List.generate(maps.length, (i) => Horario.fromMap(maps[i]));
  }

  Future<int> updateHorario(Horario horario) async {
    final db = await database;
    return await db.update(
      'horario',
      horario.toMap(),
      where: 'nhorario = ?',
      whereArgs: [horario.nhorario],
    );
  }

  Future<int> deleteHorario(int nhorario) async {
    final db = await database;
    return await db.delete(
      'horario',
      where: 'nhorario = ?',
      whereArgs: [nhorario],
    );
  }

  // CRUD para ASISTENCIA
  Future<int> insertAsistencia(Asistencia asistencia) async {
    final db = await database;
    return await db.insert('asistencia', asistencia.toMap());
  }

  Future<List<Asistencia>> getAsistencias() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('asistencia');
    return List.generate(maps.length, (i) => Asistencia.fromMap(maps[i]));
  }

  Future<int> updateAsistencia(Asistencia asistencia) async {
    final db = await database;
    return await db.update(
      'asistencia',
      asistencia.toMap(),
      where: 'idasistencia = ?',
      whereArgs: [asistencia.idasistencia],
    );
  }

  Future<int> deleteAsistencia(int idasistencia) async {
    final db = await database;
    return await db.delete(
      'asistencia',
      where: 'idasistencia = ?',
      whereArgs: [idasistencia],
    );
  }

  // CONSULTAS AVANZADAS
  // 1. Profesores con clase a cierta hora en edificio específico
  Future<List<Map<String, dynamic>>> getProfesoresPorHoraEdificio(String hora, String edificio) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.nombre, p.carrera, h.hora, h.edificio, h.salon, m.descripcion as materia
      FROM profesor p
      INNER JOIN horario h ON p.nprofesor = h.inprofesor
      INNER JOIN materia m ON h.invat = m.nmat
      WHERE h.hora = ? AND h.edificio = ?
    ''', [hora, edificio]);
  }

  // 2. Profesores que asistieron en fecha específica
  Future<List<Map<String, dynamic>>> getAsistenciaPorFecha(String fecha) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.nombre, p.carrera, h.hora, h.edificio, h.salon, m.descripcion as materia
      FROM profesor p
      INNER JOIN horario h ON p.nprofesor = h.inprofesor
      INNER JOIN materia m ON h.invat = m.nmat
      INNER JOIN asistencia a ON h.nhorario = a.nhorario
      WHERE a.fecha = ? AND a.asistencia = 1
    ''', [fecha]);
  }

  // 3. Resumen de asistencia por profesor en rango de fechas
  Future<List<Map<String, dynamic>>> getResumenAsistencia(String fechaInicio, String fechaFin) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        p.nombre,
        COUNT(a.idasistencia) as total_clases,
        SUM(CASE WHEN a.asistencia = 1 THEN 1 ELSE 0 END) as asistencias,
        ROUND(SUM(CASE WHEN a.asistencia = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(a.idasistencia), 2) as porcentaje
      FROM profesor p
      INNER JOIN horario h ON p.nprofesor = h.inprofesor
      INNER JOIN asistencia a ON h.nhorario = a.nhorario
      WHERE a.fecha BETWEEN ? AND ?
      GROUP BY p.nprofesor, p.nombre
    ''', [fechaInicio, fechaFin]);
  }
}