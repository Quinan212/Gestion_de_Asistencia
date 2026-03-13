class EvidenciaDocente {
  final int id;
  final int cursoId;
  final int? claseId;
  final int? alumnoId;
  final int? evaluacionId;
  final int? evaluacionInstanciaId;
  final DateTime fecha;
  final String tipo;
  final String titulo;
  final String? descripcion;
  final String? archivoPath;
  final String? alumnoNombre;
  final String? temaClase;
  final String? evaluacionTitulo;
  final String? evaluacionTipoInstancia;

  const EvidenciaDocente({
    required this.id,
    required this.cursoId,
    required this.claseId,
    required this.alumnoId,
    required this.evaluacionId,
    required this.evaluacionInstanciaId,
    required this.fecha,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.archivoPath,
    required this.alumnoNombre,
    required this.temaClase,
    required this.evaluacionTitulo,
    required this.evaluacionTipoInstancia,
  });
}
