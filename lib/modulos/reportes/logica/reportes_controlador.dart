// lib/modulos/reportes/logica/reportes_controlador.dart
import 'package:flutter/foundation.dart';

import '/infraestructura/dep_inyeccion/proveedores.dart';
import '../datos/reportes_repositorio.dart';

class ReportesControlador extends ChangeNotifier {
  final ReportesRepositorio _repo;
  List<Map<String, dynamic>> consumo = [];
  bool cargando = false;
  String? error;

  List<Map<String, dynamic>> ventasDia = [];
  List<Map<String, dynamic>> reposicion = [];

  ReportesControlador({ReportesRepositorio? repositorio})
      : _repo = repositorio ?? ReportesRepositorio(Proveedores.baseDeDatos);

  Future<void> cargarTodo() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      consumo = await _repo.consumoPorProducto(dias: 30);
      ventasDia = await _repo.ventasPorDia(dias: 14);
      reposicion = await _repo.reposicionPorMinimo();
    } catch (_) {
      error = 'No se pudieron cargar los reportes';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}