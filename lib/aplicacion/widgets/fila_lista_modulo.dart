import 'package:flutter/material.dart';

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
    final bgSel = cs.primary.withValues(alpha: 0.09);
    final bgHover = cs.primary.withValues(alpha: 0.045);

    return Material(
      color: selected ? bgSel : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: bgHover,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: selected ? cs.primary : Colors.transparent,
                width: 3,
              ),
              bottom: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
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
                      const SizedBox(height: 2),
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
    );
  }
}
