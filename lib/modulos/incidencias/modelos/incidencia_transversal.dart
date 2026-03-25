import 'package:flutter/material.dart';

enum SemaforoIncidenciaTransversal {
  rojo('Rojo', Icons.warning_amber_outlined),
  amarillo('Amarillo', Icons.timelapse_outlined),
  verde('Verde', Icons.check_circle_outline);

  final String etiqueta;
  final IconData icono;

  const SemaforoIncidenciaTransversal(this.etiqueta, this.icono);
}

class IncidenciaTransversal {
  final String origen;
  final String referencia;
  final String titulo;
  final String detalle;
  final String estadoOperativo;
  final String? estadoDocumental;
  final String prioridad;
  final String responsable;
  final String? codigoLegajo;
  final bool devueltaDesdeLegajos;
  final bool vencida;
  final DateTime? fechaCompromiso;

  const IncidenciaTransversal({
    required this.origen,
    required this.referencia,
    required this.titulo,
    required this.detalle,
    required this.estadoOperativo,
    required this.estadoDocumental,
    required this.prioridad,
    required this.responsable,
    required this.codigoLegajo,
    required this.devueltaDesdeLegajos,
    required this.vencida,
    required this.fechaCompromiso,
  });

  bool get urgente =>
      prioridad == 'Alta' ||
      estadoOperativo == 'Urgente' ||
      estadoDocumental == 'Critico' ||
      vencida;

  SemaforoIncidenciaTransversal get semaforo {
    if (vencida ||
        prioridad == 'Alta' ||
        estadoOperativo == 'Urgente' ||
        estadoDocumental == 'Critico') {
      return SemaforoIncidenciaTransversal.rojo;
    }
    if (devueltaDesdeLegajos ||
        prioridad == 'Media' ||
        estadoDocumental == 'En revision') {
      return SemaforoIncidenciaTransversal.amarillo;
    }
    return SemaforoIncidenciaTransversal.verde;
  }

  IconData get iconoOrigen => switch (origen) {
    'Secretaria' => Icons.work_history_outlined,
    'Preceptoria' => Icons.fact_check_outlined,
    'Biblioteca' => Icons.menu_book_outlined,
    _ => Icons.hub_outlined,
  };
}

class ResumenIncidencias {
  final int total;
  final int urgentes;
  final int devueltas;
  final int conLegajo;

  const ResumenIncidencias({
    required this.total,
    required this.urgentes,
    required this.devueltas,
    required this.conLegajo,
  });
}

