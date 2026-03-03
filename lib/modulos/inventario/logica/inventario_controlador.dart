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

  InventarioControlador({InventarioRepositorio? repositorio})
      : _repo = repositorio ?? Proveedores.inventarioRepositorio;

  Future<void> cargar() async {
    _estado = _estado.copiarCon(cargando: true, error: null);
    notifyListeners();

    try {
      final productos = await _repo.listarProductos(
        incluirInactivos: _estado.mostrarInactivos,
      );
      _estado = _estado.copiarCon(
        cargando: false,
        productos: productos,
        error: null,
      );
      notifyListeners();
    } catch (_) {
      _estado = _estado.copiarCon(
        cargando: false,
        error: 'No se pudo cargar el inventario',
      );
      notifyListeners();
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
    if (f.isEmpty) return _estado.productos;
    return _estado.productos.where((p) => p.nombre.toLowerCase().contains(f)).toList();
  }

  Future<int?> crearProductoRapido({
    required String nombre,
    required String unidad,
  }) async {
    try {
      final id = await _repo.crearProducto(nombre: nombre, unidad: unidad);
      await cargar();
      return id;
    } catch (_) {
      _estado = _estado.copiarCon(error: 'No se pudo crear el producto');
      notifyListeners();
      return null;
    }
  }
}