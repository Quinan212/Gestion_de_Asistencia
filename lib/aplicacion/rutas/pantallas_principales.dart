// lib/aplicacion/pantallas_principales.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/inventario/pantallas/inventario_pantalla.dart'
    as inv;
import 'package:gestion_de_asistencias/modulos/combos/pantallas/combos_pantalla.dart'
    as cmb;
import 'package:gestion_de_asistencias/modulos/pedidos/pantallas/pedidos_pantalla.dart'
    as ped;
import 'package:gestion_de_asistencias/modulos/ventas/pantallas/ventas_pantalla.dart'
    as ven;
import 'package:gestion_de_asistencias/modulos/compras/pantallas/compras_pantalla.dart'
    as com;
import 'package:gestion_de_asistencias/modulos/reportes/pantallas/reportes_pantalla.dart'
    as rep;

class PantallasPrincipales extends StatefulWidget {
  const PantallasPrincipales({super.key});

  @override
  State<PantallasPrincipales> createState() => _PantallasPrincipalesState();
}

class _PantallasPrincipalesState extends State<PantallasPrincipales> {
  static const _fixNotasVentasLegacyKey =
      'fix_notas_ventas_legacy_cliente_pago_v2_done';
  int _indice = 0;
  late final VoidCallback _syncMsgListener;

  final List<String> _titulos = const [
    'Inventario',
    'Combos',
    'Pedidos',
    'Ventas',
    'Compras',
    'Reportes',
  ];
  final List<Widget> _pantallas = const [
    inv.InventarioPantalla(),
    cmb.CombosPantalla(),
    ped.PedidosPantalla(),
    ven.VentasPantalla(),
    com.ComprasPantalla(),
    rep.ReportesPantalla(),
  ];

  @override
  void initState() {
    super.initState();
    _syncMsgListener = () {
      final msg = Proveedores.estadoSincronizacion.value;
      if (!mounted || msg == null || msg.trim().isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        Proveedores.limpiarEstadoSincronizacion();
      });
    };
    Proveedores.estadoSincronizacion.addListener(_syncMsgListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFixNotasVentasLegacyUnaVez();
    });
  }

  @override
  void dispose() {
    Proveedores.estadoSincronizacion.removeListener(_syncMsgListener);
    super.dispose();
  }

  Future<void> _runFixNotasVentasLegacyUnaVez() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final yaCorrio = prefs.getBool(_fixNotasVentasLegacyKey) ?? false;
      if (yaCorrio) return;

      await Proveedores.ventasRepositorio.normalizarNotasVentasLegacy();
      await prefs.setBool(_fixNotasVentasLegacyKey, true);
    } catch (_) {
      // si falla no frenamos la app
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final esTablet = w >= LayoutApp.kNavigationTablet;
        final railExtendido = w >= LayoutApp.kRailExtendida;

        final body = IndexedStack(index: _indice, children: _pantallas);

        if (!esTablet) {
          return Scaffold(
            appBar: AppBar(title: Text(_titulos[_indice])),
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _indice,
              onDestinationSelected: (nuevo) => setState(() => _indice = nuevo),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Inventario',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_list_outlined),
                  selectedIcon: Icon(Icons.view_list),
                  label: 'Combos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Pedidos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale),
                  label: 'Ventas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined),
                  selectedIcon: Icon(Icons.local_shipping),
                  label: 'Compras',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bar_chart_outlined),
                  selectedIcon: Icon(Icons.bar_chart),
                  label: 'Reportes',
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(_titulos[_indice])),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _indice,
                onDestinationSelected: (nuevo) =>
                    setState(() => _indice = nuevo),
                extended: railExtendido,
                minWidth: 68,
                minExtendedWidth: 150,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('Inventario'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.view_list_outlined),
                    selectedIcon: Icon(Icons.view_list),
                    label: Text('Combos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: Text('Pedidos'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.point_of_sale_outlined),
                    selectedIcon: Icon(Icons.point_of_sale),
                    label: Text('Ventas'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.local_shipping_outlined),
                    selectedIcon: Icon(Icons.local_shipping),
                    label: Text('Compras'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: Text('Reportes'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