class DashboardIncidencias {
  final ResumenIncidencias resumen;
  final ResumenAccionesMasivasIncidencias accionesMasivas;
  final ResumenSeguimientoAlertasMesa seguimientoAlertas;
  final ComparativaTemporalMesaIncidencias comparativaTemporal;
  final RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva;
  final HistorialEjecutivoMesaIncidencias historialEjecutivo;
  final ComparativaCabeceraEjecutivaMesa comparativaCabecera;
  final RecomendacionHistoricaMesaIncidencias recomendacionHistorica;
  final ConsolidadoHistoricoRecomendacionMesa consolidadoHistorico;
  final ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion;
  final PlanDesacopleCronificacionMesa planDesacople;
  final SeguimientoPlanDesacopleCronificacionMesa seguimientoPlanDesacople;
  final PlanReforzamientoDesacopleMesa planReforzamientoDesacople;
  final SeguimientoPlanReforzamientoDesacopleMesa seguimientoPlanReforzamientoDesacople;
  final PlanContencionCronificacionMesa planContencionCronificacion;
  final SeguimientoPlanContencionCronificacionMesa seguimientoPlanContencionCronificacion;
  final PlanRespuestaExcepcionalCronificacionMesa planRespuestaExcepcionalCronificacion;
  final SeguimientoPlanRespuestaExcepcionalCronificacionMesa seguimientoPlanRespuestaExcepcionalCronificacion;
  final PlanCierreExtremoCronificacionMesa planCierreExtremoCronificacion;
  final SeguimientoPlanCierreExtremoCronificacionMesa seguimientoPlanCierreExtremoCronificacion;
  final PlanCorteTotalCronificacionMesa planCorteTotalCronificacion;
  final SeguimientoPlanCorteTotalCronificacionMesa seguimientoPlanCorteTotalCronificacion;
  final ProtocoloFinalClausuraInstitucionalMesa protocoloFinalClausura;
  final SeguimientoProtocoloFinalClausuraInstitucionalMesa seguimientoProtocoloFinalClausura;
  final PlanEstabilizacionEjecutivaMesa planEstabilizacion;
  final SeguimientoPlanEstabilizacionMesa seguimientoPlan;
  final AjusteSugeridoPlanEstabilizacionMesa ajustePlan;
  final SeguimientoAjustePlanEstabilizacionMesa seguimientoAjuste;
  final EscalamientoEstrategicoCabeceraMesa escalamientoCabecera;
  final SeguimientoEscalamientoCabeceraMesa seguimientoEscalamiento;
  final ProtocoloContingenciaCabeceraMesa protocoloContingencia;
  final SeguimientoProtocoloContingenciaMesa seguimientoProtocolo;
  final MesaCrisisInstitucionalCabecera mesaCrisis;
  final SeguimientoMesaCrisisInstitucionalMesa seguimientoMesaCrisis;
  final ProtocoloRecuperacionInstitucionalMesa protocoloRecuperacion;
  final SeguimientoProtocoloRecuperacionInstitucionalMesa seguimientoRecuperacion;
  final PlanEstructuralRecomposicionMesa planEstructural;
  final SeguimientoPlanEstructuralRecomposicionMesa seguimientoPlanEstructural;
  final List<AlertaMesaIncidencias> alertasMesa;
  final List<IncidenciaTransversal> incidencias;

  const DashboardIncidencias({
    required this.resumen,
    required this.accionesMasivas,
    required this.seguimientoAlertas,
    required this.comparativaTemporal,
    required this.recomendacionEjecutiva,
    required this.historialEjecutivo,
    required this.comparativaCabecera,
    required this.recomendacionHistorica,
    required this.consolidadoHistorico,
    required this.consolidadoCronificacion,
    required this.planDesacople,
    required this.seguimientoPlanDesacople,
    required this.planReforzamientoDesacople,
    required this.seguimientoPlanReforzamientoDesacople,
    required this.planContencionCronificacion,
    required this.seguimientoPlanContencionCronificacion,
    required this.planRespuestaExcepcionalCronificacion,
    required this.seguimientoPlanRespuestaExcepcionalCronificacion,
    required this.planCierreExtremoCronificacion,
    required this.seguimientoPlanCierreExtremoCronificacion,
    required this.planCorteTotalCronificacion,
    required this.seguimientoPlanCorteTotalCronificacion,
    required this.protocoloFinalClausura,
    required this.seguimientoProtocoloFinalClausura,
    required this.planEstabilizacion,
    required this.seguimientoPlan,
    required this.ajustePlan,
    required this.seguimientoAjuste,
    required this.escalamientoCabecera,
    required this.seguimientoEscalamiento,
    required this.protocoloContingencia,
    required this.seguimientoProtocolo,
    required this.mesaCrisis,
    required this.seguimientoMesaCrisis,
    required this.protocoloRecuperacion,
    required this.seguimientoRecuperacion,
    required this.planEstructural,
    required this.seguimientoPlanEstructural,
    required this.alertasMesa,
    required this.incidencias,
  });
}

class ResumenAccionesMasivasIncidencias {
  final int totalReciente;
  final int priorizaciones;
  final int derivaciones;
  final int devoluciones;
  final int observaciones;
  final String lecturaEjecutiva;
  final List<ImpactoAccionMasivaModulo> impactosPorModulo;

