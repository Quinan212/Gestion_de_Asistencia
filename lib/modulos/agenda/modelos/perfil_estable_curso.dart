class PerfilEstableCurso {
  final int cursoId;
  final String ritmo;
  final String clima;
  final String estrategiasFuncionan;
  final String dificultadesFrecuentes;
  final String autonomia;
  final double asistenciaHistorica;
  final int alumnosRiesgoAlto;
  final int alumnosRiesgoMedio;
  final int alumnosRiesgoBajo;
  final int inasistenciasReiteradas;
  final DateTime? actualizadoEn;

  const PerfilEstableCurso({
    required this.cursoId,
    required this.ritmo,
    required this.clima,
    required this.estrategiasFuncionan,
    required this.dificultadesFrecuentes,
    required this.autonomia,
    required this.asistenciaHistorica,
    required this.alumnosRiesgoAlto,
    required this.alumnosRiesgoMedio,
    required this.alumnosRiesgoBajo,
    required this.inasistenciasReiteradas,
    required this.actualizadoEn,
  });
}
