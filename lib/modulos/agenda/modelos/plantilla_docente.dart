class PlantillaDocente {
  final int id;
  final String? institucion;
  final int? cursoId;
  final String tipo;
  final String titulo;
  final String contenido;
  final String? atajo;
  final int orden;
  final int usoCount;
  final DateTime actualizadoEn;

  const PlantillaDocente({
    required this.id,
    required this.institucion,
    required this.cursoId,
    required this.tipo,
    required this.titulo,
    required this.contenido,
    required this.atajo,
    required this.orden,
    required this.usoCount,
    required this.actualizadoEn,
  });

  String get alcance {
    if (cursoId != null) return 'curso';
    if ((institucion ?? '').trim().isNotEmpty) return 'institucion';
    return 'general';
  }
}