  const ResumenAccionesMasivasIncidencias({
    required this.totalReciente,
    required this.priorizaciones,
    required this.derivaciones,
    required this.devoluciones,
    required this.observaciones,
    required this.lecturaEjecutiva,
    required this.impactosPorModulo,
  });
}

class ImpactoAccionMasivaModulo {
  final String origen;
  final int total;
  final int priorizaciones;
  final int derivaciones;
  final int devoluciones;
  final int observaciones;
  final IconData icono;

  const ImpactoAccionMasivaModulo({
    required this.origen,
    required this.total,
    required this.priorizaciones,
    required this.derivaciones,
    required this.devoluciones,
    required this.observaciones,
    required this.icono,
  });
}

class AlertaMesaIncidencias {
  final String tipo;
  final String titulo;
  final String descripcion;
  final String origen;
  final String severidad;
  final String accionSugerida;
  final IconData icono;

  const AlertaMesaIncidencias({
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.origen,
    required this.severidad,
    required this.accionSugerida,
    required this.icono,
  });
}

class ResumenSeguimientoAlertasMesa {
  final int presetsAplicados;
  final int accionesEjecutadas;
  final int pendientes;
  final String lecturaEjecutiva;

  const ResumenSeguimientoAlertasMesa({
    required this.presetsAplicados,
    required this.accionesEjecutadas,
    required this.pendientes,
    required this.lecturaEjecutiva,
  });
}

class ComparativaTemporalMesaIncidencias {
  final int accionesActuales;
  final int accionesPrevias;
  final int conversionActual;
  final int conversionPrevia;
  final String estadoActividad;
  final String estadoConversion;
  final String lecturaEjecutiva;

  const ComparativaTemporalMesaIncidencias({
    required this.accionesActuales,
    required this.accionesPrevias,
    required this.conversionActual,
    required this.conversionPrevia,
    required this.estadoActividad,
    required this.estadoConversion,
    required this.lecturaEjecutiva,
  });
}

class RecomendacionEjecutivaMesaIncidencias {
  final String foco;
  final String severidad;
  final String accionSugerida;
  final String lecturaEjecutiva;
  final String tipoAlertaOrigen;
  final IconData icono;

  const RecomendacionEjecutivaMesaIncidencias({
    required this.foco,
    required this.severidad,
    required this.accionSugerida,
    required this.lecturaEjecutiva,
    required this.tipoAlertaOrigen,
    required this.icono,
  });
}

class HistorialEjecutivoMesaIncidencias {
  final int focosConsultados;
  final int accionesRapidas;
  final int conversionPorcentaje;
  final int pendientesConversion;
  final String estadoConversion;
  final String lecturaEjecutiva;
  final List<EventoEjecutivoMesaIncidencias> eventos;

  const HistorialEjecutivoMesaIncidencias({
    required this.focosConsultados,
    required this.accionesRapidas,
    required this.conversionPorcentaje,
    required this.pendientesConversion,
    required this.estadoConversion,
    required this.lecturaEjecutiva,
    required this.eventos,
  });
}

class ComparativaCabeceraEjecutivaMesa {
  final int focosActuales;
  final int focosPrevios;
  final int accionesActuales;
  final int accionesPrevias;
  final int conversionActual;
  final int conversionPrevia;
  final String estadoConversion;
  final String lecturaEjecutiva;

  const ComparativaCabeceraEjecutivaMesa({
    required this.focosActuales,
    required this.focosPrevios,
    required this.accionesActuales,
    required this.accionesPrevias,
    required this.conversionActual,
    required this.conversionPrevia,
    required this.estadoConversion,
    required this.lecturaEjecutiva,
  });
}

class RecomendacionHistoricaMesaIncidencias {
  final String focoActual;
  final String focoPrevio;
  final int eventosActuales;
  final int eventosPrevios;
  final int cambiosRecientes;
  final String estadoConsistencia;
  final String lecturaEjecutiva;

