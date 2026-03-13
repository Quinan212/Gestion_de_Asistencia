class HorarioCurso {
  final int id;
  final int cursoId;
  final int diaSemana;
  final String horaInicio;
  final String? horaFin;
  final String? aula;

  const HorarioCurso({
    required this.id,
    required this.cursoId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });

  String get franja {
    final fin = (horaFin ?? '').trim();
    if (fin.isEmpty) return horaInicio;
    return '$horaInicio-$fin';
  }
}

class HorarioCursoEdicion {
  final int diaSemana;
  final String horaInicio;
  final String? horaFin;
  final String? aula;

  const HorarioCursoEdicion({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
  });
}
