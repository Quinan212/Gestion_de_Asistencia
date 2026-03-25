import 'package:flutter/material.dart';

import '/aplicacion/tema/estilos_aplicacion.dart';

class PanelControlesModulo extends StatelessWidget {
  final Widget child;
  final bool destacado;
  final bool scrollable;

  const PanelControlesModulo({
    super.key,
    required this.child,
    this.destacado = false,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = scrollable
        ? SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: child,
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: child,
          );

    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(
        context,
        destacado: destacado,
      ),
      child: contenido,
    );
  }
}
