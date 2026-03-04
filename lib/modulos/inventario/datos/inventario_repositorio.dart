// lib/modulos/inventario/datos/inventario_repositorio.dart
import '/infraestructura/base_de_datos/base_de_datos.dart';
import 'inventario_bd.dart';
import '../modelos/producto.dart';
import '../modelos/movimiento.dart';

class InventarioRepositorio {
  final InventarioBd _bd;

  InventarioRepositorio(BaseDeDatos baseDeDatos) : _bd = InventarioBd(baseDeDatos);

  Future<int> crearProducto({
    required String nombre,
    required String unidad,
    double costoActual = 0,
    double precioSugerido = 0,
    double stockMinimo = 0,
    String? proveedor,
    String? imagen,
  }) {
    return _bd.crearProducto(
      nombre: nombre,
      unidad: unidad,
      costoActual: costoActual,
      precioSugerido: precioSugerido,
      stockMinimo: stockMinimo,
      proveedor: proveedor,
      imagen: imagen,
    );
  }

  Future<void> actualizarProducto({
    required int id,
    required String nombre,
    required String unidad,
    required double costoActual,
    required double precioSugerido,
    required double stockMinimo,
    required String? proveedor,
    required bool activo,
  }) {
    return _bd.actualizarProducto(
      id: id,
      nombre: nombre,
      unidad: unidad,
      costoActual: costoActual,
      precioSugerido: precioSugerido,
      stockMinimo: stockMinimo,
      proveedor: proveedor,
      activo: activo,
    );
  }

  Future<void> actualizarImagenProducto({required int id, required String? imagen}) {
    return _bd.actualizarImagenProducto(id: id, imagen: imagen);
  }

  Future<List<Producto>> listarProductos({bool incluirInactivos = false}) {
    return _bd.listarProductos(incluirInactivos: incluirInactivos);
  }

  Future<Producto?> obtenerProducto(int id) => _bd.obtenerProducto(id);

  Future<int> crearMovimiento({
    required int productoId,
    required String tipo,
    required double cantidad,
    String? nota,
    String? referencia,
    DateTime? fecha,
  }) {
    return _bd.crearMovimiento(
      productoId: productoId,
      tipo: tipo,
      cantidad: cantidad,
      nota: nota,
      referencia: referencia,
      fecha: fecha,
    );
  }

  Future<List<Movimiento>> listarMovimientosDeProducto(int productoId) {
    return _bd.listarMovimientosDeProducto(productoId);
  }

  /// stock de 1 producto (queda, pero por UI conviene usar batch)
  Future<double> calcularStockActual(int productoId) {
    return _bd.calcularStockActual(productoId);
  }

  /// NUEVO: stock batch para N productos
  Future<Map<int, double>> calcularStockActualPorProductos(List<int> productoIds) {
    return _bd.calcularStockActualPorProductos(productoIds);
  }

  Future<void> actualizarNotaMovimiento({required int movimientoId, required String? nota}) {
    return _bd.actualizarNotaMovimiento(movimientoId: movimientoId, nota: nota);
  }
}