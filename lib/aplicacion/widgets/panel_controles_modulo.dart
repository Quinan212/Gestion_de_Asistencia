import 'package:flutter/material.dart';

class PanelControlesModulo extends StatelessWidget {
  final Widget child;

  const PanelControlesModulo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withValues(alpha: 0.08), Colors.transparent],
        ),
      ),
      child: Card(
        color: cs.surfaceContainerLow,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}
