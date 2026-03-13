import 'package:flutter/material.dart';

// Port de animaciones usadas en correlativas_historia:
// - tarjeta_acordeon_inicio.dart
// - premium_feature_accordion.dart
class TransicionesCorrelativas {
  static const Duration duracionSizeAcordeon = Duration(milliseconds: 320);
  static const Duration duracionEntradaAcordeon = Duration(milliseconds: 240);
  static const Curve curvaPrincipal = Curves.easeOutCubic;

  static Widget contenidoAcordeon({
    required bool expandido,
    required Widget child,
  }) {
    return AnimatedSize(
      duration: duracionSizeAcordeon,
      curve: curvaPrincipal,
      alignment: Alignment.topCenter,
      child: expandido
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: duracionEntradaAcordeon,
                  curve: curvaPrincipal,
                  builder: (context, value, hijo) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 8),
                        child: hijo,
                      ),
                    );
                  },
                  child: child,
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  static Widget premiumSwitcherTransition(
    Widget child,
    Animation<double> animation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
