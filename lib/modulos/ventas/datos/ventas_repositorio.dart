import '/infraestructura/base_de_datos/base_de_datos.dart';
import 'ventas_bd.dart';
import '../modelos/venta.dart';
import '../modelos/linea_venta.dart';

class VentasRepositorio {
  final VentasBd _bd;

  VentasRepositorio(BaseDeDatos baseDeDatos) : _bd = VentasBd(baseDeDatos);

  Future<void> actualizarNotaVenta({required int ventaId, required String? nota}) {
    return _bd.actualizarNotaVenta(ventaId: ventaId, nota: nota);
  }

  Future<int> crearVenta({double total = 0, String? nota, DateTime? fecha}) {
    return _bd.crearVenta(total: total, nota: nota, fecha: fecha);
  }

  // Combo (compatibilidad con tu API anterior)
  Future<int> agregarLinea({
    required int ventaId,
    required int comboId,
    required double cantidad,
    required double precioUnitario,
  }) {
    return _bd.agregarLineaCombo(
      ventaId: ventaId,
      comboId: comboId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
  }

  // NUEVO: producto
  Future<int> agregarLineaProducto({
    required int ventaId,
    required int productoId,
    required double cantidad,
    required double precioUnitario,
  }) {
    return _bd.agregarLineaProducto(
      ventaId: ventaId,
      productoId: productoId,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
    );
  }

  Future<void> actualizarTotalVenta({required int ventaId, required double total}) {
    return _bd.actualizarTotalVenta(ventaId: ventaId, total: total);
  }

  Future<List<Venta>> listarVentas() => _bd.listarVentas();

  Future<Venta?> obtenerVenta(int id) => _bd.obtenerVenta(id);

  Future<List<LineaVenta>> listarLineas(int ventaId) => _bd.listarLineas(ventaId);
}