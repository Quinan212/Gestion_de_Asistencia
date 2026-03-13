class EventoCronologicoAlumno {
  final DateTime fecha;
  final String tipo;
  final String titulo;
  final String detalle;
  final String prioridad;
  final int? cursoId;
  final int? alumnoId;
  final int? claseId;
  final int? evaluacionId;
  final int? evaluacionInstanciaId;

  const EventoCronologicoAlumno({
    required this.fecha,
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.prioridad,
    required this.cursoId,
    required this.alumnoId,
    required this.claseId,
    required this.evaluacionId,
    required this.evaluacionInstanciaId,
  });
}
