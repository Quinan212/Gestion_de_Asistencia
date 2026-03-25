import 'package:flutter/material.dart';

enum PeriodoProductividadGestion {
  semanal(7, '7 dias'),
  mensual(30, '30 dias'),
  trimestral(90, '90 dias');

  final int dias;
  final String etiqueta;

  const PeriodoProductividadGestion(this.dias, this.etiqueta);

  String get comparacionEtiqueta => '$etiqueta anteriores';
}

class IndicadorGestion {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const IndicadorGestion({
    required this.titulo,
    required this.valor,
    required this.descripcion,
    required this.icono,
  });
}

class AlertaGestion {
  final String clave;
  final String titulo;
  final String descripcion;
  final String severidad;
  final IconData icono;
  final String? accionSugerida;
  final String? estadoSeguimiento;
  final String? derivadaA;
  final String? comentario;

  const AlertaGestion({
    required this.clave,
    required this.titulo,
    required this.descripcion,
    required this.severidad,
    required this.icono,
    this.accionSugerida,
    this.estadoSeguimiento,
    this.derivadaA,
    this.comentario,
  });

  AlertaGestion copyWith({
    String? accionSugerida,
    String? estadoSeguimiento,
    String? derivadaA,
    String? comentario,
  }) {
    return AlertaGestion(
      clave: clave,
      titulo: titulo,
      descripcion: descripcion,
      severidad: severidad,
      icono: icono,
      accionSugerida: accionSugerida ?? this.accionSugerida,
      estadoSeguimiento: estadoSeguimiento ?? this.estadoSeguimiento,
      derivadaA: derivadaA ?? this.derivadaA,
      comentario: comentario ?? this.comentario,
    );
  }
}

class HitoGestion {
  final String etiqueta;
  final String valor;
  final String ayuda;

  const HitoGestion({
    required this.etiqueta,
    required this.valor,
    required this.ayuda,
  });
}

class SemaforoGestion {
  final String titulo;
  final String valor;
  final String descripcion;
  final String estado;
  final IconData icono;

  const SemaforoGestion({
    required this.titulo,
    required this.valor,
    required this.descripcion,
    required this.estado,
    required this.icono,
  });
}

class TableroGestionItem {
  final List<IndicadorGestion> indicadores;
  final List<SemaforoGestion> semaforos;
  final ProductividadGestion productividad;
  final List<SeguimientoGestion> escalamientos;
  final List<AlertaGestion> alertas;
  final List<HitoGestion> hitos;
  final List<SeguimientoGestion> seguimientos;

  const TableroGestionItem({
    required this.indicadores,
    required this.semaforos,
    required this.productividad,
    required this.escalamientos,
    required this.alertas,
    required this.hitos,
    required this.seguimientos,
  });
}

class ProductividadGestion {
  final PeriodoProductividadGestion periodo;
  final int cierresEjecutivos;
  final int resoluciones;
  final int reaberturas;
  final int planesCorrectivosActivos;
  final int planesCorrectivosResueltos;
  final int planesCorrectivosReabiertos;
  final double promedioHorasResolucion;
  final ComparativaPlanCorrectivo comparativaPlanesCorrectivos;
  final ResumenRevisionCorrectiva resumenRevisionesCorrectivas;
  final ResumenCumplimientoPlanMejora resumenCumplimientoPlanMejora;
  final ResumenPostReplanificacion resumenPostReplanificacion;
  final ComparativaRiesgoReplanificacion comparativaRiesgoReplanificacion;
  final ResumenEstrategiasCorrectivas resumenEstrategiasCorrectivas;
  final ResumenDecisionesEstrategicas resumenDecisionesEstrategicas;
  final List<TendenciaProductividad> tendencias;
  final List<ProductividadResponsable> responsables;
  final List<CierreEjecutivoPatron> cierresPatrones;

  const ProductividadGestion({
    required this.periodo,
    required this.cierresEjecutivos,
    required this.resoluciones,
    required this.reaberturas,
    required this.planesCorrectivosActivos,
    required this.planesCorrectivosResueltos,
    required this.planesCorrectivosReabiertos,
    required this.promedioHorasResolucion,
    required this.comparativaPlanesCorrectivos,
    required this.resumenRevisionesCorrectivas,
    required this.resumenCumplimientoPlanMejora,
    required this.resumenPostReplanificacion,
    required this.comparativaRiesgoReplanificacion,
    required this.resumenEstrategiasCorrectivas,
    required this.resumenDecisionesEstrategicas,
    required this.tendencias,
    required this.responsables,
    required this.cierresPatrones,
  });
}

class TendenciaProductividad {
  final String clave;
  final String titulo;
  final String valorActual;
  final String valorAnterior;
  final String variacion;
  final String estado;
  final String descripcion;

