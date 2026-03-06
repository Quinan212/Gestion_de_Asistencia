// lib/modulos/ventas/pantallas/venta_nueva_pantalla.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';

class VentaNuevaPantalla extends StatefulWidget {
  const VentaNuevaPantalla({super.key});

  @override
  State<VentaNuevaPantalla> createState() => _VentaNuevaPantallaState();
}

class _VentaNuevaPantallaState extends State<VentaNuevaPantalla> {
  static const double _kTablet = 900;
  static const double _kMaxAnchoTablet = 620;

  int _modo = 0; // 0: combo, 1: productos
  String _moneda = r'$';

  int? _comboId;

  final List<_LineaProductoTmp> _lineas = [];

  final _cantidadCtrl = TextEditingController(text: '1');
  final _notaCtrl = TextEditingController();

  // cliente, medio de pago, envío
  final _clienteCtrl = TextEditingController();
  bool _cobraEnvio = false;
  final _envioCtrl = TextEditingController(text: '0');
  String _medioPago = 'Efectivo';

  bool _guardando = false;
  String? _error;

  double? _capacidad;
  bool _calculandoCapacidad = false;

  @override
  void initState() {
    super.initState();
    _precargarNota();
    _cargarMoneda();
    _envioCtrl.addListener(_onEnvioChanged);
  }

  void _onEnvioChanged() {
    if (!mounted) return;
    if (_cobraEnvio) setState(() {});
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  Future<void> _precargarNota() async {
    final prefs = await SharedPreferences.getInstance();
    final nota = (prefs.getString('config_nota_venta') ?? '').trim();
    if (nota.isEmpty) return;
    if (_notaCtrl.text.trim().isEmpty) _notaCtrl.text = nota;
  }

  @override
  void dispose() {
    _envioCtrl.removeListener(_onEnvioChanged);

    _cantidadCtrl.dispose();
    _notaCtrl.dispose();
    _clienteCtrl.dispose();
    _envioCtrl.dispose();
    super.dispose();
  }

  Future<List<Combo>> _cargarCombos() => Proveedores.combosRepositorio.listarCombos();

  Future<List<Producto>> _cargarProductos() =>
      Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);

  double _num(String t) => double.tryParse(t.trim().replaceAll(',', '.')) ?? 0.0;

  double get _totalProductos {
    double t = 0;
    for (final l in _lineas) {
      t += l.cantidad * l.precioUnitario;
    }
    return t;
  }

  double get _montoEnvio {
    if (!_cobraEnvio) return 0.0;
    final v = _num(_envioCtrl.text);
    return v < 0 ? 0.0 : v;
  }

  Widget _miniaturaProductoPorRuta(String? ruta) {
    final r = (ruta ?? '').trim();
    final ok = r.isNotEmpty && File(r).existsSync();
    if (ok) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(r),
          width: 34,
          height: 34,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(Icons.image_outlined);
  }

  Widget _miniaturaProducto(Producto p) => _miniaturaProductoPorRuta(p.imagen);

