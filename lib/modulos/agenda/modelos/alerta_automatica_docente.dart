class AlertaAutomaticaDocente {
  final String clave;
  final String tipo;
  final String severidad;
  final String mensaje;
  final int? cursoId;
  final int? alumnoId;
  final String? institucion;
  final String? materia;
  final String? etiquetaCurso;

  const AlertaAutomaticaDocente({
    required this.clave,
    required this.tipo,
    required this.severidad,
    required this.mensaje,
    required this.cursoId,
    required this.alumnoId,
    required this.institucion,
    required this.materia,
    required this.etiquetaCurso,
  });
}
