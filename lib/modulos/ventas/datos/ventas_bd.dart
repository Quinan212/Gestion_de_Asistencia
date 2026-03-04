// lib/modulos/ventas/datos/ventas_bd.dart
import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/venta.dart';
import '../modelos/linea_venta.dart';

class VentasBd {
  final BaseDeDatos _bd;

  VentasBd(this._bd);

  Future<void> actualizarNotaVenta({
    required int ventaId,
    required String? nota,
  }) {
    return (_bd.update(_bd.tablaVentas)..where((t) => t.id.equals(ventaId))).write(
      TablaVentasCompanion(nota: Value(nota)),
    );
  }

  Future<int> crearVenta({
    double total = 0,
    String? nota,
    DateTime? fecha,
  }) {
    return _bd.into(_bd.tablaVentas).insert(
      TablaVentasCompanion.insert(
        total: Value(total), // <-- FIX definitivo
        nota: Value(nota),
        fecha: fecha == null ? const Value.absent() : Value(fecha),
      ),
    );
  }

  Future<int> agregarLineaCombo({
    required int ventaId,
    required int comboId,
    required double cantidad,
    required double precioUnitario,
  }) {
    final subtotal = cantidad * precioUnitario;

    return _bd.into(_bd.tablaLineasVenta).insert(
      TablaLineasVentaCompanion.insert(
        ventaId: ventaId,
        comboId: comboId,
        productoId: const Value.absent(),
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        subtotal: subtotal,
      ),
    );
  }

  Future<int> agregarLineaProducto({
    required int ventaId,
    required int productoId,
    required double cantidad,
    required double precioUnitario,
  }) {
    final subtotal = cantidad * precioUnitario;

    return _bd.into(_bd.tablaLineasVenta).insert(
      TablaLineasVentaCompanion.insert(
        ventaId: ventaId,
        comboId: 0,
        productoId: Value(productoId),
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        subtotal: subtotal,
      ),
    );
  }

  Future<void> actualizarTotalVenta({
    required int ventaId,
    required double total,
  }) {
    return (_bd.update(_bd.tablaVentas)..where((t) => t.id.equals(ventaId))).write(
      TablaVentasCompanion(total: Value(total)),
    );
  }

  Future<List<Venta>> listarVentas() async {
    final consulta = _bd.select(_bd.tablaVentas)
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)]);
    final filas = await consulta.get();

    return filas
        .map(
          (fila) => Venta(
        id: fila.id,
        fecha: fila.fecha,
        total: fila.total,
        nota: fila.nota,
      ),
    )
        .toList();
  }

  Future<Venta?> obtenerVenta(int id) async {
    final fila = await (_bd.select(_bd.tablaVentas)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (fila == null) return null;

    return Venta(
      id: fila.id,
      fecha: fila.fecha,
      total: fila.total,
      nota: fila.nota,
    );
  }

  Future<List<LineaVenta>> listarLineas(int ventaId) async {
    final consulta = _bd.select(_bd.tablaLineasVenta)
      ..where((t) => t.ventaId.equals(ventaId));
    final filas = await consulta.get();

    return filas
        .map(
          (fila) => LineaVenta(
        id: fila.id,
        ventaId: fila.ventaId,
        comboId: fila.comboId,
        productoId: fila.productoId,
        cantidad: fila.cantidad,
        precioUnitario: fila.precioUnitario,
        subtotal: fila.subtotal,
      ),
    )
        .toList();
  }
}