  Future<void> _editarLineaProducto(int index) async {
    final l = _lineas[index];

    final cantidadCtrl = TextEditingController(text: l.cantidad.toStringAsFixed(2));
    final precioCtrl = TextEditingController(text: l.precioUnitario.toStringAsFixed(2));

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: Text(
            l.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cantidadCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Cantidad (${l.unidad})'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Precio unitario ($_moneda)'),
              ),
            ],
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

    final cant = _num(cantidadCtrl.text);
    final precio = _num(precioCtrl.text);

    if (cant <= 0) return;
    if (precio < 0) return;

    setState(() {
      _lineas[index] = l.copiarCon(cantidad: cant, precioUnitario: precio);
    });
  }

  Future<void> _recalcularCapacidad(int? comboId) async {
    setState(() {
      _capacidad = null;
      _calculandoCapacidad = comboId != null;
    });

    if (comboId == null) return;

    try {
      final componentes = await Proveedores.combosRepositorio.listarComponentes(comboId);
      if (componentes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _capacidad = 0;
          _calculandoCapacidad = false;
        });
        return;
      }

      double? cap;
      for (final c in componentes) {
        final stock = await Proveedores.inventarioRepositorio.calcularStockActual(c.productoId);
        final posible = stock / c.cantidad;
        cap = (cap == null) ? posible : (posible < cap ? posible : cap);
      }

      final res = (cap == null || cap.isNaN || cap.isInfinite) ? 0.0 : cap.floorToDouble();
      if (!mounted) return;

      setState(() {
        _capacidad = res;
        _calculandoCapacidad = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _capacidad = null;
        _calculandoCapacidad = false;
      });
    }
  }

  Future<({List<String> faltantes, double maximoCombos})> _analizarStock({
    required int comboId,
    required double cantidadCombos,
  }) async {
    final componentes = await Proveedores.combosRepositorio.listarComponentes(comboId);
    if (componentes.isEmpty) {
      return (faltantes: <String>['El combo no tiene productos cargados'], maximoCombos: 0.0);
    }

    final productos = await Proveedores.inventarioRepositorio.listarProductos(
      incluirInactivos: true,
    );
    final porId = <int, Producto>{for (final p in productos) p.id: p};

    final List<String> faltantes = [];
    double? maximo;

    for (final c in componentes) {
      final stock = await Proveedores.inventarioRepositorio.calcularStockActual(c.productoId);

      final posible = stock / c.cantidad;
      maximo = (maximo == null) ? posible : (posible < maximo ? posible : maximo);

      final requerido = c.cantidad * cantidadCombos;
      if (stock + 1e-9 < requerido) {
        final p = porId[c.productoId];
        final nombre = p?.nombre ?? 'Producto ${c.productoId}';
        final unidad = p?.unidad ?? '';
        final falta = requerido - stock;

        faltantes.add(
          '$nombre: falta ${falta.toStringAsFixed(2)} $unidad (stock ${stock.toStringAsFixed(2)})',
        );
      }
    }

    final maximoFinal = (maximo == null || maximo.isNaN || maximo.isInfinite)
        ? 0.0
        : maximo.floorToDouble();

    return (faltantes: faltantes, maximoCombos: maximoFinal);
  }

  Future<double> _costoEstimadoPorCombo(int comboId) async {
    final componentes = await Proveedores.combosRepositorio.listarComponentes(comboId);
    if (componentes.isEmpty) return 0.0;

    final productos = await Proveedores.inventarioRepositorio.listarProductos(
      incluirInactivos: true,
    );
    final porId = <int, Producto>{for (final p in productos) p.id: p};

    double costo = 0.0;
    for (final c in componentes) {
      final prod = porId[c.productoId];
      final costoProd = prod?.costoActual ?? 0.0;
      costo += c.cantidad * costoProd;
    }
    return costo;
  }

  Future<void> _mostrarProblemaStock({
    required List<String> faltantes,
    required double maximoCombos,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No alcanza el stock'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Máximo que podés vender hoy: ${maximoCombos.toStringAsFixed(0)} combos'),
                const SizedBox(height: 12),
                const Text('Faltantes:'),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: faltantes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => Text('• ${faltantes[i]}'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  String _armarNotaFinal({
    required String? notaUsuario,
    required double costoCombo,
    required double costoTotal,
    required double margenTotal,
    required String? cliente,
    required String medioPago,
    required double envio,
  }) {
    final baseUsuario = (notaUsuario ?? '').trim();

    final meta = <String>[
      if ((cliente ?? '').trim().isNotEmpty) 'Cliente: ${cliente!.trim()}',
      'Pago: $medioPago',
      if (envio > 0) 'Envío: ${Formatos.dinero(_moneda, envio)}',
    ].join(' • ');

    final extra =
        'Costo estimado combo: ${Formatos.dinero(_moneda, costoCombo)}; '
        'Costo estimado total: ${Formatos.dinero(_moneda, costoTotal)}; '
        'Margen estimado: ${Formatos.dinero(_moneda, margenTotal)}';

    if (baseUsuario.isEmpty) {
      return meta.isEmpty ? extra : '$meta\n$extra';
    }
    return meta.isEmpty ? '$baseUsuario\n$extra' : '$meta\n$baseUsuario\n$extra';
  }

  Future<void> _agregarProductoALaVenta() async {
    final productos = await _cargarProductos();
    if (!mounted) return;

    int? productoId;
    Producto? seleccionado;

    final cantidadCtrl = TextEditingController(text: '1');
    final precioCtrl = TextEditingController(text: '0');

    double? stockActual;
    bool cargandoStock = false;
    String? aviso;

    Future<void> cargarStock(Producto p, void Function(void Function()) setStateLocal) async {
      setStateLocal(() {
        cargandoStock = true;
        stockActual = null;
        aviso = null;
      });
      try {
        final stock = await Proveedores.inventarioRepositorio.calcularStockActual(p.id);
        setStateLocal(() {
          stockActual = stock;
          cargandoStock = false;
        });
      } catch (_) {
        setStateLocal(() {
          stockActual = null;
          cargandoStock = false;
          aviso = 'No se pudo leer el stock';
        });
      }
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Agregar producto'),
          content: StatefulBuilder(
            builder: (context, setStateLocal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: productoId,
                    items: productos
                        .where((p) => p.activo)
                        .map(
                          (p) => DropdownMenuItem<int>(
                        value: p.id,
                        child: Row(
                          children: [
                            _miniaturaProducto(p),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return productos.where((p) => p.activo).map((p) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              _miniaturaProducto(p),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  p.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    onChanged: _guardando
                        ? null
                        : (id) async {
                      setStateLocal(() {
                        productoId = id;
                        seleccionado =
                        (id == null) ? null : productos.firstWhere((x) => x.id == id);
                        aviso = null;
                      });

                      if (seleccionado != null) {
                        precioCtrl.text = seleccionado!.precioSugerido.toStringAsFixed(2);
                        await cargarStock(seleccionado!, setStateLocal);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Producto'),
                  ),
                  const SizedBox(height: 12),
                  if (seleccionado != null) ...[
                    if (cargandoStock)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Calculando stock...'),
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Stock actual: ${(stockActual ?? 0).toStringAsFixed(2)} ${seleccionado!.unidad}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    onChanged: (t) {
                      final cant = _num(t);
                      final st = stockActual;
                      if (seleccionado == null || st == null) return;

                      setStateLocal(() {
                        if (cant > st + 1e-9) {
                          aviso = 'No alcanza el stock para esa cantidad';
                        } else {
                          aviso = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Precio unitario ($_moneda)'),
                  ),
                  if (aviso != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        aviso!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;
    if (productoId == null) return;

    final p = productos.firstWhere((x) => x.id == productoId);
    final cant = _num(cantidadCtrl.text);
    final precio = _num(precioCtrl.text);

    if (cant <= 0) return;
    if (precio < 0) return;

    if (stockActual != null && cant > (stockActual! + 1e-9)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No alcanza el stock para esa cantidad')),
      );
      return;
    }

    setState(() {
      final idx = _lineas.indexWhere((x) => x.productoId == productoId);
      if (idx >= 0) {
        final actual = _lineas[idx];
        _lineas[idx] = actual.copiarCon(
          cantidad: actual.cantidad + cant,
          precioUnitario: precio,
        );
      } else {
        _lineas.add(
          _LineaProductoTmp(
            productoId: p.id,
            nombre: p.nombre,
            unidad: p.unidad,
            cantidad: cant,
            precioUnitario: precio,
            imagen: p.imagen,
          ),
        );
      }
    });
  }

  Future<int> _crearComboInvisibleDesdeProductos() async {
    final total = _totalProductos;

    final nombre =
        'Venta directa ${DateTime.now().toIso8601String().substring(0, 16).replaceAll("T", " ")}';

    final comboId = await Proveedores.combosRepositorio.crearCombo(
      nombre: nombre,
      precioVenta: total,
    );

    await Proveedores.combosRepositorio.actualizarCombo(
      id: comboId,
      nombre: nombre,
      precioVenta: total,
      activo: false,
    );

    for (final l in _lineas) {
      await Proveedores.combosRepositorio.agregarComponente(
        comboId: comboId,
        productoId: l.productoId,
        cantidad: l.cantidad,
      );
    }

    return comboId;
  }

  Future<void> _confirmarVenta() async {
    setState(() => _error = null);

    final cliente = _clienteCtrl.text.trim();
    final envio = _montoEnvio;
    if (_cobraEnvio && envio <= 0) {
      setState(() => _error = 'El envío está activado, cargá un monto válido');
      return;
    }

    setState(() => _guardando = true);

    try {
      int comboId;
      double cantidadCombos;

      if (_modo == 0) {
        final id = _comboId;
        if (id == null) {
          setState(() {
            _guardando = false;
            _error = 'Elegí un combo';
          });
          return;
        }

        final cantTxt = _cantidadCtrl.text.trim().replaceAll(',', '.');
        final cant = double.tryParse(cantTxt);
        if (cant == null || cant <= 0) {
          setState(() {
            _guardando = false;
            _error = 'Cantidad inválida';
          });
          return;
        }

        comboId = id;
        cantidadCombos = cant;
      } else {
        if (_lineas.isEmpty) {
          setState(() {
            _guardando = false;
            _error = 'Agregá al menos un producto';
          });
          return;
        }
        comboId = await _crearComboInvisibleDesdeProductos();
        cantidadCombos = 1.0;
      }

      final combo = await Proveedores.combosRepositorio.obtenerCombo(comboId);
      if (combo == null) {
        setState(() {
          _guardando = false;
          _error = 'Combo no encontrado';
        });
        return;
      }

      final analisis = await _analizarStock(comboId: comboId, cantidadCombos: cantidadCombos);
      if (analisis.faltantes.isNotEmpty) {
        if (!mounted) return;
        setState(() => _guardando = false);
        await _mostrarProblemaStock(
          faltantes: analisis.faltantes,
          maximoCombos: analisis.maximoCombos,
        );
        return;
      }

      final subtotal = combo.precioVenta * cantidadCombos;
      final total = subtotal + envio;

      final costoCombo = await _costoEstimadoPorCombo(comboId);
      final costoTotal = costoCombo * cantidadCombos;
      final margenTotal = subtotal - costoTotal;

      var notaFinal = _armarNotaFinal(
        notaUsuario: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
        costoCombo: costoCombo,
        costoTotal: costoTotal,
        margenTotal: margenTotal,
        cliente: cliente.isEmpty ? null : cliente,
        medioPago: _medioPago,
        envio: envio,
      );

      if (_modo == 1) {
        notaFinal = 'VENTA DIRECTA (por productos)\n$notaFinal';
      }

      final ventaId = await Proveedores.ventasRepositorio.crearVenta(
        total: 0,
        nota: notaFinal,
      );

      await Proveedores.ventasRepositorio.agregarLinea(
        ventaId: ventaId,
        comboId: combo.id,
        cantidad: cantidadCombos,
        precioUnitario: combo.precioVenta,
      );

      await Proveedores.ventasRepositorio.actualizarTotalVenta(
        ventaId: ventaId,
        total: total,
      );

      final componentes = await Proveedores.combosRepositorio.listarComponentes(combo.id);
      for (final c in componentes) {
        await Proveedores.inventarioRepositorio.crearMovimiento(
          productoId: c.productoId,
          tipo: 'egreso',
          cantidad: c.cantidad * cantidadCombos,
          nota: 'Venta: ${combo.nombre}',
          referencia: 'venta:$ventaId',
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar la venta';
      });
    }
  }

  Widget _seccionDatosVenta() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _clienteCtrl,
              enabled: !_guardando,
              decoration: const InputDecoration(
                labelText: 'Cliente (opcional)',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _medioPago,
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
              ],
              onChanged: _guardando
                  ? null
                  : (v) {
                setState(() => _medioPago = v ?? 'Efectivo');
              },
              decoration: const InputDecoration(labelText: 'Medio de pago'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cobrar envío'),
              value: _cobraEnvio,
              onChanged: _guardando
                  ? null
                  : (v) {
                setState(() {
                  _cobraEnvio = v;

                  if (!_cobraEnvio) {
                    _envioCtrl.text = '0';
                  } else {
                    if (_envioCtrl.text.trim() == '0') _envioCtrl.clear();
                  }
                });
              },
            ),
            if (_cobraEnvio) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _envioCtrl,
                enabled: !_guardando,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Monto envío ($_moneda)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context, {required bool esTablet}) {
    final envio = _montoEnvio;

    final inner = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          _seccionDatosVenta(),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Combo')),
              ButtonSegment(value: 1, label: Text('Productos')),
            ],
            selected: {_modo},
            onSelectionChanged: _guardando
                ? null
                : (s) {
              setState(() {
                _modo = s.first;
                _error = null;
                _capacidad = null;
                _calculandoCapacidad = false;
              });
            },
          ),
          const SizedBox(height: 12),
          if (_modo == 0) ...[
            FutureBuilder<List<Combo>>(
              future: _cargarCombos(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }
                final combos = snap.data ?? [];
                if (combos.isEmpty) return const Text('Primero creá un combo');

                return Column(
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _comboId,
                      isExpanded: true,
                      items: combos
                          .map(
                            (c) => DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(
                            '${c.nombre} (${Formatos.dinero(_moneda, c.precioVenta)})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      selectedItemBuilder: (context) {
                        return combos.map((c) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${c.nombre} (${Formatos.dinero(_moneda, c.precioVenta)})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                      onChanged: _guardando
                          ? null
                          : (id) {
                        setState(() => _comboId = id);
                        _recalcularCapacidad(id);
                      },
                      decoration: const InputDecoration(labelText: 'Combo'),
                    ),
                    const SizedBox(height: 8),
                    if (_calculandoCapacidad)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Calculando capacidad...'),
                      )
                    else if (_capacidad != null && _comboId != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Podés vender hasta: ${_capacidad!.toStringAsFixed(0)} combos',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadCtrl,
              enabled: !_guardando,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cantidad de combos'),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _guardando ? null : _agregarProductoALaVenta,
                icon: const Icon(Icons.add),
                label: const Text('Agregar producto'),
              ),
            ),
            const SizedBox(height: 12),
            if (_lineas.isEmpty)
              const Text('Agregá productos para armar la venta')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lineas.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final l = _lineas[i];
                  final sub = l.cantidad * l.precioUnitario;

                  return Card(
                    child: ListTile(
                      leading: _miniaturaProductoPorRuta(l.imagen),
                      title: Text(
                        l.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Cant: ${l.cantidad.toStringAsFixed(2)} ${l.unidad}  •  '
                            'PU: ${Formatos.dinero(_moneda, l.precioUnitario)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(Formatos.dinero(_moneda, sub)),
                      onTap: _guardando ? null : () => _editarLineaProducto(i),
                      onLongPress: _guardando
                          ? null
                          : () {
                        setState(() => _lineas.removeAt(i));
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Subtotal: ${Formatos.dinero(_moneda, _totalProductos)}'),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Tip: mantené apretado un producto para quitarlo'),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _notaCtrl,
            enabled: !_guardando,
            decoration: const InputDecoration(labelText: 'Nota (opcional)'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              envio > 0 ? 'Envío: ${Formatos.dinero(_moneda, envio)}' : 'Envío: -',
            ),
          ),
          const SizedBox(height: 4),
          if (_modo == 1)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total estimado: ${Formatos.dinero(_moneda, _totalProductos + envio)}',
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardando ? null : _confirmarVenta,
              child: Text(_guardando ? 'Guardando...' : 'Confirmar'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );

    if (!esTablet) return inner;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kMaxAnchoTablet),
        child: inner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final esTablet = c.maxWidth >= _kTablet;

        return Scaffold(
          appBar: AppBar(title: const Text('Nueva venta')),
          body: SafeArea(
            child: _contenido(context, esTablet: esTablet),
          ),
        );
      },
    );
  }
}

class _LineaProductoTmp {
  final int productoId;
  final String nombre;
  final String unidad;
  final double cantidad;
  final double precioUnitario;
  final String? imagen;

  const _LineaProductoTmp({
    required this.productoId,
    required this.nombre,
    required this.unidad,
    required this.cantidad,
    required this.precioUnitario,
    required this.imagen,
  });

  _LineaProductoTmp copiarCon({double? cantidad, double? precioUnitario, String? imagen}) {
    return _LineaProductoTmp(
      productoId: productoId,
      nombre: nombre,
      unidad: unidad,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      imagen: imagen ?? this.imagen,
    );
  }
}
