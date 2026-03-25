import 'package:flutter/material.dart';

class EstilosAplicacion {
  EstilosAplicacion._();

  static const Color marca = Color(0xFF005B7F);
  static const Color acento = Color(0xFF1D4ED8);
  static const Color fondoClaro = Color(0xFFF5F7FA);
  static const Color superficieClaro = Color(0xFFFFFFFF);
  static const Color bordeClaro = Color(0xFFE5E7EB);

  static BorderRadius get radioPanel => BorderRadius.circular(18);
  static BorderRadius get radioSuave => BorderRadius.circular(14);
  static BorderRadius get radioChip => BorderRadius.circular(999);

  static LinearGradient gradienteHero(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        cs.primary.withValues(alpha: 0.16),
        acento.withValues(alpha: 0.11),
        cs.surfaceContainerLowest,
      ],
    );
  }

  static BoxDecoration decoracionPanel(
    BuildContext context, {
    bool destacado = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return BoxDecoration(
      color: cs.surfaceContainerLowest,
      borderRadius: radioPanel,
      border: Border.all(
        color: destacado
            ? cs.primary.withValues(alpha: 0.28)
            : cs.outlineVariant.withValues(alpha: 0.9),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: destacado ? 0.07 : 0.045),
          blurRadius: destacado ? 26 : 20,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.72),
          blurRadius: 0,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration decoracionHeroPanel(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      borderRadius: radioPanel,
      gradient: gradienteHero(context),
      border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: cs.primary.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }

  static BoxDecoration decoracionChip(
    BuildContext context, {
    required bool seleccionado,
  }) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: seleccionado
          ? cs.primary.withValues(alpha: 0.12)
          : cs.surfaceContainerLowest.withValues(alpha: 0.86),
      borderRadius: radioChip,
      border: Border.all(color: seleccionado ? cs.primary : cs.outlineVariant),
    );
  }

  static List<Widget> fondosDecorativos(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return [
      Positioned(
        top: -90,
        right: -70,
        child: IgnorePointer(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.16),
                  cs.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 120,
        left: -80,
        child: IgnorePointer(
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  acento.withValues(alpha: 0.08),
                  acento.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
