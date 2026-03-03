// lib/modulos/combos/modelos/componente_combo.dart
class ComponenteCombo {
  final int id;
  final int comboId;
  final int productoId;
  final double cantidad;

  const ComponenteCombo({
    required this.id,
    required this.comboId,
    required this.productoId,
    required this.cantidad,
  });
}