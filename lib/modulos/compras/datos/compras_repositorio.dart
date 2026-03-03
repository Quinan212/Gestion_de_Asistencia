import '/infraestructura/base_de_datos/base_de_datos.dart';
import 'compras_bd.dart';
import '../modelos/compra.dart';
import '../modelos/linea_compra.dart';

class ComprasRepositorio {
  final ComprasBd _bd;
  Future<void> actualizarNotaCompra({required int compraId, required String? nota}) {
    return _bd.actualizarNotaCompra(compraId: compraId, nota: nota);
  }
  ComprasRepositorio(BaseDeDatos baseDeDatos) : _bd = ComprasBd(baseDeDatos);

  Future<int> crearCompra({
    String? proveedor,
    double total = 0,
    String? nota,
    DateTime? fecha,
  }) {
    return _bd.crearCompra(
      proveedor: proveedor,
      total: total,
      nota: nota,
      fecha: fecha,
    );
  }

  Future<int> agregarLinea({
    required int compraId,
    required int productoId,
    required double cantidad,
    required double costoUnitario,
  }) {
    return _bd.agregarLinea(
      compraId: compraId,
      productoId: productoId,
      cantidad: cantidad,
      costoUnitario: costoUnitario,
    );
  }

  Future<void> actualizarTotalCompra({
    required int compraId,
    required double total,
  }) {
    return _bd.actualizarTotalCompra(compraId: compraId, total: total);
  }

  Future<List<Compra>> listarCompras() => _bd.listarCompras();

  Future<Compra?> obtenerCompra(int id) => _bd.obtenerCompra(id);

  Future<List<LineaCompra>> listarLineas(int compraId) => _bd.listarLineas(compraId);
}