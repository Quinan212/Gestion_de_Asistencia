class AcuerdoConvivencia {
  final int id;
  final int cursoId;
  final DateTime fecha;
  final String tipo;
  final String descripcion;
  final String? estrategia;
  final bool reiterada;
  final bool resuelta;

  const AcuerdoConvivencia({
    required this.id,
    required this.cursoId,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.estrategia,
    required this.reiterada,
    required this.resuelta,
  });
}
