import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gestion_de_stock/aplicacion/utiles/formatos.dart';
import 'package:gestion_de_stock/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_stock/modulos/combos/modelos/combo.dart';
import 'package:gestion_de_stock/modulos/inventario/modelos/producto.dart';
import 'package:gestion_de_stock/modulos/pedidos/datos/pedidos_repositorio.dart';
import 'package:gestion_de_stock/modulos/pedidos/modelos/linea_pedido_tmp.dart';

Future<int?> showPedidoNuevoSheet(BuildContext context) {
  return showModalBottomSheet<int?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _PedidoNuevoSheet(),
  );
}

class _PedidoNuevoSheet extends StatefulWidget {
  const _PedidoNuevoSheet();

  @override
  State<_PedidoNuevoSheet> createState() => _PedidoNuevoSheetState();
}

class _PedidoNuevoSheetState extends State<_PedidoNuevoSheet> {
  String _moneda = r'$';

  int _modo = 0; // 0 combo, 1 productos
  int? _comboId;
  final _cantidadComboCtrl = TextEditingController(text: '1');

  final _clienteCtrl = TextEditingController();
  final _notaCtrl = TextEditingController();

  String _medioPago = 'Efectivo';
  String _estadoPago = 'pendiente';

  bool _cobraEnvio = false;
  final _envioCtrl = TextEditingController(text: '0');

  bool _guardando = false;
  String? _error;

  final List<LineaPedidoTmp> _lineas = [];

  late final Future<List<Combo>> _combosF;
  late final Future<List<Producto>> _productosF;

  int? _maxVendible; // cache simple
  bool _cargandoMax = false;

  @override
  void initState() {
    super.initState();
    _combosF = Proveedores.combosRepositorio.listarCombos(incluirInactivos: false);
    _productosF = Proveedores.inventarioRepositorio.listarProductos(incluirInactivos: true);
    _cargarMoneda();
  }

  @override
  void dispose() {
    _cantidadComboCtrl.dispose();
    _clienteCtrl.dispose();
    _notaCtrl.dispose();
    _envioCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMoneda() async {
    final m = await Formatos.leerMoneda();
    if (!mounted) return;
    setState(() => _moneda = m);
  }

  double _num(String t) {
    var s = t.trim();
    if (s.isEmpty) return 0.0;

    s = s.replaceAll(' ', '');
    if (s.contains('.') && s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',') && !s.contains('.')) {
      s = s.replaceAll(',', '.');
    }

    s = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(s) ?? 0.0;
  }

  double get _montoEnvio {
    if (!_cobraEnvio) return 0.0;
    final v = _num(_envioCtrl.text);
    return v < 0 ? 0.0 : v;
  }

  double get _totalProductos {
    double t = 0.0;
    for (final l in _lineas) {
      t += l.cantidad * l.precioUnitario;
    }
    return t;
  }

