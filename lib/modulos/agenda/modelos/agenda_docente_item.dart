class AgendaDocenteItem {
  final int cursoId;
  final String institucion;
  final String carrera;
  final String materia;
  final String etiquetaCurso;
  final List<String> bloquesHorarios;
  final String? horaReferenciaOrden;
  final bool tieneClaseHoy;
  final int? claseHoyId;
  final int registrosHoy;
  final DateTime? ultimaClaseFecha;
  final String? temaClasePasada;
  final String continuarHoy;
  final int alumnosPendientes;
  final int actividadesSinEntregar;
  final int trabajosSinCorregir;
  final DateTime? proximaEvaluacionFecha;
  final String? proximaEvaluacion;

  const AgendaDocenteItem({
    required this.cursoId,
    required this.institucion,
    required this.carrera,
    required this.materia,
    required this.etiquetaCurso,
    required this.bloquesHorarios,
    required this.horaReferenciaOrden,
    required this.tieneClaseHoy,
    required this.claseHoyId,
    required this.registrosHoy,
    required this.ultimaClaseFecha,
    required this.temaClasePasada,
    required this.continuarHoy,
    required this.alumnosPendientes,
    required this.actividadesSinEntregar,
    required this.trabajosSinCorregir,
    required this.proximaEvaluacionFecha,
    required this.proximaEvaluacion,
  });

  bool get asistenciaInicializada => tieneClaseHoy && registrosHoy > 0;
}
