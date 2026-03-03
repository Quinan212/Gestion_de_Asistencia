// lib/modulos/combos/datos/combos_repositorio.dart
import '/infraestructura/base_de_datos/base_de_datos.dart';
import 'combos_bd.dart';
import '../modelos/combo.dart';
import '../modelos/componente_combo.dart';

class CombosRepositorio {
  final CombosBd _bd;

  CombosRepositorio(BaseDeDatos baseDeDatos) : _bd = CombosBd(baseDeDatos);

  Future<int> crearCombo({required String nombre, double precioVenta = 0}) {
    return _bd.crearCombo(nombre: nombre, precioVenta: precioVenta);
  }

  Future<void> actualizarCombo({
    required int id,
    required String nombre,
    required double precioVenta,
    required bool activo,
  }) {
    return _bd.actualizarCombo(
      id: id,
      nombre: nombre,
      precioVenta: precioVenta,
      activo: activo,
    );
  }

  Future<List<Combo>> listarCombos({bool incluirInactivos = false}) {
    return _bd.listarCombos(incluirInactivos: incluirInactivos);
  }

  Future<Combo?> obtenerCombo(int id) => _bd.obtenerCombo(id);

  Future<List<ComponenteCombo>> listarComponentes(int comboId) {
    return _bd.listarComponentes(comboId);
  }

  Future<int> agregarComponente({
    required int comboId,
    required int productoId,
    required double cantidad,
  }) {
    return _bd.agregarComponente(
      comboId: comboId,
      productoId: productoId,
      cantidad: cantidad,
    );
  }
  Future<void> borrarComponentePorId(int componenteId) {
    return _bd.borrarComponentePorId(componenteId);
  }
  Future<void> borrarComponentesDeCombo(int comboId) {
    return _bd.borrarComponentesDeCombo(comboId);
  }
}