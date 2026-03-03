// lib/aplicacion/pantallas_principales.dart
import 'package:flutter/material.dart';

import 'package:gestion_de_stock/modulos/inventario/pantallas/inventario_pantalla.dart' as inv;
import 'package:gestion_de_stock/modulos/combos/pantallas/combos_pantalla.dart' as cmb;
import 'package:gestion_de_stock/modulos/ventas/pantallas/ventas_pantalla.dart' as ven;
import 'package:gestion_de_stock/modulos/compras/pantallas/compras_pantalla.dart' as com;
import 'package:gestion_de_stock/modulos/reportes/pantallas/reportes_pantalla.dart' as rep;

class PantallasPrincipales extends StatefulWidget {
  const PantallasPrincipales({super.key});

  @override
  State<PantallasPrincipales> createState() => _PantallasPrincipalesState();
}

class _PantallasPrincipalesState extends State<PantallasPrincipales> {
  int _indice = 0;

  late final List<Widget> _pantallas = const [
    inv.InventarioPantalla(),
    cmb.CombosPantalla(),
    ven.VentasPantalla(),
    com.ComprasPantalla(),
    rep.ReportesPantalla(),
  ];

  final List<String> _titulos = const [
    'Inventario',
    'Combos',
    'Ventas',
    'Compras',
    'Reportes',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final esTablet = w >= 700;
        final railExtendido = w >= 1000;

        final body = _pantallas[_indice];

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
                onDestinationSelected: (nuevo) => setState(() => _indice = nuevo),
                extended: railExtendido,
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