  Widget _miniaturaRuta(String? ruta) {
    final r = (ruta ?? '').trim();
    final ok = r.isNotEmpty && File(r).existsSync();
    if (ok) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(r), width: 34, height: 34, fit: BoxFit.cover),
      );
    }
    return const Icon(Icons.image_outlined);
  }

  double _precioProducto(Producto p) => p.precioSugerido;

  Future<void> _recalcularMaxVendible() async {
    final id = _comboId;
    if (id == null) {
      if (!mounted) return;
      setState(() => _maxVendible = null);
      return;
    }

    if (!mounted) return;
    setState(() => _cargandoMax = true);

    try {
      final max = await Proveedores.pedidosRepositorio.maxCombosVendibles(id);
      if (!mounted) return;
      setState(() {
        _maxVendible = max;
        _cargandoMax = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _maxVendible = null;
        _cargandoMax = false;
      });
    }
  }

  Future<void> _mostrarFaltantesDialog(StockInsuficientePedido e) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(e.titulo),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: e.faltantes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final f = e.faltantes[i];
                final unidad = f.unidad.trim();
                final u = unidad.isEmpty ? '' : ' $unidad';
                return Text('Falta ${f.falta.toStringAsFixed(2)}$u de ${f.nombre}');
              },
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _agregarProducto() async {
    final productos = await _productosF;
    if (!mounted) return;

    int? productoId;
    Producto? seleccionado;

    final cantidadCtrl = TextEditingController(text: '1');
    final precioCtrl = TextEditingController(text: '0');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
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
                            _miniaturaRuta(p.imagen),
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
                    onChanged: (id) {
                      setStateLocal(() {
                        productoId = id;
                        seleccionado = (id == null) ? null : productos.firstWhere((x) => x.id == id);
                        if (seleccionado != null) {
                          precioCtrl.text = _precioProducto(seleccionado!).toStringAsFixed(2);
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Producto'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Precio unitario ($_moneda)'),
                  ),
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

    if (!mounted) return;
    setState(() {
      final idx = _lineas.indexWhere((x) => x.productoId == productoId);
      if (idx >= 0) {
        final actual = _lineas[idx];
        _lineas[idx] = actual.copyWith(
          cantidad: actual.cantidad + cant,
          precioUnitario: precio,
        );
      } else {
        _lineas.add(
          LineaPedidoTmp(
            productoId: p.id,
            nombre: p.nombre,
            unidad: p.unidad,
            cantidad: cant,
            precioUnitario: precio,
          ),
        );
      }
    });
  }

  Future<void> _confirmar() async {
    if (_guardando) return;

    setState(() => _error = null);

    final cliente = _clienteCtrl.text.trim();
    final envio = _montoEnvio;

    if (_cobraEnvio && envio <= 0) {
      setState(() => _error = 'El envío está activado, cargá un monto válido');
      return;
    }

    setState(() => _guardando = true);

    try {
      if (_modo == 0) {
        final id = _comboId;
        if (id == null) {
          setState(() {
            _guardando = false;
            _error = 'Elegí un combo';
          });
          return;
        }

        final cant = _num(_cantidadComboCtrl.text);
        if (cant <= 0) {
          setState(() {
            _guardando = false;
            _error = 'Cantidad inválida';
          });
          return;
        }

        final pedidoId = await Proveedores.pedidosRepositorio.crearPedidoPorCombo(
          comboId: id,
          cantidad: cant,
          cliente: cliente.isEmpty ? null : cliente,
          nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
          envioMonto: envio,
          medioPago: _medioPago,
          estadoPago: _estadoPago,
          crearEnEncargadoYReservar: true,
        );

        if (!mounted) return;
        Navigator.pop(context, pedidoId);
        return;
      }

      if (_lineas.isEmpty) {
        setState(() {
          _guardando = false;
          _error = 'Agregá al menos un producto';
        });
        return;
      }

      final pedidoId = await Proveedores.pedidosRepositorio.crearPedidoPorProductos(
        lineas: _lineas,
        cliente: cliente.isEmpty ? null : cliente,
        nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
        envioMonto: envio,
        medioPago: _medioPago,
        estadoPago: _estadoPago,
        crearEnEncargadoYReservar: true,
      );

      if (!mounted) return;
      Navigator.pop(context, pedidoId);
    } on StockInsuficientePedido catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      await _mostrarFaltantesDialog(e);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo guardar el pedido';
      });
    }
  }

  Widget _seccionDatos() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _clienteCtrl,
              enabled: !_guardando,
              decoration: const InputDecoration(labelText: 'Cliente (opcional)'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _medioPago,
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
              ],
              onChanged: _guardando ? null : (v) => setState(() => _medioPago = v ?? 'Efectivo'),
              decoration: const InputDecoration(labelText: 'Medio de pago'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _estadoPago,
              items: const [
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                DropdownMenuItem(value: 'parcial', child: Text('Parcial')),
              ],
              onChanged: _guardando ? null : (v) => setState(() => _estadoPago = v ?? 'pendiente'),
              decoration: const InputDecoration(labelText: 'Estado de pago'),
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final envio = _montoEnvio;
    final totalProd = _totalProductos;
    final totalFinal = (_modo == 1) ? (totalProd + envio) : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Nuevo pedido', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                onPressed: _guardando ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                tooltip: 'Cerrar',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _seccionDatos(),
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
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_modo == 0) ...[
                    FutureBuilder<List<Combo>>(
                      future: _combosF,
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
                              onChanged: _guardando
                                  ? null
                                  : (id) {
                                setState(() => _comboId = id);
                                // recalcular max después de setState
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _recalcularMaxVendible();
                                });
                              },
                              decoration: const InputDecoration(labelText: 'Combo'),
                            ),
                            const SizedBox(height: 10),
                            if (_comboId != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: _cargandoMax
                                    ? const Text('Calculando stock...')
                                    : Text(
                                  _maxVendible == null
                                      ? 'Stock no disponible'
                                      : 'Según stock, podés vender hasta $_maxVendible combos',
                                ),
                              ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _cantidadComboCtrl,
                              enabled: !_guardando,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Cantidad de combos'),
                            ),
                          ],
                        );
                      },
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _guardando ? null : _agregarProducto,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar producto'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_lineas.isEmpty)
                      const Text('Agregá productos para armar el pedido')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lineas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final l = _lineas[i];
                          final sub = l.cantidad * l.precioUnitario;

                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: ListTile(
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(l.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                'Cant: ${l.cantidad.toStringAsFixed(2)} ${l.unidad}  •  PU: ${Formatos.dinero(_moneda, l.precioUnitario)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(Formatos.dinero(_moneda, sub)),
                              onLongPress: _guardando ? null : () => setState(() => _lineas.removeAt(i)),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Subtotal: ${Formatos.dinero(_moneda, totalProd)}'),
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
                    child: Text(envio > 0 ? 'Envío: ${Formatos.dinero(_moneda, envio)}' : 'Envío: -'),
                  ),
                  if (totalFinal != null) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Total estimado: ${Formatos.dinero(_moneda, totalFinal)}'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _guardando ? null : _confirmar,
              child: Text(_guardando ? 'Guardando...' : 'Crear pedido (encargado)'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
    );
  }
}