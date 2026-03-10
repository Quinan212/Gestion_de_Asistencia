// lib/modulos/pedidos/datos/pedidos_repositorio.dart
import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '/modulos/pedidos/modelos/pedido.dart';
import '/modulos/pedidos/modelos/linea_pedido.dart';
import '/modulos/pedidos/modelos/linea_pedido_tmp.dart';

class FaltanteStock {
  final int productoId;
  final String nombre;
  final String unidad;
  final double falta;

  const FaltanteStock({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.falta,
  });
}

class StockInsuficientePedido implements Exception {
  final String titulo;
  final List<FaltanteStock> faltantes;

  const StockInsuficientePedido({
    this.titulo = 'No podes crear este pedido',
    required this.faltantes,
  });

  @override
  String toString() => '$titulo (${faltantes.length})';
}

class PedidosRepositorio {
  final BaseDeDatos db;
  PedidosRepositorio(this.db);

  String _nombreProductoConVariante(TablaProducto? p, int productoId) {
    final base = (p?.nombre ?? '').trim();
    final variante = (p?.variante ?? '').trim();
    final subvariante = (p?.subvariante ?? '').trim();

    if (base.isEmpty) return 'Producto $productoId';
    if (variante.isEmpty && subvariante.isEmpty) return base;
    if (variante.isNotEmpty && subvariante.isEmpty) return '$base - $variante';
    if (variante.isEmpty && subvariante.isNotEmpty) {
      return '$base - $subvariante';
    }
    return '$base - $variante - $subvariante';
  }

  // -------------------- mappers --------------------

  Pedido _mapPedido(TablaPedido row) {
    return Pedido(
      id: row.id,
      fecha: row.fecha,
      cliente: row.cliente,
      nota: row.nota,
      envioMonto: row.envioMonto,
      medioPago: row.medioPago,
      estadoPago: row.estadoPago,
      estado: PedidoEstadoX.fromCode(row.estado),
      subtotal: row.subtotal,
      total: row.total,
      stockDescontado: row.stockDescontado,
      ventaId: row.ventaId,
    );
  }

  // -------------------- lecturas --------------------

  Future<List<Pedido>> listarPedidos() async {
    final q = db.select(db.tablaPedidos)
      ..orderBy([(t) => OrderingTerm.desc(t.fecha)]);
    final rows = await q.get();
    return rows.map(_mapPedido).toList();
  }

  Future<Pedido?> obtenerPedido(int pedidoId) async {
    final q = db.select(db.tablaPedidos)..where((t) => t.id.equals(pedidoId));
    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return _mapPedido(row);
  }

  Future<Pedido?> obtenerPedidoPorVentaId(int ventaId) async {
    final q = db.select(db.tablaPedidos)
      ..where((t) => t.ventaId.equals(ventaId))
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    if (row == null) return null;
    return _mapPedido(row);
  }

  Future<List<LineaPedido>> listarLineas(int pedidoId) async {
    final q = db.select(db.tablaLineasPedido)
      ..where((t) => t.pedidoId.equals(pedidoId))
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    final rows = await q.get();

    final idsProductos = rows
        .map((r) => r.productoId)
        .whereType<int>()
        .toSet()
        .toList();

    final prodPorId = <int, TablaProducto>{};
    if (idsProductos.isNotEmpty) {
      final prods = await (db.select(
        db.tablaProductos,
      )..where((t) => t.id.isIn(idsProductos))).get();
      for (final p in prods) {
        prodPorId[p.id] = p;
      }
    }

    return rows.map((row) {
      final productoId = row.productoId;
      String nombre = row.nombre;
      if (productoId != null) {
        final actual = _nombreProductoConVariante(
          prodPorId[productoId],
          productoId,
        );
        final nombreGuardado = row.nombre.trim();
        if (nombreGuardado.isEmpty ||
            nombreGuardado == 'Producto $productoId') {
          nombre = actual;
        }
      }

      return LineaPedido(
        id: row.id,
        pedidoId: row.pedidoId,
        comboId: row.comboId,
        productoId: row.productoId,
        nombre: nombre,
        unidad: row.unidad,
        cantidad: row.cantidad,
        precioUnitario: row.precioUnitario,
        subtotal: row.subtotal,
      );
    }).toList();
  }

