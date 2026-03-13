class IntervencionDocente {
  final int id;
  final int? cursoId;
  final int? alumnoId;
  final DateTime fecha;
  final String tipo;
  final String descripcion;
  final String? seguimiento;
  final bool resuelta;
  final String? alumnoNombre;

  const IntervencionDocente({
    required this.id,
    required this.cursoId,
    required this.alumnoId,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.seguimiento,
    required this.resuelta,
    required this.alumnoNombre,
  });
}
