import 'package:flutter/material.dart';

import '/aplicacion/animaciones/transiciones_correlativas.dart';

class TarjetaAcordeonInicio extends StatefulWidget {
  const TarjetaAcordeonInicio({
    super.key,
    this.leading,
    this.eyebrowLeading,
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.child,
    this.initiallyExpanded = false,
    this.compactoAlColapsar = false,
    this.etiquetaColapsada,
    this.soloIconoAlColapsar = false,
    this.mantenerAltoAlColapsar = false,
    this.onExpansionChanged,
  });

  final Widget? leading;
  final Widget? eyebrowLeading;
  final String eyebrow;
  final String title;
  final String summary;
  final Widget child;
  final bool initiallyExpanded;
  final bool compactoAlColapsar;
  final String? etiquetaColapsada;
  final bool soloIconoAlColapsar;
  final bool mantenerAltoAlColapsar;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<TarjetaAcordeonInicio> createState() => _TarjetaAcordeonInicioState();
}

class _TarjetaAcordeonInicioState extends State<TarjetaAcordeonInicio>
    with SingleTickerProviderStateMixin {
  static const Duration _duracionPanel = Duration(milliseconds: 430);
  static const Curve _curvaPanel = Cubic(0.22, 1.0, 0.36, 1.0);

  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final mostrarEyebrow = widget.eyebrow.trim().isNotEmpty;
    final mostrarTitulo = widget.title.trim().isNotEmpty;
    final mostrarResumen = widget.summary.trim().isNotEmpty;
    final labelColapsado =
        (widget.etiquetaColapsada ?? widget.title).trim().isEmpty
        ? 'Configuracion'
        : (widget.etiquetaColapsada ?? widget.title).trim();
    final colapsadoCompacto = widget.compactoAlColapsar && !_expanded;
    final colapsadoSoloIcono = colapsadoCompacto && widget.soloIconoAlColapsar;

    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoExpandido = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : null;
        final altoColapsado = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : null;

        Widget tarjeta = AnimatedContainer(
          duration: _duracionPanel,
          curve: _curvaPanel,
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: _expanded ? 14 : 8,
                offset: const Offset(0, 8),
                color: theme.shadowColor.withValues(
                  alpha: _expanded ? 0.14 : 0.1,
                ),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: colapsadoCompacto
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                    : const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() => _expanded = !_expanded);
                        widget.onExpansionChanged?.call(_expanded);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: AnimatedSwitcher(
                          duration: _duracionPanel,
                          switchInCurve: _curvaPanel,
                          switchOutCurve: _curvaPanel,
                          transitionBuilder: TransicionesCorrelativas
                              .premiumSwitcherTransition,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [...previousChildren, ?currentChild],
                            );
                          },
                          child: colapsadoCompacto
                              ? Row(
                                  key: const ValueKey('header-compacto'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    widget.leading ??
                                        Icon(
                                          Icons.settings_outlined,
                                          size: 20,
                                          color: cs.onSurfaceVariant,
                                        ),
                                    if (!colapsadoSoloIcono) ...[
                                      const SizedBox(width: 10),
                                      Text(
                                        labelColapsado,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface,
                                            ),
                                      ),
                                    ],
                                  ],
                                )
                              : Column(
                                  key: const ValueKey('header-expandido'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (widget.leading != null) ...[
                                          widget.leading!,
                                          const SizedBox(width: 12),
                                        ],
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (mostrarEyebrow)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    if (widget.eyebrowLeading !=
                                                        null) ...[
                                                      widget.eyebrowLeading!,
                                                      const SizedBox(width: 8),
                                                    ],
                                                    Flexible(
                                                      child: Text(
                                                        widget.eyebrow,
                                                        style: theme
                                                            .textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: cs.primary,
                                                              letterSpacing:
                                                                  0.2,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              if (mostrarEyebrow &&
                                                  mostrarTitulo)
                                                const SizedBox(height: 4),
                                              if (mostrarTitulo)
                                                Text(
                                                  widget.title,
                                                  style: theme
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: cs.onSurface,
                                                        height: 1.08,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        AnimatedRotation(
                                          turns: _expanded ? 0.125 : 0,
                                          duration: const Duration(
                                            milliseconds: 240,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          child: Container(
                                            width: 34,
                                            height: 34,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? cs.surfaceContainerHighest
                                                        .withValues(alpha: 0.34)
                                                  : const Color(0xFFF3F4F6),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDark
                                                    ? cs.outlineVariant
                                                    : const Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            child: Icon(
                                              _expanded
                                                  ? Icons.close_rounded
                                                  : Icons.add_rounded,
                                              size: 18,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (mostrarResumen) ...[
                                      const SizedBox(height: 12),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        style: theme.textTheme.bodyMedium!
                                            .copyWith(
                                              height: 1.5,
                                              color: _expanded
                                                  ? cs.onSurfaceVariant
                                                  : cs.onSurfaceVariant
                                                        .withValues(
                                                          alpha: 0.92,
                                                        ),
                                            ),
                                        child: Text(widget.summary),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _expanded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 240),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, (1 - value) * 8),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: widget.child,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        if (!colapsadoCompacto && anchoExpandido != null) {
          tarjeta = SizedBox(width: anchoExpandido, child: tarjeta);
        }
        if (colapsadoCompacto &&
            widget.mantenerAltoAlColapsar &&
            altoColapsado != null) {
          tarjeta = SizedBox(height: altoColapsado, child: tarjeta);
        }

        return AnimatedSize(
          duration: _duracionPanel,
          curve: _curvaPanel,
          alignment: Alignment.topLeft,
          child: tarjeta,
        );
      },
    );
  }
}
