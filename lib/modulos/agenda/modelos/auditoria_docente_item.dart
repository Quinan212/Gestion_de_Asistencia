class AuditoriaDocenteItem {
  final int id;
  final String entidad;
  final int? entidadId;
  final String campo;
  final String? valorAnterior;
  final String? valorNuevo;
  final String? contexto;
  final int? cursoId;
  final String? institucion;
  final String usuario;
  final DateTime creadoEn;

  const AuditoriaDocenteItem({
    required this.id,
    required this.entidad,
    required this.entidadId,
    required this.campo,
    required this.valorAnterior,
    required this.valorNuevo,
    required this.contexto,
    required this.cursoId,
    required this.institucion,
    required this.usuario,
    required this.creadoEn,
  });
}
