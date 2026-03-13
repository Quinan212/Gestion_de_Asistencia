class SintesisPeriodoAlumno {
  final int cursoId;
  final int alumnoId;
  final String alumnoNombre;
  final DateTime desde;
  final DateTime hasta;
  final double asistenciaPorcentaje;
  final int clasesConRegistro;
  final int faltas;
  final int trabajosPendientes;
  final int trabajosSinCorregir;
  final int evaluacionesRendidas;
  final int recuperatoriosRendidos;
  final int aprobadas;
  final int noAprobadas;
  final int pendientes;
  final int ausentes;
  final double? promedioNumerico;
  final int alertasActivas;
  final String nivelRiesgo;
  final String condicionCierre;

  const SintesisPeriodoAlumno({
    required this.cursoId,
    required this.alumnoId,
    required this.alumnoNombre,
    required this.desde,
    required this.hasta,
    required this.asistenciaPorcentaje,
    required this.clasesConRegistro,
    required this.faltas,
    required this.trabajosPendientes,
    required this.trabajosSinCorregir,
    required this.evaluacionesRendidas,
    required this.recuperatoriosRendidos,
    required this.aprobadas,
    required this.noAprobadas,
    required this.pendientes,
    required this.ausentes,
    required this.promedioNumerico,
    required this.alertasActivas,
    required this.nivelRiesgo,
    required this.condicionCierre,
  });
}

class SintesisPeriodoCurso {
  final int cursoId;
  final String institucion;
  final String materia;
  final String etiquetaCurso;
  final DateTime desde;
  final DateTime hasta;
  final int clasesDictadas;
  final double asistenciaPorcentaje;
  final int entregasPendientes;
  final int trabajosSinCorregir;
  final int evaluacionesAbiertas;
  final int evaluacionesRendidas;
  final int recuperatoriosTomados;
  final int alumnosRiesgoAlto;
  final int alumnosRiesgoMedio;
  final int alumnosRiesgoBajo;
  final int alertasActivas;
  final int contenidosPendientes;
  final int contenidosTrabajados;
  final int bitacoraCompletada;
  final int bitacoraParcial;
  final int bitacoraReprogramada;

  const SintesisPeriodoCurso({
    required this.cursoId,
    required this.institucion,
    required this.materia,
    required this.etiquetaCurso,
    required this.desde,
    required this.hasta,
    required this.clasesDictadas,
    required this.asistenciaPorcentaje,
    required this.entregasPendientes,
    required this.trabajosSinCorregir,
    required this.evaluacionesAbiertas,
    required this.evaluacionesRendidas,
    required this.recuperatoriosTomados,
    required this.alumnosRiesgoAlto,
    required this.alumnosRiesgoMedio,
    required this.alumnosRiesgoBajo,
    required this.alertasActivas,
    required this.contenidosPendientes,
    required this.contenidosTrabajados,
    required this.bitacoraCompletada,
    required this.bitacoraParcial,
    required this.bitacoraReprogramada,
  });
}
