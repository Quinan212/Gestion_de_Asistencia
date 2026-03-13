part of 'carreras_pantalla.dart';

class _ConfirmacionBorrado {
  final bool eliminarAlumnosAsociados;

  const _ConfirmacionBorrado({required this.eliminarAlumnosAsociados});
}

class _NombreMateriaConScroll extends StatefulWidget {
  final String texto;
  final TextStyle style;
  final int maxLineas;

  const _NombreMateriaConScroll({
    required this.texto,
    required this.style,
    this.maxLineas = 3,
  });

  @override
  State<_NombreMateriaConScroll> createState() =>
      _NombreMateriaConScrollState();
}

class _NombreMateriaConScrollState extends State<_NombreMateriaConScroll> {
  final ScrollController _scroll = ScrollController();
  int _versionAnimacion = 0;
  bool _animando = false;
  bool _iniciandoAnimacion = false;

  static const Duration _pausaInicial = Duration(milliseconds: 250);
  static const Duration _pausaEnExtremos = Duration(milliseconds: 450);
  static const int _reintentosMaximosClientes = 8;
  static const double _pxPorSegundoIda = 34;
  static const double _pxPorSegundoVuelta = 52;
  static const int _duracionMinimaMs = 450;
  static const int _duracionMaximaMs = 6500;

  bool _excedeLineas(double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: widget.texto, style: widget.style),
      maxLines: widget.maxLineas,
      textDirection: Directionality.of(context),
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  double _anchoTextoLineaUnica() {
    final painter = TextPainter(
      text: TextSpan(text: widget.texto, style: widget.style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    return painter.width;
  }

  Duration _duracionPorDistancia(
    double distancia, {
    required double pxPorSegundo,
  }) {
    final milisegundos = ((distancia / pxPorSegundo) * 1000).round();
    final ajustado = milisegundos.clamp(_duracionMinimaMs, _duracionMaximaMs);
    return Duration(milliseconds: ajustado);
  }

  Future<void> _iniciarAnimacionHorizontal() async {
    if (!mounted || _animando || _iniciandoAnimacion) return;
    _iniciandoAnimacion = true;
    final version = ++_versionAnimacion;
    try {
      var intentos = 0;
      while (mounted &&
          !_scroll.hasClients &&
          version == _versionAnimacion &&
          intentos < _reintentosMaximosClientes) {
        intentos++;
        await Future<void>.delayed(const Duration(milliseconds: 16));
      }
      if (!mounted || !_scroll.hasClients || version != _versionAnimacion) {
        return;
      }

      _animando = true;
      var primerCiclo = true;
      while (mounted && _scroll.hasClients && version == _versionAnimacion) {
        final max = _scroll.position.maxScrollExtent;
        if (max <= 0) break;

        await Future<void>.delayed(
          primerCiclo ? _pausaInicial : _pausaEnExtremos,
        );
        if (!mounted || !_scroll.hasClients || version != _versionAnimacion) {
          break;
        }

        await _scroll.animateTo(
          max,
          duration: _duracionPorDistancia(max, pxPorSegundo: _pxPorSegundoIda),
          curve: Curves.linear,
        );

        await Future<void>.delayed(_pausaEnExtremos);
        if (!mounted || !_scroll.hasClients || version != _versionAnimacion) {
          break;
        }

        await _scroll.animateTo(
          0,
          duration: _duracionPorDistancia(
            max,
            pxPorSegundo: _pxPorSegundoVuelta,
          ),
          curve: Curves.linear,
        );
        primerCiclo = false;
      }
    } finally {
      _animando = false;
      _iniciandoAnimacion = false;
    }
  }

  void _detenerAnimacion() {
    _versionAnimacion++;
    _animando = false;
    _iniciandoAnimacion = false;
    if (_scroll.hasClients && _scroll.offset != 0) {
      _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.style.fontSize ?? 14;
    final factorAlto = widget.style.height ?? 1.2;
    final altoLinea = fontSize * factorAlto;
    final altoTotal = altoLinea * widget.maxLineas + 2;

    return SizedBox(
      height: altoTotal,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final excede = _excedeLineas(constraints.maxWidth);
          if (!excede) {
            _detenerAnimacion();
            return Text(
              widget.texto,
              maxLines: widget.maxLineas,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            );
          }
          final anchoVisible = constraints.maxWidth;
          final anchoTexto = _anchoTextoLineaUnica();
          final overflowHorizontal = anchoTexto - anchoVisible;
          final requiereScroll = overflowHorizontal > 0.1;
          if (!requiereScroll) {
            _detenerAnimacion();
            return Text(
              widget.texto,
              maxLines: widget.maxLineas,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _iniciarAnimacionHorizontal();
          });

          final separacionFinal = (anchoVisible * 0.30)
              .clamp(24.0, 72.0)
              .toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.texto,
                maxLines: widget.maxLineas - 1,
                overflow: TextOverflow.ellipsis,
                style: widget.style,
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                height: altoLinea,
                child: ClipRect(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      width: anchoTexto + separacionFinal,
                      child: Text(
                        widget.texto,
                        maxLines: 1,
                        softWrap: false,
                        style: widget.style,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
