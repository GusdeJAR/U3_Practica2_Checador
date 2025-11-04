class Materia {
  int? nmat;
  String descripcion;

  Materia({
    this.nmat,
    required this.descripcion,
  });

  Map<String, dynamic> toMap() {
    return {
      'nmat': nmat,
      'descripcion': descripcion,
    };
  }

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      nmat: map['nmat'],
      descripcion: map['descripcion'],
    );
  }
}