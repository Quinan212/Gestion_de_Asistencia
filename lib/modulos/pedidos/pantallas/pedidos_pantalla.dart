// lib/modulos/pedidos/pantallas/pedidos_pantalla.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/filtros_persistidos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/estado_lista.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/fila_lista_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/panel_controles_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/pedidos/logica/pedidos_controlador.dart';
import 'package:gestion_de_asistencias/modulos/pedidos/modelos/pedido.dart';
import 'package:gestion_de_asistencias/modulos/pedidos/pantallas/pedido_detalle_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/pedidos/pantallas/pedido_nuevo_sheet.dart';

class PedidosPantalla extends StatefulWidget {
  const PedidosPantalla({super.key});

  @override
  State<PedidosPantalla> createState() => _PedidosPantallaState();
}

class _PedidosPantallaState extends State<PedidosPantalla> {
  static const double kTablet = LayoutApp.kTablet;
  static const _kBusquedaKey = 'pedidos_busqueda_v1';
  static const _kMostrarCanceladosKey = 'pedidos_mostrar_cancelados_v1';

  late final PedidosControlador _c;
  final _buscarCtrl = TextEditingController();
  late final VoidCallback _datosVersionListener;
  bool _creandoNuevoPedido = false;

  static const _fixKey = 'fix_cancelados_stock_y_ventas_v2_done';

  @override
  void initState() {
    super.initState();

    _c = PedidosControlador();
    _c.cargar();
    _restaurarFiltros();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);

    _buscarCtrl.addListener(() {
      final t = _buscarCtrl.text;
      _c.cambiarBusqueda(t);
      FiltrosPersistidos.guardarTexto(_kBusquedaKey, t);
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFixCanceladosUnaVez();
    });
  }

  Future<void> _restaurarFiltros() async {
    final q = await FiltrosPersistidos.leerTexto(_kBusquedaKey);
    final mostrarCancelados = await FiltrosPersistidos.leerBool(
      _kMostrarCanceladosKey,
    );
    if (!mounted) return;
    _buscarCtrl.text = q;
    _c.cambiarBusqueda(q);
    _c.cambiarMostrarCancelados(mostrarCancelados);
    setState(() {});
  }

  void _onCambiarMostrarCancelados(bool value) {
    _c.cambiarMostrarCancelados(value);
    FiltrosPersistidos.guardarBool(_kMostrarCanceladosKey, value);
  }

  Future<void> _runFixCanceladosUnaVez() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final yaCorrio = prefs.getBool(_fixKey) ?? false;
      if (yaCorrio) return;

      // 1) repone stock de pedidos cancelados retroactivos (si corresponde)
      await Proveedores.pedidosRepositorio
          .repararStockDeCanceladosRetroactivo();
      await Proveedores.pedidosRepositorio
          .marcarVentasDePedidosCanceladosRetroactivo();
      await prefs.setBool(_fixKey, true);

      await _c.cargar();
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      // si falla no frenamos la pantalla ni mostramos nada
    }
  }

  void _onDatosVersionChanged() {
    _c.cargar();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    _buscarCtrl.dispose();
    _c.dispose();
    super.dispose();
  }

  bool _esTablet(BoxConstraints c) => c.maxWidth >= kTablet;

  Future<void> _nuevoPedido() async {
    final w = MediaQuery.of(context).size.width;
    if (w >= kTablet) {
      setState(() => _creandoNuevoPedido = true);
      return;
    }

    final id = await showPedidoNuevoSheet(context);
    if (!mounted || id == null) return;

    await _c.cargar();
    if (!mounted) return;

    _c.seleccionar(id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PedidoDetallePantalla(pedidoId: id)),
    );
  }

  Future<void> _onPedidoCreado(int id) async {
    await _c.cargar();
    if (!mounted) return;
    _c.seleccionar(id);
    setState(() => _creandoNuevoPedido = false);
  }

  void _cancelarNuevoPedido() {
    if (!mounted) return;
    setState(() => _creandoNuevoPedido = false);
  }

  void _seleccionarPedido(int id, {required bool ancha}) {
    if (ancha) {
      setState(() {
        _creandoNuevoPedido = false;
      });
      _c.seleccionar(id);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PedidoDetallePantalla(pedidoId: id)),
    );
  }

  Widget _toolbar() {
    return PanelControlesModulo(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _nuevoPedido,
              icon: const Icon(Icons.add),
              label: Text(
                _creandoNuevoPedido ? 'Editando nuevo pedido' : 'Nuevo pedido',
              ),
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
                onChanged: _onCambiarMostrarCancelados,
              );
            },
          ),
        ],
      ),
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

    final titulo = _tituloPedido(p);
    final subtitulo = p.estado.label;

    return FilaListaModulo(
      onTap: () {
        _seleccionarPedido(p.id, ancha: ancha);
      },
      selected: seleccionada,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(
          p.cancelado ? Icons.block : Icons.local_shipping_outlined,
          color: cs.onSurfaceVariant,
        ),
      ),
      title: Text(
        titulo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: p.cancelado ? cs.onSurfaceVariant : null,
        ),
      ),
      subtitle: Text(
        subtitulo,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: _badgeEstado(p.estado),
    );
  }

  Widget _listaPedidos({required bool ancha}) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final e = _c.estado;

        if (e.cargando) {
          return const Expanded(
            child: EstadoListaCargando(mensaje: 'Cargando pedidos...'),
          );
        }
        if (e.error != null) {
          return Expanded(
            child: EstadoListaError(
              mensaje: e.error!,
              alReintentar: () {
                _c.cargar();
              },
            ),
          );
        }

        final list = _c.pedidosFiltrados();
        if (list.isEmpty) {
          return Expanded(
            child: EstadoListaVacia(
              titulo: _buscarCtrl.text.trim().isEmpty
                  ? 'Todavia no hay pedidos'
                  : 'Sin resultados',
              icono: Icons.local_shipping_outlined,
            ),
          );
        }

        return Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
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

        Widget panelLista({required bool conPadding}) {
          final contenido = Column(
            children: [
              _toolbar(),
              const SizedBox(height: 6),
              _listaPedidos(ancha: ancha),
            ],
          );
          if (!conPadding) return contenido;
          return Padding(
            padding: TabletMasterDetailLayout.kPagePadding,
            child: contenido,
          );
        }

        if (!ancha) return panelLista(conPadding: true);

        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final id = _c.estado.seleccionadoId;

            return Padding(
              padding: TabletMasterDetailLayout.kPagePadding,
              child: TabletMasterDetailLayout(
                master: panelLista(conPadding: false),
                detail: Card(
                  clipBehavior: Clip.antiAlias,
                  child: RepaintBoundary(
                    child: KeyedSubtree(
                      key: ValueKey<String>(
                        _creandoNuevoPedido
                            ? 'pedido_nuevo'
                            : 'pedido_detalle_${id ?? 0}',
                      ),
                      child: _creandoNuevoPedido
                          ? PedidoNuevoPanel(
                              embebido: true,
                              onCreado: (id) {
                                _onPedidoCreado(id);
                              },
                              onCancelar: _cancelarNuevoPedido,
                            )
                          : Padding(
                              padding: const EdgeInsets.all(12),
                              child: id == null
                                  ? const Center(
                                      child: Text(
                                        'Selecciona un pedido para ver detalles',
                                      ),
                                    )
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
              ),
            );
          },
        );
      },
    );
  }
}
