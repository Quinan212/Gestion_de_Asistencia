class Venta {
  final int id;
  final DateTime fecha;
  final double total;
  final String? nota;

  const Venta({
    required this.id,
    required this.fecha,
    required this.total,
    required this.nota,
  });
}