  const TendenciaProductividad({
    required this.clave,
    required this.titulo,
    required this.valorActual,
    required this.valorAnterior,
    required this.variacion,
    required this.estado,
    required this.descripcion,
  });
}

class ProductividadResponsable {
  final String responsable;
  final int activos;
  final int resueltosPeriodo;
  final int reabiertosPeriodo;

  const ProductividadResponsable({
    required this.responsable,
    required this.activos,
    required this.resueltosPeriodo,
    required this.reabiertosPeriodo,
  });
}

class ComparativaPlanCorrectivo {
  final SegmentoEfectividadPlanCorrectivo conPlanCorrectivo;
  final SegmentoEfectividadPlanCorrectivo sinPlanCorrectivo;
  final String estado;
  final String lecturaEjecutiva;

  const ComparativaPlanCorrectivo({
    required this.conPlanCorrectivo,
    required this.sinPlanCorrectivo,
    required this.estado,
    required this.lecturaEjecutiva,
  });
}

class SegmentoEfectividadPlanCorrectivo {
  final String etiqueta;
  final int casosResueltos;
  final int reaperturas;
  final double tasaReapertura;
  final double promedioHorasResolucion;
  final String descripcion;

  const SegmentoEfectividadPlanCorrectivo({
    required this.etiqueta,
    required this.casosResueltos,
    required this.reaperturas,
    required this.tasaReapertura,
    required this.promedioHorasResolucion,
    required this.descripcion,
  });
}

class ResumenRevisionCorrectiva {
  final int revisionesRegistradas;
  final int planesAuditados;
  final String lecturaEjecutiva;
  final List<PatronRevisionCorrectiva> bloqueosFrecuentes;
  final List<PatronRevisionCorrectiva> areasComprometidas;

  const ResumenRevisionCorrectiva({
    required this.revisionesRegistradas,
    required this.planesAuditados,
    required this.lecturaEjecutiva,
    required this.bloqueosFrecuentes,
    required this.areasComprometidas,
  });
}

class ResumenCumplimientoPlanMejora {
  final int replanificacionesRegistradas;
  final int planesReplanificados;
  final int planesVencidosActivos;
  final int planesCronificados;
  final String lecturaEjecutiva;
  final List<PatronCumplimientoPlanMejora> responsablesReprogramados;
  final List<PatronCumplimientoPlanMejora> planesCronificadosDetalle;

  const ResumenCumplimientoPlanMejora({
    required this.replanificacionesRegistradas,
    required this.planesReplanificados,
    required this.planesVencidosActivos,
    required this.planesCronificados,
    required this.lecturaEjecutiva,
    required this.responsablesReprogramados,
    required this.planesCronificadosDetalle,
  });
}

class ResumenPostReplanificacion {
  final int planesObservados;
  final int estabilizados;
  final int reabiertos;
  final int vencidosActivos;
  final int enSeguimiento;
  final String estado;
  final String lecturaEjecutiva;
  final List<PatronCumplimientoPlanMejora> responsablesEnRiesgo;

  const ResumenPostReplanificacion({
    required this.planesObservados,
    required this.estabilizados,
    required this.reabiertos,
    required this.vencidosActivos,
    required this.enSeguimiento,
    required this.estado,
    required this.lecturaEjecutiva,
    required this.responsablesEnRiesgo,
  });
}

class ComparativaRiesgoReplanificacion {
  final int presionCronificacion;
  final int riesgoPostAjuste;
  final String foco;
  final String lecturaEjecutiva;
  final String accionSugerida;

  const ComparativaRiesgoReplanificacion({
    required this.presionCronificacion,
    required this.riesgoPostAjuste,
    required this.foco,
    required this.lecturaEjecutiva,
    required this.accionSugerida,
  });
}

class ResumenEstrategiasCorrectivas {
  final String lecturaEjecutiva;
  final RecomendacionEstrategiaCorrectiva recomendacion;
  final List<EstrategiaCorrectivaItem> estrategias;
  final List<TendenciaEstrategiaCorrectiva> tendencias;

  const ResumenEstrategiasCorrectivas({
    required this.lecturaEjecutiva,
    required this.recomendacion,
    required this.estrategias,
    required this.tendencias,
  });
}

class RecomendacionEstrategiaCorrectiva {
  final String estrategia;
  final String estrategiaAnterior;
  final String estado;
  final bool esInestable;
  final String lecturaEjecutiva;
  final String accionSugerida;

  const RecomendacionEstrategiaCorrectiva({
    required this.estrategia,
    required this.estrategiaAnterior,
    required this.estado,
    required this.esInestable,
    required this.lecturaEjecutiva,
    required this.accionSugerida,
  });
}

