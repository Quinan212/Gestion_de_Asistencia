import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/compras/modelos/compra.dart';
import 'package:gestion_de_stock/modulos/compras/pantallas/compra_nueva_pantalla.dart';
import 'package:gestion_de_stock/modulos/compras/pantallas/compra_detalle_pantalla.dart';

class ComprasPantalla extends StatefulWidget {
  const ComprasPantalla({super.key});

  @override
  State<ComprasPantalla> createState() => _ComprasPantallaState();
}

class _ComprasPantallaState extends State<ComprasPantalla> {
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

  Future<List<Compra>> _cargar() => Proveedores.comprasRepositorio.listarCompras();

  String _fecha(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  Future<void> _nuevaCompra() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompraNuevaPantalla()),
    );
    if (!mounted) return;
    setState(() => _refreshTick++);
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancha = _esAncha(c);

        return Padding(
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<List<Compra>>(
            future: _cargar(),
            key: ValueKey('compras_future_$_refreshTick'),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final compras = snap.data ?? [];

              if (compras.isEmpty) {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nuevaCompra,
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva compra'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Expanded(
                      child: Center(child: Text('Todavía no hay compras')),
                    ),
                  ],
                );
              }

              if (ancha && _seleccionadaId == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_seleccionadaId == null && compras.isNotEmpty) {
                    setState(() => _seleccionadaId = compras.first.id);
                  }
                });
              }

              Widget lista() {
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nuevaCompra,
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva compra'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: compras.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final c = compras[i];
                          final cancelada = (c.nota ?? '').contains('COMPRA CANCELADA');
                          final seleccionada = ancha && _seleccionadaId == c.id;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                if (ancha) {
                                  setState(() => _seleccionadaId = c.id);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CompraDetallePantalla(compraId: c.id),
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
                                          'Total: $_moneda ${c.total.toStringAsFixed(2)}',
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
                                  subtitle: Text(
                                    '${_fecha(c.fecha)}  •  ${c.proveedor ?? 'Sin proveedor'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Icon(ancha ? Icons.chevron_right : Icons.open_in_new),
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

              if (!ancha) return lista();

              final id = _seleccionadaId;

              return Row(
                children: [
                  Expanded(flex: 3, child: lista()),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: id == null
                            ? const Center(child: Text('Elegí una compra'))
                            : CompraDetallePantalla(
                          compraId: id,
                          embebido: true,
                          alCambiarAlgo: () {
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