  // -------------------- stock helpers --------------------

  Future<double> _stockActualProducto(int productoId) async {
    final m = db.tablaMovimientos;

    final q = db.selectOnly(m)
      ..addColumns([m.tipo, m.cantidad])
      ..where(m.productoId.equals(productoId));

    final rows = await q.get();

    double stock = 0.0;
    for (final r in rows) {
      final tipo = (r.read(m.tipo) ?? '').toString().toLowerCase();
      final cant = r.read(m.cantidad) ?? 0.0;

      if (tipo == 'ingreso') stock += cant;
      if (tipo == 'egreso') stock -= cant;
    }
    return stock;
  }

  Future<Map<int, double>> _stockActualMuchos(Set<int> productoIds) async {
    final out = <int, double>{};
    for (final id in productoIds) {
      out[id] = await _stockActualProducto(id);
    }
    return out;
  }

  Future<List<FaltanteStock>> _faltantesPorConsumo(
    Map<int, double> consumo,
  ) async {
    if (consumo.isEmpty) return const [];

    final ids = consumo.keys.toSet();
    final stocks = await _stockActualMuchos(ids);

    final productos = await (db.select(
      db.tablaProductos,
    )..where((t) => t.id.isIn(ids))).get();
    final prodPorId = {for (final p in productos) p.id: p};

    final faltantes = <FaltanteStock>[];

    for (final e in consumo.entries) {
      final productoId = e.key;
      final necesita = e.value <= 0 ? 0.0 : e.value;

      final stock = stocks[productoId] ?? 0.0;
      if (stock + 1e-9 < necesita) {
        final p = prodPorId[productoId];
        final nombre = _nombreProductoConVariante(p, productoId).trim();
        final unidad = (p?.unidad ?? '').trim();

        faltantes.add(
          FaltanteStock(
            productoId: productoId,
            nombre: nombre.isEmpty ? 'Producto $productoId' : nombre,
            unidad: unidad,
            falta: (necesita - stock),
          ),
        );
      }
    }

    faltantes.sort((a, b) => b.falta.compareTo(a.falta));
    return faltantes;
  }

  Future<void> _asegurarStockSuficiente(Map<int, double> consumo) async {
    final falt = await _faltantesPorConsumo(consumo);
    if (falt.isNotEmpty) throw StockInsuficientePedido(faltantes: falt);
  }

  Future<int> maxCombosVendibles(int comboId) async {
    final comps = await (db.select(
      db.tablaComponentes,
    )..where((t) => t.comboId.equals(comboId))).get();
    if (comps.isEmpty) return 0;

    final productoIds = comps.map((c) => c.productoId).toSet();
    final stock = await _stockActualMuchos(productoIds);

    int? max;
    for (final c in comps) {
      final reqPorCombo = c.cantidad;
      if (reqPorCombo <= 0) continue;

      final s = stock[c.productoId] ?? 0.0;
      final posible = (s <= 0) ? 0 : (s / reqPorCombo).floor();
      max = (max == null) ? posible : (posible < max ? posible : max);
    }

    return (max ?? 0).clamp(0, 1 << 30);
  }

  Future<List<FaltanteStock>> faltantesParaCombo({
    required int comboId,
    required double cantidadCombos,
  }) async {
    final cant = cantidadCombos <= 0 ? 0.0 : cantidadCombos;

    final comps = await (db.select(
      db.tablaComponentes,
    )..where((t) => t.comboId.equals(comboId))).get();
    if (comps.isEmpty) return const [];

    final consumo = <int, double>{};
    for (final c in comps) {
      final necesita = c.cantidad * cant;
      if (necesita == 0) continue;
      consumo[c.productoId] = (consumo[c.productoId] ?? 0.0) + necesita;
    }

    return _faltantesPorConsumo(consumo);
  }

