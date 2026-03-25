import 'package:flutter/material.dart';

import '/aplicacion/tema/estilos_aplicacion.dart';

class FilaListaModulo extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const FilaListaModulo({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgSel = cs.primary.withValues(alpha: 0.1);
    final bgHover = cs.primary.withValues(alpha: 0.04);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? bgSel
            : cs.surfaceContainerLowest.withValues(alpha: 0),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color: selected
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: bgHover,
          borderRadius: EstilosAplicacion.radioSuave,
          child: Padding(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        subtitle!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
