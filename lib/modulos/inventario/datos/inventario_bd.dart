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
    String? sku,
    int? productoPadreId,
    String? variante,
    String? subvariante,
    required String unidad,
    double costoActual = 0,
    double precioSugerido = 0,
    double stockMinimo = 0,
    String? proveedor,
    String? imagen,
  }) {
    return _bd
        .into(_bd.tablaProductos)
        .insert(
          TablaProductosCompanion.insert(
            nombre: nombre,
            sku: Value(_normalizarTextoOpcional(sku)),
            productoPadreId: Value(_normalizarIdOpcional(productoPadreId)),
            variante: Value(_normalizarTextoOpcional(variante)),
            subvariante: Value(_normalizarTextoOpcional(subvariante)),
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
    Value<String?> sku = const Value.absent(),
    Value<int?> productoPadreId = const Value.absent(),
    Value<String?> variante = const Value.absent(),
    Value<String?> subvariante = const Value.absent(),
    required String unidad,
    required double costoActual,
    required double precioSugerido,
    required double stockMinimo,
    required String? proveedor,
    required bool activo,
  }) {
    return (_bd.update(
      _bd.tablaProductos,
    )..where((t) => t.id.equals(id))).write(
      TablaProductosCompanion(
        nombre: Value(nombre),
        sku: sku.present
            ? Value(_normalizarTextoOpcional(sku.value))
            : const Value.absent(),
        productoPadreId: productoPadreId.present
            ? Value(_normalizarIdOpcional(productoPadreId.value))
            : const Value.absent(),
        variante: variante.present
            ? Value(_normalizarTextoOpcional(variante.value))
            : const Value.absent(),
        subvariante: subvariante.present
            ? Value(_normalizarTextoOpcional(subvariante.value))
            : const Value.absent(),
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
    return (_bd.update(_bd.tablaProductos)..where((t) => t.id.equals(id)))
        .write(TablaProductosCompanion(imagen: Value(imagen)));
  }

  Future<List<Producto>> listarProductos({
    bool incluirInactivos = false,
  }) async {
    final consulta = _bd.select(_bd.tablaProductos);
    if (!incluirInactivos) {
      consulta.where((t) => t.activo.equals(true));
    }
    consulta.orderBy([
      (t) => OrderingTerm.asc(t.nombre),
      (t) => OrderingTerm.asc(t.variante),
      (t) => OrderingTerm.asc(t.subvariante),
      (t) => OrderingTerm.asc(t.sku),
    ]);
    final filas = await consulta.get();
    return filas.map(_mapearProducto).toList();
  }

  Future<Producto?> obtenerProducto(int id) async {
    final fila = await (_bd.select(
      _bd.tablaProductos,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
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
    return _bd
        .into(_bd.tablaMovimientos)
        .insert(
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
    final filas = await (_bd.select(
      _bd.tablaMovimientos,
    )..where((t) => t.productoId.equals(productoId))).get();

    double total = 0;
    for (final m in filas) {
      final tipo = m.tipo;
      final cant = m.cantidad;

      if (tipo == 'ingreso' || tipo == 'devolucion') {
        total += cant;
      } else if (tipo == 'egreso') {
        total -= cant;
      } else if (tipo == 'ajuste') {
        total += cant; // ajuste ya puede venir con signo
      }
    }
    return total;
  }

  // ---------------- NUEVO: batch ----------------
  Future<Map<int, double>> calcularStockActualPorProductos(
    List<int> productoIds,
  ) async {
    final ids = productoIds.where((e) => e > 0).toSet().toList();
    if (ids.isEmpty) return {};

    final mov = _bd.tablaMovimientos;

    // ingresos = tipo != 'egreso'  (ingreso, devolucion, ajuste)
    final qIng = _bd.selectOnly(mov)
      ..addColumns([mov.productoId, mov.cantidad.sum()])
      ..where(mov.productoId.isIn(ids) & mov.tipo.isNotValue('egreso'))
      ..groupBy([mov.productoId]);

    // egresos = tipo == 'egreso'
    final qEgr = _bd.selectOnly(mov)
      ..addColumns([mov.productoId, mov.cantidad.sum()])
      ..where(mov.productoId.isIn(ids) & mov.tipo.equals('egreso'))
      ..groupBy([mov.productoId]);

    final ingRows = await qIng.get();
    final egrRows = await qEgr.get();

    final Map<int, double> ing = {};
    for (final r in ingRows) {
      final id = r.read(mov.productoId)!;
      final sum = r.read(mov.cantidad.sum()) ?? 0.0;
      ing[id] = sum;
    }

    final Map<int, double> egr = {};
    for (final r in egrRows) {
      final id = r.read(mov.productoId)!;
      final sum = r.read(mov.cantidad.sum()) ?? 0.0;
      egr[id] = sum;
    }

    final Map<int, double> out = {};
    for (final id in ids) {
      out[id] = (ing[id] ?? 0.0) - (egr[id] ?? 0.0);
    }
    return out;
  }

  Future<void> actualizarNotaMovimiento({
    required int movimientoId,
    required String? nota,
  }) {
    return (_bd.update(_bd.tablaMovimientos)
          ..where((t) => t.id.equals(movimientoId)))
        .write(TablaMovimientosCompanion(nota: Value(nota)));
  }

  Producto _mapearProducto(TablaProducto fila) {
    return Producto(
      id: fila.id,
      nombre: fila.nombre,
      sku: fila.sku,
      productoPadreId: fila.productoPadreId,
      variante: fila.variante,
      subvariante: fila.subvariante,
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

  String? _normalizarTextoOpcional(String? valor) {
    final t = (valor ?? '').trim();
    return t.isEmpty ? null : t;
  }

  int? _normalizarIdOpcional(int? valor) {
    if (valor == null || valor <= 0) return null;
    return valor;
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
