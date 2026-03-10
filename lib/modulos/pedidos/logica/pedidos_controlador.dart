// lib/modulos/pedidos/logica/pedidos_controlador.dart
import 'package:flutter/foundation.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/pedidos/modelos/pedido.dart';

class PedidosEstadoVM {
  final bool cargando;
  final bool accionando; // acciones sobre un pedido (cambiar estado / cancelar / entregar)
  final String? error;

  final List<Pedido> pedidos;

  final bool mostrarCancelados;
  final String q;

  final int? seleccionadoId; // tablet master-detail

  const PedidosEstadoVM({
    required this.cargando,
    required this.accionando,
    required this.error,
    required this.pedidos,
    required this.mostrarCancelados,
    required this.q,
    required this.seleccionadoId,
  });

  PedidosEstadoVM copyWith({
    bool? cargando,
    bool? accionando,
    String? error,
    List<Pedido>? pedidos,
    bool? mostrarCancelados,
    String? q,
    int? seleccionadoId,
    bool clearError = false,
  }) {
    return PedidosEstadoVM(
      cargando: cargando ?? this.cargando,
      accionando: accionando ?? this.accionando,
      error: clearError ? null : (error ?? this.error),
      pedidos: pedidos ?? this.pedidos,
      mostrarCancelados: mostrarCancelados ?? this.mostrarCancelados,
      q: q ?? this.q,
      seleccionadoId: seleccionadoId ?? this.seleccionadoId,
    );
  }
}

class PedidosControlador extends ChangeNotifier {
  PedidosEstadoVM _estado = const PedidosEstadoVM(
    cargando: true,
    accionando: false,
    error: null,
    pedidos: [],
    mostrarCancelados: false,
    q: '',
    seleccionadoId: null,
  );

  PedidosEstadoVM get estado => _estado;

  Future<void> cargar() async {
    _estado = _estado.copyWith(cargando: true, clearError: true);
    notifyListeners();

    try {
      final pedidos = await Proveedores.pedidosRepositorio.listarPedidos();

      int? sel = _estado.seleccionadoId;
      if (sel != null && !pedidos.any((p) => p.id == sel)) {
        sel = null;
      }

      _estado = _estado.copyWith(
        cargando: false,
        pedidos: pedidos,
        seleccionadoId: sel,
        clearError: true,
      );
      notifyListeners();
    } catch (e, st) {
      debugPrint('PedidosControlador.cargar error: ${e.toString()}');
      debugPrintStack(stackTrace: st);
      _estado = _estado.copyWith(cargando: false, error: 'No se pudo cargar');
      notifyListeners();
    }
  }

  void seleccionar(int? pedidoId) {
    _estado = _estado.copyWith(seleccionadoId: pedidoId);
    notifyListeners();
  }

  void cambiarMostrarCancelados(bool v) {
    _estado = _estado.copyWith(mostrarCancelados: v);
    notifyListeners();
  }

  void cambiarBusqueda(String q) {
    _estado = _estado.copyWith(q: q.trim());
    notifyListeners();
  }

  List<Pedido> pedidosFiltrados() {
    final q = _estado.q.trim().toLowerCase();
    var list = _estado.pedidos;

    if (!_estado.mostrarCancelados) {
      list = list.where((p) => p.estado != PedidoEstado.cancelado).toList();
    }

    if (q.isNotEmpty) {
      list = list.where((p) {
        final c = (p.cliente ?? '').toLowerCase();
        final n = (p.nota ?? '').toLowerCase();
        return c.contains(q) || n.contains(q) || p.estado.label.toLowerCase().contains(q);
      }).toList();
    }

    list.sort((a, b) => b.fecha.compareTo(a.fecha));
    return list;
  }

  Future<void> cambiarEstado({
    required int pedidoId,
    required PedidoEstado estado,
    bool recalcularReservasSiEncargado = true,
  }) async {
    _estado = _estado.copyWith(accionando: true, clearError: true);
    notifyListeners();

    try {
      await Proveedores.pedidosRepositorio.cambiarEstado(
        pedidoId: pedidoId,
        estado: estado,
        recalcularReservasSiEncargado: recalcularReservasSiEncargado,
      );
      await cargar();
    } catch (_) {
      _estado = _estado.copyWith(accionando: false, error: 'No se pudo cambiar el estado');
      notifyListeners();
    }
  }

  Future<void> cancelarPedido(int pedidoId) async {
    _estado = _estado.copyWith(accionando: true, clearError: true);
    notifyListeners();

    try {
      await Proveedores.pedidosRepositorio.cancelarPedido(pedidoId: pedidoId);
      await cargar();
    } catch (_) {
      _estado = _estado.copyWith(accionando: false, error: 'No se pudo cancelar');
      notifyListeners();
    }
  }

  // clave del cambio que pediste: la venta se crea acá
  Future<void> marcarEntregadoYCrearVenta(int pedidoId) async {
    _estado = _estado.copyWith(accionando: true, clearError: true);
    notifyListeners();

    try {
      await Proveedores.pedidosRepositorio.marcarEntregadoYCrearVenta(pedidoId: pedidoId);
      await cargar();
    } catch (_) {
      _estado = _estado.copyWith(accionando: false, error: 'No se pudo marcar como entregado');
      notifyListeners();
    }
  }
}
