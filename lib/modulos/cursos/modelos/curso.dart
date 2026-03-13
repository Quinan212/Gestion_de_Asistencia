class Curso {
  final int id;
  final int? institucionId;
  final int? carreraId;
  final int? materiaId;
  final String institucion;
  final String carrera;
  final String nombre;
  final String division;
  final String materia;
  final int anio;
  final int anioCursada;
  final String curso;
  final bool activo;

  const Curso({
    required this.id,
    required this.institucionId,
    required this.carreraId,
    required this.materiaId,
    required this.institucion,
    required this.carrera,
    required this.nombre,
    required this.division,
    required this.materia,
    required this.anio,
    required this.anioCursada,
    required this.curso,
    required this.activo,
  });

  String get etiqueta => '$materia - $anioCursada\u00b0 $curso';
}
