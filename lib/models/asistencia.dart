class Asistencia {
  int? idasistencia;
  int nhorario;
  String fecha;
  bool asistencia;

  Asistencia({
    this.idasistencia,
    required this.nhorario,
    required this.fecha,
    required this.asistencia,
  });

  Map<String, dynamic> toMap() {
    return {
      'idasistencia': idasistencia,
      'nhorario': nhorario,
      'fecha': fecha,
      'asistencia': asistencia ? 1 : 0,
    };
  }

  factory Asistencia.fromMap(Map<String, dynamic> map) {
    return Asistencia(
      idasistencia: map['idasistencia'],
      nhorario: map['nhorario'],
      fecha: map['fecha'],
      asistencia: map['asistencia'] == 1,
    );
  }
}