  Future<Map<int, double>> _consumoPorLineasPedido(
    List<TablaLineasPedidoData> lineas,
  ) async {
    final consumo = <int, double>{};
    final compCache = <int, List<dynamic>>{};

    for (final l in lineas) {
      final pId = l.productoId;
      final cId = l.comboId;
      final cantLinea = l.cantidad;

      if (pId != null) {
        consumo[pId] = (consumo[pId] ?? 0.0) + cantLinea;
        continue;
      }

      if (cId == null) continue;

      final comps =
          compCache[cId] ??
          await (db.select(
            db.tablaComponentes,
          )..where((t) => t.comboId.equals(cId))).get();

      compCache[cId] = comps;

      for (final c in comps) {
        final int pid = c.productoId as int;
        final double cantComp = (c.cantidad as num).toDouble();

        final necesita = cantComp * cantLinea;
        if (necesita == 0) continue;

        consumo[pid] = (consumo[pid] ?? 0.0) + necesita;
      }
    }

    return consumo;
  }

  // -------------------- creacion --------------------

  Future<void> _descontarStockDePedido({
    required int pedidoId,
    required List<TablaLineasPedidoData> lineas,
  }) async {
    final consumo = await _consumoPorLineasPedido(lineas);
    await _asegurarStockSuficiente(consumo);

    for (final e in consumo.entries) {
      final cant = e.value;
      if (cant == 0) continue;

      await db
          .into(db.tablaMovimientos)
          .insert(
            TablaMovimientosCompanion.insert(
              productoId: e.key,
              tipo: 'egreso',
              cantidad: cant,
              nota: const Value('PEDIDO PREPARADO'),
              referencia: Value('pedido:$pedidoId'),
            ),
          );
    }
  }

  Future<void> _revertirStockDePedidoPreparado({required int pedidoId}) async {
    final egresos =
        await (db.select(db.tablaMovimientos)..where(
              (m) =>
                  m.referencia.equals('pedido:$pedidoId') &
                  m.tipo.equals('egreso'),
            ))
            .get();

    if (egresos.isEmpty) return;

    final yaRevertido =
        await (db.select(db.tablaMovimientos)..where(
              (m) =>
                  m.referencia.equals('pedido:$pedidoId') &
                  m.tipo.equals('ingreso') &
                  m.nota.like('%REVERSION PREPARADO%'),
            ))
            .getSingleOrNull();

    if (yaRevertido != null) return;

    for (final m in egresos) {
      final cant = m.cantidad;
      if (cant == 0) continue;

      await db
          .into(db.tablaMovimientos)
          .insert(
            TablaMovimientosCompanion.insert(
              productoId: m.productoId,
              tipo: 'ingreso',
              cantidad: cant,
              nota: const Value('REVERSION PREPARADO'),
              referencia: Value('pedido:$pedidoId'),
            ),
          );
    }
  }

  Future<bool> _pedidoTieneStockDescontadoReal(int pedidoId) async {
    final mov =
        await (db.select(db.tablaMovimientos)
              ..where(
                (m) =>
                    m.referencia.equals('pedido:$pedidoId') &
                    m.tipo.equals('egreso'),
              )
              ..limit(1))
            .getSingleOrNull();
    return mov != null;
  }

