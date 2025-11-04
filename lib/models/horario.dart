class Horario {
  int? nhorario;
  String inprofesor;
  String invat;
  String hora;
  String edificio;
  String salon;

  Horario({
    this.nhorario,
    required this.inprofesor,
    required this.invat,
    required this.hora,
    required this.edificio,
    required this.salon,
  });

  Map<String, dynamic> toMap() {
    return {
      'nhorario': nhorario,
      'inprofesor': inprofesor,
      'invat': invat,
      'hora': hora,
      'edificio': edificio,
      'salon': salon,
    };
  }

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      nhorario: map['nhorario'],
      inprofesor: map['inprofesor'],
      invat: map['invat'],
      hora: map['hora'],
      edificio: map['edificio'],
      salon: map['salon'],
    );
  }
}