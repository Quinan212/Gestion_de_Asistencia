// lib/modulos/combos/pantallas/combos_pantalla.dart
import 'package:flutter/material.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/filtros_persistidos.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/estado_lista.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/panel_controles_modulo.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/combos/logica/combos_controlador.dart';
import 'package:gestion_de_asistencias/modulos/combos/modelos/combo.dart';
import 'combo_editor_pantalla.dart';

class CombosPantalla extends StatefulWidget {
  const CombosPantalla({super.key});

  @override
  State<CombosPantalla> createState() => _CombosPantallaState();
}

class _CombosPantallaState extends State<CombosPantalla> {
  static const _kBusquedaKey = 'combos_busqueda_v1';
  static const _kMostrarInactivosKey = 'combos_mostrar_inactivos_v1';

  late final CombosControlador _controlador;
  late final VoidCallback _datosVersionListener;
  String _moneda = r'$';

  int? _seleccionadoId;
  bool _creandoNuevoCombo = false;
  int _capacidadEpoch = 0;
  String _capacidadKey = '';
  Future<Map<int, double>>? _capacidadFuture;
  Map<int, double> _ultimasCapacidades = const <int, double>{};

  final _buscarCtrl = TextEditingController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _controlador = CombosControlador();
    _controlador.cargar();
    _restaurarFiltros();
    _datosVersionListener = () {
      _controlador.cargar();
      if (!mounted) return;
      setState(() => _capacidadEpoch++);
    };
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _cargarMoneda();
    _buscarCtrl.addListener(() {
      final t = _buscarCtrl.text.trim();
      if (t == _q) return;
      setState(() => _q = t);
      FiltrosPersistidos.guardarTexto(_kBusquedaKey, t);
    });
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  @override
  void dispose() {
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    _buscarCtrl.dispose();
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _restaurarFiltros() async {
    final q = await FiltrosPersistidos.leerTexto(_kBusquedaKey);
    final mostrarInactivos = await FiltrosPersistidos.leerBool(
      _kMostrarInactivosKey,
    );
    if (!mounted) return;
    _buscarCtrl.text = q;
    setState(() => _q = q.trim());
    if (mostrarInactivos != _controlador.estado.mostrarInactivos) {
      _controlador.cambiarMostrarInactivos(mostrarInactivos);
    }
  }

  void _onCambiarMostrarInactivos(bool value) {
    _controlador.cambiarMostrarInactivos(value);
    FiltrosPersistidos.guardarBool(_kMostrarInactivosKey, value);
  }

  bool _esAncha(BoxConstraints c) => c.maxWidth >= LayoutApp.kTablet;

  Future<void> _nuevoCombo() async {
    final ancha = MediaQuery.of(context).size.width >= LayoutApp.kTablet;
    if (ancha) {
      setState(() => _creandoNuevoCombo = true);
      return;
    }

    final id = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const ComboEditorPantalla.nuevo()),
    );

