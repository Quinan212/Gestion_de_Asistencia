// lib/modulos/inventario/pantallas/movimiento_nuevo_pantalla.dart
import 'package:flutter/material.dart';

import '/infraestructura/dep_inyeccion/proveedores.dart';

class MovimientoNuevoPantalla extends StatefulWidget {
  final int productoId;

  const MovimientoNuevoPantalla({super.key, required this.productoId});

  @override
  State<MovimientoNuevoPantalla> createState() => _MovimientoNuevoPantallaState();
}

class _MovimientoNuevoPantallaState extends State<MovimientoNuevoPantalla> {
  String _tipo = 'ingreso';
  final _cantidadCtrl = TextEditingController();
  final _notaCtrl = TextEditingController();

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final txt = _cantidadCtrl.text.trim().replaceAll(',', '.');
    final cantidad = double.tryParse(txt);

    if (cantidad == null || cantidad == 0) return;

    await Proveedores.inventarioRepositorio.crearMovimiento(
      productoId: widget.productoId,
      tipo: _tipo,
      cantidad: cantidad,
      nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo movimiento')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              items: const [
                DropdownMenuItem(value: 'ingreso', child: Text('Ingreso')),
                DropdownMenuItem(value: 'egreso', child: Text('Egreso')),
                DropdownMenuItem(value: 'ajuste', child: Text('Ajuste')),
                DropdownMenuItem(value: 'devolucion', child: Text('Devolución')),
              ],
              onChanged: (v) => setState(() => _tipo = v ?? 'ingreso'),
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cantidadCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notaCtrl,
              decoration: const InputDecoration(labelText: 'Nota (opcional)'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}