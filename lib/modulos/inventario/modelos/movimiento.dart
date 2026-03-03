// lib/modulos/inventario/modelos/movimiento.dart

class Movimiento {
  final int id;
  final int productoId;
  final String tipo; // ingreso, egreso, ajuste, devolucion
  final double cantidad;
  final DateTime fecha;
  final String? nota;
  final String? referencia;

  const Movimiento({
    required this.id,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    required this.nota,
    required this.referencia,
  });
}