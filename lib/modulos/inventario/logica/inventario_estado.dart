// lib/modulos/inventario/logica/inventario_estado.dart
import '../modelos/producto.dart';

class InventarioEstado {
  final bool cargando;
  final String? error;
  final List<Producto> productos;
  final String filtro;
  final bool mostrarInactivos;
  final String orden;

  const InventarioEstado({
    required this.cargando,
    required this.error,
    required this.productos,
    required this.filtro,
    required this.mostrarInactivos,
    required this.orden,
  });

  factory InventarioEstado.inicial() {
    return const InventarioEstado(
      cargando: false,
      error: null,
      productos: [],
      filtro: '',
      mostrarInactivos: false,
      orden: 'nombre',
    );
  }

  InventarioEstado copiarCon({
    bool? cargando,
    String? error,
    List<Producto>? productos,
    String? filtro,
    bool? mostrarInactivos,
    String? orden,
  }) {
    return InventarioEstado(
      cargando: cargando ?? this.cargando,
      error: error,
      productos: productos ?? this.productos,
      filtro: filtro ?? this.filtro,
      mostrarInactivos: mostrarInactivos ?? this.mostrarInactivos,
      orden: orden ?? this.orden,
    );
  }
}