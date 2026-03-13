class FichaPedagogicaCurso {
  final int cursoId;
  final String contenidosDados;
  final String contenidosPendientes;
  final String ritmoGrupo;
  final String observacionesGenerales;
  final String alertasDidacticas;

  const FichaPedagogicaCurso({
    required this.cursoId,
    required this.contenidosDados,
    required this.contenidosPendientes,
    required this.ritmoGrupo,
    required this.observacionesGenerales,
    required this.alertasDidacticas,
  });

  static FichaPedagogicaCurso vacia(int cursoId) {
    return FichaPedagogicaCurso(
      cursoId: cursoId,
      contenidosDados: '',
      contenidosPendientes: '',
      ritmoGrupo: '',
      observacionesGenerales: '',
      alertasDidacticas: '',
    );
  }
}
