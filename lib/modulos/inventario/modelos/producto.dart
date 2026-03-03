class Producto {
  final int id;
  final String nombre;
  final String unidad;
  final double costoActual;
  final double precioSugerido;
  final double stockMinimo;
  final String? proveedor;
  final String? imagen; // NUEVO
  final bool activo;
  final DateTime creadoEn;

  const Producto({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.costoActual,
    required this.precioSugerido,
    required this.stockMinimo,
    required this.proveedor,
    required this.imagen,
    required this.activo,
    required this.creadoEn,
  });

  Producto copiarCon({
    String? nombre,
    String? unidad,
    double? costoActual,
    double? precioSugerido,
    double? stockMinimo,
    String? proveedor,
    String? imagen,
    bool? activo,
  }) {
    return Producto(
      id: id,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      costoActual: costoActual ?? this.costoActual,
      precioSugerido: precioSugerido ?? this.precioSugerido,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      proveedor: proveedor ?? this.proveedor,
      imagen: imagen ?? this.imagen,
      activo: activo ?? this.activo,
      creadoEn: creadoEn,
    );
  }
}