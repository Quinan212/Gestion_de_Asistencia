// lib/modulos/combos/pantallas/combos_pantalla.dart
import 'package:flutter/material.dart';
import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/combos/logica/combos_controlador.dart';
import 'package:gestion_de_stock/modulos/combos/modelos/combo.dart';
import 'combo_editor_pantalla.dart';

class CombosPantalla extends StatefulWidget {
  const CombosPantalla({super.key});

  @override
  State<CombosPantalla> createState() => _CombosPantallaState();
}

class _CombosPantallaState extends State<CombosPantalla> {
  late final CombosControlador _controlador;
  String _moneda = r'$';

  int? _seleccionadoId;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _controlador = CombosControlador();
    _controlador.cargar();
    _cargarMoneda();
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= 900;

  Future<void> _nuevoCombo() async {
    final nombreCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Nuevo combo'),
          content: TextField(
            controller: nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) return;

    final id = await _controlador.crearComboRapido(
      nombre: nombre,
      precioVenta: 0.0, // no lo pedimos acá
    );

    if (!mounted || id == null) return;

    final ancha = MediaQuery.of(context).size.width >= 900;
    if (ancha) {
      setState(() {
        _seleccionadoId = id;
        _refreshTick++;
      });
      _controlador.cargar();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ComboEditorPantalla(comboId: id)),
    );

    if (!mounted) return;
    _controlador.cargar();
  }

  Future<double> _capacidadCombo(int comboId) async {
    final componentes = await Proveedores.combosRepositorio.listarComponentes(comboId);
    if (componentes.isEmpty) return 0;

    double? cap;
    for (final c in componentes) {
      final stock = await Proveedores.inventarioRepositorio.calcularStockActual(c.productoId);
      final posible = stock / c.cantidad;
      cap = (cap == null) ? posible : (posible < cap ? posible : cap);
    }

    if (cap == null || cap.isInfinite || cap.isNaN) return 0;
    return cap.floorToDouble();
  }

  Widget _subtitleCombo(Combo cb, double cap) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Precio: ${Formatos.dinero(_moneda, cb.precioVenta)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          'Podés armar: ${cap.toStringAsFixed(0)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final ancha = _esAncha(c);

        return AnimatedBuilder(
          animation: _controlador,
          builder: (context, _) {
            final estado = _controlador.estado;

            if (estado.cargando) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ancha && _seleccionadoId == null && estado.combos.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (_seleccionadoId == null && estado.combos.isNotEmpty) {
                  setState(() => _seleccionadoId = estado.combos.first.id);
                }
              });
            }

            Widget lista() {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _nuevoCombo,
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo combo'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mostrar inactivos'),
                      value: estado.mostrarInactivos,
                      onChanged: _controlador.cambiarMostrarInactivos,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: estado.combos.isEmpty
                          ? const Center(child: Text('Todavía no hay combos'))
                          : ListView.separated(
                        itemCount: estado.combos.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final cb = estado.combos[i];
                          final seleccionado = ancha && _seleccionadoId == cb.id;

                          return FutureBuilder<double>(
                            future: _capacidadCombo(cb.id),
                            builder: (context, snapCap) {
                              final cap = snapCap.data ?? 0;

                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () async {
                                    if (ancha) {
                                      setState(() => _seleccionadoId = cb.id);
                                      return;
                                    }

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ComboEditorPantalla(comboId: cb.id),
                                      ),
                                    );

                                    if (!mounted) return;
                                    _controlador.cargar();
                                  },
                                  child: Container(
                                    decoration: seleccionado
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
                                      isThreeLine: true,
                                      title: Text(
                                        cb.activo ? cb.nombre : '${cb.nombre} (INACTIVO)',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: _subtitleCombo(cb, cap),
                                      trailing: Icon(
                                        ancha ? Icons.chevron_right : Icons.open_in_new,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (estado.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        estado.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              );
            }

            if (!ancha) return lista();

            final id = _seleccionadoId;

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
                          ? const Center(child: Text('Elegí un combo'))
                          : ComboEditorPantalla(
                        comboId: id,
                        embebido: true,
                        onChanged: () {
                          setState(() => _refreshTick++);
                          _controlador.cargar();
                        },
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