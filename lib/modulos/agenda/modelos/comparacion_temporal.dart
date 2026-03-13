import 'sintesis_periodo.dart';

class ComparacionTemporalCurso {
  final SintesisPeriodoCurso actual;
  final SintesisPeriodoCurso anterior;

  const ComparacionTemporalCurso({
    required this.actual,
    required this.anterior,
  });

  double get deltaAsistencia =>
      actual.asistenciaPorcentaje - anterior.asistenciaPorcentaje;
  int get deltaEntregasPendientes =>
      actual.entregasPendientes - anterior.entregasPendientes;
  int get deltaEvaluacionesAbiertas =>
      actual.evaluacionesAbiertas - anterior.evaluacionesAbiertas;
  int get deltaAlertas => actual.alertasActivas - anterior.alertasActivas;
  int get deltaRiesgoAlto =>
      actual.alumnosRiesgoAlto - anterior.alumnosRiesgoAlto;
  int get deltaContenidosPendientes =>
      actual.contenidosPendientes - anterior.contenidosPendientes;
  int get deltaBitacoraReprogramada =>
      actual.bitacoraReprogramada - anterior.bitacoraReprogramada;
}

class ComparacionTemporalAlumno {
  final SintesisPeriodoAlumno actual;
  final SintesisPeriodoAlumno anterior;

  const ComparacionTemporalAlumno({
    required this.actual,
    required this.anterior,
  });

  double get deltaAsistencia =>
      actual.asistenciaPorcentaje - anterior.asistenciaPorcentaje;
  int get deltaFaltas => actual.faltas - anterior.faltas;
  int get deltaTrabajosPendientes =>
      actual.trabajosPendientes - anterior.trabajosPendientes;
  int get deltaNoAprobadas => actual.noAprobadas - anterior.noAprobadas;
  int get deltaPendientes => actual.pendientes - anterior.pendientes;
  int get deltaAlertas => actual.alertasActivas - anterior.alertasActivas;
  int get deltaRecuperatorios =>
      actual.recuperatoriosRendidos - anterior.recuperatoriosRendidos;
  double? get deltaPromedio {
    final a = actual.promedioNumerico;
    final b = anterior.promedioNumerico;
    if (a == null || b == null) return null;
    return a - b;
  }
}
