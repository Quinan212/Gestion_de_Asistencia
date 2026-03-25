class LegajoDocumental {
  final int id;
  final String tipoRegistro;
  final String categoria;
  final String codigo;
  final String titulo;
  final String detalle;
  final String responsable;
  final String estado;
  final String severidad;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final int? horasHastaVencimiento;

  const LegajoDocumental({
    required this.id,
    required this.tipoRegistro,
    required this.categoria,
    required this.codigo,
    required this.titulo,
    required this.detalle,
    required this.responsable,
    required this.estado,
    required this.severidad,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.horasHastaVencimiento,
  });
}

class EstadoCruceLegajo {
  final String codigoLegajo;
  final String tipoRegistro;
  final String estado;
  final String severidad;
  final int cantidadRegistros;
  final bool activo;

  const EstadoCruceLegajo({
    required this.codigoLegajo,
    required this.tipoRegistro,
    required this.estado,
    required this.severidad,
    required this.cantidadRegistros,
    required this.activo,
  });
}

class OrigenLegajo {
  final String modulo;
  final String referencia;

  const OrigenLegajo({required this.modulo, required this.referencia});
}

class LegajoDocumentalBorrador {
  final int? id;
  final String tipoRegistro;
  final String categoria;
  final String codigo;
  final String titulo;
  final String detalle;
  final String responsable;
  final String estado;
  final String severidad;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;
  final int? horasHastaVencimiento;

  const LegajoDocumentalBorrador({
    this.id,
    required this.tipoRegistro,
    required this.categoria,
    required this.codigo,
    required this.titulo,
    required this.detalle,
    required this.responsable,
    required this.estado,
    required this.severidad,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
    required this.horasHastaVencimiento,
  });

  factory LegajoDocumentalBorrador.desdeRegistro(LegajoDocumental item) {
    return LegajoDocumentalBorrador(
      id: item.id,
      tipoRegistro: item.tipoRegistro,
      categoria: item.categoria,
      codigo: item.codigo,
      titulo: item.titulo,
      detalle: item.detalle,
      responsable: item.responsable,
      estado: item.estado,
      severidad: item.severidad,
      rolDestino: item.rolDestino,
      nivelDestino: item.nivelDestino,
      dependenciaDestino: item.dependenciaDestino,
      horasHastaVencimiento: item.horasHastaVencimiento,
    );
  }

  LegajoDocumentalBorrador copyWith({
    int? id,
    String? tipoRegistro,
    String? categoria,
    String? codigo,
    String? titulo,
    String? detalle,
    String? responsable,
    String? estado,
    String? severidad,
    String? rolDestino,
    String? nivelDestino,
    String? dependenciaDestino,
    int? horasHastaVencimiento,
  }) {
    return LegajoDocumentalBorrador(
      id: id ?? this.id,
      tipoRegistro: tipoRegistro ?? this.tipoRegistro,
      categoria: categoria ?? this.categoria,
      codigo: codigo ?? this.codigo,
      titulo: titulo ?? this.titulo,
      detalle: detalle ?? this.detalle,
      responsable: responsable ?? this.responsable,
      estado: estado ?? this.estado,
      severidad: severidad ?? this.severidad,
      rolDestino: rolDestino ?? this.rolDestino,
      nivelDestino: nivelDestino ?? this.nivelDestino,
      dependenciaDestino: dependenciaDestino ?? this.dependenciaDestino,
      horasHastaVencimiento:
          horasHastaVencimiento ?? this.horasHastaVencimiento,
    );
  }
}

class ResumenLegajos {
  final int legajosActivos;
  final int pendientes;
  final int criticos;

  const ResumenLegajos({
    required this.legajosActivos,
    required this.pendientes,
    required this.criticos,
  });
}

class DashboardLegajos {
  final ResumenLegajos resumen;
  final List<LegajoDocumental> expedientes;
  final List<LegajoDocumental> documentosPendientes;

  const DashboardLegajos({
    required this.resumen,
    required this.expedientes,
    required this.documentosPendientes,
  });
}

extension LegajoDocumentalX on LegajoDocumental {
  OrigenLegajo? get origen {
    final moduloDetalle = _valorDetalle('Origen');
    if (moduloDetalle == 'Secretaria' || codigo.startsWith('SEC-')) {
      return OrigenLegajo(
        modulo: 'Secretaria',
        referencia:
            _valorDetalle('Solicitante') ??
            _valorDetalle('Referencia') ??
            codigo.replaceFirst('SEC-', ''),
      );
    }
    if (moduloDetalle == 'Preceptoria' || codigo.startsWith('PRE-')) {
      return OrigenLegajo(
        modulo: 'Preceptoria',
        referencia:
            _valorDetalle('Alumno o referencia') ??
            _valorDetalle('Curso') ??
            codigo.replaceFirst(RegExp(r'^PRE-\d+-?'), ''),
      );
    }
    if (moduloDetalle == 'Biblioteca' || codigo.startsWith('BIB-')) {
      return OrigenLegajo(
        modulo: 'Biblioteca',
        referencia:
            _valorDetalle('Destinatario') ??
            _valorDetalle('Curso') ??
            _valorDetalle('Recurso') ??
            codigo.replaceFirst('BIB-', ''),
      );
    }
    return null;
  }

  String? get codigoSecretariaOrigen {
    if (!codigo.startsWith('SEC-')) return null;
    return codigo.replaceFirst('SEC-', '');
  }

  int? get idPreceptoriaOrigen {
    final match = RegExp(r'^PRE-(\d+)').firstMatch(codigo);
    return int.tryParse(match?.group(1) ?? '');
  }

  String? get codigoBibliotecaOrigen {
    if (!codigo.startsWith('BIB-')) return null;
    return codigo.replaceFirst('BIB-', '');
  }

  String? _valorDetalle(String etiqueta) {
    for (final linea in detalle.split('\n')) {
      final partes = linea.split(':');
      if (partes.length < 2) continue;
      if (partes.first.trim() != etiqueta) continue;
      return partes.sublist(1).join(':').trim();
    }
    return null;
  }
}
