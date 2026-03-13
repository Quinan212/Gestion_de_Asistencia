class EvaluacionCurso {
  final int id;
  final int cursoId;
  final DateTime fecha;
  final String tipo;
  final String titulo;
  final String? descripcion;
  final String estado;
  final int totalAlumnos;
  final int resultadosCargados;
  final int aprobados;
  final int enProceso;
  final int recuperacion;
  final int pendientes;
  final int instancias;
  final int recuperatoriosGenerados;
  final int aprobadosPrimeraInstancia;
  final int fueronARecuperatorio;
  final int aprobaronLuegoRecuperatorio;
  final int ausentesFinales;
  final int noAprobadosFinales;

  const EvaluacionCurso({
    required this.id,
    required this.cursoId,
    required this.fecha,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.estado,
    required this.totalAlumnos,
    required this.resultadosCargados,
    required this.aprobados,
    required this.enProceso,
    required this.recuperacion,
    required this.pendientes,
    this.instancias = 1,
    this.recuperatoriosGenerados = 0,
    this.aprobadosPrimeraInstancia = 0,
    this.fueronARecuperatorio = 0,
    this.aprobaronLuegoRecuperatorio = 0,
    this.ausentesFinales = 0,
    this.noAprobadosFinales = 0,
  });

  bool get cerrada => estado.trim().toLowerCase() == 'cerrada';

  double get avanceCarga {
    if (totalAlumnos <= 0) return 0;
    return resultadosCargados / totalAlumnos;
  }
}