  // -------------------- creacion --------------------
  Future<int> crearPedidoPorCombo({
    required int comboId,
    required double cantidad,
    required String? cliente,
    required String? nota,
    required double envioMonto,
    required String medioPago,
    required String estadoPago,
    required bool crearEnEncargadoYReservar,
  }) async {
    final cant = cantidad <= 0 ? 1.0 : cantidad;
    final envio = envioMonto < 0 ? 0.0 : envioMonto;

    final combo = await (db.select(
      db.tablaCombos,
    )..where((t) => t.id.equals(comboId))).getSingleOrNull();
    if (combo == null) throw StateError('Combo no encontrado');

    final precioUnit = combo.precioVenta;
    final sub = cant * precioUnit;
    final total = sub + envio;

    return db.transaction(() async {
      final estado = crearEnEncargadoYReservar
          ? PedidoEstado.encargado.code
          : PedidoEstado.borrador.code;

      if (crearEnEncargadoYReservar) {
        final falt = await faltantesParaCombo(
          comboId: comboId,
          cantidadCombos: cant,
        );
        if (falt.isNotEmpty) throw StockInsuficientePedido(faltantes: falt);
      }

      final pedidoId = await db
          .into(db.tablaPedidos)
          .insert(
            TablaPedidosCompanion.insert(
              cliente: Value(
                (cliente ?? '').trim().isEmpty ? null : cliente!.trim(),
              ),
              nota: Value((nota ?? '').trim().isEmpty ? null : nota!.trim()),
              envioMonto: Value(envio),
              medioPago: Value(medioPago.trim()),
              estadoPago: Value(estadoPago.trim()),
              estado: Value(estado),
              subtotal: Value(sub),
              total: Value(total),
            ),
          );

      await db
          .into(db.tablaLineasPedido)
          .insert(
            TablaLineasPedidoCompanion.insert(
              pedidoId: pedidoId,
              comboId: Value(comboId),
              productoId: const Value.absent(),
              nombre: combo.nombre,
              unidad: 'combo',
              cantidad: cant,
              precioUnitario: Value(precioUnit),
              subtotal: Value(sub),
            ),
          );

      return pedidoId;
    });
  }

  Future<int> crearPedidoPorProductos({
    required List<LineaPedidoTmp> lineas,
    required String? cliente,
    required String? nota,
    required double envioMonto,
    required String medioPago,
    required String estadoPago,
    required bool crearEnEncargadoYReservar,
  }) async {
    if (lineas.isEmpty) throw ArgumentError('lineas vacias');

    final envio = envioMonto < 0 ? 0.0 : envioMonto;

    double subtotal = 0.0;
    for (final l in lineas) {
      final cant = l.cantidad <= 0 ? 0.0 : l.cantidad;
      final pu = l.precioUnitario < 0 ? 0.0 : l.precioUnitario;
      subtotal += cant * pu;
    }
    final total = subtotal + envio;

    return db.transaction(() async {
      final estado = crearEnEncargadoYReservar
          ? PedidoEstado.encargado.code
          : PedidoEstado.borrador.code;

      if (crearEnEncargadoYReservar) {
        final consumo = <int, double>{};
        for (final l in lineas) {
          final cant = l.cantidad <= 0 ? 0.0 : l.cantidad;
          if (cant == 0) continue;
          consumo[l.productoId] = (consumo[l.productoId] ?? 0.0) + cant;
        }
        await _asegurarStockSuficiente(consumo);
      }

      final pedidoId = await db
          .into(db.tablaPedidos)
          .insert(
            TablaPedidosCompanion.insert(
              cliente: Value(
                (cliente ?? '').trim().isEmpty ? null : cliente!.trim(),
              ),
              nota: Value((nota ?? '').trim().isEmpty ? null : nota!.trim()),
              envioMonto: Value(envio),
              medioPago: Value(medioPago.trim()),
              estadoPago: Value(estadoPago.trim()),
              estado: Value(estado),
              subtotal: Value(subtotal),
              total: Value(total),
            ),
          );

      for (final l in lineas) {
        final cant = l.cantidad <= 0 ? 0.0 : l.cantidad;
        if (cant == 0) continue;

        final pu = l.precioUnitario < 0 ? 0.0 : l.precioUnitario;
        final sub = cant * pu;

        await db
            .into(db.tablaLineasPedido)
            .insert(
              TablaLineasPedidoCompanion.insert(
                pedidoId: pedidoId,
                comboId: const Value.absent(),
                productoId: Value(l.productoId),
                nombre: l.nombre,
                unidad: l.unidad,
                cantidad: cant,
                precioUnitario: Value(pu),
                subtotal: Value(sub),
              ),
            );
      }

      return pedidoId;
    });
  }

