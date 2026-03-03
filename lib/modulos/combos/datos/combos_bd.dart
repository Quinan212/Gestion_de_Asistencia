// lib/modulos/combos/datos/combos_bd.dart
import 'package:drift/drift.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '../modelos/combo.dart';
import '../modelos/componente_combo.dart';

class CombosBd {
  final BaseDeDatos _bd;

  CombosBd(this._bd);

  Future<int> crearCombo({
    required String nombre,
    double precioVenta = 0,
  }) {
    return _bd.into(_bd.tablaCombos).insert(
      TablaCombosCompanion.insert(
        nombre: nombre,
        precioVenta: Value(precioVenta),
      ),
    );
  }
  Future<void> borrarComponentePorId(int componenteId) {
    return (_bd.delete(_bd.tablaComponentes)..where((t) => t.id.equals(componenteId)))
        .go();
  }


  Future<void> actualizarCombo({
    required int id,
    required String nombre,
    required double precioVenta,
    required bool activo,
  }) {
    return (_bd.update(_bd.tablaCombos)..where((t) => t.id.equals(id))).write(
      TablaCombosCompanion(
        nombre: Value(nombre),
        precioVenta: Value(precioVenta),
        activo: Value(activo),
      ),
    );
  }

  Future<List<Combo>> listarCombos({bool incluirInactivos = false}) async {
    final consulta = _bd.select(_bd.tablaCombos);
    if (!incluirInactivos) {
      consulta.where((t) => t.activo.equals(true));
    }
    consulta.orderBy([(t) => OrderingTerm.asc(t.nombre)]);
    final filas = await consulta.get();
    return filas.map(_mapearCombo).toList();
  }

  Future<Combo?> obtenerCombo(int id) async {
    final fila = await (_bd.select(_bd.tablaCombos)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return fila == null ? null : _mapearCombo(fila);
  }

  Future<List<ComponenteCombo>> listarComponentes(int comboId) async {
    final consulta = _bd.select(_bd.tablaComponentes)
      ..where((t) => t.comboId.equals(comboId));
    final filas = await consulta.get();
    return filas.map(_mapearComponente).toList();
  }

  Future<int> agregarComponente({
    required int comboId,
    required int productoId,
    required double cantidad,
  }) {
    return _bd.into(_bd.tablaComponentes).insert(
      TablaComponentesCompanion.insert(
        comboId: comboId,
        productoId: productoId,
        cantidad: cantidad,
      ),
    );
  }

  Future<void> borrarComponentesDeCombo(int comboId) {
    return (_bd.delete(_bd.tablaComponentes)..where((t) => t.comboId.equals(comboId)))
        .go();
  }

  Combo _mapearCombo(TablaCombo fila) {
    return Combo(
      id: fila.id,
      nombre: fila.nombre,
      precioVenta: fila.precioVenta,
      activo: fila.activo,
      creadoEn: fila.creadoEn,
    );
  }

  ComponenteCombo _mapearComponente(TablaComponente fila) {
    return ComponenteCombo(
      id: fila.id,
      comboId: fila.comboId,
      productoId: fila.productoId,
      cantidad: fila.cantidad,
    );
  }
}