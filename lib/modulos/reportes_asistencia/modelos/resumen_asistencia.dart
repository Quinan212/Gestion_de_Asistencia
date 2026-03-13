class ResumenAsistenciaAlumno {
  final int alumnoId;
  final String apellido;
  final String nombre;
  final int presentes;
  final int ausentes;
  final int tardes;
  final int justificadas;

  const ResumenAsistenciaAlumno({
    required this.alumnoId,
    required this.apellido,
    required this.nombre,
    required this.presentes,
    required this.ausentes,
    required this.tardes,
    required this.justificadas,
  });

  String get nombreCompleto => '$apellido, $nombre';

  int get totalRegistros => presentes + ausentes + tardes + justificadas;

  int get asistenciasComputables => presentes + tardes + justificadas;

  double get porcentajeAsistencia {
    final total = totalRegistros;
    if (total <= 0) return 0;
    return (asistenciasComputables / total) * 100;
  }
}

class ResumenAsistenciaMensual {
  final DateTime mes;
  final int clases;
  final int presentes;
  final int ausentes;
  final int tardes;
  final int justificadas;

  const ResumenAsistenciaMensual({
    required this.mes,
    required this.clases,
    required this.presentes,
    required this.ausentes,
    required this.tardes,
    required this.justificadas,
  });

  int get totalRegistros => presentes + ausentes + tardes + justificadas;

  int get asistenciasComputables => presentes + tardes + justificadas;

  double get porcentajeAsistencia {
    final total = totalRegistros;
    if (total <= 0) return 0;
    return (asistenciasComputables / total) * 100;
  }
}
