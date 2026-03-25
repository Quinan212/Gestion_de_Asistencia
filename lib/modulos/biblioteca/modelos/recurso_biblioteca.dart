class RecursoBiblioteca {
  final int id;
  final String tipoRecurso;
  final String categoria;
  final String codigo;
  final String titulo;
  final String? autorReferencia;
  final String estado;
  final String responsable;
  final String? destinatario;
  final String? cursoReferencia;
  final int cantidadTotal;
  final int cantidadDisponible;
  final DateTime? fechaVencimiento;
  final String observaciones;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;

  const RecursoBiblioteca({
    required this.id,
    required this.tipoRecurso,
    required this.categoria,
    required this.codigo,
    required this.titulo,
    required this.autorReferencia,
    required this.estado,
    required this.responsable,
    required this.destinatario,
    required this.cursoReferencia,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    required this.fechaVencimiento,
    required this.observaciones,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
  });

  bool get prestadoOReservado =>
      estado == 'Prestado' || estado == 'Reservado';

  bool get vencido =>
      prestadoOReservado &&
      fechaVencimiento != null &&
      fechaVencimiento!.isBefore(DateTime.now());

  bool get porVencer {
    if (!prestadoOReservado || fechaVencimiento == null || vencido) {
      return false;
    }
    return fechaVencimiento!.difference(DateTime.now()) <=
        const Duration(days: 3);
  }

  bool get actualizadoDesdeLegajos =>
      observaciones.contains('Actualizado desde Legajos:');
}

class RecursoBibliotecaBorrador {
  final int? id;
  final String tipoRecurso;
  final String categoria;
  final String codigo;
  final String titulo;
  final String? autorReferencia;
  final String estado;
  final String responsable;
  final String? destinatario;
  final String? cursoReferencia;
  final int cantidadTotal;
  final int cantidadDisponible;
  final DateTime? fechaVencimiento;
  final String observaciones;
  final String rolDestino;
  final String nivelDestino;
  final String dependenciaDestino;

  const RecursoBibliotecaBorrador({
    this.id,
    required this.tipoRecurso,
    required this.categoria,
    required this.codigo,
    required this.titulo,
    required this.autorReferencia,
    required this.estado,
    required this.responsable,
    required this.destinatario,
    required this.cursoReferencia,
    required this.cantidadTotal,
    required this.cantidadDisponible,
    required this.fechaVencimiento,
    required this.observaciones,
    required this.rolDestino,
    required this.nivelDestino,
    required this.dependenciaDestino,
  });

  factory RecursoBibliotecaBorrador.desdeRecurso(RecursoBiblioteca item) {
    return RecursoBibliotecaBorrador(
      id: item.id,
      tipoRecurso: item.tipoRecurso,
      categoria: item.categoria,
      codigo: item.codigo,
      titulo: item.titulo,
      autorReferencia: item.autorReferencia,
      estado: item.estado,
      responsable: item.responsable,
      destinatario: item.destinatario,
      cursoReferencia: item.cursoReferencia,
      cantidadTotal: item.cantidadTotal,
      cantidadDisponible: item.cantidadDisponible,
      fechaVencimiento: item.fechaVencimiento,
      observaciones: item.observaciones,
      rolDestino: item.rolDestino,
      nivelDestino: item.nivelDestino,
      dependenciaDestino: item.dependenciaDestino,
    );
  }
}

class ResumenBiblioteca {
  final int recursosActivos;
  final int prestamosActivos;
  final int vencidos;
  final int disponibles;
  final int vinculadosALegajos;
  final int devueltosDesdeLegajos;

  const ResumenBiblioteca({
    required this.recursosActivos,
    required this.prestamosActivos,
    required this.vencidos,
    required this.disponibles,
    required this.vinculadosALegajos,
    required this.devueltosDesdeLegajos,
  });
}

class DashboardBiblioteca {
  final ResumenBiblioteca resumen;
  final List<RecursoBiblioteca> prestamos;
  final List<RecursoBiblioteca> catalogo;
  final List<RecursoBiblioteca> recursosDerivados;

  const DashboardBiblioteca({
    required this.resumen,
    required this.prestamos,
    required this.catalogo,
    required this.recursosDerivados,
  });
}
