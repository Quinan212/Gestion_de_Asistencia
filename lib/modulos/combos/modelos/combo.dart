// lib/modulos/combos/modelos/combo.dart
class Combo {
  final int id;
  final String nombre;
  final double precioVenta;
  final bool activo;
  final DateTime creadoEn;

  const Combo({
    required this.id,
    required this.nombre,
    required this.precioVenta,
    required this.activo,
    required this.creadoEn,
  });
}