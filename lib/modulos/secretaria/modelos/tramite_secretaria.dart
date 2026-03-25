class TramiteSecretaria {
  final int id;
  final String tipoTramite;
  final String categoria;
  final String codigo;
  final String asunto;
  final String solicitante;
  final String? cursoReferencia;
  final String estado;
  final String prioridad;
  final String responsable;
  final String observaciones;
  final DateTime? fechaLimite;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;

  const TramiteSecretaria({
    required this.id,
    required this.tipoTramite,
    required this.categoria,
    required this.codigo,
    required this.asunto,
    required this.solicitante,
    required this.cursoReferencia,
    required this.estado,
    required this.prioridad,
    required this.responsable,
    required this.observaciones,
    required this.fechaLimite,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
  });

  bool get vencido =>
      fechaLimite != null && fechaLimite!.isBefore(DateTime.now());

  bool get porVencer {
    if (fechaLimite == null || vencido) return false;
    return fechaLimite!.difference(DateTime.now()) <= const Duration(days: 3);
  }

  bool get actualizadoDesdeLegajos =>
      observaciones.contains('Actualizado desde Legajos:');
}

class TramiteSecretariaBorrador {
  final int? id;
  final String tipoTramite;
  final String categoria;
  final String codigo;
  final String asunto;
  final String solicitante;
  final String? cursoReferencia;
  final String estado;
  final String prioridad;
  final String responsable;
  final String observaciones;
  final DateTime? fechaLimite;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;

  const TramiteSecretariaBorrador({
    this.id,
    required this.tipoTramite,
    required this.categoria,
    required this.codigo,
    required this.asunto,
    required this.solicitante,
    required this.cursoReferencia,
    required this.estado,
    required this.prioridad,
    required this.responsable,
    required this.observaciones,
    required this.fechaLimite,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
  });

  factory TramiteSecretariaBorrador.desdeTramite(TramiteSecretaria item) {
    return TramiteSecretariaBorrador(
      id: item.id,
      tipoTramite: item.tipoTramite,
      categoria: item.categoria,
      codigo: item.codigo,
      asunto: item.asunto,
      solicitante: item.solicitante,
      cursoReferencia: item.cursoReferencia,
      estado: item.estado,
      prioridad: item.prioridad,
      responsable: item.responsable,
      observaciones: item.observaciones,
      fechaLimite: item.fechaLimite,
      rolDestino: item.rolDestino,
      nivelDestino: item.nivelDestino,
      dependenciaDestino: item.dependenciaDestino,
    );
  }
}

class ResumenSecretaria {
  final int tramitesActivos;
  final int urgentes;
  final int porVencer;
  final int listosParaEmitir;
  final int vinculadosALegajos;
  final int devueltosDesdeLegajos;

  const ResumenSecretaria({
    required this.tramitesActivos,
    required this.urgentes,
    required this.porVencer,
    required this.listosParaEmitir,
    required this.vinculadosALegajos,
    required this.devueltosDesdeLegajos,
  });
}

class DashboardSecretaria {
  final ResumenSecretaria resumen;
  final List<TramiteSecretaria> tramitesPendientes;
  final List<TramiteSecretaria> emisiones;
  final List<TramiteSecretaria> tramitesDerivados;

  const DashboardSecretaria({
    required this.resumen,
    required this.tramitesPendientes,
    required this.emisiones,
    required this.tramitesDerivados,
  });
}
