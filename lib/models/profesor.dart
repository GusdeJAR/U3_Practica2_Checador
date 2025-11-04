class Profesor {
  String nprofesor;
  String nombre;
  String carrera;

  Profesor({
    required this.nprofesor,
    required this.nombre,
    required this.carrera,
  });

  Map<String, dynamic> toMap() {
    return {
      'nprofesor': nprofesor,
      'nombre': nombre,
      'carrera': carrera,
    };
  }

  factory Profesor.fromMap(Map<String, dynamic> map) {
    return Profesor(
      nprofesor: map['nprofesor'],
      nombre: map['nombre'],
      carrera: map['carrera'],
    );
  }
}