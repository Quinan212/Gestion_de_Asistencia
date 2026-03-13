class MateriaInstitucion {
  final int id;
  final int carreraId;
  final String nombre;
  final int anioCursada;
  final String curso;
  final bool activo;

  const MateriaInstitucion({
    required this.id,
    required this.carreraId,
    required this.nombre,
    required this.anioCursada,
    required this.curso,
    required this.activo,
  });

  String get etiquetaCurso => '$anioCursada\u00b0';
}
