import '../modelos/combo.dart';

class CombosEstado {
  final bool cargando;
  final String? error;
  final List<Combo> combos;
  final bool mostrarInactivos;

  const CombosEstado({
    required this.cargando,
    required this.error,
    required this.combos,
    required this.mostrarInactivos,
  });

  factory CombosEstado.inicial() {
    return const CombosEstado(
      cargando: false,
      error: null,
      combos: [],
      mostrarInactivos: false,
    );
  }

  CombosEstado copiarCon({
    bool? cargando,
    String? error,
    List<Combo>? combos,
    bool? mostrarInactivos,
  }) {
    return CombosEstado(
      cargando: cargando ?? this.cargando,
      error: error,
      combos: combos ?? this.combos,
      mostrarInactivos: mostrarInactivos ?? this.mostrarInactivos,
    );
  }
}