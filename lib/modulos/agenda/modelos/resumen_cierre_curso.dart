class ResumenCierreCurso {
  final DateTime desde;
  final DateTime hasta;
  final int clasesDictadas;
  final int registrosAsistencia;
  final int presentes;
  final int ausentes;
  final int tardes;
  final int justificadas;
  final int actividadesSinEntregar;
  final int trabajosSinCorregir;
  final int alumnosEnRiesgo;
  final int contenidosIniciados;
  final int contenidosEnDesarrollo;
  final int contenidosTrabajados;
  final int contenidosEvaluados;
  final int contenidosPendientes;

  const ResumenCierreCurso({
    required this.desde,
    required this.hasta,
    required this.clasesDictadas,
    required this.registrosAsistencia,
    required this.presentes,
    required this.ausentes,
    required this.tardes,
    required this.justificadas,
    required this.actividadesSinEntregar,
    required this.trabajosSinCorregir,
    required this.alumnosEnRiesgo,
    required this.contenidosIniciados,
    required this.contenidosEnDesarrollo,
    required this.contenidosTrabajados,
    required this.contenidosEvaluados,
    required this.contenidosPendientes,
  });

  double get porcentajeAsistencia {
    if (registrosAsistencia <= 0) return 0;
    final computables = presentes + tardes + justificadas;
    return (computables / registrosAsistencia) * 100;
  }

  String generarTexto(String cursoEtiqueta) {
    String d(DateTime f) =>
        '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

    return '''
Cierre de periodo - $cursoEtiqueta
Rango: ${d(desde)} al ${d(hasta)}

Clases dictadas: $clasesDictadas
Asistencia: ${porcentajeAsistencia.toStringAsFixed(1)}% ($presentes presentes, $tardes tarde, $justificadas justificadas, $ausentes ausentes)

Actividades sin entregar: $actividadesSinEntregar
Trabajos sin corregir: $trabajosSinCorregir
Alumnos en riesgo: $alumnosEnRiesgo

Progreso de contenidos:
- Iniciado: $contenidosIniciados
- En desarrollo: $contenidosEnDesarrollo
- Trabajado: $contenidosTrabajados
- Evaluado: $contenidosEvaluados
- Pendiente: $contenidosPendientes
'''
        .trim();
  }
}
