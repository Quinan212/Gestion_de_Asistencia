class Compra {
  final int id;
  final DateTime fecha;
  final String? proveedor;
  final double envioMonto;
  final double total;
  final String? nota;

  const Compra({
    required this.id,
    required this.fecha,
    required this.proveedor,
    required this.envioMonto,
    required this.total,
    required this.nota,
  });
}