// lib/modulos/inventario/datos/inventario_bd.dart
import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/producto.dart';
import '../modelos/movimiento.dart';

class InventarioBd {
  final BaseDeDatos _bd;

  InventarioBd(this._bd);

  Future<int> crearProducto({
    required String nombre,
    required String unidad,
    double costoActual = 0,
    double precioSugerido = 0,
    double stockMinimo = 0,
    String? proveedor,
    String? imagen,
  }) {
    return _bd.into(_bd.tablaProductos).insert(
      TablaProductosCompanion.insert(
        nombre: nombre,
        unidad: unidad,
        costoActual: Value(costoActual),
        precioSugerido: Value(precioSugerido),
        stockMinimo: Value(stockMinimo),
        proveedor: Value(proveedor),
        imagen: Value(imagen),
      ),
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
    return (_bd.update(_bd.tablaProductos)..where((t) => t.id.equals(id))).write(
      TablaProductosCompanion(
        nombre: Value(nombre),
        unidad: Value(unidad),
        costoActual: Value(costoActual),
        precioSugerido: Value(precioSugerido),
        stockMinimo: Value(stockMinimo),
        proveedor: Value(proveedor),
        activo: Value(activo),
      ),
    );
  }

  Future<void> actualizarImagenProducto({
    required int id,
    required String? imagen,
  }) {
    return (_bd.update(_bd.tablaProductos)..where((t) => t.id.equals(id))).write(
      TablaProductosCompanion(imagen: Value(imagen)),
    );
  }

  Future<List<Producto>> listarProductos({bool incluirInactivos = false}) async {
    final consulta = _bd.select(_bd.tablaProductos);
    if (!incluirInactivos) {
      consulta.where((t) => t.activo.equals(true));
    }
    consulta.orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    final filas = await consulta.get();
    return filas.map(_mapearProducto).toList();
  }

  Future<Producto?> obtenerProducto(int id) async {
    final fila =
    await (_bd.select(_bd.tablaProductos)..where((t) => t.id.equals(id))).getSingleOrNull();
    return fila == null ? null : _mapearProducto(fila);
  }

  Future<int> crearMovimiento({
    required int productoId,
    required String tipo,
    required double cantidad,
    String? nota,
    String? referencia,
    DateTime? fecha,
  }) {
    return _bd.into(_bd.tablaMovimientos).insert(
      TablaMovimientosCompanion.insert(
        productoId: productoId,
        tipo: tipo,
        cantidad: cantidad,
        nota: Value(nota),
        referencia: Value(referencia),
        fecha: fecha == null ? const Value.absent() : Value(fecha),
      ),
    );
  }

  Future<List<Movimiento>> listarMovimientosDeProducto(int productoId) async {
    final consulta = _bd.select(_bd.tablaMovimientos)
      ..where((t) => t.productoId.equals(productoId))
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)]);
    final filas = await consulta.get();
    return filas.map(_mapearMovimiento).toList();
  }

  Future<double> calcularStockActual(int productoId) async {
    final filas = await (_bd.select(_bd.tablaMovimientos)..where((t) => t.productoId.equals(productoId)))
        .get();

    double total = 0;
    for (final m in filas) {
      final tipo = m.tipo;
      final cant = m.cantidad;

      if (tipo == 'ingreso' || tipo == 'devolucion') {
        total += cant;
      } else if (tipo == 'egreso') {
        total -= cant;
      } else if (tipo == 'ajuste') {
        total += cant;
      }
    }
    return total;
  }

  Future<void> actualizarNotaMovimiento({
    required int movimientoId,
    required String? nota,
  }) {
    return (_bd.update(_bd.tablaMovimientos)..where((t) => t.id.equals(movimientoId))).write(
      TablaMovimientosCompanion(nota: Value(nota)),
    );
  }

  Producto _mapearProducto(TablaProducto fila) {
    return Producto(
      id: fila.id,
      nombre: fila.nombre,
      unidad: fila.unidad,
      costoActual: fila.costoActual,
      precioSugerido: fila.precioSugerido,
      stockMinimo: fila.stockMinimo,
      proveedor: fila.proveedor,
      imagen: fila.imagen,
      activo: fila.activo,
      creadoEn: fila.creadoEn,
    );
  }

  Movimiento _mapearMovimiento(TablaMovimiento fila) {
    return Movimiento(
      id: fila.id,
      productoId: fila.productoId,
      tipo: fila.tipo,
      cantidad: fila.cantidad,
      fecha: fila.fecha,
      nota: fila.nota,
      referencia: fila.referencia,
    );
  }
}