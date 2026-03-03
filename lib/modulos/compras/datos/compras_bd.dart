import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/compra.dart';
import '../modelos/linea_compra.dart';

class ComprasBd {
  final BaseDeDatos _bd;
  Future<void> actualizarNotaCompra({
    required int compraId,
    required String? nota,
  }) {
    return (_bd.update(_bd.tablaCompras)..where((t) => t.id.equals(compraId))).write(
      TablaComprasCompanion(
        nota: Value(nota),
      ),
    );
  }
  ComprasBd(this._bd);

  Future<int> crearCompra({
    String? proveedor,
    double total = 0,
    String? nota,
    DateTime? fecha,
  }) {
    return _bd.into(_bd.tablaCompras).insert(
      TablaComprasCompanion.insert(
        proveedor: Value(proveedor),
        total: Value(total),
        nota: Value(nota),
        fecha: fecha == null ? const Value.absent() : Value(fecha),
      ),
    );
  }

  Future<int> agregarLinea({
    required int compraId,
    required int productoId,
    required double cantidad,
    required double costoUnitario,
  }) {
    final subtotal = cantidad * costoUnitario;

    return _bd.into(_bd.tablaLineasCompra).insert(
      TablaLineasCompraCompanion.insert(
        compraId: compraId,
        productoId: productoId,
        cantidad: cantidad,
        costoUnitario: Value(costoUnitario),
        subtotal: Value(subtotal),
      ),
    );
  }

  Future<void> actualizarTotalCompra({
    required int compraId,
    required double total,
  }) {
    return (_bd.update(_bd.tablaCompras)..where((t) => t.id.equals(compraId))).write(
      TablaComprasCompanion(
        total: Value(total),
      ),
    );
  }

  Future<List<Compra>> listarCompras() async {
    final consulta = _bd.select(_bd.tablaCompras)
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)]);
    final filas = await consulta.get();

    return filas
        .map<Compra>(
          (fila) => Compra(
        id: fila.id,
        fecha: fila.fecha,
        proveedor: fila.proveedor,
        total: fila.total,
        nota: fila.nota,
      ),
    )
        .toList();
  }

  Future<Compra?> obtenerCompra(int id) async {
    final fila = await (_bd.select(_bd.tablaCompras)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (fila == null) return null;

    return Compra(
      id: fila.id,
      fecha: fila.fecha,
      proveedor: fila.proveedor,
      total: fila.total,
      nota: fila.nota,
    );
  }

  Future<List<LineaCompra>> listarLineas(int compraId) async {
    final consulta = _bd.select(_bd.tablaLineasCompra)
      ..where((t) => t.compraId.equals(compraId));
    final filas = await consulta.get();

    return filas
        .map<LineaCompra>(
          (fila) => LineaCompra(
        id: fila.id,
        compraId: fila.compraId,
        productoId: fila.productoId,
        cantidad: fila.cantidad,
        costoUnitario: fila.costoUnitario,
        subtotal: fila.subtotal,
      ),
    )
        .toList();
  }
}