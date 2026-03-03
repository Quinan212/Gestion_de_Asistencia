import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/ventas/modelos/venta.dart';
import 'package:gestion_de_stock/modulos/ventas/pantallas/venta_nueva_pantalla.dart';
import 'package:gestion_de_stock/modulos/ventas/pantallas/venta_detalle_pantalla.dart';

class VentasPantalla extends StatefulWidget {
  const VentasPantalla({super.key});

  @override
  State<VentasPantalla> createState() => _VentasPantallaState();
}

class _VentasPantallaState extends State<VentasPantalla> {
  String _moneda = r'$';
  int? _seleccionadaId;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _cargarMoneda();
  }

  Future<void> _cargarMoneda() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _moneda = prefs.getString('config_moneda') ?? r'$');
  }

  Future<List<Venta>> _cargar() => Proveedores.ventasRepositorio.listarVentas();

  Future<void> _nuevaVenta() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VentaNuevaPantalla()),
    );
    if (!mounted) return;
    setState(() => _refreshTick++);
  }

  String _fecha(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancha = _esAncha(c);

        return Padding(
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<List<Venta>>(
            future: _cargar(),
            // el refreshTick fuerza a que el FutureBuilder recalcule al volver de "nueva venta"
            key: ValueKey('ventas_future_$_refreshTick'),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final ventas = snap.data ?? [];
              if (ventas.isEmpty) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nuevaVenta,
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva venta'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Expanded(
                      child: Center(child: Text('Todavía no hay ventas')),
                    ),
                  ],
                );
              }

              // en modo tablet, si no hay selección, selecciona la primera (sin setState en build directo)
              if (ancha && _seleccionadaId == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_seleccionadaId == null && ventas.isNotEmpty) {
                    setState(() => _seleccionadaId = ventas.first.id);
                  }
                });
              }

              Widget lista() {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nuevaVenta,
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva venta'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: ventas.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final v = ventas[i];
                          final cancelada = (v.nota ?? '').contains('VENTA CANCELADA');

                          final seleccionada = ancha && _seleccionadaId == v.id;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                if (ancha) {
                                  setState(() => _seleccionadaId = v.id);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VentaDetallePantalla(ventaId: v.id),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: seleccionada
                                    ? BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      width: 5,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                )
                                    : null,
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Total: $_moneda ${v.total.toStringAsFixed(2)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (cancelada)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(999),
                                            color: Theme.of(context).colorScheme.errorContainer,
                                          ),
                                          child: Text(
                                            'CANCELADA',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onErrorContainer,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(_fecha(v.fecha)),
                                  trailing: Icon(
                                    ancha ? Icons.chevron_right : Icons.open_in_new,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }

              if (!ancha) {
                return lista();
              }

              final id = _seleccionadaId;
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: lista(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: id == null
                            ? const Center(child: Text('Elegí una venta'))
                            : VentaDetallePantalla(
                          ventaId: id,
                          embebido: true,
                          alCambiarAlgo: () {
                            // si la devolución cambia totales/notas, refrescamos lista y detalle
                            setState(() => _refreshTick++);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}