  const RecomendacionHistoricaMesaIncidencias({
    required this.focoActual,
    required this.focoPrevio,
    required this.eventosActuales,
    required this.eventosPrevios,
    required this.cambiosRecientes,
    required this.estadoConsistencia,
    required this.lecturaEjecutiva,
  });
}

class ConsolidadoHistoricoRecomendacionMesa {
  final String patron;
  final String estado;
  final int riesgoOscilacion;
  final String lecturaEjecutiva;

  const ConsolidadoHistoricoRecomendacionMesa({
    required this.patron,
    required this.estado,
    required this.riesgoOscilacion,
    required this.lecturaEjecutiva,
  });
}

class ConsolidadoCronificacionInstitucionalMesa {
  final String patron;
  final String estado;
  final int riesgoCronificacion;
  final List<String> modulosConcentrados;
  final String lecturaEjecutiva;

  const ConsolidadoCronificacionInstitucionalMesa({
    required this.patron,
    required this.estado,
    required this.riesgoCronificacion,
    required this.modulosConcentrados,
    required this.lecturaEjecutiva,
  });
}

class PlanDesacopleCronificacionMesa {
  final String estado;
  final String tipoDesacople;
  final String criterioDesacople;
  final int horizonteDias;
  final List<String> modulosDesacople;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanDesacopleCronificacionMesa({
    required this.estado,
    required this.tipoDesacople,
    required this.criterioDesacople,
    required this.horizonteDias,
    required this.modulosDesacople,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanDesacopleCronificacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanDesacopleCronificacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanReforzamientoDesacopleMesa {
  final String estado;
  final String tipoReforzamiento;
  final String criterioReforzamiento;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanReforzamientoDesacopleMesa({
    required this.estado,
    required this.tipoReforzamiento,
    required this.criterioReforzamiento,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanReforzamientoDesacopleMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanReforzamientoDesacopleMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanContencionCronificacionMesa {
  final String estado;
  final String tipoContencion;
  final String criterioContencion;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanContencionCronificacionMesa({
    required this.estado,
    required this.tipoContencion,
    required this.criterioContencion,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanContencionCronificacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanContencionCronificacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanRespuestaExcepcionalCronificacionMesa {
  final String estado;
  final String tipoRespuesta;
  final String criterioRespuesta;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanRespuestaExcepcionalCronificacionMesa({
    required this.estado,
    required this.tipoRespuesta,
    required this.criterioRespuesta,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanRespuestaExcepcionalCronificacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanRespuestaExcepcionalCronificacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanCierreExtremoCronificacionMesa {
  final String estado;
  final String tipoCierre;
  final String criterioCierre;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanCierreExtremoCronificacionMesa({
    required this.estado,
    required this.tipoCierre,
    required this.criterioCierre,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanCierreExtremoCronificacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanCierreExtremoCronificacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanCorteTotalCronificacionMesa {
  final String estado;
  final String tipoCorte;
  final String criterioCorte;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanCorteTotalCronificacionMesa({
    required this.estado,
    required this.tipoCorte,
    required this.criterioCorte,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanCorteTotalCronificacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanCorteTotalCronificacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class ProtocoloFinalClausuraInstitucionalMesa {
  final String estado;
  final String tipoClausura;
  final String criterioClausura;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const ProtocoloFinalClausuraInstitucionalMesa({
    required this.estado,
    required this.tipoClausura,
    required this.criterioClausura,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoProtocoloFinalClausuraInstitucionalMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoProtocoloFinalClausuraInstitucionalMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanEstabilizacionEjecutivaMesa {
  final String estado;
  final String criterio;
  final int horizonteDias;
  final List<String> modulosPrioritarios;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanEstabilizacionEjecutivaMesa({
    required this.estado,
    required this.criterio,
    required this.horizonteDias,
    required this.modulosPrioritarios,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanEstabilizacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanEstabilizacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class AjusteSugeridoPlanEstabilizacionMesa {
  final String estado;
  final String tipoAjuste;
  final String criterioAjustado;
  final int horizonteDiasSugerido;
  final List<String> modulosRefuerzo;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const AjusteSugeridoPlanEstabilizacionMesa({
    required this.estado,
    required this.tipoAjuste,
    required this.criterioAjustado,
    required this.horizonteDiasSugerido,
    required this.modulosRefuerzo,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoAjustePlanEstabilizacionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoAjustePlanEstabilizacionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class EscalamientoEstrategicoCabeceraMesa {
  final String estado;
  final String tipoIntervencion;
  final String criterioEjecutivo;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const EscalamientoEstrategicoCabeceraMesa({
    required this.estado,
    required this.tipoIntervencion,
    required this.criterioEjecutivo,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoEscalamientoCabeceraMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoEscalamientoCabeceraMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class ProtocoloContingenciaCabeceraMesa {
  final String estado;
  final String tipoProtocolo;
  final String criterioInstitucional;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const ProtocoloContingenciaCabeceraMesa({
    required this.estado,
    required this.tipoProtocolo,
    required this.criterioInstitucional,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoProtocoloContingenciaMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoProtocoloContingenciaMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class MesaCrisisInstitucionalCabecera {
  final String estado;
  final String tipoMesa;
  final String criterioCrisis;
  final int horizonteDias;
  final List<String> modulosCriticos;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const MesaCrisisInstitucionalCabecera({
    required this.estado,
    required this.tipoMesa,
    required this.criterioCrisis,
    required this.horizonteDias,
    required this.modulosCriticos,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoMesaCrisisInstitucionalMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoMesaCrisisInstitucionalMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class ProtocoloRecuperacionInstitucionalMesa {
  final String estado;
  final String tipoRecuperacion;
  final String criterioRecuperacion;
  final int horizonteDias;
  final List<String> modulosPrioritarios;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const ProtocoloRecuperacionInstitucionalMesa({
    required this.estado,
    required this.tipoRecuperacion,
    required this.criterioRecuperacion,
    required this.horizonteDias,
    required this.modulosPrioritarios,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoProtocoloRecuperacionInstitucionalMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoProtocoloRecuperacionInstitucionalMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class PlanEstructuralRecomposicionMesa {
  final String estado;
  final String tipoPlan;
  final String criterioEstructural;
  final int horizonteDias;
  final List<String> modulosPrioritarios;
  final List<String> accionesSugeridas;
  final String lecturaEjecutiva;

  const PlanEstructuralRecomposicionMesa({
    required this.estado,
    required this.tipoPlan,
    required this.criterioEstructural,
    required this.horizonteDias,
    required this.modulosPrioritarios,
    required this.accionesSugeridas,
    required this.lecturaEjecutiva,
  });
}

class SeguimientoPlanEstructuralRecomposicionMesa {
  final int presetsAplicados;
  final int ejecucionesRegistradas;
  final int conversionPorcentaje;
  final int pendientes;
  final String estadoEfecto;
  final String lecturaEjecutiva;

  const SeguimientoPlanEstructuralRecomposicionMesa({
    required this.presetsAplicados,
    required this.ejecucionesRegistradas,
    required this.conversionPorcentaje,
    required this.pendientes,
    required this.estadoEfecto,
    required this.lecturaEjecutiva,
  });
}

class EventoEjecutivoMesaIncidencias {
  final String accion;
  final String tipoAlerta;
  final int cantidadCasos;
  final String detalle;
  final DateTime creadoEn;

  const EventoEjecutivoMesaIncidencias({
    required this.accion,
    required this.tipoAlerta,
    required this.cantidadCasos,
    required this.detalle,
    required this.creadoEn,
  });
}

class HistorialIncidenciaTransversal {
  final String accion;
  final String? estadoOperativo;
  final String? estadoDocumental;
  final String? detalle;
  final DateTime creadoEn;

  const HistorialIncidenciaTransversal({
    required this.accion,
    required this.estadoOperativo,
    required this.estadoDocumental,
    required this.detalle,
    required this.creadoEn,
  });
}
