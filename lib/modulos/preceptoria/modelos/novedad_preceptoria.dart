class NovedadPreceptoria {
  final int id;
  final String tipoNovedad;
  final String categoria;
  final String? cursoReferencia;
  final String? alumnoReferencia;
  final String estado;
  final String prioridad;
  final String responsable;
  final String observaciones;
  final DateTime? fechaSeguimiento;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;

  const NovedadPreceptoria({
    required this.id,
    required this.tipoNovedad,
    required this.categoria,
    required this.cursoReferencia,
    required this.alumnoReferencia,
    required this.estado,
    required this.prioridad,
    required this.responsable,
    required this.observaciones,
    required this.fechaSeguimiento,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
  });

  bool get vencida =>
      fechaSeguimiento != null && fechaSeguimiento!.isBefore(DateTime.now());

  bool get actualizadaDesdeLegajos =>
      observaciones.contains('Actualizado desde Legajos:');
}

class NovedadPreceptoriaBorrador {
  final int? id;
  final String tipoNovedad;
  final String categoria;
  final String? cursoReferencia;
  final String? alumnoReferencia;
  final String estado;
  final String prioridad;
  final String responsable;
  final String observaciones;
  final DateTime? fechaSeguimiento;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;

  const NovedadPreceptoriaBorrador({
    this.id,
    required this.tipoNovedad,
    required this.categoria,
    required this.cursoReferencia,
    required this.alumnoReferencia,
    required this.estado,
    required this.prioridad,
    required this.responsable,
    required this.observaciones,
    required this.fechaSeguimiento,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
  });

  factory NovedadPreceptoriaBorrador.desdeNovedad(NovedadPreceptoria item) {
    return NovedadPreceptoriaBorrador(
      id: item.id,
      tipoNovedad: item.tipoNovedad,
      categoria: item.categoria,
      cursoReferencia: item.cursoReferencia,
      alumnoReferencia: item.alumnoReferencia,
      estado: item.estado,
      prioridad: item.prioridad,
      responsable: item.responsable,
      observaciones: item.observaciones,
      fechaSeguimiento: item.fechaSeguimiento,
      rolDestino: item.rolDestino,
      nivelDestino: item.nivelDestino,
      dependenciaDestino: item.dependenciaDestino,
    );
  }
}

class AlertaPreceptoria {
  final String titulo;
  final String descripcion;
  final String valor;

  const AlertaPreceptoria({
    required this.titulo,
    required this.descripcion,
    required this.valor,
  });
}

class ResumenPreceptoria {
  final int novedadesActivas;
  final int urgentes;
  final int alumnosSinDocumento;
  final int alumnosConInasistenciasRiesgo;
  final int vinculadasALegajos;
  final int devueltasDesdeLegajos;

  const ResumenPreceptoria({
    required this.novedadesActivas,
    required this.urgentes,
    required this.alumnosSinDocumento,
    required this.alumnosConInasistenciasRiesgo,
    required this.vinculadasALegajos,
    required this.devueltasDesdeLegajos,
  });
}

class DashboardPreceptoria {
  final ResumenPreceptoria resumen;
  final List<NovedadPreceptoria> novedades;
  final List<AlertaPreceptoria> alertas;
  final List<NovedadPreceptoria> novedadesDerivadas;

  const DashboardPreceptoria({
    required this.resumen,
    required this.novedades,
    required this.alertas,
    required this.novedadesDerivadas,
  });
}
