// lib/modulos/pedidos/pantallas/pedido_detalle_pantalla.dart
import 'package:flutter/material.dart';
import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/pedidos/modelos/linea_pedido.dart';
import 'package:gestion_de_stock/modulos/pedidos/modelos/pedido.dart';

class PedidoDetallePantalla extends StatefulWidget {
  final int pedidoId;
  final bool embebido;
  final VoidCallback? alCambiarAlgo;

  const PedidoDetallePantalla({
    super.key,
    required this.pedidoId,
    this.embebido = false,
    this.alCambiarAlgo,
  });

  @override
  State<PedidoDetallePantalla> createState() => _PedidoDetallePantallaState();
}

class _PedidoDetallePantallaState extends State<PedidoDetallePantalla> {
  String _moneda = r'$';

  late Future<Pedido?> _pedidoF;
  late Future<List<LineaPedido>> _lineasF;

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
    _refrescar();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PedidoDetallePantalla oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pedidoId != widget.pedidoId) {
      setState(_refrescar);
      if (_scrollCtrl.hasClients) _scrollCtrl.jumpTo(0);
    }
  }

  void _refrescar() {
    _pedidoF = Proveedores.pedidosRepositorio.obtenerPedido(widget.pedidoId);
    _lineasF = Proveedores.pedidosRepositorio.listarLineas(widget.pedidoId);
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Color _colorEstado(PedidoEstado st) {
    final cs = Theme.of(context).colorScheme;
    switch (st) {
      case PedidoEstado.encargado:
        return cs.primary;
      case PedidoEstado.preparado:
        return cs.tertiary;
      case PedidoEstado.entregado:
        return Colors.green;
      case PedidoEstado.cancelado:
        return cs.error;
      case PedidoEstado.borrador:
      default:
        return cs.onSurfaceVariant;
    }
  }

  Widget _chipEstado(PedidoEstado st) {
    final c = _colorEstado(st);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: c.withValues(alpha: 0.10),
        border: Border.all(color: c.withValues(alpha: 0.22)),
      ),
      child: Text(
        st.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: c,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _cambiarEstado(Pedido p, PedidoEstado nuevo) async {
    if (p.estado == nuevo) return;

    // solo bloqueamos si está cancelado
    if (p.estado == PedidoEstado.cancelado) return;

    // si el usuario marca "Entregado" desde acá y todavía no hay venta, usamos la lógica de entregar
    if (nuevo == PedidoEstado.entregado && p.ventaId == null) {
      await _entregar(p);
      return;
    }

    await Proveedores.pedidosRepositorio.cambiarEstado(
      pedidoId: p.id,
      estado: nuevo,
      recalcularReservasSiEncargado: (nuevo == PedidoEstado.encargado),
    );

    if (!mounted) return;
    widget.alCambiarAlgo?.call();
    setState(_refrescar);
  }

  Future<void> _cancelarPedido(Pedido p) async {
    if (p.estado == PedidoEstado.cancelado) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('Deja el pedido cancelado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await Proveedores.pedidosRepositorio.cancelarPedido(pedidoId: p.id);

    if (!mounted) return;
    widget.alCambiarAlgo?.call();

    if (!widget.embebido) {
      Navigator.pop(context);
    } else {
      setState(_refrescar);
    }
  }

  Future<void> _entregar(Pedido p) async {
    if (p.estado == PedidoEstado.cancelado) return;
    if (p.estado == PedidoEstado.entregado) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Marcar entregado'),
        content: const Text('Crea la venta y registra movimientos de stock.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entregar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await Proveedores.pedidosRepositorio.marcarEntregadoYCrearVenta(pedidoId: p.id);

    if (!mounted) return;
    widget.alCambiarAlgo?.call();
    setState(_refrescar);
  }

  Future<void> _actualizarPago({
    required int pedidoId,
    String? medioPago,
    String? estadoPago,
  }) async {
    await Proveedores.pedidosRepositorio.actualizarPago(
      pedidoId: pedidoId,
      medioPago: medioPago,
      estadoPago: estadoPago,
    );

    if (!mounted) return;
    widget.alCambiarAlgo?.call();
    setState(_refrescar);
  }

  Widget _bloque(String titulo, List<Widget> hijos) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...hijos,
          ],
        ),
      ),
    );
  }

  Widget _fila(String label, String value, {bool strong = false}) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: strong
                    ? t.titleMedium?.copyWith(fontWeight: FontWeight.w800)
                    : t.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contenido() {
    return FutureBuilder<Pedido?>(
      future: _pedidoF,
      builder: (context, snapP) {
        if (snapP.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = snapP.data;
        if (p == null) return const Center(child: Text('Pedido no encontrado'));

        return FutureBuilder<List<LineaPedido>>(
          future: _lineasF,
          builder: (context, snapL) {
            if (snapL.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final lineas = snapL.data ?? [];
            final cs = Theme.of(context).colorScheme;
            final est = p.estado;

            final bool puedeEditarPago = est != PedidoEstado.cancelado;

            final list = Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                controller: _scrollCtrl,
                primary: false,
                padding: EdgeInsets.zero,
                children: [
                  if (widget.embebido) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (p.cliente ?? '').trim().isEmpty
                                ? 'Pedido'
                                : (p.cliente ?? '').trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        _chipEstado(est),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      if (!widget.embebido) _chipEstado(est),
                      if (est != PedidoEstado.cancelado && est != PedidoEstado.entregado)
                        FilledButton.tonal(
                          onPressed: () => _entregar(p),
                          child: const Text('Entregar'),
                        ),
                      if (est != PedidoEstado.cancelado)
                        OutlinedButton(
                          onPressed: () => _cancelarPedido(p),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _bloque(
                    'Estado',
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: (est == PedidoEstado.borrador)
                                ? null
                                : () => _cambiarEstado(p, PedidoEstado.borrador),
                            child: const Text('Borrador'),
                          ),
                          OutlinedButton(
                            onPressed: () => _cambiarEstado(p, PedidoEstado.encargado),
                            child: const Text('Encargado'),
                          ),
                          OutlinedButton(
                            onPressed: () => _cambiarEstado(p, PedidoEstado.preparado),
                            child: const Text('Preparado'),
                          ),

                          // si ya está entregado, igual permitimos "reabrir" a preparado/encargado/borrador arriba.
                          // este botón deja marcar entregado manual (si no hay venta va por _entregar)
                          OutlinedButton(
                            onPressed: () => _cambiarEstado(p, PedidoEstado.entregado),
                            child: const Text('Entregado'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        est == PedidoEstado.entregado
                            ? (p.ventaId == null
                            ? 'Entregado'
                            : 'Entregado (se generó venta)')
                            : est == PedidoEstado.cancelado
                            ? 'Cancelado'
                            : 'Podés cambiar el estado.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      if (p.ventaId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Venta vinculada: #${p.ventaId}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  _bloque(
                    'Totales',
                    [
                      // subtotal es lo importante
                      _fila('Subtotal', Formatos.dinero(_moneda, p.subtotal), strong: true),
                      _fila('Envío', p.envioMonto > 0 ? Formatos.dinero(_moneda, p.envioMonto) : '-'),
                      _fila('Total (con envío)', Formatos.dinero(_moneda, p.total)),
                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: (p.medioPago).trim().isEmpty ? 'Efectivo' : p.medioPago,
                        items: const [
                          DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                          DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                          DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                        ],
                        onChanged: puedeEditarPago
                            ? (v) async {
                          if (v == null) return;
                          await _actualizarPago(pedidoId: p.id, medioPago: v);
                        }
                            : null,
                        decoration: const InputDecoration(labelText: 'Medio de pago'),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: (p.estadoPago).trim().isEmpty ? 'pendiente' : p.estadoPago,
                        items: const [
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                          DropdownMenuItem(value: 'parcial', child: Text('Parcial')),
                        ],
                        onChanged: puedeEditarPago
                            ? (v) async {
                          if (v == null) return;
                          await _actualizarPago(pedidoId: p.id, estadoPago: v);
                        }
                            : null,
                        decoration: const InputDecoration(labelText: 'Estado de pago'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _bloque(
                    'Nota',
                    [
                      Text((p.nota ?? '').trim().isEmpty ? '-' : (p.nota ?? '').trim()),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text('Descripción de la venta', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  if (lineas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: Text('Sin líneas')),
                    )
                  else
                    for (final l in lineas)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            title: Text(l.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              'Cant: ${l.cantidad.toStringAsFixed(2)} ${l.unidad}  •  PU: ${Formatos.dinero(_moneda, l.precioUnitario)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              Formatos.dinero(_moneda, l.subtotal),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            );

            if (widget.embebido) return Material(color: Colors.transparent, child: list);
            return list;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embebido) return _contenido();

    return Scaffold(
      appBar: AppBar(title: const Text('Pedido')),
      body: _contenido(),
    );
  }
}