import 'package:flutter/foundation.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '../datos/combos_repositorio.dart';
import 'combos_estado.dart';

class CombosControlador extends ChangeNotifier {
  final CombosRepositorio _repo;

  CombosEstado _estado = CombosEstado.inicial();
  CombosEstado get estado => _estado;

  CombosControlador({CombosRepositorio? repositorio})
      : _repo = repositorio ?? Proveedores.combosRepositorio;

  Future<void> cargar() async {
    _estado = _estado.copiarCon(cargando: true, error: null);
    notifyListeners();

    try {
      final combos = await _repo.listarCombos(
        incluirInactivos: _estado.mostrarInactivos,
      );

      final visibles = combos.where((c) {
        final n = c.nombre.trim().toLowerCase();
        return !n.startsWith('venta directa ');
      }).toList();

      _estado = _estado.copiarCon(cargando: false, combos: visibles, error: null);
      notifyListeners();
    } catch (e, st) {
      debugPrint('CombosControlador.cargar error: ${e.toString()}');
      debugPrintStack(stackTrace: st);
      _estado = _estado.copiarCon(
        cargando: false,
        error: 'No se pudieron cargar los combos',
      );
      notifyListeners();
    }
  }

  void cambiarMostrarInactivos(bool valor) {
    _estado = _estado.copiarCon(mostrarInactivos: valor);
    notifyListeners();
    cargar();
  }

  Future<int?> crearComboRapido({
    required String nombre,
    double precioVenta = 0,
  }) async {
    try {
      final id = await _repo.crearCombo(nombre: nombre, precioVenta: precioVenta);
      await cargar();
      return id;
    } catch (e, st) {
      debugPrint('CombosControlador.crearComboRapido error: ${e.toString()}');
      debugPrintStack(stackTrace: st);
      _estado = _estado.copiarCon(error: 'No se pudo crear el combo');
      notifyListeners();
      return null;
    }
  }
}