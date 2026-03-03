// lib/modulos/inventario/widgets/filtro_inventario.dart
import 'package:flutter/material.dart';

class FiltroInventario extends StatefulWidget {
  final String valor;
  final ValueChanged<String> alCambiar;

  const FiltroInventario({
    super.key,
    required this.valor,
    required this.alCambiar,
  });

  @override
  State<FiltroInventario> createState() => _FiltroInventarioState();
}

class _FiltroInventarioState extends State<FiltroInventario> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.valor);
  }

  @override
  void didUpdateWidget(covariant FiltroInventario oldWidget) {
    super.didUpdateWidget(oldWidget);

    // si el valor cambia desde afuera (ej: botón “limpiar”), lo sincronizamos
    if (oldWidget.valor != widget.valor && _ctrl.text != widget.valor) {
      _ctrl.value = _ctrl.value.copyWith(
        text: widget.valor,
        selection: TextSelection.collapsed(offset: widget.valor.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: widget.alCambiar,
      decoration: const InputDecoration(
        hintText: 'Buscar producto',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}