class LineaPedidoTmp {
  final int productoId;
  final String nombre;
  final String unidad;
  final double cantidad;
  final double precioUnitario;

  const LineaPedidoTmp({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.precioUnitario,
  });

  LineaPedidoTmp copyWith({
    double? cantidad,
    double? precioUnitario,
    String? nombre,
    String? unidad,
  }) {
    return LineaPedidoTmp(
      productoId: productoId,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }
}