class RubricaSimple {
  final int id;
  final String? institucion;
  final int? cursoId;
  final String tipo;
  final String titulo;
  final String criterios;
  final int orden;
  final int usoCount;
  final DateTime actualizadoEn;

  const RubricaSimple({
    required this.id,
    required this.institucion,
    required this.cursoId,
    required this.tipo,
    required this.titulo,
    required this.criterios,
    required this.orden,
    required this.usoCount,
    required this.actualizadoEn,
  });
}