class EstrategiaCorrectivaItem {
  final String estrategia;
  final int activas;
  final int resueltasPeriodo;
  final int reabiertasPeriodo;
  final int vencidasActivas;

  const EstrategiaCorrectivaItem({
    required this.estrategia,
    required this.activas,
    required this.resueltasPeriodo,
    required this.reabiertasPeriodo,
    required this.vencidasActivas,
  });
}

class TendenciaEstrategiaCorrectiva {
  final String estrategia;
  final int resueltasActual;
  final int resueltasAnterior;
  final int reabiertasActual;
  final int reabiertasAnterior;
  final String estado;
  final String lectura;

  const TendenciaEstrategiaCorrectiva({
    required this.estrategia,
    required this.resueltasActual,
    required this.resueltasAnterior,
    required this.reabiertasActual,
    required this.reabiertasAnterior,
    required this.estado,
    required this.lectura,
  });
}

class ResumenDecisionesEstrategicas {
  final String lecturaEjecutiva;
  final List<DecisionEstrategicaItem> decisiones;

  const ResumenDecisionesEstrategicas({
    required this.lecturaEjecutiva,
    required this.decisiones,
  });
}

class DecisionEstrategicaItem {
  final String decision;
  final int activas;
  final int resueltasPeriodo;
  final int reabiertasPeriodo;

  const DecisionEstrategicaItem({
    required this.decision,
    required this.activas,
    required this.resueltasPeriodo,
    required this.reabiertasPeriodo,
  });
}

class PatronCumplimientoPlanMejora {
  final String etiqueta;
  final int cantidad;
  final String subtitulo;

  const PatronCumplimientoPlanMejora({
    required this.etiqueta,
    required this.cantidad,
    required this.subtitulo,
  });
}

class PatronRevisionCorrectiva {
  final String etiqueta;
  final int cantidad;
  final String subtitulo;

  const PatronRevisionCorrectiva({
    required this.etiqueta,
    required this.cantidad,
    required this.subtitulo,
  });
}

class CierreEjecutivoPatron {
  final String plantilla;
  final String tipoCaso;
  final String impacto;
  final int cantidad;

  const CierreEjecutivoPatron({
    required this.plantilla,
    required this.tipoCaso,
    required this.impacto,
    required this.cantidad,
  });
}

class DetalleAlertaGestion {
  final String titulo;
  final String descripcion;
  final List<DetalleAlertaGestionFila> filas;

  const DetalleAlertaGestion({
    required this.titulo,
    required this.descripcion,
    required this.filas,
  });
}

class DetalleAlertaGestionFila {
  final String titulo;
  final String subtitulo;
  final String valor;

  const DetalleAlertaGestionFila({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
  });
}

class SeguimientoGestion {
  final String clave;
  final String titulo;
  final String responsable;
  final String estado;
  final String comentario;
  final String? estrategiaCorrectiva;
  final String? decisionEstrategica;
  final DateTime actualizadoEn;
  final DateTime venceEn;
  final String urgencia;
  final String impactoProductividad;
  final bool esPlanCorrectivo;
  final bool tienePlanMejoraCorrectiva;
  final DateTime? fechaObjetivoPlan;

  const SeguimientoGestion({
    required this.clave,
    required this.titulo,
    required this.responsable,
    required this.estado,
    required this.comentario,
    required this.estrategiaCorrectiva,
    required this.decisionEstrategica,
    required this.actualizadoEn,
    required this.venceEn,
    required this.urgencia,
    required this.impactoProductividad,
    required this.esPlanCorrectivo,
    required this.tienePlanMejoraCorrectiva,
    required this.fechaObjetivoPlan,
  });

  bool get estaVencido => venceEn.isBefore(DateTime.now());

  bool get planMejoraVencido =>
      tienePlanMejoraCorrectiva &&
      estado != 'resuelta' &&
      fechaObjetivoPlan != null &&
      fechaObjetivoPlan!.isBefore(DateTime.now());

  bool get planMejoraPorVencer {
    if (!tienePlanMejoraCorrectiva ||
        estado == 'resuelta' ||
        fechaObjetivoPlan == null) {
      return false;
    }
    final ahora = DateTime.now();
    if (fechaObjetivoPlan!.isBefore(ahora)) return false;
    return fechaObjetivoPlan!.difference(ahora) <= const Duration(days: 3);
  }
}

class HistorialAlertaGestion {
  final String accion;
  final String? estadoAnterior;
  final String estadoNuevo;
  final String? derivadaA;
  final String comentario;
  final DateTime creadoEn;

  const HistorialAlertaGestion({
    required this.accion,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.derivadaA,
    required this.comentario,
    required this.creadoEn,
  });
}
