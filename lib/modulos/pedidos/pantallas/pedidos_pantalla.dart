// lib/modulos/pedidos/pantallas/pedidos_pantalla.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/pedidos/logica/pedidos_controlador.dart';
import 'package:gestion_de_stock/modulos/pedidos/modelos/pedido.dart';
import 'package:gestion_de_stock/modulos/pedidos/pantallas/pedido_detalle_pantalla.dart';
import 'package:gestion_de_stock/modulos/pedidos/pantallas/pedido_nuevo_sheet.dart';

class PedidosPantalla extends StatefulWidget {
  const PedidosPantalla({super.key});

  @override
  State<PedidosPantalla> createState() => _PedidosPantallaState();
}

class _PedidosPantallaState extends State<PedidosPantalla> {
  static const double kTablet = 900;

  late final PedidosControlador _c;
  final _buscarCtrl = TextEditingController();

  static const _fixKey = 'fix_cancelados_stock_y_ventas_v2_done';

  @override
  void initState() {
    super.initState();

    _c = PedidosControlador();
    _c.cargar();

    _buscarCtrl.addListener(() {
      _c.cambiarBusqueda(_buscarCtrl.text);
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFixCanceladosUnaVez();
    });
  }

  Future<void> _runFixCanceladosUnaVez() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final yaCorrio = prefs.getBool(_fixKey) ?? false;
      if (yaCorrio) return;

      // 1) repone stock de pedidos cancelados retroactivos (si corresponde)
      await Proveedores.pedidosRepositorio.repararStockDeCanceladosRetroactivo();
      await Proveedores.pedidosRepositorio.marcarVentasDePedidosCanceladosRetroactivo();
      await prefs.setBool(_fixKey, true);

      await _c.cargar();
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      // si falla no frenamos la pantalla ni mostramos nada
    }
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    _c.dispose();
    super.dispose();
  }

  bool _esTablet(BoxConstraints c) => c.maxWidth >= kTablet;

  Future<void> _nuevoPedido() async {
    final id = await showPedidoNuevoSheet(context);
    if (!mounted) return;

    await _c.cargar();
    if (!mounted) return;

    if (id != null) {
      _c.seleccionar(id);

      final w = MediaQuery.of(context).size.width;
      if (w < kTablet) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PedidoDetallePantalla(pedidoId: id)),
        );
      }
    }
  }

  Widget _toolbar() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _nuevoPedido,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo pedido'),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _buscarCtrl,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Buscar pedido',
            suffixIcon: _buscarCtrl.text.trim().isEmpty
                ? null
                : IconButton(
              onPressed: () {
                _buscarCtrl.clear();
                FocusScope.of(context).unfocus();
              },
              icon: const Icon(Icons.close),
              tooltip: 'Limpiar',
            ),
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final e = _c.estado;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mostrar cancelados'),
              value: e.mostrarCancelados,
              onChanged: _c.cambiarMostrarCancelados,
            );
          },
        ),
      ],
    );
  }

  Widget _badgeEstado(PedidoEstado st) {
    final cs = Theme.of(context).colorScheme;

    late final Color color;
    switch (st) {
      case PedidoEstado.encargado:
        color = cs.primary;
        break;
      case PedidoEstado.preparado:
        color = cs.tertiary;
        break;
      case PedidoEstado.entregado:
        color = Colors.green;
        break;
      case PedidoEstado.cancelado:
        color = cs.error;
        break;
      case PedidoEstado.borrador:
        color = cs.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        st.label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _tituloPedido(Pedido p) {
    final cliente = (p.cliente ?? '').trim();
    if (cliente.isNotEmpty) return cliente;
    return 'Pedido #${p.id}';
  }

  Widget _filaPedido({
    required bool ancha,
    required Pedido p,
    required bool seleccionada,
  }) {
    final cs = Theme.of(context).colorScheme;
    final bgSel = cs.primary.withValues(alpha: 0.08);

    final titulo = _tituloPedido(p);
    final subtitulo = p.estado.label;

    return InkWell(
      onTap: () {
        if (ancha) {
          _c.seleccionar(p.id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PedidoDetallePantalla(pedidoId: p.id)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: seleccionada ? bgSel : null,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(
                p.cancelado ? Icons.block : Icons.local_shipping_outlined,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: p.cancelado ? cs.onSurfaceVariant : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _badgeEstado(p.estado),
          ],
        ),
      ),
    );
  }

  Widget _listaPedidos({required bool ancha}) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final e = _c.estado;

        if (e.cargando) {
          return const Expanded(child: Center(child: CircularProgressIndicator()));
        }
        if (e.error != null) {
          return Expanded(child: Center(child: Text(e.error!)));
        }

        final list = _c.pedidosFiltrados();
        if (list.isEmpty) {
          return const Expanded(child: Center(child: Text('Todavía no hay pedidos')));
        }

        if (ancha && e.seleccionadoId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final now = _c.estado;
            if (now.seleccionadoId == null && list.isNotEmpty) {
              _c.seleccionar(list.first.id);
            }
          });
        }

        return Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = list[i];
              final sel = ancha && e.seleccionadoId == p.id;
              return _filaPedido(ancha: ancha, p: p, seleccionada: sel);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancha = _esTablet(c);

        Widget panelLista() {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _toolbar(),
                const SizedBox(height: 6),
                _listaPedidos(ancha: ancha),
              ],
            ),
          );
        }

        if (!ancha) return panelLista();

        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final id = _c.estado.seleccionadoId;

            return Row(
              children: [
                Expanded(flex: 4, child: panelLista()),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: id == null
                            ? const Center(child: Text('Elegí un pedido'))
                            : PedidoDetallePantalla(
                          pedidoId: id,
                          embebido: true,
                          alCambiarAlgo: () async {
                            await _c.cargar();
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}