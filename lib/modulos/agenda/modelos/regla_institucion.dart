class ReglaInstitucion {
  final String institucion;
  final String escalaCalificacion;
  final String notaAprobacion;
  final double asistenciaMinima;
  final int maxRecuperatorios;
  final bool recuperatorioReemplazaNota;
  final bool recuperatorioSoloCambiaCondicion;
  final bool recuperatorioObligatorio;
  final bool ausenteJustificadoNoPenaliza;
  final String? regimenAsistencia;
  final String? criteriosGenerales;
  final String? observacionesEstandar;
  final DateTime? actualizadoEn;

  const ReglaInstitucion({
    required this.institucion,
    required this.escalaCalificacion,
    required this.notaAprobacion,
    required this.asistenciaMinima,
    required this.maxRecuperatorios,
    required this.recuperatorioReemplazaNota,
    required this.recuperatorioSoloCambiaCondicion,
    required this.recuperatorioObligatorio,
    required this.ausenteJustificadoNoPenaliza,
    required this.regimenAsistencia,
    required this.criteriosGenerales,
    required this.observacionesEstandar,
    required this.actualizadoEn,
  });

  factory ReglaInstitucion.porDefecto(String institucion) {
    return ReglaInstitucion(
      institucion: institucion,
      escalaCalificacion: 'numerica_10',
      notaAprobacion: '6',
      asistenciaMinima: 75,
      maxRecuperatorios: 1,
      recuperatorioReemplazaNota: true,
      recuperatorioSoloCambiaCondicion: false,
      recuperatorioObligatorio: false,
      ausenteJustificadoNoPenaliza: true,
      regimenAsistencia: null,
      criteriosGenerales: null,
      observacionesEstandar: null,
      actualizadoEn: null,
    );
  }
}
