class LineaVenta {
  final int id;
  final int ventaId;

  // comboId se mantiene porque la tabla lo exige.
  // Si es una línea de PRODUCTO: comboId = 0 y productoId != null.
  final int comboId;

  final int? productoId;

  final double cantidad;
  final double precioUnitario;
  final double subtotal;

  const LineaVenta({
    required this.id,
    required this.ventaId,
    required this.comboId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  bool get esProducto => productoId != null;
  bool get esCombo => productoId == null;
}