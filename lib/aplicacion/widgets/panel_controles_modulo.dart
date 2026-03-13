import 'package:flutter/material.dart';

class PanelControlesModulo extends StatelessWidget {
  final Widget child;

  const PanelControlesModulo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Card(
        color: cs.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: child,
        ),
      ),
    );
  }
}
