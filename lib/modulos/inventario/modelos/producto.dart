class Producto {
  final int id;
  final String nombre;
  final String? sku;
  final int? productoPadreId;
  final String? variante;
  final String? subvariante;
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
    required this.sku,
    required this.productoPadreId,
    required this.variante,
    required this.subvariante,
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
    String? sku,
    int? productoPadreId,
    String? variante,
    String? subvariante,
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
      sku: sku ?? this.sku,
      productoPadreId: productoPadreId ?? this.productoPadreId,
      variante: variante ?? this.variante,
      subvariante: subvariante ?? this.subvariante,
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

  String get nombreConVariante {
    final base = nombre.trim();
    final v = (variante ?? '').trim();
    final s = (subvariante ?? '').trim();

    if (v.isEmpty && s.isEmpty) return base;
    if (v.isNotEmpty && s.isEmpty) return '$base - $v';
    if (v.isEmpty && s.isNotEmpty) return '$base - $s';
    return '$base - $v - $s';
  }

  bool get esVariante => productoPadreId != null;
}
