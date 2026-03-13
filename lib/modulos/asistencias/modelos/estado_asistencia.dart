enum EstadoAsistencia { pendiente, presente, ausente, tarde, justificada }

extension EstadoAsistenciaX on EstadoAsistencia {
  String get code {
    switch (this) {
      case EstadoAsistencia.pendiente:
        return 'pendiente';
      case EstadoAsistencia.presente:
        return 'presente';
      case EstadoAsistencia.ausente:
        return 'ausente';
      case EstadoAsistencia.tarde:
        return 'tarde';
      case EstadoAsistencia.justificada:
        return 'justificada';
    }
  }

  String get label {
    switch (this) {
      case EstadoAsistencia.pendiente:
        return 'Pendiente';
      case EstadoAsistencia.presente:
        return 'Presente';
      case EstadoAsistencia.ausente:
        return 'Ausente';
      case EstadoAsistencia.tarde:
        return 'Tarde';
      case EstadoAsistencia.justificada:
        return 'Justificada';
    }
  }

  static EstadoAsistencia fromCode(String? code) {
    final t = (code ?? '').trim().toLowerCase();
    switch (t) {
      case 'pendiente':
        return EstadoAsistencia.pendiente;
      case 'ausente':
        return EstadoAsistencia.ausente;
      case 'tarde':
        return EstadoAsistencia.tarde;
      case 'justificada':
        return EstadoAsistencia.justificada;
      case 'presente':
        return EstadoAsistencia.presente;
      default:
        return EstadoAsistencia.pendiente;
    }
  }

  static List<EstadoAsistencia> get valuesOrdenadas => const [
    EstadoAsistencia.pendiente,
    EstadoAsistencia.presente,
    EstadoAsistencia.ausente,
    EstadoAsistencia.tarde,
    EstadoAsistencia.justificada,
  ];
}
