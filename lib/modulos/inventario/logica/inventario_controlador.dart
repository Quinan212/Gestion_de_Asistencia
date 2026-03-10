// lib/modulos/inventario/logica/inventario_controlador.dart
import 'package:flutter/foundation.dart';
import '../modelos/producto.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '../datos/inventario_repositorio.dart';
import 'inventario_estado.dart';

class InventarioControlador extends ChangeNotifier {
  final InventarioRepositorio _repo;

  InventarioEstado _estado = InventarioEstado.inicial();
  InventarioEstado get estado => _estado;

  // NUEVO: cache de stock por producto
  Map<int, double> _stockPorProducto = const {};
  Map<int, double> get stockPorProducto => _stockPorProducto;

  InventarioControlador({InventarioRepositorio? repositorio})
    : _repo = repositorio ?? Proveedores.inventarioRepositorio;

  double _stockPropio(int productoId) => _stockPorProducto[productoId] ?? 0.0;

  Producto? _productoPorId(int id) {
    for (final p in _estado.productos) {
      if (p.id == id) return p;
    }
    return null;
  }

  bool _coincideFiltro(Producto p, String f) {
    final nombre = p.nombre.toLowerCase();
    final variante = (p.variante ?? '').toLowerCase();
    final subvariante = (p.subvariante ?? '').toLowerCase();
    final sku = (p.sku ?? '').toLowerCase();
    final nombreCompleto = p.nombreConVariante.toLowerCase();
    return nombre.contains(f) ||
        variante.contains(f) ||
        subvariante.contains(f) ||
        sku.contains(f) ||
        nombreCompleto.contains(f);
  }

  double stockDe(int productoId) {
    final p = _productoPorId(productoId);
    if (p == null) return _stockPropio(productoId);
    if (p.productoPadreId != null) return _stockPropio(productoId);

    double total = _stockPropio(productoId);
    for (final item in _estado.productos) {
      if (item.productoPadreId == productoId) {
        total += _stockPropio(item.id);
      }
    }
    return total;
  }

  Future<void> cargar() async {
    _estado = _estado.copiarCon(cargando: true, error: null);
    notifyListeners();

    try {
      final productos = await _repo.listarProductos(
        incluirInactivos: _estado.mostrarInactivos,
      );

      // batch stock
      final ids = productos.map((p) => p.id).toList();
      final stockMap = await _repo.calcularStockActualPorProductos(ids);

      _stockPorProducto = stockMap;

      _estado = _estado.copiarCon(
        cargando: false,
        productos: productos,
        error: null,
      );
      notifyListeners();
    } catch (e, st) {
      debugPrint('InventarioControlador.cargar error: ${e.toString()}');
      debugPrintStack(stackTrace: st);
      _estado = _estado.copiarCon(
        cargando: false,
        error: 'No se pudo cargar el inventario',
      );
      notifyListeners();
    }
  }

  Future<void> recargarStockSolo() async {
    try {
      final ids = _estado.productos.map((p) => p.id).toList();
      _stockPorProducto = await _repo.calcularStockActualPorProductos(ids);
      notifyListeners();
    } catch (_) {
      // si falla no frenamos UI
    }
  }

  void cambiarFiltro(String texto) {
    _estado = _estado.copiarCon(filtro: texto);
    notifyListeners();
  }

  void cambiarMostrarInactivos(bool valor) {
    _estado = _estado.copiarCon(mostrarInactivos: valor);
    notifyListeners();
    cargar();
  }

  List<Producto> productosFiltrados() {
    final f = _estado.filtro.trim().toLowerCase();
    final bases = _estado.productos
        .where((p) => p.productoPadreId == null)
        .toList();
    if (f.isEmpty) return bases;

    return bases.where((base) {
      if (_coincideFiltro(base, f)) return true;
      for (final item in _estado.productos) {
        if (item.productoPadreId == base.id && _coincideFiltro(item, f)) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  Future<int?> crearProductoRapido({
    required String nombre,
    required String unidad,
  }) async {
    try {
      final id = await _repo.crearProducto(nombre: nombre, unidad: unidad);
      await cargar();
      return id;
    } catch (e, st) {
      debugPrint(
        'InventarioControlador.crearProductoRapido error: ${e.toString()}',
      );
      debugPrintStack(stackTrace: st);
      _estado = _estado.copiarCon(error: 'No se pudo crear el producto');
      notifyListeners();
      return null;
    }
  }
}