    if (!mounted || id == null) return;
    await _controlador.cargar();
    if (!mounted) return;
    setState(() {
      _seleccionadoId = id;
      _capacidadEpoch++;
    });
  }

  Future<void> _onComboCreado(int id) async {
    await _controlador.cargar();
    if (!mounted) return;
    setState(() {
      _creandoNuevoCombo = false;
      _seleccionadoId = id;
      _capacidadEpoch++;
    });
  }

  void _cancelarNuevoCombo() {
    if (!mounted) return;
    setState(() => _creandoNuevoCombo = false);
  }

  Future<double> _capacidadCombo(int comboId) async {
    final componentes = await Proveedores.combosRepositorio.listarComponentes(
      comboId,
    );
    if (componentes.isEmpty) return 0;

    double? cap;
    for (final c in componentes) {
      final stock = await Proveedores.inventarioRepositorio.calcularStockActual(
        c.productoId,
      );
      final posible = stock / c.cantidad;
      cap = (cap == null) ? posible : (posible < cap ? posible : cap);
    }

    if (cap == null || cap.isInfinite || cap.isNaN) return 0;
    return cap.floorToDouble();
  }

  Future<Map<int, double>> _armarCapacidadMap(List<Combo> combos) async {
    final out = <int, double>{};
    await Future.wait(
      combos.map((cb) async {
        try {
          out[cb.id] = await _capacidadCombo(cb.id);
        } catch (_) {
          out[cb.id] = 0;
        }
      }),
    );
    return out;
  }

  void _sincronizarCapacidades(List<Combo> combos) {
    final key = '${_capacidadEpoch}_${combos.map((c) => c.id).join(',')}';
    if (key == _capacidadKey && _capacidadFuture != null) return;
    _capacidadKey = key;
    _capacidadFuture = _armarCapacidadMap(combos);
  }

  Widget _buscador() {
    return TextField(
      controller: _buscarCtrl,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar combo',
        suffixIcon: _q.isEmpty
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
    );
  }

  List<Combo> _filtrarCombos(List<Combo> combos) {
    final q = _q.trim().toLowerCase();
    if (q.isEmpty) return combos;

    return combos.where((cb) => cb.nombre.toLowerCase().contains(q)).toList();
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
          'Podes armar: ${cap.toStringAsFixed(0)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
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
            final combosVisibles = _filtrarCombos(estado.combos);
            _sincronizarCapacidades(combosVisibles);

            if (estado.cargando) {
              return const Padding(
                padding: TabletMasterDetailLayout.kPagePadding,
                child: EstadoListaCargando(mensaje: 'Cargando combos...'),
              );
            }

            if (ancha &&
                !_creandoNuevoCombo &&
                _seleccionadoId != null &&
                !combosVisibles.any((cb) => cb.id == _seleccionadoId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (_seleccionadoId != null &&
                    !combosVisibles.any((cb) => cb.id == _seleccionadoId)) {
                  setState(() => _seleccionadoId = null);
                }
              });
            }

            Widget lista({required bool conPadding}) {
              final contenido = Column(
                children: [
                  PanelControlesModulo(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _nuevoCombo,
                            icon: const Icon(Icons.add),
                            label: Text(
                              _creandoNuevoCombo
                                  ? 'Editando nuevo combo'
                                  : 'Nuevo combo',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buscador(),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mostrar inactivos'),
                          value: estado.mostrarInactivos,
                          onChanged: _onCambiarMostrarInactivos,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: combosVisibles.isEmpty
                        ? EstadoListaVacia(
                            titulo: _q.isEmpty
                                ? 'Todavia no hay combos'
                                : 'Sin resultados',
                            icono: Icons.inventory_2_outlined,
                          )
                        : FutureBuilder<Map<int, double>>(
                            future: _capacidadFuture,
                            builder: (context, snapCaps) {
                              if (snapCaps.connectionState ==
                                      ConnectionState.done &&
                                  snapCaps.hasData) {
                                _ultimasCapacidades = snapCaps.data!;
                              }

                              final caps = snapCaps.data ?? _ultimasCapacidades;

                              return ListView.separated(
                                itemCount: combosVisibles.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final cb = combosVisibles[i];
                                  final seleccionado =
                                      ancha && _seleccionadoId == cb.id;
                                  final cap = caps[cb.id] ?? 0;

                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () async {
                                        if (ancha) {
                                          setState(() {
                                            _creandoNuevoCombo = false;
                                            _seleccionadoId = cb.id;
                                          });
                                          return;
                                        }

                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ComboEditorPantalla(
                                              comboId: cb.id,
                                            ),
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
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                ),
                                              )
                                            : null,
                                        child: ListTile(
                                          isThreeLine: true,
                                          title: Text(
                                            cb.activo
                                                ? cb.nombre
                                                : '${cb.nombre} (INACTIVO)',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: _subtitleCombo(cb, cap),
                                          trailing: Icon(
                                            ancha
                                                ? Icons.chevron_right
                                                : Icons.open_in_new,
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
                    EstadoListaError(
                      mensaje: estado.error!,
                      alReintentar: () {
                        _controlador.cargar();
                      },
                    ),
                  ],
                ],
              );
              if (!conPadding) return contenido;
              return Padding(
                padding: TabletMasterDetailLayout.kPagePadding,
                child: contenido,
              );
            }

            if (!ancha) return lista(conPadding: true);

            final id = _seleccionadoId;

            return Padding(
              padding: TabletMasterDetailLayout.kPagePadding,
              child: TabletMasterDetailLayout(
                master: lista(conPadding: false),
                detail: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _creandoNuevoCombo
                        ? ComboEditorPantalla.nuevo(
                            embebido: true,
                            onCreado: _onComboCreado,
                            onCancelarCreacion: _cancelarNuevoCombo,
                          )
                        : id == null
                        ? const Center(
                            child: Text(
                              'Selecciona un combo para ver detalles',
                            ),
                          )
                        : ComboEditorPantalla(
                            comboId: id,
                            embebido: true,
                            onChanged: () {
                              setState(() => _capacidadEpoch++);
                              _controlador.cargar();
                            },
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
