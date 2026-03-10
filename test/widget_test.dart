import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_de_asistencias/modulos/pedidos/modelos/pedido.dart';

void main() {
  test('PedidoEstadoX.fromCode mapea correctamente', () {
    expect(PedidoEstadoX.fromCode('borrador'), PedidoEstado.borrador);
    expect(PedidoEstadoX.fromCode('encargado'), PedidoEstado.encargado);
    expect(PedidoEstadoX.fromCode('preparado'), PedidoEstado.preparado);
    expect(PedidoEstadoX.fromCode('entregado'), PedidoEstado.entregado);
    expect(PedidoEstadoX.fromCode('cancelado'), PedidoEstado.cancelado);

    expect(PedidoEstadoX.fromCode('desconocido'), PedidoEstado.borrador);
    expect(PedidoEstadoX.fromCode('  CANCELADO  '), PedidoEstado.cancelado);
  });
}
