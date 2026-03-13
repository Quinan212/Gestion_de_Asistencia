class AlumnoOrganizado {
  final int alumnoId;
  final int? cursoId;
  final String apellido;
  final String nombre;
  final int? edad;
  final String notaManual;
  final String institucion;
  final String carrera;
  final String materia;
  final int anioCursada;
  final String curso;
  final int anioLectivo;
  final int ordenIngreso;

  const AlumnoOrganizado({
    required this.alumnoId,
    required this.cursoId,
    required this.apellido,
    required this.nombre,
    required this.edad,
    required this.notaManual,
    required this.institucion,
    required this.carrera,
    required this.materia,
    required this.anioCursada,
    required this.curso,
    required this.anioLectivo,
    required this.ordenIngreso,
  });

  String get nombreCompleto => '$apellido, $nombre';

  String get etiquetaCurso {
    final c = curso.trim();
    if (anioCursada > 0 && c.isNotEmpty && c.toLowerCase() != 'sin curso') {
      return '$anioCursada° $c';
    }
    if (anioCursada > 0) return '$anioCursada°';
    if (c.isNotEmpty) return c;
    return 'Sin curso';
  }

  String get etiquetaAnioLectivo =>
      anioLectivo > 0 ? anioLectivo.toString() : 'Sin a\u00f1o lectivo';
}