  // -------------------- estado --------------------

  Future<void> cambiarEstado({
    required int pedidoId,
    required PedidoEstado estado,
    required bool recalcularReservasSiEncargado,
  }) async {
    final p = await (db.select(
      db.tablaPedidos,
    )..where((t) => t.id.equals(pedidoId))).getSingleOrNull();
    if (p == null) throw StateError('Pedido no encontrado');

    final actual = PedidoEstadoX.fromCode(p.estado);
    if (actual == PedidoEstado.cancelado || actual == estado) return;

    if (actual == PedidoEstado.entregado && estado != PedidoEstado.entregado) {
      throw StateError('No se puede reabrir un pedido entregado');
    }

    if (estado == PedidoEstado.entregado) {
      await marcarEntregadoYCrearVenta(pedidoId: pedidoId);
      return;
    }

    if (estado == PedidoEstado.preparado) {
      if (!p.stockDescontado) {
        final lineas = await (db.select(
          db.tablaLineasPedido,
        )..where((t) => t.pedidoId.equals(pedidoId))).get();
        await _descontarStockDePedido(pedidoId: pedidoId, lineas: lineas);
      }

      await (db.update(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).write(
        TablaPedidosCompanion(
          estado: Value(PedidoEstado.preparado.code),
          stockDescontado: const Value(true),
        ),
      );
      return;
    }

    final stockDescontadoReal = await _pedidoTieneStockDescontadoReal(pedidoId);

    if ((p.stockDescontado || stockDescontadoReal) &&
        p.ventaId == null &&
        (estado == PedidoEstado.borrador || estado == PedidoEstado.encargado)) {
      await _revertirStockDePedidoPreparado(pedidoId: pedidoId);

      await (db.update(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).write(
        TablaPedidosCompanion(
          estado: Value(estado.code),
          stockDescontado: const Value(false),
        ),
      );
      return;
    }

    await (db.update(db.tablaPedidos)..where((t) => t.id.equals(pedidoId)))
        .write(TablaPedidosCompanion(estado: Value(estado.code)));
  }
  // -------------------- cancelacion / venta cancelada --------------------

  Future<void> _marcarVentaCancelada(int ventaId) async {
    final v = await (db.select(
      db.tablaVentas,
    )..where((t) => t.id.equals(ventaId))).getSingleOrNull();
    if (v == null) return;

    final nota = (v.nota ?? '').trim();
    if (nota.contains('VENTA CANCELADA')) return;

    final nueva = nota.isEmpty ? 'VENTA CANCELADA' : 'VENTA CANCELADA\n$nota';

    await (db.update(db.tablaVentas)..where((t) => t.id.equals(ventaId))).write(
      TablaVentasCompanion(nota: Value(nueva)),
    );
  }

  Future<void> _revertirStockDeVenta({
    required int pedidoId,
    required int ventaId,
  }) async {
    final egresos =
        await (db.select(db.tablaMovimientos)..where(
              (m) =>
                  m.referencia.equals('venta:$ventaId') &
                  m.tipo.equals('egreso'),
            ))
            .get();

    if (egresos.isEmpty) return;

    final yaRevertido =
        await (db.select(db.tablaMovimientos)..where(
              (m) =>
                  m.referencia.equals('venta:$ventaId') &
                  m.tipo.equals('ingreso') &
                  m.nota.like('%CANCELACI%'),
            ))
            .getSingleOrNull();

    if (yaRevertido != null) return;

    for (final m in egresos) {
      final cant = m.cantidad;
      if (cant == 0) continue;

      await db
          .into(db.tablaMovimientos)
          .insert(
            TablaMovimientosCompanion.insert(
              productoId: m.productoId,
              tipo: 'ingreso',
              cantidad: cant,
              nota: Value(
                'CANCELACION (pedido:$pedidoId - revierte venta:$ventaId)',
              ),
              referencia: Value('venta:$ventaId'),
            ),
          );
    }
  }

  Future<void> cancelarPedido({required int pedidoId}) async {
    await db.transaction(() async {
      final p = await (db.select(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).getSingleOrNull();
      if (p == null) throw StateError('Pedido no encontrado');

      final est = PedidoEstadoX.fromCode(p.estado);
      if (est == PedidoEstado.cancelado) return;

      final ventaId = p.ventaId;
      if (ventaId != null) {
        await _marcarVentaCancelada(ventaId);
      }

      final stockDescontadoReal = await _pedidoTieneStockDescontadoReal(
        pedidoId,
      );

      if (stockDescontadoReal) {
        await _revertirStockDePedidoPreparado(pedidoId: pedidoId);
      } else if (ventaId != null) {
        await _revertirStockDeVenta(pedidoId: pedidoId, ventaId: ventaId);
      }

      await (db.update(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).write(
        TablaPedidosCompanion(
          estado: Value(PedidoEstado.cancelado.code),
          stockDescontado: const Value(false),
        ),
      );
    });
  }
  // -------------------- RETROACTIVO --------------------

  int? _extraerPedidoIdDeTexto(String texto) {
    final t = texto.toLowerCase();
    final i = t.indexOf('pedido');
    if (i < 0) return null;

    final sub = t.substring(i);
    final m = RegExp(r'pedido\s*:\s*(\d+)').firstMatch(sub);
    if (m == null) return null;

    return int.tryParse(m.group(1) ?? '');
  }

  int? _extraerVentaIdDeReferencia(String ref) {
    final r = ref.trim().toLowerCase();
    if (!r.startsWith('venta:')) return null;
    return int.tryParse(r.substring('venta:'.length).trim());
  }

  Future<int> marcarVentasDePedidosCanceladosRetroactivo() async {
    return db.transaction(() async {
      final pedidosCancelados = await (db.select(
        db.tablaPedidos,
      )..where((p) => p.estado.equals(PedidoEstado.cancelado.code))).get();

      if (pedidosCancelados.isEmpty) return 0;

      final canceladosIds = pedidosCancelados.map((p) => p.id).toSet();

      // movimientos de venta con nota que mencione pedido:
      final movs =
          await (db.select(db.tablaMovimientos)..where(
                (m) =>
                    m.referencia.like('venta:%') &
                    m.nota.like('%pedido%') &
                    m.tipo.equals('egreso'),
              ))
              .get();

      final pedidoToVenta = <int, int>{};
      for (final m in movs) {
        final pid = _extraerPedidoIdDeTexto(m.nota ?? '');
        if (pid == null) continue;
        if (!canceladosIds.contains(pid)) continue;

        final vid = _extraerVentaIdDeReferencia(m.referencia ?? '');
        if (vid == null) continue;

        pedidoToVenta.putIfAbsent(pid, () => vid);
      }

      int tocadas = 0;

      for (final p in pedidosCancelados) {
        final pid = p.id;
        final ventaId = p.ventaId ?? pedidoToVenta[pid];
        if (ventaId == null) continue;

        await _marcarVentaCancelada(ventaId);

        if (p.ventaId == null) {
          await (db.update(db.tablaPedidos)..where((x) => x.id.equals(pid)))
              .write(TablaPedidosCompanion(ventaId: Value(ventaId)));
        }

        tocadas++;
      }

      return tocadas;
    });
  }

  Future<int> repararStockDeCanceladosRetroactivo() async {
    return db.transaction(() async {
      final pedidosCancelados =
          await (db.select(db.tablaPedidos)..where(
                (p) =>
                    p.estado.equals(PedidoEstado.cancelado.code) &
                    p.ventaId.isNotNull(),
              ))
              .get();

      int reparados = 0;

      for (final p in pedidosCancelados) {
        final ventaId = p.ventaId;
        if (ventaId == null) continue;

        final egresos =
            await (db.select(db.tablaMovimientos)..where(
                  (m) =>
                      m.referencia.equals('venta:$ventaId') &
                      m.tipo.equals('egreso'),
                ))
                .get();
        if (egresos.isEmpty) continue;

        final yaRevertido =
            await (db.select(db.tablaMovimientos)..where(
                  (m) =>
                      m.referencia.equals('venta:$ventaId') &
                      m.tipo.equals('ingreso') &
                      m.nota.like('%CANCELACI%'),
                ))
                .getSingleOrNull();
        if (yaRevertido != null) continue;

        for (final m in egresos) {
          final cant = m.cantidad;
          if (cant == 0) continue;

          await db
              .into(db.tablaMovimientos)
              .insert(
                TablaMovimientosCompanion.insert(
                  productoId: m.productoId,
                  tipo: 'ingreso',
                  cantidad: cant,
                  nota: Value(
                    'CANCELACION (retroactiva) - pedido:${p.id} - revierte venta:$ventaId',
                  ),
                  referencia: Value('venta:$ventaId'),
                ),
              );
        }

        reparados++;
      }

      return reparados;
    });
  }

  // -------------------- pago (sincroniza nota venta si existe) --------------------

  String _notaVentaDesdePedido({
    required int pedidoId,
    required String? cliente,
    required String? notaPedido,
    required String medioPago,
    required double envioMonto,
    required String estadoPago,
  }) {
    final parts = <String>[];
    parts.add('Pedido:$pedidoId');

    final c = (cliente ?? '').trim();
    if (c.isNotEmpty) parts.add('Cliente: $c');

    final nota = (notaPedido ?? '').trim();
    if (nota.isNotEmpty) parts.add('Nota: $nota');

    final mp = medioPago.trim();
    if (mp.isNotEmpty) parts.add('Pago: $mp');

    final ep = estadoPago.trim();
    if (ep.isNotEmpty) parts.add('Estado pago: $ep');

    if (envioMonto > 0) parts.add('Envio: $envioMonto');

    return parts.join(' - ');
  }

  Future<void> actualizarPago({
    required int pedidoId,
    String? medioPago,
    String? estadoPago,
  }) async {
    await db.transaction(() async {
      final pRow = await (db.select(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).getSingleOrNull();
      if (pRow == null) throw StateError('Pedido no encontrado');

      final mp = medioPago?.trim();
      final ep = estadoPago?.trim();

      await (db.update(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).write(
        TablaPedidosCompanion(
          medioPago: (mp == null || mp.isEmpty)
              ? const Value.absent()
              : Value(mp),
          estadoPago: (ep == null || ep.isEmpty)
              ? const Value.absent()
              : Value(ep),
        ),
      );

      final ventaId = pRow.ventaId;
      if (ventaId != null) {
        final p2 = await (db.select(
          db.tablaPedidos,
        )..where((t) => t.id.equals(pedidoId))).getSingle();
        final notaVenta = _notaVentaDesdePedido(
          pedidoId: pedidoId,
          cliente: p2.cliente,
          notaPedido: p2.nota,
          medioPago: p2.medioPago,
          envioMonto: p2.envioMonto,
          estadoPago: p2.estadoPago,
        );

        await (db.update(db.tablaVentas)..where((t) => t.id.equals(ventaId)))
            .write(TablaVentasCompanion(nota: Value(notaVenta)));
      }
    });
  }

  // -------------------- entregar --------------------

  Future<int> _crearComboVirtualDesdeProducto({
    required int productoId,
    required String nombreProducto,
    required double precioUnitario,
  }) async {
    final nombre = nombreProducto.trim().isEmpty
        ? 'Producto $productoId'
        : nombreProducto.trim();

    final comboId = await db
        .into(db.tablaCombos)
        .insert(
          TablaCombosCompanion.insert(
            nombre: nombre,
            precioVenta: Value(precioUnitario),
            activo: const Value(true),
            creadoEn: Value(DateTime.now()),
          ),
        );

    await db
        .into(db.tablaComponentes)
        .insert(
          TablaComponentesCompanion.insert(
            comboId: comboId,
            productoId: productoId,
            cantidad: 1.0,
          ),
        );

    return comboId;
  }

  Future<bool> ventaEstaCancelada(int ventaId) async {
    final q = db.select(db.tablaPedidos)
      ..where(
        (p) =>
            p.ventaId.equals(ventaId) &
            p.estado.equals(PedidoEstado.cancelado.code),
      )
      ..limit(1);

    final row = await q.getSingleOrNull();
    return row != null;
  }

  Future<void> marcarEntregadoYCrearVenta({required int pedidoId}) async {
    await db.transaction(() async {
      final pRow = await (db.select(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).getSingleOrNull();
      if (pRow == null) throw StateError('Pedido no encontrado');

      final estadoActual = PedidoEstadoX.fromCode(pRow.estado);
      if (estadoActual == PedidoEstado.cancelado) return;
      if (estadoActual == PedidoEstado.entregado && pRow.ventaId != null) {
        return;
      }

      final lineas = await (db.select(
        db.tablaLineasPedido,
      )..where((t) => t.pedidoId.equals(pedidoId))).get();
      final stockDescontadoReal = await _pedidoTieneStockDescontadoReal(
        pedidoId,
      );
      if (!pRow.stockDescontado && !stockDescontadoReal) {
        throw StateError('Primero prepara el pedido para descontar stock');
      }

      final notaVenta = _notaVentaDesdePedido(
        pedidoId: pedidoId,
        cliente: pRow.cliente,
        notaPedido: pRow.nota,
        medioPago: pRow.medioPago,
        envioMonto: pRow.envioMonto,
        estadoPago: pRow.estadoPago,
      );

      final ventaId = await db
          .into(db.tablaVentas)
          .insert(
            TablaVentasCompanion.insert(
              total: Value(pRow.total),
              nota: Value(notaVenta),
            ),
          );

      final combosPorId = <int, String>{};

      for (final l in lineas) {
        int? comboId = l.comboId;

        if (comboId == null && l.productoId != null) {
          comboId = await _crearComboVirtualDesdeProducto(
            productoId: l.productoId!,
            nombreProducto: l.nombre,
            precioUnitario: l.precioUnitario,
          );
          final n = l.nombre.trim();
          combosPorId[comboId] = n.isEmpty ? 'Producto ${l.productoId}' : n;
        }

        if (comboId == null) continue;
        final int comboIdFinal = comboId;

        if (!combosPorId.containsKey(comboIdFinal)) {
          final c = await (db.select(
            db.tablaCombos,
          )..where((t) => t.id.equals(comboIdFinal))).getSingleOrNull();
          if (c != null) {
            final n = c.nombre.trim();
            combosPorId[comboIdFinal] = n.isEmpty ? 'Combo $comboIdFinal' : n;
          }
        }

        await db
            .into(db.tablaLineasVenta)
            .insert(
              TablaLineasVentaCompanion.insert(
                ventaId: ventaId,
                comboId: comboIdFinal,
                productoId: const Value.absent(),
                cantidad: l.cantidad,
                precioUnitario: l.precioUnitario,
                subtotal: l.subtotal,
              ),
            );
      }

      await (db.update(
        db.tablaPedidos,
      )..where((t) => t.id.equals(pedidoId))).write(
        TablaPedidosCompanion(
          estado: Value(PedidoEstado.entregado.code),
          ventaId: Value(ventaId),
          stockDescontado: const Value(true),
        ),
      );
    });
  }
}
