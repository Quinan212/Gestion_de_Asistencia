import 'package:flutter/material.dart';
import 'package:drift/drift.dart';

import 'package:gestion_de_asistencias/infraestructura/base_de_datos/base_de_datos.dart';
import 'package:gestion_de_asistencias/modulos/incidencias/modelos/incidencia_transversal.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class IncidenciasTransversalesRepositorio {
  final BaseDeDatos _db;

  IncidenciasTransversalesRepositorio(this._db);

  Future<DashboardIncidencias> cargarDashboard({
    required ContextoInstitucional contexto,
    required String origen,
  }) async {
    final legajos =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    final legajosSecretaria = {
      for (final item in legajos.where((it) => it.codigo.startsWith('SEC-')))
        item.codigo.replaceFirst('SEC-', ''): item,
    };
    final legajosBiblioteca = {
      for (final item in legajos.where((it) => it.codigo.startsWith('BIB-')))
        item.codigo.replaceFirst('BIB-', ''): item,
    };
    final legajosPreceptoria = {
      for (final item in legajos.where((it) => it.codigo.startsWith('PRE-')))
        _idPreceptoria(item.codigo): item,
    };

    final incidencias = <IncidenciaTransversal>[
      ...await _incidenciasSecretaria(contexto, legajosSecretaria),
      ...await _incidenciasPreceptoria(contexto, legajosPreceptoria),
      ...await _incidenciasBiblioteca(contexto, legajosBiblioteca),
    ];

    final filtradas = origen == 'todas'
        ? incidencias
        : incidencias.where((item) => item.origen.toLowerCase() == origen).toList(
            growable: false,
          );

    filtradas.sort((a, b) {
      final pesoUrgencia = _pesoUrgencia(b).compareTo(_pesoUrgencia(a));
      if (pesoUrgencia != 0) return pesoUrgencia;
      final fechaA = a.fechaCompromiso ?? DateTime(2100);
      final fechaB = b.fechaCompromiso ?? DateTime(2100);
      return fechaA.compareTo(fechaB);
    });

    final accionesMasivas = await _cargarResumenAccionesMasivas();
    final seguimientoAlertas = await _cargarSeguimientoAlertasMesa();
    final comparativaTemporal = await _cargarComparativaTemporalMesa();
    final historialEjecutivo = await _cargarHistorialEjecutivoMesa();
    final comparativaCabecera = await _cargarComparativaCabeceraEjecutivaMesa();
    final alertasBase = _construirAlertasMesa(
      incidencias: incidencias,
      accionesMasivas: accionesMasivas,
      seguimientoAlertas: seguimientoAlertas,
      comparativaTemporal: comparativaTemporal,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
      consolidadoCronificacion: null,
    );
    final recomendacionBase = _construirRecomendacionEjecutiva(
      alertasMesa: alertasBase,
      comparativaTemporal: comparativaTemporal,
      seguimientoAlertas: seguimientoAlertas,
    );
    final recomendacionHistorica = await _cargarRecomendacionHistoricaMesa(
      recomendacionActual: recomendacionBase,
    );
    final consolidadoBase = _construirConsolidadoHistoricoRecomendacion(
      recomendacionHistorica: recomendacionHistorica,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
    );
    final alertasMesa = _construirAlertasMesa(
      incidencias: incidencias,
      accionesMasivas: accionesMasivas,
      seguimientoAlertas: seguimientoAlertas,
      comparativaTemporal: comparativaTemporal,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
      recomendacionHistorica: recomendacionHistorica,
      consolidadoHistorico: consolidadoBase,
      consolidadoCronificacion: null,
    );
    final recomendacionEjecutiva = _construirRecomendacionEjecutiva(
      alertasMesa: alertasMesa,
      comparativaTemporal: comparativaTemporal,
      seguimientoAlertas: seguimientoAlertas,
    );
    final recomendacionHistoricaActualizada = await _cargarRecomendacionHistoricaMesa(
      recomendacionActual: recomendacionEjecutiva,
    );
    final consolidadoHistorico = _construirConsolidadoHistoricoRecomendacion(
      recomendacionHistorica: recomendacionHistoricaActualizada,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
    );
    final seguimientoPlan = await _cargarSeguimientoPlanEstabilizacion(
      consolidadoHistorico: consolidadoHistorico,
      comparativaCabecera: comparativaCabecera,
    );
    final seguimientoAjuste = await _cargarSeguimientoAjustePlanEstabilizacion(
      seguimientoPlan: seguimientoPlan,
      comparativaCabecera: comparativaCabecera,
    );
    final seguimientoEscalamiento =
        await _cargarSeguimientoEscalamientoCabecera(
          seguimientoAjuste: seguimientoAjuste,
          comparativaCabecera: comparativaCabecera,
        );
    final seguimientoProtocolo = await _cargarSeguimientoProtocoloContingencia(
      seguimientoEscalamiento: seguimientoEscalamiento,
      comparativaCabecera: comparativaCabecera,
    );
    final alertasMesaFinal = _construirAlertasMesa(
      incidencias: incidencias,
      accionesMasivas: accionesMasivas,
      seguimientoAlertas: seguimientoAlertas,
      comparativaTemporal: comparativaTemporal,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
      recomendacionHistorica: recomendacionHistoricaActualizada,
      consolidadoHistorico: consolidadoHistorico,
      consolidadoCronificacion: null,
      seguimientoPlan: seguimientoPlan,
      seguimientoAjuste: seguimientoAjuste,
      seguimientoEscalamiento: seguimientoEscalamiento,
      seguimientoProtocolo: seguimientoProtocolo,
    );
    final recomendacionEjecutivaFinal = _construirRecomendacionEjecutiva(
      alertasMesa: alertasMesaFinal,
      comparativaTemporal: comparativaTemporal,
      seguimientoAlertas: seguimientoAlertas,
    );
    final planEstabilizacion = _construirPlanEstabilizacionEjecutiva(
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaFinal,
      consolidadoHistorico: consolidadoHistorico,
      recomendacionHistorica: recomendacionHistoricaActualizada,
    );
    final ajustePlan = _construirAjusteSugeridoPlanEstabilizacion(
      planActual: planEstabilizacion,
      seguimientoPlan: seguimientoPlan,
      recomendacionEjecutiva: recomendacionEjecutivaFinal,
      incidencias: incidencias,
    );
    final escalamientoCabecera = _construirEscalamientoCabecera(
      seguimientoAjuste: seguimientoAjuste,
      ajustePlan: ajustePlan,
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaFinal,
    );
    final protocoloContingencia = _construirProtocoloContingencia(
      seguimientoEscalamiento: seguimientoEscalamiento,
      escalamientoCabecera: escalamientoCabecera,
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaFinal,
    );
    final mesaCrisis = _construirMesaCrisisInstitucional(
      seguimientoProtocolo: seguimientoProtocolo,
      protocoloContingencia: protocoloContingencia,
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaFinal,
    );
    final seguimientoMesaCrisis = await _cargarSeguimientoMesaCrisisInstitucional(
      seguimientoProtocolo: seguimientoProtocolo,
      comparativaCabecera: comparativaCabecera,
    );
    final protocoloRecuperacion = _construirProtocoloRecuperacionInstitucional(
      seguimientoMesaCrisis: seguimientoMesaCrisis,
      mesaCrisis: mesaCrisis,
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaFinal,
    );
    final seguimientoRecuperacion =
        await _cargarSeguimientoProtocoloRecuperacionInstitucional(
          seguimientoMesaCrisis: seguimientoMesaCrisis,
          comparativaCabecera: comparativaCabecera,
        );
    final alertasMesaConCrisis = _construirAlertasMesa(
      incidencias: incidencias,
      accionesMasivas: accionesMasivas,
      seguimientoAlertas: seguimientoAlertas,
      comparativaTemporal: comparativaTemporal,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
      recomendacionHistorica: recomendacionHistoricaActualizada,
      consolidadoHistorico: consolidadoHistorico,
      consolidadoCronificacion: null,
      seguimientoPlan: seguimientoPlan,
      seguimientoAjuste: seguimientoAjuste,
      seguimientoEscalamiento: seguimientoEscalamiento,
      seguimientoProtocolo: seguimientoProtocolo,
      seguimientoMesaCrisis: seguimientoMesaCrisis,
      seguimientoRecuperacion: seguimientoRecuperacion,
    );
    final recomendacionEjecutivaConCrisis = _construirRecomendacionEjecutiva(
      alertasMesa: alertasMesaConCrisis,
      comparativaTemporal: comparativaTemporal,
      seguimientoAlertas: seguimientoAlertas,
    );
    final planEstructural = _construirPlanEstructuralRecomposicion(
      seguimientoRecuperacion: seguimientoRecuperacion,
      protocoloRecuperacion: protocoloRecuperacion,
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaConCrisis,
    );
    final seguimientoPlanEstructural =
        await _cargarSeguimientoPlanEstructuralRecomposicion(
          seguimientoRecuperacion: seguimientoRecuperacion,
          comparativaCabecera: comparativaCabecera,
        );
    final consolidadoCronificacion = _construirConsolidadoCronificacionInstitucional(
      incidencias: incidencias,
      consolidadoHistorico: consolidadoHistorico,
      seguimientoRecuperacion: seguimientoRecuperacion,
      seguimientoPlanEstructural: seguimientoPlanEstructural,
    );
    final planDesacople = _construirPlanDesacopleCronificacion(
      consolidadoCronificacion: consolidadoCronificacion,
      incidencias: incidencias,
      recomendacionEjecutiva: recomendacionEjecutivaConCrisis,
    );
    final seguimientoPlanDesacople =
        await _cargarSeguimientoPlanDesacopleCronificacion(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
        );
    final planReforzamientoDesacople = _construirPlanReforzamientoDesacople(
      seguimientoPlanDesacople: seguimientoPlanDesacople,
      planDesacople: planDesacople,
      consolidadoCronificacion: consolidadoCronificacion,
      incidencias: incidencias,
    );
    final seguimientoPlanReforzamientoDesacople =
        await _cargarSeguimientoPlanReforzamientoDesacople(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
          seguimientoPlanDesacople: seguimientoPlanDesacople,
        );
    final planContencionCronificacion = _construirPlanContencionCronificacion(
      seguimientoPlanReforzamientoDesacople:
          seguimientoPlanReforzamientoDesacople,
      planReforzamientoDesacople: planReforzamientoDesacople,
      consolidadoCronificacion: consolidadoCronificacion,
      incidencias: incidencias,
    );
    final seguimientoPlanContencionCronificacion =
        await _cargarSeguimientoPlanContencionCronificacion(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
          seguimientoPlanReforzamientoDesacople:
              seguimientoPlanReforzamientoDesacople,
        );
    final planRespuestaExcepcionalCronificacion =
        _construirPlanRespuestaExcepcionalCronificacion(
          seguimientoPlanContencionCronificacion:
              seguimientoPlanContencionCronificacion,
          planContencionCronificacion: planContencionCronificacion,
          consolidadoCronificacion: consolidadoCronificacion,
          incidencias: incidencias,
        );
    final seguimientoPlanRespuestaExcepcionalCronificacion =
        await _cargarSeguimientoPlanRespuestaExcepcionalCronificacion(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
          seguimientoPlanContencionCronificacion:
              seguimientoPlanContencionCronificacion,
        );
    final planCierreExtremoCronificacion =
        _construirPlanCierreExtremoCronificacion(
          seguimientoPlanRespuestaExcepcionalCronificacion:
              seguimientoPlanRespuestaExcepcionalCronificacion,
          planRespuestaExcepcionalCronificacion:
              planRespuestaExcepcionalCronificacion,
          consolidadoCronificacion: consolidadoCronificacion,
          incidencias: incidencias,
        );
    final seguimientoPlanCierreExtremoCronificacion =
        await _cargarSeguimientoPlanCierreExtremoCronificacion(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
          seguimientoPlanRespuestaExcepcionalCronificacion:
              seguimientoPlanRespuestaExcepcionalCronificacion,
        );
    final planCorteTotalCronificacion = _construirPlanCorteTotalCronificacion(
      seguimientoPlanCierreExtremoCronificacion:
          seguimientoPlanCierreExtremoCronificacion,
      planCierreExtremoCronificacion: planCierreExtremoCronificacion,
      consolidadoCronificacion: consolidadoCronificacion,
      incidencias: incidencias,
    );
    final seguimientoPlanCorteTotalCronificacion =
        await _cargarSeguimientoPlanCorteTotalCronificacion(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
          seguimientoPlanCierreExtremoCronificacion:
              seguimientoPlanCierreExtremoCronificacion,
        );
    final protocoloFinalClausura = _construirProtocoloFinalClausuraInstitucional(
      seguimientoPlanCorteTotalCronificacion:
          seguimientoPlanCorteTotalCronificacion,
      planCorteTotalCronificacion: planCorteTotalCronificacion,
      consolidadoCronificacion: consolidadoCronificacion,
      incidencias: incidencias,
    );
    final seguimientoProtocoloFinalClausura =
        await _cargarSeguimientoProtocoloFinalClausuraInstitucional(
          consolidadoCronificacion: consolidadoCronificacion,
          comparativaCabecera: comparativaCabecera,
          seguimientoPlanCorteTotalCronificacion:
              seguimientoPlanCorteTotalCronificacion,
        );
    final alertasMesaCronica = _construirAlertasMesa(
      incidencias: incidencias,
      accionesMasivas: accionesMasivas,
      seguimientoAlertas: seguimientoAlertas,
      comparativaTemporal: comparativaTemporal,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
      recomendacionHistorica: recomendacionHistoricaActualizada,
      consolidadoHistorico: consolidadoHistorico,
      consolidadoCronificacion: consolidadoCronificacion,
      seguimientoPlanDesacople: seguimientoPlanDesacople,
      seguimientoPlanReforzamientoDesacople:
          seguimientoPlanReforzamientoDesacople,
      seguimientoPlanContencionCronificacion:
          seguimientoPlanContencionCronificacion,
      seguimientoPlanRespuestaExcepcionalCronificacion:
          seguimientoPlanRespuestaExcepcionalCronificacion,
      seguimientoPlanCierreExtremoCronificacion:
          seguimientoPlanCierreExtremoCronificacion,
      seguimientoPlanCorteTotalCronificacion:
          seguimientoPlanCorteTotalCronificacion,
      seguimientoProtocoloFinalClausura:
          seguimientoProtocoloFinalClausura,
      seguimientoPlan: seguimientoPlan,
      seguimientoAjuste: seguimientoAjuste,
      seguimientoEscalamiento: seguimientoEscalamiento,
      seguimientoProtocolo: seguimientoProtocolo,
      seguimientoMesaCrisis: seguimientoMesaCrisis,
      seguimientoRecuperacion: seguimientoRecuperacion,
      seguimientoPlanEstructural: seguimientoPlanEstructural,
    );
    final recomendacionEjecutivaCronica = _construirRecomendacionEjecutiva(
      alertasMesa: alertasMesaCronica,
      comparativaTemporal: comparativaTemporal,
      seguimientoAlertas: seguimientoAlertas,
    );

    return DashboardIncidencias(
      resumen: ResumenIncidencias(
        total: incidencias.length,
        urgentes: incidencias.where((item) => item.urgente).length,
        devueltas: incidencias.where((item) => item.devueltaDesdeLegajos).length,
        conLegajo: incidencias.where((item) => item.codigoLegajo != null).length,
      ),
      accionesMasivas: accionesMasivas,
      seguimientoAlertas: seguimientoAlertas,
      comparativaTemporal: comparativaTemporal,
      recomendacionEjecutiva: recomendacionEjecutivaCronica,
      historialEjecutivo: historialEjecutivo,
      comparativaCabecera: comparativaCabecera,
      recomendacionHistorica: recomendacionHistoricaActualizada,
      consolidadoHistorico: consolidadoHistorico,
      consolidadoCronificacion: consolidadoCronificacion,
      planDesacople: planDesacople,
      seguimientoPlanDesacople: seguimientoPlanDesacople,
      planReforzamientoDesacople: planReforzamientoDesacople,
      seguimientoPlanReforzamientoDesacople:
          seguimientoPlanReforzamientoDesacople,
      planContencionCronificacion: planContencionCronificacion,
      seguimientoPlanContencionCronificacion:
          seguimientoPlanContencionCronificacion,
      planRespuestaExcepcionalCronificacion:
          planRespuestaExcepcionalCronificacion,
      seguimientoPlanRespuestaExcepcionalCronificacion:
          seguimientoPlanRespuestaExcepcionalCronificacion,
      planCierreExtremoCronificacion: planCierreExtremoCronificacion,
      seguimientoPlanCierreExtremoCronificacion:
          seguimientoPlanCierreExtremoCronificacion,
      planCorteTotalCronificacion: planCorteTotalCronificacion,
      seguimientoPlanCorteTotalCronificacion:
          seguimientoPlanCorteTotalCronificacion,
      protocoloFinalClausura: protocoloFinalClausura,
      seguimientoProtocoloFinalClausura:
          seguimientoProtocoloFinalClausura,
      planEstabilizacion: planEstabilizacion,
      seguimientoPlan: seguimientoPlan,
      ajustePlan: ajustePlan,
      seguimientoAjuste: seguimientoAjuste,
      escalamientoCabecera: escalamientoCabecera,
      seguimientoEscalamiento: seguimientoEscalamiento,
      protocoloContingencia: protocoloContingencia,
      seguimientoProtocolo: seguimientoProtocolo,
      mesaCrisis: mesaCrisis,
      seguimientoMesaCrisis: seguimientoMesaCrisis,
      protocoloRecuperacion: protocoloRecuperacion,
      seguimientoRecuperacion: seguimientoRecuperacion,
      planEstructural: planEstructural,
      seguimientoPlanEstructural: seguimientoPlanEstructural,
      alertasMesa: alertasMesaCronica,
      incidencias: filtradas,
    );
  }

  Future<bool> priorizar(
    IncidenciaTransversal item, {
    String? criterio,
    DateTime? fechaObjetivo,
    bool enLote = false,
  }) async {
    final textoCriterio = criterio?.trim();
    bool ok;
    switch (item.origen) {
      case 'Secretaria':
        ok = await _priorizarSecretaria(
          item,
          criterio: textoCriterio,
          fechaObjetivo: fechaObjetivo,
        );
        break;
      case 'Preceptoria':
        ok = await _priorizarPreceptoria(
          item,
          criterio: textoCriterio,
          fechaObjetivo: fechaObjetivo,
        );
        break;
      case 'Biblioteca':
        ok = await _priorizarBiblioteca(
          item,
          criterio: textoCriterio,
          fechaObjetivo: fechaObjetivo,
        );
        break;
      default:
        ok = false;
    }
    if (ok) {
      await _registrarHistorial(
        item: item,
        accion: 'priorizada',
        detalle: _detallePriorizacion(textoCriterio, fechaObjetivo),
      );
      if (enLote) {
        await _registrarHistorial(
          item: item,
          accion: 'priorizacion_masiva',
          detalle: _detallePriorizacion(textoCriterio, fechaObjetivo),
        );
      }
    }
    return ok;
  }

  Future<bool> derivarALegajos({
    required IncidenciaTransversal item,
    required ContextoInstitucional contexto,
    String? justificacion,
    bool enLote = false,
  }) async {
    final textoJustificacion = justificacion?.trim();
    final codigo = _codigoLegajo(item);
    final existente =
        await (_db.select(_db.tablaLegajosDocumentales)
              ..where((t) => t.codigo.equals(codigo) & t.activo.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (existente != null) return false;

    await _db.into(_db.tablaLegajosDocumentales).insert(
      TablaLegajosDocumentalesCompanion.insert(
        tipoRegistro: _tipoRegistro(item),
        categoria: _categoria(item),
        codigo: codigo,
        titulo: item.titulo,
        detalle: _detalleLegajo(item, justificacion: textoJustificacion),
        responsable: item.responsable,
        estado: item.estadoDocumental ?? _estadoLegajo(item),
        severidad: _severidad(item),
        rolDestino: contexto.tienePermiso(PermisoModulo.legajos)
            ? contexto.rol.name
            : RolInstitucional.director.name,
        nivelDestino: contexto.nivel.name,
        dependenciaDestino: contexto.dependencia.name,
        horasHastaVencimiento: Value(_horasHastaCompromiso(item.fechaCompromiso)),
      ),
    );
    await _registrarJustificacionDerivacion(
      item,
      textoJustificacion,
    );
    await _registrarHistorial(
      item: item,
      accion: 'derivada_a_legajos',
      estadoDocumental: _estadoLegajo(item),
      detalle:
          textoJustificacion == null || textoJustificacion.isEmpty
              ? 'La mesa transversal genero un legajo documental para el caso.'
              : 'La mesa transversal genero un legajo documental para el caso. Justificacion: $textoJustificacion',
    );
    if (enLote) {
      await _registrarHistorial(
        item: item,
        accion: 'derivacion_masiva',
        estadoDocumental: _estadoLegajo(item),
        detalle:
            textoJustificacion == null || textoJustificacion.isEmpty
                ? 'Derivacion masiva a Legajos registrada desde la mesa transversal.'
                : 'Derivacion masiva a Legajos. Justificacion: $textoJustificacion',
      );
    }
    return true;
  }

  Future<bool> devolverAlOrigen(
    IncidenciaTransversal item, {
    String? motivo,
    bool enLote = false,
  }) async {
    if (item.codigoLegajo == null && item.estadoDocumental == null) return false;
    final textoMotivo = motivo?.trim();
    bool ok;
    switch (item.origen) {
      case 'Secretaria':
        ok = await _devolverSecretaria(item, motivo: textoMotivo);
        break;
      case 'Preceptoria':
        ok = await _devolverPreceptoria(item, motivo: textoMotivo);
        break;
      case 'Biblioteca':
        ok = await _devolverBiblioteca(item, motivo: textoMotivo);
        break;
      default:
        ok = false;
    }
    if (ok) {
      final detalle = textoMotivo == null || textoMotivo.isEmpty
          ? 'La mesa transversal devolvio el caso a ${item.origen}.'
          : 'La mesa transversal devolvio el caso a ${item.origen}. Motivo: $textoMotivo';
      await _registrarHistorial(
        item: item,
        accion: 'devuelta_al_origen',
        detalle: detalle,
      );
      if (enLote) {
        await _registrarHistorial(
          item: item,
          accion: 'devolucion_masiva',
          detalle: detalle,
        );
      }
    }
    return ok;
  }

  Future<bool> registrarObservacion({
    required IncidenciaTransversal item,
    required String observacion,
    bool enLote = false,
  }) async {
    final texto = observacion.trim();
    if (texto.isEmpty) return false;
    bool ok;
    switch (item.origen) {
      case 'Secretaria':
        ok = await _registrarObservacionSecretaria(item, texto);
        break;
      case 'Preceptoria':
        ok = await _registrarObservacionPreceptoria(item, texto);
        break;
      case 'Biblioteca':
        ok = await _registrarObservacionBiblioteca(item, texto);
        break;
      default:
        ok = false;
    }
    if (ok) {
      final detalle =
          enLote
              ? 'Observacion masiva registrada desde la mesa transversal: $texto'
              : 'Observacion operativa registrada desde la mesa transversal: $texto';
      await _registrarHistorial(
        item: item,
        accion: enLote ? 'observacion_masiva' : 'observacion_operativa',
        detalle: detalle,
      );
    }
    return ok;
  }

  Future<List<HistorialIncidenciaTransversal>> obtenerHistorial(
    IncidenciaTransversal item,
  ) async {
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.origen.equals(item.origen) &
                    t.referencia.equals(item.referencia),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    return rows
        .map(
          (row) => HistorialIncidenciaTransversal(
            accion: row.accion,
            estadoOperativo: row.estadoOperativo,
            estadoDocumental: row.estadoDocumental,
            detalle: row.detalle,
            creadoEn: row.creadoEn,
          ),
        )
        .toList(growable: false);
  }

  Future<void> registrarPresetAlerta({
    required String tipoAlerta,
    required List<IncidenciaTransversal> items,
  }) async {
    for (final item in items) {
      await _registrarHistorial(
        item: item,
        accion: 'preset_alerta_$tipoAlerta',
        detalle:
            'La mesa aplico el preset de alerta $tipoAlerta sobre este caso.',
      );
    }
  }

  Future<void> registrarAccionSugeridaAlerta({
    required String tipoAlerta,
    required List<IncidenciaTransversal> items,
  }) async {
    for (final item in items) {
      await _registrarHistorial(
        item: item,
        accion: 'accion_sugerida_$tipoAlerta',
        detalle:
            'La mesa ejecuto la accion sugerida para la alerta $tipoAlerta sobre este caso.',
      );
    }
  }

  Future<void> registrarFocoRecomendacionDominante({
    required String tipoAlerta,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'foco_dominante_$tipoAlerta',
      detalle:
          'La mesa consulto el foco dominante $tipoAlerta sobre ${items.length} casos.',
    );
  }

  Future<void> registrarAccionRapidaRecomendacionDominante({
    required String tipoAlerta,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'accion_rapida_dominante_$tipoAlerta',
      detalle:
          'La mesa ejecuto la recomendacion dominante $tipoAlerta sobre ${items.length} casos.',
    );
  }

  Future<void> registrarPresetPlanEstabilizacion({
    required PlanEstabilizacionEjecutivaMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_estabilizacion_preset',
      detalle:
          'La cabecera aplico el plan de estabilizacion ${plan.estado.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterio}',
    );
  }

  Future<void> registrarEjecucionPlanEstabilizacion({
    required PlanEstabilizacionEjecutivaMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_estabilizacion_ejecutado',
      detalle:
          'La cabecera ejecuto el plan de estabilizacion ${plan.estado.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetAjustePlanEstabilizacion({
    required AjusteSugeridoPlanEstabilizacionMesa ajuste,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'ajuste_plan_estabilizacion_preset',
      detalle:
          'La cabecera aplico el ajuste ${ajuste.tipoAjuste.toLowerCase()} sobre ${items.length} casos. Nuevo criterio: ${ajuste.criterioAjustado}',
    );
  }

  Future<void> registrarEjecucionAjustePlanEstabilizacion({
    required AjusteSugeridoPlanEstabilizacionMesa ajuste,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'ajuste_plan_estabilizacion_ejecutado',
      detalle:
          'La cabecera ejecuto el ajuste ${ajuste.tipoAjuste.toLowerCase()} sobre ${items.length} casos. Horizonte sugerido: ${ajuste.horizonteDiasSugerido} dias.',
    );
  }

  Future<void> registrarPresetEscalamientoCabecera({
    required EscalamientoEstrategicoCabeceraMesa escalamiento,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'escalamiento_cabecera_preset',
      detalle:
          'La cabecera aplico el escalamiento ${escalamiento.tipoIntervencion.toLowerCase()} sobre ${items.length} casos. Criterio: ${escalamiento.criterioEjecutivo}',
    );
  }

  Future<void> registrarEjecucionEscalamientoCabecera({
    required EscalamientoEstrategicoCabeceraMesa escalamiento,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'escalamiento_cabecera_ejecutado',
      detalle:
          'La cabecera ejecuto el escalamiento ${escalamiento.tipoIntervencion.toLowerCase()} sobre ${items.length} casos. Horizonte: ${escalamiento.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetProtocoloContingencia({
    required ProtocoloContingenciaCabeceraMesa protocolo,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'protocolo_contingencia_preset',
      detalle:
          'La cabecera aplico el protocolo ${protocolo.tipoProtocolo.toLowerCase()} sobre ${items.length} casos. Criterio: ${protocolo.criterioInstitucional}',
    );
  }

  Future<void> registrarEjecucionProtocoloContingencia({
    required ProtocoloContingenciaCabeceraMesa protocolo,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'protocolo_contingencia_ejecutado',
      detalle:
          'La cabecera ejecuto el protocolo ${protocolo.tipoProtocolo.toLowerCase()} sobre ${items.length} casos. Horizonte: ${protocolo.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetMesaCrisis({
    required MesaCrisisInstitucionalCabecera mesa,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'mesa_crisis_preset',
      detalle:
          'La cabecera activo la mesa de crisis ${mesa.tipoMesa.toLowerCase()} sobre ${items.length} casos. Criterio: ${mesa.criterioCrisis}',
    );
  }

  Future<void> registrarEjecucionMesaCrisis({
    required MesaCrisisInstitucionalCabecera mesa,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'mesa_crisis_ejecutada',
        detalle:
          'La cabecera ejecuto la mesa de crisis ${mesa.tipoMesa.toLowerCase()} sobre ${items.length} casos. Horizonte: ${mesa.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetProtocoloRecuperacion({
    required ProtocoloRecuperacionInstitucionalMesa protocolo,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'protocolo_recuperacion_preset',
      detalle:
          'La cabecera aplico el protocolo de recuperacion ${protocolo.tipoRecuperacion.toLowerCase()} sobre ${items.length} casos. Criterio: ${protocolo.criterioRecuperacion}',
    );
  }

  Future<void> registrarEjecucionProtocoloRecuperacion({
    required ProtocoloRecuperacionInstitucionalMesa protocolo,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'protocolo_recuperacion_ejecutado',
        detalle:
          'La cabecera ejecuto el protocolo de recuperacion ${protocolo.tipoRecuperacion.toLowerCase()} sobre ${items.length} casos. Horizonte: ${protocolo.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanEstructural({
    required PlanEstructuralRecomposicionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_estructural_preset',
      detalle:
          'La cabecera aplico el plan estructural ${plan.tipoPlan.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioEstructural}',
    );
  }

  Future<void> registrarEjecucionPlanEstructural({
    required PlanEstructuralRecomposicionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_estructural_ejecutado',
      detalle:
          'La cabecera ejecuto el plan estructural ${plan.tipoPlan.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanDesacopleCronificacion({
    required PlanDesacopleCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_desacople_cronificacion_preset',
      detalle:
          'La cabecera aplico el plan de desacople ${plan.tipoDesacople.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioDesacople}',
    );
  }

  Future<void> registrarEjecucionPlanDesacopleCronificacion({
    required PlanDesacopleCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_desacople_cronificacion_ejecutado',
      detalle:
          'La cabecera ejecuto el plan de desacople ${plan.tipoDesacople.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanReforzamientoDesacople({
    required PlanReforzamientoDesacopleMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_reforzamiento_desacople_preset',
      detalle:
          'La cabecera aplico el plan de reforzamiento ${plan.tipoReforzamiento.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioReforzamiento}',
    );
  }

  Future<void> registrarEjecucionPlanReforzamientoDesacople({
    required PlanReforzamientoDesacopleMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_reforzamiento_desacople_ejecutado',
      detalle:
          'La cabecera ejecuto el plan de reforzamiento ${plan.tipoReforzamiento.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanContencionCronificacion({
    required PlanContencionCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_contencion_cronificacion_preset',
      detalle:
          'La cabecera aplico el plan de contencion ${plan.tipoContencion.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioContencion}',
    );
  }

  Future<void> registrarEjecucionPlanContencionCronificacion({
    required PlanContencionCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_contencion_cronificacion_ejecutado',
      detalle:
          'La cabecera ejecuto el plan de contencion ${plan.tipoContencion.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanRespuestaExcepcionalCronificacion({
    required PlanRespuestaExcepcionalCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_respuesta_excepcional_cronificacion_preset',
      detalle:
          'La cabecera aplico la respuesta excepcional ${plan.tipoRespuesta.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioRespuesta}',
    );
  }

  Future<void> registrarEjecucionPlanRespuestaExcepcionalCronificacion({
    required PlanRespuestaExcepcionalCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_respuesta_excepcional_cronificacion_ejecutado',
      detalle:
          'La cabecera ejecuto la respuesta excepcional ${plan.tipoRespuesta.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanCierreExtremoCronificacion({
    required PlanCierreExtremoCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_cierre_extremo_cronificacion_preset',
      detalle:
          'La cabecera aplico el cierre extremo ${plan.tipoCierre.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioCierre}',
    );
  }

  Future<void> registrarEjecucionPlanCierreExtremoCronificacion({
    required PlanCierreExtremoCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_cierre_extremo_cronificacion_ejecutado',
      detalle:
          'La cabecera ejecuto el cierre extremo ${plan.tipoCierre.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetPlanCorteTotalCronificacion({
    required PlanCorteTotalCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_corte_total_cronificacion_preset',
      detalle:
          'La cabecera aplico el corte total ${plan.tipoCorte.toLowerCase()} sobre ${items.length} casos. Criterio: ${plan.criterioCorte}',
    );
  }

  Future<void> registrarEjecucionPlanCorteTotalCronificacion({
    required PlanCorteTotalCronificacionMesa plan,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'plan_corte_total_cronificacion_ejecutado',
      detalle:
          'La cabecera ejecuto el corte total ${plan.tipoCorte.toLowerCase()} sobre ${items.length} casos. Horizonte: ${plan.horizonteDias} dias.',
    );
  }

  Future<void> registrarPresetProtocoloFinalClausura({
    required ProtocoloFinalClausuraInstitucionalMesa protocolo,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'protocolo_final_clausura_preset',
      detalle:
          'La cabecera aplico la clausura final ${protocolo.tipoClausura.toLowerCase()} sobre ${items.length} casos. Criterio: ${protocolo.criterioClausura}',
    );
  }

  Future<void> registrarEjecucionProtocoloFinalClausura({
    required ProtocoloFinalClausuraInstitucionalMesa protocolo,
    required List<IncidenciaTransversal> items,
  }) async {
    if (items.isEmpty) return;
    await _registrarHistorial(
      item: items.first,
      accion: 'protocolo_final_clausura_ejecutado',
      detalle:
          'La cabecera ejecuto la clausura final ${protocolo.tipoClausura.toLowerCase()} sobre ${items.length} casos. Horizonte: ${protocolo.horizonteDias} dias.',
    );
  }

  Future<ResumenAccionesMasivasIncidencias> _cargarResumenAccionesMasivas() async {
    final desde = DateTime.now().subtract(const Duration(days: 14));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'priorizacion_masiva',
                      'derivacion_masiva',
                      'devolucion_masiva',
                      'observacion_masiva',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final grupos = <String, List<TablaIncidenciasTransversalesHistorialData>>{};
    for (final row in rows) {
      grupos.putIfAbsent(row.origen, () => <TablaIncidenciasTransversalesHistorialData>[]).add(row);
    }

    final impactos = grupos.entries.map((entry) {
      final items = entry.value;
      final priorizaciones =
          items.where((it) => it.accion == 'priorizacion_masiva').length;
      final derivaciones =
          items.where((it) => it.accion == 'derivacion_masiva').length;
      final devoluciones =
          items.where((it) => it.accion == 'devolucion_masiva').length;
      final observaciones =
          items.where((it) => it.accion == 'observacion_masiva').length;
      return ImpactoAccionMasivaModulo(
        origen: entry.key,
        total: items.length,
        priorizaciones: priorizaciones,
        derivaciones: derivaciones,
        devoluciones: devoluciones,
        observaciones: observaciones,
        icono: _iconoOrigen(entry.key),
      );
    }).toList(growable: false)
      ..sort((a, b) => b.total.compareTo(a.total));

    final priorizaciones =
        rows.where((it) => it.accion == 'priorizacion_masiva').length;
    final derivaciones =
        rows.where((it) => it.accion == 'derivacion_masiva').length;
    final devoluciones =
        rows.where((it) => it.accion == 'devolucion_masiva').length;
    final observaciones =
        rows.where((it) => it.accion == 'observacion_masiva').length;

    final lectura = rows.isEmpty
        ? 'Todavia no hay acciones masivas registradas en los ultimos 14 dias.'
        : impactos.isEmpty
            ? 'La mesa transversal ya registra actividad masiva reciente.'
            : '${impactos.first.origen} concentro la mayor actividad masiva reciente, con ${impactos.first.total} intervenciones en lote registradas.';

    return ResumenAccionesMasivasIncidencias(
      totalReciente: rows.length,
      priorizaciones: priorizaciones,
      derivaciones: derivaciones,
      devoluciones: devoluciones,
      observaciones: observaciones,
      lecturaEjecutiva: lectura,
      impactosPorModulo: impactos,
    );
  }

  Future<ResumenSeguimientoAlertasMesa> _cargarSeguimientoAlertasMesa() async {
    final desde = DateTime.now().subtract(const Duration(days: 14));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where((t) => t.creadoEn.isBiggerOrEqualValue(desde))
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion.startsWith('preset_alerta_'))
        .length;
    final acciones = rows
        .where((row) => row.accion.startsWith('accion_sugerida_'))
        .length;
    final pendientes = presets > acciones ? presets - acciones : 0;

    final lectura = presets == 0
        ? 'Todavia no hay presets de alerta aplicados en los ultimos 14 dias.'
        : pendientes == 0
            ? 'Las alertas aplicadas en la mesa ya muestran conversion operativa completa hacia acciones sugeridas.'
            : 'La mesa aplico $presets presets de alerta y todavia tiene $pendientes seguimientos sin accion sugerida registrada.';

    return ResumenSeguimientoAlertasMesa(
      presetsAplicados: presets,
      accionesEjecutadas: acciones,
      pendientes: pendientes,
      lecturaEjecutiva: lectura,
    );
  }

  Future<HistorialEjecutivoMesaIncidencias> _cargarHistorialEjecutivoMesa() async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where((t) => t.creadoEn.isBiggerOrEqualValue(desde))
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final ejecutivos = rows.where((row) {
      return row.accion.startsWith('foco_dominante_') ||
          row.accion.startsWith('accion_rapida_dominante_');
    }).toList(growable: false);

    final focos = ejecutivos
        .where((row) => row.accion.startsWith('foco_dominante_'))
        .length;
    final acciones = ejecutivos
        .where((row) => row.accion.startsWith('accion_rapida_dominante_'))
        .length;
    final pendientes = focos > acciones ? focos - acciones : 0;
    final conversion = focos == 0 ? 100 : ((acciones / focos) * 100).round();
    final estadoConversion = conversion >= 80
        ? 'Solida'
        : conversion >= 60
            ? 'Atencion'
            : 'Critica';

    final eventos = ejecutivos.take(8).map((row) {
      final esAccion = row.accion.startsWith('accion_rapida_dominante_');
      final tipo = row.accion
          .replaceFirst(
            esAccion
                ? 'accion_rapida_dominante_'
                : 'foco_dominante_',
            '',
          );
      final cantidad = _extraerCantidadCasos(row.detalle);
      return EventoEjecutivoMesaIncidencias(
        accion: esAccion ? 'Accion rapida' : 'Foco consultado',
        tipoAlerta: tipo,
        cantidadCasos: cantidad,
        detalle: row.detalle ?? '',
        creadoEn: row.creadoEn,
      );
    }).toList(growable: false);

    final lectura = ejecutivos.isEmpty
        ? 'Todavia no hay decisiones ejecutivas registradas desde la cabecera de la mesa.'
        : 'La cabecera ejecutiva ya registra $focos focos consultados y $acciones acciones rapidas en los ultimos 30 dias, con $conversion% de conversion.';

    return HistorialEjecutivoMesaIncidencias(
      focosConsultados: focos,
      accionesRapidas: acciones,
      conversionPorcentaje: conversion,
      pendientesConversion: pendientes,
      estadoConversion: estadoConversion,
      lecturaEjecutiva: lectura,
      eventos: eventos,
    );
  }

  Future<ComparativaCabeceraEjecutivaMesa>
  _cargarComparativaCabeceraEjecutivaMesa() async {
    final ahora = DateTime.now();
    final inicioActual = ahora.subtract(const Duration(days: 15));
    final inicioPrevio = inicioActual.subtract(const Duration(days: 15));

    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where((t) => t.creadoEn.isBiggerOrEqualValue(inicioPrevio))
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final actuales = rows
        .where((row) => row.creadoEn.isAfter(inicioActual))
        .toList(growable: false);
    final previos = rows
        .where(
          (row) =>
              row.creadoEn.isAfter(inicioPrevio) &&
              !row.creadoEn.isAfter(inicioActual),
        )
        .toList(growable: false);

    final focosActuales = actuales
        .where((row) => row.accion.startsWith('foco_dominante_'))
        .length;
    final focosPrevios = previos
        .where((row) => row.accion.startsWith('foco_dominante_'))
        .length;
    final accionesActuales = actuales
        .where((row) => row.accion.startsWith('accion_rapida_dominante_'))
        .length;
    final accionesPrevias = previos
        .where((row) => row.accion.startsWith('accion_rapida_dominante_'))
        .length;

    final conversionActual = focosActuales == 0
        ? 100
        : ((accionesActuales / focosActuales) * 100).round();
    final conversionPrevia = focosPrevios == 0
        ? 100
        : ((accionesPrevias / focosPrevios) * 100).round();

    final estadoConversion = conversionActual > conversionPrevia
        ? 'Mejora'
        : conversionActual < conversionPrevia
            ? 'Retroceso'
            : 'Estable';

    final lectura = focosActuales == 0 && focosPrevios == 0
        ? 'La cabecera ejecutiva todavia no tiene suficiente actividad para comparar periodos consecutivos.'
        : 'La conversion de la cabecera ejecutiva paso de $conversionPrevia% a $conversionActual% entre los dos periodos mas recientes.';

    return ComparativaCabeceraEjecutivaMesa(
      focosActuales: focosActuales,
      focosPrevios: focosPrevios,
      accionesActuales: accionesActuales,
      accionesPrevias: accionesPrevias,
      conversionActual: conversionActual,
      conversionPrevia: conversionPrevia,
      estadoConversion: estadoConversion,
      lecturaEjecutiva: lectura,
    );
  }

  Future<RecomendacionHistoricaMesaIncidencias>
  _cargarRecomendacionHistoricaMesa({
    required RecomendacionEjecutivaMesaIncidencias recomendacionActual,
  }) async {
    final ahora = DateTime.now();
    final inicioActual = ahora.subtract(const Duration(days: 15));
    final inicioPrevio = inicioActual.subtract(const Duration(days: 15));

    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where((t) => t.creadoEn.isBiggerOrEqualValue(inicioPrevio))
              ..orderBy([(t) => OrderingTerm.asc(t.creadoEn)]))
            .get();

    final ejecutivos = rows
        .where((row) => _esEventoCabeceraEjecutiva(row.accion))
        .toList(growable: false);
    final actuales = ejecutivos
        .where((row) => row.creadoEn.isAfter(inicioActual))
        .toList(growable: false);
    final previos = ejecutivos
        .where(
          (row) =>
              row.creadoEn.isAfter(inicioPrevio) &&
              !row.creadoEn.isAfter(inicioActual),
        )
        .toList(growable: false);

    final tipoPrevio = _tipoDominanteEventosCabecera(previos);
    final focoActual = _etiquetaTipoAlertaMesa(
      recomendacionActual.tipoAlertaOrigen,
      fallback: recomendacionActual.foco,
    );
    final focoPrevio = tipoPrevio == null
        ? 'Sin referencia'
        : _etiquetaTipoAlertaMesa(tipoPrevio);
    final cambiosRecientes = _contarCambiosFoco(ejecutivos);

    final estadoConsistencia = tipoPrevio == null
        ? 'Sin referencia'
        : recomendacionActual.tipoAlertaOrigen == tipoPrevio
            ? 'Consistente'
            : cambiosRecientes >= 2
                ? 'Inestable'
                : 'Cambio';

    final lectura = switch (estadoConsistencia) {
      'Consistente' =>
        'La recomendacion dominante se mantiene estable entre los dos periodos mas recientes y sostiene el foco en $focoActual.',
      'Inestable' =>
        'La cabecera viene rotando su foco ejecutivo entre periodos y ya registra $cambiosRecientes cambios recientes; conviene consolidar un criterio de intervencion.',
      'Cambio' =>
        'La recomendacion dominante cambio respecto del periodo anterior: paso de $focoPrevio a $focoActual.',
      _ =>
        'Todavia no hay referencia historica suficiente para saber si la recomendacion dominante se sostiene entre periodos.',
    };

    return RecomendacionHistoricaMesaIncidencias(
      focoActual: focoActual,
      focoPrevio: focoPrevio,
      eventosActuales: actuales.length,
      eventosPrevios: previos.length,
      cambiosRecientes: cambiosRecientes,
      estadoConsistencia: estadoConsistencia,
      lecturaEjecutiva: lectura,
    );
  }

  Future<ComparativaTemporalMesaIncidencias> _cargarComparativaTemporalMesa() async {
    final ahora = DateTime.now();
    final inicioActual = ahora.subtract(const Duration(days: 14));
    final inicioPrevio = inicioActual.subtract(const Duration(days: 14));

    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where((t) => t.creadoEn.isBiggerOrEqualValue(inicioPrevio))
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final actuales = rows
        .where((row) => row.creadoEn.isAfter(inicioActual))
        .toList(growable: false);
    final previos = rows
        .where(
          (row) =>
              row.creadoEn.isAfter(inicioPrevio) &&
              !row.creadoEn.isAfter(inicioActual),
        )
        .toList(growable: false);

    final accionesActuales = actuales
        .where((row) => _esAccionMasiva(row.accion))
        .length;
    final accionesPrevias = previos
        .where((row) => _esAccionMasiva(row.accion))
        .length;

    final conversionActual = _porcentajeConversion(actuales);
    final conversionPrevia = _porcentajeConversion(previos);

    final estadoActividad = accionesActuales > accionesPrevias
        ? 'Mayor presion'
        : accionesActuales < accionesPrevias
            ? 'Menor presion'
            : 'Estable';
    final estadoConversion = conversionActual > conversionPrevia
        ? 'Mejora'
        : conversionActual < conversionPrevia
            ? 'Retroceso'
            : 'Estable';

    final lectura = _lecturaComparativaTemporal(
      accionesActuales: accionesActuales,
      accionesPrevias: accionesPrevias,
      conversionActual: conversionActual,
      conversionPrevia: conversionPrevia,
      estadoActividad: estadoActividad,
      estadoConversion: estadoConversion,
    );

    return ComparativaTemporalMesaIncidencias(
      accionesActuales: accionesActuales,
      accionesPrevias: accionesPrevias,
      conversionActual: conversionActual,
      conversionPrevia: conversionPrevia,
      estadoActividad: estadoActividad,
      estadoConversion: estadoConversion,
      lecturaEjecutiva: lectura,
    );
  }

  List<AlertaMesaIncidencias> _construirAlertasMesa({
    required List<IncidenciaTransversal> incidencias,
    required ResumenAccionesMasivasIncidencias accionesMasivas,
    required ResumenSeguimientoAlertasMesa seguimientoAlertas,
    required ComparativaTemporalMesaIncidencias comparativaTemporal,
    required HistorialEjecutivoMesaIncidencias historialEjecutivo,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    RecomendacionHistoricaMesaIncidencias? recomendacionHistorica,
    ConsolidadoHistoricoRecomendacionMesa? consolidadoHistorico,
    ConsolidadoCronificacionInstitucionalMesa? consolidadoCronificacion,
    SeguimientoPlanDesacopleCronificacionMesa? seguimientoPlanDesacople,
    SeguimientoPlanReforzamientoDesacopleMesa?
    seguimientoPlanReforzamientoDesacople,
    SeguimientoPlanContencionCronificacionMesa?
    seguimientoPlanContencionCronificacion,
    SeguimientoPlanRespuestaExcepcionalCronificacionMesa?
    seguimientoPlanRespuestaExcepcionalCronificacion,
    SeguimientoPlanCierreExtremoCronificacionMesa?
    seguimientoPlanCierreExtremoCronificacion,
    SeguimientoPlanCorteTotalCronificacionMesa?
    seguimientoPlanCorteTotalCronificacion,
    SeguimientoProtocoloFinalClausuraInstitucionalMesa?
    seguimientoProtocoloFinalClausura,
    SeguimientoPlanEstabilizacionMesa? seguimientoPlan,
    SeguimientoAjustePlanEstabilizacionMesa? seguimientoAjuste,
    SeguimientoEscalamientoCabeceraMesa? seguimientoEscalamiento,
    SeguimientoProtocoloContingenciaMesa? seguimientoProtocolo,
    SeguimientoMesaCrisisInstitucionalMesa? seguimientoMesaCrisis,
    SeguimientoProtocoloRecuperacionInstitucionalMesa? seguimientoRecuperacion,
    SeguimientoPlanEstructuralRecomposicionMesa? seguimientoPlanEstructural,
  }) {
    final alertas = <AlertaMesaIncidencias>[];
    final incidenciasPorOrigen = <String, List<IncidenciaTransversal>>{};
    for (final item in incidencias) {
      incidenciasPorOrigen.putIfAbsent(item.origen, () => <IncidenciaTransversal>[]).add(item);
    }

    for (final impacto in accionesMasivas.impactosPorModulo) {
      final items = incidenciasPorOrigen[impacto.origen] ?? const <IncidenciaTransversal>[];
      final rojas = items
          .where((item) => item.semaforo == SemaforoIncidenciaTransversal.rojo)
          .length;
      final vencidas = items.where((item) => item.vencida).length;

      if (impacto.devoluciones >= 3) {
        alertas.add(
          AlertaMesaIncidencias(
            tipo: 'devoluciones_recurrentes',
            titulo: 'Devoluciones recurrentes',
            descripcion:
                '${impacto.origen} acumula ${impacto.devoluciones} devoluciones masivas recientes; conviene revisar por que los casos vuelven al origen sin cerrar el circuito.',
            origen: impacto.origen,
            severidad: impacto.devoluciones >= 5 ? 'Alta' : 'Media',
            accionSugerida:
                'Revisar criterios de devolucion y definir una respuesta operativa unica para el modulo.',
            icono: Icons.reply_all_outlined,
          ),
        );
      }

      if (impacto.derivaciones >= 4) {
        alertas.add(
          AlertaMesaIncidencias(
            tipo: 'presion_documental_elevada',
            titulo: 'Presion documental elevada',
            descripcion:
                '${impacto.origen} derivo ${impacto.derivaciones} casos en lote a Legajos durante los ultimos 14 dias.',
            origen: impacto.origen,
            severidad: impacto.derivaciones >= 6 ? 'Alta' : 'Media',
            accionSugerida:
                'Confirmar si el modulo necesita refuerzo operativo antes de seguir escalando al circuito documental.',
            icono: Icons.folder_copy_outlined,
          ),
        );
      }

      if (impacto.total >= 4 && rojas >= 2) {
        alertas.add(
          AlertaMesaIncidencias(
            tipo: 'intervencion_roja',
            titulo: 'Intervencion intensa sobre casos rojos',
            descripcion:
                '${impacto.origen} combina ${impacto.total} acciones masivas recientes con $rojas incidencias rojas visibles y $vencidas vencidas.',
            origen: impacto.origen,
            severidad: rojas >= 3 || vencidas >= 2 ? 'Alta' : 'Media',
            accionSugerida:
                'Priorizar una revision ejecutiva del modulo y definir horizonte de cierre compartido para los casos criticos.',
            icono: Icons.crisis_alert_outlined,
          ),
        );
      }
    }

    final conversion = seguimientoAlertas.presetsAplicados == 0
        ? 1.0
        : seguimientoAlertas.accionesEjecutadas /
            seguimientoAlertas.presetsAplicados;
    if (seguimientoAlertas.presetsAplicados >= 4 &&
        seguimientoAlertas.pendientes >= 2 &&
        conversion < 0.7) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'baja_conversion_operativa',
          titulo: 'Baja conversion operativa',
          descripcion:
              'La mesa aplico ${seguimientoAlertas.presetsAplicados} presets de alerta, pero solo ${seguimientoAlertas.accionesEjecutadas} terminaron en acciones reales durante los ultimos 14 dias.',
          origen: 'Mesa transversal',
          severidad: conversion < 0.5 ? 'Alta' : 'Media',
          accionSugerida:
              'Revisar las alertas activas y ejecutar una intervencion comun sobre los casos visibles para evitar seguimiento pasivo.',
          icono: Icons.low_priority_outlined,
        ),
      );
    }

    if (comparativaTemporal.estadoActividad == 'Mayor presion' &&
        comparativaTemporal.accionesActuales >= 4) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'deterioro_presion_temporal',
          titulo: 'Presion operativa en aumento',
          descripcion:
              'La mesa paso de ${comparativaTemporal.accionesPrevias} a ${comparativaTemporal.accionesActuales} acciones masivas entre periodos consecutivos.',
          origen: 'Mesa transversal',
          severidad:
              comparativaTemporal.accionesActuales >=
                      comparativaTemporal.accionesPrevias + 3
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Concentrar la revision sobre casos urgentes de todos los modulos y absorber el pico operativo con una priorizacion comun.',
          icono: Icons.trending_up_outlined,
        ),
      );
    }

    if (comparativaTemporal.estadoConversion == 'Retroceso' &&
        comparativaTemporal.conversionActual < 70) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'deterioro_conversion_temporal',
          titulo: 'Conversion operativa en retroceso',
          descripcion:
              'La conversion de presets a acciones reales bajo de ${comparativaTemporal.conversionPrevia}% a ${comparativaTemporal.conversionActual}% entre periodos.',
          origen: 'Mesa transversal',
          severidad: comparativaTemporal.conversionActual < 50 ? 'Alta' : 'Media',
          accionSugerida:
              'Aplicar una accion sugerida comun sobre los casos urgentes para recuperar conversion y evitar seguimiento pasivo.',
          icono: Icons.trending_down_outlined,
        ),
      );
    }

    if (historialEjecutivo.focosConsultados >= 3 &&
        historialEjecutivo.conversionPorcentaje < 70) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'baja_conversion_recomendacion_dominante',
          titulo: 'Baja conversion de recomendacion dominante',
          descripcion:
              'La cabecera ejecutiva consulto ${historialEjecutivo.focosConsultados} focos dominantes, pero solo ${historialEjecutivo.accionesRapidas} terminaron en acciones rapidas.',
          origen: 'Mesa transversal',
          severidad:
              historialEjecutivo.conversionPorcentaje < 50 ? 'Alta' : 'Media',
          accionSugerida:
              'Ejecutar la recomendacion dominante actual sobre los casos urgentes para evitar una cabecera solo consultiva.',
          icono: Icons.bolt_outlined,
        ),
      );
    }

    if (comparativaCabecera.estadoConversion == 'Retroceso' &&
        comparativaCabecera.conversionActual < 70 &&
        comparativaCabecera.conversionActual <=
            comparativaCabecera.conversionPrevia - 15) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'deterioro_cabecera_ejecutiva',
          titulo: 'Deterioro de cabecera ejecutiva',
          descripcion:
              'La conversion de la recomendacion dominante cayo de ${comparativaCabecera.conversionPrevia}% a ${comparativaCabecera.conversionActual}% respecto del periodo anterior.',
          origen: 'Mesa transversal',
          severidad:
              comparativaCabecera.conversionActual < 50 ? 'Alta' : 'Media',
          accionSugerida:
              'Aplicar la recomendacion dominante actual sobre casos urgentes y revisar por que la cabecera viene perdiendo conversion.',
          icono: Icons.trending_down_outlined,
        ),
      );
    }

    if (recomendacionHistorica != null &&
        recomendacionHistorica.estadoConsistencia == 'Inestable') {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'recomendacion_ejecutiva_inestable',
          titulo: 'Recomendacion ejecutiva inestable',
          descripcion:
              'La cabecera cambio ${recomendacionHistorica.cambiosRecientes} veces de foco reciente y paso de ${recomendacionHistorica.focoPrevio} a ${recomendacionHistorica.focoActual}.',
          origen: 'Mesa transversal',
          severidad:
              recomendacionHistorica.cambiosRecientes >= 3 ? 'Alta' : 'Media',
          accionSugerida:
              'Aplicar una priorizacion comun sobre casos urgentes y estabilizar un criterio ejecutivo antes de seguir rotando el foco.',
          icono: Icons.change_circle_outlined,
        ),
      );
    }

    if (consolidadoHistorico != null && consolidadoHistorico.estado == 'Critico') {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'oscilacion_cronica_cabecera',
          titulo: 'Oscilacion cronica de cabecera',
          descripcion:
              'La cabecera ejecutiva ya muestra un patron de oscilacion cronica con riesgo ${consolidadoHistorico.riesgoOscilacion} y necesita estabilizar su criterio de intervencion.',
          origen: 'Mesa transversal',
          severidad:
              consolidadoHistorico.riesgoOscilacion >= 4 ? 'Alta' : 'Media',
          accionSugerida:
              'Priorizar los casos urgentes visibles y fijar un criterio ejecutivo unico para el proximo periodo de trabajo.',
          icono: Icons.autorenew_outlined,
        ),
      );
    }

    if (consolidadoCronificacion != null &&
        (consolidadoCronificacion.estado == 'Cronificada' ||
            consolidadoCronificacion.estado == 'Alta')) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'cronificacion_institucional_critica',
          titulo: 'Cronificacion institucional critica',
          descripcion:
              'La mesa ya muestra ${consolidadoCronificacion.patron.toLowerCase()} con riesgo ${consolidadoCronificacion.riesgoCronificacion} y concentracion sostenida en ${consolidadoCronificacion.modulosConcentrados.join(', ')}.',
          origen: 'Mesa transversal',
          severidad:
              consolidadoCronificacion.estado == 'Cronificada'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Priorizar una lectura institucional unica sobre los casos criticos visibles y sostener foco en los modulos mas comprometidos para frenar la cronificacion.',
          icono: Icons.apartment_outlined,
        ),
      );
    }

    if (seguimientoPlan != null &&
        seguimientoPlan.presetsAplicados >= 1 &&
        (seguimientoPlan.estadoEfecto == 'Sin efecto' ||
            (seguimientoPlan.estadoEfecto == 'Parcial' &&
                seguimientoPlan.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'plan_estabilizacion_inefectivo',
          titulo: 'Plan de estabilizacion inefectivo',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlan.presetsAplicados} planes de estabilizacion, pero el efecto sigue ${seguimientoPlan.estadoEfecto.toLowerCase()} con ${seguimientoPlan.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlan.estadoEfecto == 'Sin efecto' ? 'Alta' : 'Media',
          accionSugerida:
              'Reforzar la intervencion sobre casos urgentes y revisar si el criterio del plan necesita corregirse antes del siguiente periodo.',
          icono: Icons.assignment_late_outlined,
        ),
      );
    }

    if (seguimientoAjuste != null &&
        seguimientoAjuste.presetsAplicados >= 1 &&
        (seguimientoAjuste.estadoEfecto == 'Sin efecto' ||
            (seguimientoAjuste.estadoEfecto == 'Parcial' &&
                seguimientoAjuste.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'ajuste_plan_inefectivo',
          titulo: 'Ajuste del plan inefectivo',
          descripcion:
              'La cabecera ya aplico ${seguimientoAjuste.presetsAplicados} ajustes del plan, pero el efecto sigue ${seguimientoAjuste.estadoEfecto.toLowerCase()} con ${seguimientoAjuste.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoAjuste.estadoEfecto == 'Sin efecto' ? 'Alta' : 'Media',
          accionSugerida:
              'Intervenir sobre los casos urgentes visibles y revisar si la cabecera necesita una redefinicion mas profunda del criterio ejecutivo.',
          icono: Icons.warning_amber_outlined,
        ),
      );
    }

    if (seguimientoEscalamiento != null &&
        seguimientoEscalamiento.presetsAplicados >= 1 &&
        (seguimientoEscalamiento.estadoEfecto == 'Sin efecto' ||
            (seguimientoEscalamiento.estadoEfecto == 'Parcial' &&
                seguimientoEscalamiento.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'escalamiento_insuficiente',
          titulo: 'Escalamiento estrategico insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoEscalamiento.presetsAplicados} escalamientos estrategicos, pero el efecto sigue ${seguimientoEscalamiento.estadoEfecto.toLowerCase()} con ${seguimientoEscalamiento.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoEscalamiento.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Intervenir sobre los casos criticos visibles y revisar si la cabecera necesita una redefinicion institucional mas estructural.',
          icono: Icons.warning_amber_outlined,
        ),
      );
    }

    if (seguimientoProtocolo != null &&
        seguimientoProtocolo.presetsAplicados >= 1 &&
        (seguimientoProtocolo.estadoEfecto == 'Sin efecto' ||
            (seguimientoProtocolo.estadoEfecto == 'Parcial' &&
                seguimientoProtocolo.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'contingencia_insuficiente',
          titulo: 'Contingencia institucional insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoProtocolo.presetsAplicados} protocolos de contingencia, pero el efecto sigue ${seguimientoProtocolo.estadoEfecto.toLowerCase()} con ${seguimientoProtocolo.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoProtocolo.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Intervenir sobre los casos criticos visibles y asumir una respuesta institucional excepcional, mas estructurada que la simple priorizacion.',
          icono: Icons.error_outline,
        ),
      );
    }

    if (seguimientoMesaCrisis != null &&
        seguimientoMesaCrisis.presetsAplicados >= 1 &&
        (seguimientoMesaCrisis.estadoEfecto == 'Sin efecto' ||
            (seguimientoMesaCrisis.estadoEfecto == 'Parcial' &&
                seguimientoMesaCrisis.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'crisis_sostenida',
          titulo: 'Crisis institucional sostenida',
          descripcion:
              'La cabecera ya aplico ${seguimientoMesaCrisis.presetsAplicados} mesas de crisis, pero el efecto sigue ${seguimientoMesaCrisis.estadoEfecto.toLowerCase()} con ${seguimientoMesaCrisis.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoMesaCrisis.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Asumir un criterio institucional de crisis sostenida sobre los casos criticos visibles y concentrar la intervencion en los modulos mas comprometidos.',
          icono: Icons.dangerous_outlined,
        ),
      );
    }

    if (seguimientoRecuperacion != null &&
        seguimientoRecuperacion.presetsAplicados >= 1 &&
        (seguimientoRecuperacion.estadoEfecto == 'Sin efecto' ||
            (seguimientoRecuperacion.estadoEfecto == 'Parcial' &&
                seguimientoRecuperacion.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'recuperacion_insuficiente',
          titulo: 'Recuperacion institucional insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoRecuperacion.presetsAplicados} protocolos de recuperacion, pero el efecto sigue ${seguimientoRecuperacion.estadoEfecto.toLowerCase()} con ${seguimientoRecuperacion.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoRecuperacion.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener un criterio institucional unico sobre los casos criticos visibles y revisar si la recuperacion necesita una redefinicion estructural mas profunda.',
          icono: Icons.healing_outlined,
        ),
      );
    }

    if (seguimientoPlanEstructural != null &&
        seguimientoPlanEstructural.presetsAplicados >= 1 &&
        (seguimientoPlanEstructural.estadoEfecto == 'Sin efecto' ||
            (seguimientoPlanEstructural.estadoEfecto == 'Parcial' &&
                seguimientoPlanEstructural.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'recomposicion_insuficiente',
          titulo: 'Recomposicion estructural insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanEstructural.presetsAplicados} planes estructurales, pero el efecto sigue ${seguimientoPlanEstructural.estadoEfecto.toLowerCase()} con ${seguimientoPlanEstructural.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanEstructural.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener un criterio estructural unico sobre los casos criticos visibles y revisar si la recomposicion ya se cronifico a nivel institucional.',
          icono: Icons.foundation_outlined,
        ),
      );
    }

    if (seguimientoPlanDesacople != null &&
        seguimientoPlanDesacople.presetsAplicados >= 1 &&
        (seguimientoPlanDesacople.estadoEfecto == 'Sin efecto' ||
            (seguimientoPlanDesacople.estadoEfecto == 'Parcial' &&
                seguimientoPlanDesacople.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'desacople_insuficiente',
          titulo: 'Desacople de cronificacion insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanDesacople.presetsAplicados} planes de desacople, pero el efecto sigue ${seguimientoPlanDesacople.estadoEfecto.toLowerCase()} con ${seguimientoPlanDesacople.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanDesacople.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion unica sobre los modulos cronificados y revisar si el desacople necesita mayor profundidad institucional.',
          icono: Icons.call_split_outlined,
        ),
      );
    }

    if (seguimientoPlanReforzamientoDesacople != null &&
        seguimientoPlanReforzamientoDesacople.presetsAplicados >= 1 &&
        (seguimientoPlanReforzamientoDesacople.estadoEfecto == 'Sin efecto' ||
            (seguimientoPlanReforzamientoDesacople.estadoEfecto == 'Parcial' &&
                seguimientoPlanReforzamientoDesacople.conversionPorcentaje <
                    70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'reforzamiento_desacople_insuficiente',
          titulo: 'Reforzamiento del desacople insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanReforzamientoDesacople.presetsAplicados} refuerzos del desacople, pero el efecto sigue ${seguimientoPlanReforzamientoDesacople.estadoEfecto.toLowerCase()} con ${seguimientoPlanReforzamientoDesacople.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanReforzamientoDesacople.estadoEfecto ==
                      'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion critica sobre los modulos cronificados y revisar si el desacople ya requiere una redefinicion institucional mas profunda.',
          icono: Icons.rule_folder_outlined,
        ),
      );
    }

    if (seguimientoPlanContencionCronificacion != null &&
        seguimientoPlanContencionCronificacion.presetsAplicados >= 1 &&
        (seguimientoPlanContencionCronificacion.estadoEfecto == 'Sin efecto' ||
            (seguimientoPlanContencionCronificacion.estadoEfecto == 'Parcial' &&
                seguimientoPlanContencionCronificacion.conversionPorcentaje <
                    70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'contencion_insuficiente',
          titulo: 'Contencion de cronificacion insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanContencionCronificacion.presetsAplicados} planes de contencion, pero el efecto sigue ${seguimientoPlanContencionCronificacion.estadoEfecto.toLowerCase()} con ${seguimientoPlanContencionCronificacion.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanContencionCronificacion.estadoEfecto ==
                      'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion critica sobre los modulos cronificados y revisar si la contencion ya necesita una salida institucional excepcional.',
          icono: Icons.shield_moon_outlined,
        ),
      );
    }

    if (seguimientoPlanRespuestaExcepcionalCronificacion != null &&
        seguimientoPlanRespuestaExcepcionalCronificacion.presetsAplicados >=
            1 &&
        (seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto ==
                'Sin efecto' ||
            (seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto ==
                    'Parcial' &&
                seguimientoPlanRespuestaExcepcionalCronificacion
                        .conversionPorcentaje <
                    70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'respuesta_excepcional_insuficiente',
          titulo: 'Respuesta excepcional insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanRespuestaExcepcionalCronificacion.presetsAplicados} respuestas excepcionales, pero el efecto sigue ${seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto.toLowerCase()} con ${seguimientoPlanRespuestaExcepcionalCronificacion.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto ==
                      'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion institucional extrema sobre los modulos cronificados y revisar si la respuesta excepcional ya necesita una redefinicion integral del criterio de salida.',
          icono: Icons.local_fire_department_outlined,
        ),
      );
    }

    if (seguimientoPlanCierreExtremoCronificacion != null &&
        seguimientoPlanCierreExtremoCronificacion.presetsAplicados >= 1 &&
        (seguimientoPlanCierreExtremoCronificacion.estadoEfecto ==
                'Sin efecto' ||
            (seguimientoPlanCierreExtremoCronificacion.estadoEfecto ==
                    'Parcial' &&
                seguimientoPlanCierreExtremoCronificacion
                        .conversionPorcentaje <
                    70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'cierre_extremo_insuficiente',
          titulo: 'Cierre extremo insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanCierreExtremoCronificacion.presetsAplicados} cierres extremos, pero el efecto sigue ${seguimientoPlanCierreExtremoCronificacion.estadoEfecto.toLowerCase()} con ${seguimientoPlanCierreExtremoCronificacion.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanCierreExtremoCronificacion.estadoEfecto ==
                      'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion institucional de cierre total sobre los modulos cronificados y revisar si la salida extrema ya necesita redefinirse como corte integral del circuito.',
          icono: Icons.no_accounts_outlined,
        ),
      );
    }

    if (seguimientoPlanCorteTotalCronificacion != null &&
        seguimientoPlanCorteTotalCronificacion.presetsAplicados >= 1 &&
        (seguimientoPlanCorteTotalCronificacion.estadoEfecto == 'Sin efecto' ||
            (seguimientoPlanCorteTotalCronificacion.estadoEfecto ==
                    'Parcial' &&
                seguimientoPlanCorteTotalCronificacion.conversionPorcentaje <
                    70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'corte_total_insuficiente',
          titulo: 'Corte total insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoPlanCorteTotalCronificacion.presetsAplicados} cortes totales, pero el efecto sigue ${seguimientoPlanCorteTotalCronificacion.estadoEfecto.toLowerCase()} con ${seguimientoPlanCorteTotalCronificacion.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoPlanCorteTotalCronificacion.estadoEfecto ==
                      'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion institucional final sobre los modulos cronificados y revisar si el corte total ya necesita redefinirse como cierre definitivo del circuito excepcional.',
          icono: Icons.do_not_disturb_on_total_silence_outlined,
        ),
      );
    }

    if (seguimientoProtocoloFinalClausura != null &&
        seguimientoProtocoloFinalClausura.presetsAplicados >= 1 &&
        (seguimientoProtocoloFinalClausura.estadoEfecto == 'Sin efecto' ||
            (seguimientoProtocoloFinalClausura.estadoEfecto == 'Parcial' &&
                seguimientoProtocoloFinalClausura.conversionPorcentaje < 70))) {
      alertas.add(
        AlertaMesaIncidencias(
          tipo: 'clausura_final_insuficiente',
          titulo: 'Clausura final insuficiente',
          descripcion:
              'La cabecera ya aplico ${seguimientoProtocoloFinalClausura.presetsAplicados} clausuras finales, pero el efecto sigue ${seguimientoProtocoloFinalClausura.estadoEfecto.toLowerCase()} con ${seguimientoProtocoloFinalClausura.conversionPorcentaje}% de conversion.',
          origen: 'Mesa transversal',
          severidad:
              seguimientoProtocoloFinalClausura.estadoEfecto == 'Sin efecto'
                  ? 'Alta'
                  : 'Media',
          accionSugerida:
              'Sostener una intervencion terminal sobre los modulos cronificados y revisar si la clausura final ya necesita redefinirse como cierre definitivo del circuito institucional.',
          icono: Icons.gpp_bad_outlined,
        ),
      );
    }

    alertas.sort((a, b) {
      final severidad = _pesoSeveridadAlerta(b.severidad).compareTo(
        _pesoSeveridadAlerta(a.severidad),
      );
      if (severidad != 0) return severidad;
      return a.origen.compareTo(b.origen);
    });
    return alertas;
  }

  RecomendacionEjecutivaMesaIncidencias _construirRecomendacionEjecutiva({
    required List<AlertaMesaIncidencias> alertasMesa,
    required ComparativaTemporalMesaIncidencias comparativaTemporal,
    required ResumenSeguimientoAlertasMesa seguimientoAlertas,
  }) {
    if (alertasMesa.isEmpty) {
      return const RecomendacionEjecutivaMesaIncidencias(
        foco: 'Mesa estable',
        severidad: 'Baja',
        accionSugerida:
            'Sostener la operatoria actual y monitorear la conversion de alertas en los proximos periodos.',
        lecturaEjecutiva:
            'La mesa no muestra desbordes relevantes y hoy no necesita una intervencion ejecutiva dominante.',
        tipoAlertaOrigen: 'sin_alerta',
        icono: Icons.verified_outlined,
      );
    }

    final principal = [...alertasMesa]..sort((a, b) {
      final severidad = _pesoSeveridadAlerta(b.severidad).compareTo(
        _pesoSeveridadAlerta(a.severidad),
      );
      if (severidad != 0) return severidad;
      return _pesoTipoAlertaDominante(b.tipo).compareTo(
        _pesoTipoAlertaDominante(a.tipo),
      );
    });

    final alerta = principal.first;
    final lectura = switch (alerta.tipo) {
      'clausura_final_insuficiente' =>
        'El principal problema hoy es que incluso la clausura final institucional ya se esta aplicando sin recomponer la concentracion critica por modulo.',
      'corte_total_insuficiente' =>
        'El principal problema hoy es que incluso el corte total de cronificacion ya se esta aplicando sin cortar la concentracion critica por modulo.',
      'cierre_extremo_insuficiente' =>
        'El principal problema hoy es que incluso el cierre extremo de cronificacion ya se esta aplicando sin cortar la concentracion critica por modulo.',
      'respuesta_excepcional_insuficiente' =>
        'El principal problema hoy es que incluso la respuesta excepcional de cronificacion ya se esta aplicando sin cortar la concentracion critica por modulo.',
      'contencion_insuficiente' =>
        'El principal problema hoy es que incluso la contencion de cronificacion ya se esta aplicando sin contener la concentracion critica por modulo.',
      'reforzamiento_desacople_insuficiente' =>
        'El principal problema hoy es que incluso el reforzamiento del desacople ya se esta aplicando sin bajar la concentracion cronica por modulo.',
      'contingencia_insuficiente' =>
        'El principal problema hoy es que incluso la contingencia institucional no esta logrando recomponer el efecto ejecutivo de la cabecera.',
      'desacople_insuficiente' =>
        'El principal problema hoy es que incluso el desacople de cronificacion ya se esta aplicando sin bajar la concentracion critica por modulo.',
      'cronificacion_institucional_critica' =>
        'El principal problema hoy es que la mesa ya entro en una cronificacion institucional critica, con concentracion sostenida del deterioro en los mismos modulos.',
      'recuperacion_insuficiente' =>
        'El principal problema hoy es que incluso el protocolo de recuperacion institucional ya se esta aplicando sin lograr recomponer la cabecera, lo que marca un deterioro estructural de la salida propuesta.',
      'recomposicion_insuficiente' =>
        'El principal problema hoy es que incluso la recomposicion estructural ya se esta aplicando sin estabilizar la cabecera, lo que marca una cronificacion institucional del problema.',
      'crisis_sostenida' =>
        'El principal problema hoy es que incluso la mesa de crisis institucional ya se esta aplicando sin lograr recomponer la cabecera, lo que marca una crisis sostenida.',
      'escalamiento_insuficiente' =>
        'El principal problema hoy es que incluso el escalamiento estrategico de cabecera no esta logrando recomponer su efecto ejecutivo.',
      'ajuste_plan_inefectivo' =>
        'El principal problema hoy es que incluso el ajuste del plan de estabilizacion no esta logrando mejorar el comportamiento de la cabecera ejecutiva.',
      'plan_estabilizacion_inefectivo' =>
        'El principal problema hoy es que la cabecera ya esta aplicando planes de estabilizacion, pero todavia no logra mejorar su efecto operativo.',
      'oscilacion_cronica_cabecera' =>
        'El principal problema hoy es la oscilacion cronica de la cabecera ejecutiva, que viene cambiando de criterio sin lograr estabilizar un patron saludable.',
      'recomendacion_ejecutiva_inestable' =>
        'El foco dominante hoy es la inestabilidad de la propia cabecera ejecutiva, que viene rotando demasiadas veces entre criterios de intervencion.',
      'baja_conversion_operativa' =>
        'El principal problema hoy es la baja conversion de presets en acciones reales, con ${seguimientoAlertas.pendientes} seguimientos todavia pendientes.',
      'deterioro_presion_temporal' =>
        'La mesa viene empeorando por aumento de presion operativa entre periodos consecutivos.',
      'deterioro_conversion_temporal' =>
        'La mesa viene empeorando por retroceso de conversion respecto del periodo anterior.',
      'devoluciones_recurrentes' =>
        'El foco dominante esta en las devoluciones al origen, que siguen devolviendo trabajo sin cierre del circuito.',
      'presion_documental_elevada' =>
        'El foco dominante esta en la presion documental, con demasiados casos empujados a Legajos para el periodo actual.',
      'intervencion_roja' =>
        'El foco dominante esta en los casos rojos visibles, que requieren absorcion ejecutiva inmediata.',
      _ =>
        'La mesa muestra una recomendacion dominante que conviene atender antes que el resto de las senales.',
    };

    return RecomendacionEjecutivaMesaIncidencias(
      foco: alerta.titulo,
      severidad: alerta.severidad,
      accionSugerida: alerta.accionSugerida,
      lecturaEjecutiva: lectura,
      tipoAlertaOrigen: alerta.tipo,
      icono: alerta.icono,
    );
  }

  ConsolidadoHistoricoRecomendacionMesa
  _construirConsolidadoHistoricoRecomendacion({
    required RecomendacionHistoricaMesaIncidencias recomendacionHistorica,
    required HistorialEjecutivoMesaIncidencias historialEjecutivo,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) {
    final riesgoOscilacion =
        recomendacionHistorica.cambiosRecientes +
        (comparativaCabecera.estadoConversion == 'Retroceso' ? 1 : 0) +
        (historialEjecutivo.estadoConversion == 'Critica' ? 1 : 0);

    if (recomendacionHistorica.estadoConsistencia == 'Consistente' &&
        comparativaCabecera.estadoConversion != 'Retroceso' &&
        historialEjecutivo.conversionPorcentaje >= 70) {
      return const ConsolidadoHistoricoRecomendacionMesa(
        patron: 'Patron saludable',
        estado: 'Saludable',
        riesgoOscilacion: 0,
        lecturaEjecutiva:
            'La cabecera viene sosteniendo un criterio ejecutivo estable y con conversion suficiente entre periodos consecutivos.',
      );
    }

    if (recomendacionHistorica.estadoConsistencia == 'Inestable' &&
        riesgoOscilacion >= 3) {
      return ConsolidadoHistoricoRecomendacionMesa(
        patron: 'Oscilacion cronica',
        estado: 'Critico',
        riesgoOscilacion: riesgoOscilacion,
        lecturaEjecutiva:
            'La recomendacion dominante ya muestra una oscilacion cronica: cambia seguido, pierde conversion y necesita consolidar un patron ejecutivo antes de seguir escalando criterios.',
      );
    }

    if (recomendacionHistorica.estadoConsistencia == 'Cambio' ||
        comparativaCabecera.estadoConversion == 'Retroceso' ||
        historialEjecutivo.pendientesConversion > 0) {
      return ConsolidadoHistoricoRecomendacionMesa(
        patron: 'Patron reactivo',
        estado: 'Atencion',
        riesgoOscilacion: riesgoOscilacion,
        lecturaEjecutiva:
            'La cabecera todavia opera de forma reactiva: ya muestra cambios de foco o retrocesos de conversion que conviene estabilizar en el proximo periodo.',
      );
    }

    return ConsolidadoHistoricoRecomendacionMesa(
      patron: 'En consolidacion',
      estado: 'Vigilancia',
      riesgoOscilacion: riesgoOscilacion,
      lecturaEjecutiva:
          'La cabecera empieza a consolidar un patron ejecutivo, pero todavia necesita mas continuidad para considerarse estable.',
    );
  }

  ConsolidadoCronificacionInstitucionalMesa
  _construirConsolidadoCronificacionInstitucional({
    required List<IncidenciaTransversal> incidencias,
    required ConsolidadoHistoricoRecomendacionMesa consolidadoHistorico,
    required SeguimientoProtocoloRecuperacionInstitucionalMesa seguimientoRecuperacion,
    required SeguimientoPlanEstructuralRecomposicionMesa seguimientoPlanEstructural,
  }) {
    var riesgo = 0;

    switch (consolidadoHistorico.estado) {
      case 'Critico':
        riesgo += 2;
        break;
      case 'Atencion':
        riesgo += 1;
        break;
    }

    switch (seguimientoRecuperacion.estadoEfecto) {
      case 'Sin efecto':
        riesgo += 2;
        break;
      case 'Parcial':
        riesgo += 1;
        break;
    }

    switch (seguimientoPlanEstructural.estadoEfecto) {
      case 'Sin efecto':
        riesgo += 3;
        break;
      case 'Parcial':
        riesgo += 2;
        break;
      case 'Estable':
        riesgo += 1;
        break;
    }

    final urgentes = incidencias
        .where((item) => item.urgente || item.vencida)
        .toList(growable: false);
    if (urgentes.length >= 6) {
      riesgo += 1;
    }

    final conteos = <String, int>{};
    for (final item in urgentes) {
      conteos.update(item.origen, (actual) => actual + 1, ifAbsent: () => 1);
    }
    final modulos = conteos.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final modulosConcentrados = modulos
        .take(3)
        .map((item) => item.key)
        .toList(growable: false);

    final estado = riesgo >= 6
        ? 'Cronificada'
        : riesgo >= 4
            ? 'Alta'
            : riesgo >= 2
                ? 'En tension'
                : 'Contenida';

    final patron = switch (estado) {
      'Cronificada' => 'Cronificacion profunda',
      'Alta' => 'Cronificacion en ascenso',
      'En tension' => 'Cronificacion incipiente',
      _ => 'Cronificacion contenida',
    };

    final lecturaEjecutiva = switch (estado) {
      'Cronificada' =>
        'La cabecera ya muestra una cronificacion institucional profunda: fallan recuperacion y recomposicion, y la concentracion critica sigue sostenida en ${modulosConcentrados.join(', ')}.',
      'Alta' =>
        'La cronificacion institucional viene en ascenso y ya se concentra sobre ${modulosConcentrados.join(', ')}; conviene sostener una lectura unica para evitar una fijacion estructural del problema.',
      'En tension' =>
        'La cabecera muestra tension de cronificacion, aunque todavia conserva margen para recomponerse si sostiene foco en ${modulosConcentrados.join(', ')}.',
      _ =>
        'La cronificacion institucional permanece contenida y hoy no domina la lectura ejecutiva de la mesa.',
    };

    return ConsolidadoCronificacionInstitucionalMesa(
      patron: patron,
      estado: estado,
      riesgoCronificacion: riesgo,
      modulosConcentrados: modulosConcentrados,
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  PlanDesacopleCronificacionMesa _construirPlanDesacopleCronificacion({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
  }) {
    if (consolidadoCronificacion.estado != 'Alta' &&
        consolidadoCronificacion.estado != 'Cronificada') {
      return const PlanDesacopleCronificacionMesa(
        estado: 'No requerido',
        tipoDesacople: 'Sin desacople',
        criterioDesacople: '',
        horizonteDias: 0,
        modulosDesacople: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta abrir un plan de desacople de cronificacion.',
      );
    }

    final modulosDesacople = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias = consolidadoCronificacion.estado == 'Cronificada'
        ? 30
        : 21;
    final tipoDesacople = consolidadoCronificacion.estado == 'Cronificada'
        ? 'Desacople cronico intensivo'
        : 'Desacople cronico guiado';
    final criterioDesacople =
        switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'cronificacion_institucional_critica' =>
        'Durante el siguiente ciclo, desacoplar la presion cronica de ${modulosDesacople.join(' y ')} con un foco ejecutivo unico, reduciendo la rotacion de urgencias y sacando casos rojos repetidos de la cabecera general.',
      _ =>
        'Durante el siguiente ciclo, descomprimir ${modulosDesacople.join(' y ')} con una lectura ejecutiva unica, separando los casos cronicos del resto de la operatoria transversal.',
    };
    final lecturaEjecutiva = consolidadoCronificacion.estado == 'Cronificada'
        ? 'La cronificacion ya se fijo sobre ${modulosDesacople.join(', ')}; conviene abrir un desacople intensivo para bajar presion repetida y evitar que toda la cabecera siga orbitando los mismos casos.'
        : 'La cronificacion viene creciendo sobre ${modulosDesacople.join(', ')}; conviene desacoplar esos modulos antes de que el patron se vuelva estructural.';

    return PlanDesacopleCronificacionMesa(
      estado: 'Activar',
      tipoDesacople: tipoDesacople,
      criterioDesacople: criterioDesacople,
      horizonteDias: horizonteDias,
      modulosDesacople: modulosDesacople,
      accionesSugeridas: [
        'Sostener una mesa focal sobre ${modulosDesacople.join(' y ')} durante $horizonteDias dias.',
        'Separar los casos rojos repetidos de la rotacion diaria para reducir reingresos cronicos en cabecera.',
        'Cerrar cada semana con una lectura de desacople y alivio de carga por modulo comprometido.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoPlanDesacopleCronificacionMesa>
  _cargarSeguimientoPlanDesacopleCronificacion({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_desacople_cronificacion_preset',
                      'plan_desacople_cronificacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_desacople_cronificacion_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'plan_desacople_cronificacion_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado == 'Contenida'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        consolidadoCronificacion.estado == 'Alta'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay planes de desacople de cronificacion aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets planes de desacople y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanDesacopleCronificacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  Future<SeguimientoPlanReforzamientoDesacopleMesa>
  _cargarSeguimientoPlanReforzamientoDesacople({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    required SeguimientoPlanDesacopleCronificacionMesa seguimientoPlanDesacople,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_reforzamiento_desacople_preset',
                      'plan_reforzamiento_desacople_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_reforzamiento_desacople_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'plan_reforzamiento_desacople_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado != 'Cronificada'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoPlanDesacople.estadoEfecto == 'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay planes de reforzamiento del desacople aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets refuerzos de desacople y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanReforzamientoDesacopleMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  PlanReforzamientoDesacopleMesa _construirPlanReforzamientoDesacople({
    required SeguimientoPlanDesacopleCronificacionMesa seguimientoPlanDesacople,
    required PlanDesacopleCronificacionMesa planDesacople,
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (seguimientoPlanDesacople.presetsAplicados == 0 ||
        (seguimientoPlanDesacople.estadoEfecto != 'Sin efecto' &&
            seguimientoPlanDesacople.estadoEfecto != 'Parcial')) {
      return const PlanReforzamientoDesacopleMesa(
        estado: 'No requerido',
        tipoReforzamiento: 'Sin reforzamiento',
        criterioReforzamiento: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta reforzar el plan de desacople de cronificacion.',
      );
    }

    final modulosCriticos = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias = seguimientoPlanDesacople.estadoEfecto == 'Sin efecto'
        ? planDesacople.horizonteDias + 14
        : planDesacople.horizonteDias + 7;
    final tipoReforzamiento =
        seguimientoPlanDesacople.estadoEfecto == 'Sin efecto'
        ? 'Reforzamiento cronico intensivo'
        : 'Reforzamiento cronico guiado';
    final criterioReforzamiento =
        'Durante el siguiente ciclo reforzado, sostener una intervencion unica sobre ${modulosCriticos.join(' y ')}, con corte de reingresos rojos, horizonte mas largo y seguimiento semanal del alivio de carga.';
    final lecturaEjecutiva =
        seguimientoPlanDesacople.estadoEfecto == 'Sin efecto'
        ? 'El desacople inicial no alcanza; conviene reforzarlo con una version mas dura y prolongada sobre ${modulosCriticos.join(', ')} para cortar la concentracion cronica.'
        : 'El desacople actual mejora poco; conviene reforzarlo sobre ${modulosCriticos.join(', ')} antes de que la concentracion vuelva a fijarse.';

    return PlanReforzamientoDesacopleMesa(
      estado: 'Activar',
      tipoReforzamiento: tipoReforzamiento,
      criterioReforzamiento: criterioReforzamiento,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Sostener un desacople reforzado sobre ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Cortar reingresos de casos rojos repetidos y revisar semanalmente la carga cronica por modulo.',
        'Mantener una sola lectura ejecutiva hasta que la concentracion baje de forma visible.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  PlanContencionCronificacionMesa _construirPlanContencionCronificacion({
    required SeguimientoPlanReforzamientoDesacopleMesa
    seguimientoPlanReforzamientoDesacople,
    required PlanReforzamientoDesacopleMesa planReforzamientoDesacople,
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (seguimientoPlanReforzamientoDesacople.presetsAplicados == 0 ||
        (seguimientoPlanReforzamientoDesacople.estadoEfecto != 'Sin efecto' &&
            seguimientoPlanReforzamientoDesacople.estadoEfecto != 'Parcial')) {
      return const PlanContencionCronificacionMesa(
        estado: 'No requerido',
        tipoContencion: 'Sin contencion',
        criterioContencion: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un plan de contencion de cronificacion.',
      );
    }

    final modulosCriticos = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias =
        seguimientoPlanReforzamientoDesacople.estadoEfecto == 'Sin efecto'
        ? planReforzamientoDesacople.horizonteDias + 14
        : planReforzamientoDesacople.horizonteDias + 7;
    final tipoContencion =
        seguimientoPlanReforzamientoDesacople.estadoEfecto == 'Sin efecto'
        ? 'Contencion cronica intensiva'
        : 'Contencion cronica focalizada';
    final criterioContencion =
        'Durante el siguiente ciclo critico, contener la cronificacion sobre ${modulosCriticos.join(' y ')} con un unico criterio ejecutivo, ventana cerrada y absorcion prioritaria de casos rojos repetidos.';
    final lecturaEjecutiva =
        seguimientoPlanReforzamientoDesacople.estadoEfecto == 'Sin efecto'
        ? 'El reforzamiento del desacople tampoco alcanza; conviene pasar a una contencion cronica mas intensa sobre ${modulosCriticos.join(', ')} para evitar que el deterioro siga expandiendose.'
        : 'El reforzamiento mejora poco; conviene abrir una contencion focalizada sobre ${modulosCriticos.join(', ')} para limitar la cronificacion visible.';

    return PlanContencionCronificacionMesa(
      estado: 'Activar',
      tipoContencion: tipoContencion,
      criterioContencion: criterioContencion,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Sostener una contencion cerrada sobre ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Absorber primero los casos rojos repetidos y limitar la apertura de nuevos frentes cronicos.',
        'Cerrar cada semana con una lectura unica de contencion y alivio de concentracion por modulo.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoPlanContencionCronificacionMesa>
  _cargarSeguimientoPlanContencionCronificacion({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    required SeguimientoPlanReforzamientoDesacopleMesa
    seguimientoPlanReforzamientoDesacople,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_contencion_cronificacion_preset',
                      'plan_contencion_cronificacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_contencion_cronificacion_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'plan_contencion_cronificacion_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado != 'Cronificada'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoPlanReforzamientoDesacople.estadoEfecto ==
                            'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay planes de contencion de cronificacion aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets planes de contencion y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanContencionCronificacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  PlanRespuestaExcepcionalCronificacionMesa
  _construirPlanRespuestaExcepcionalCronificacion({
    required SeguimientoPlanContencionCronificacionMesa
    seguimientoPlanContencionCronificacion,
    required PlanContencionCronificacionMesa planContencionCronificacion,
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (seguimientoPlanContencionCronificacion.presetsAplicados == 0 ||
        (seguimientoPlanContencionCronificacion.estadoEfecto != 'Sin efecto' &&
            seguimientoPlanContencionCronificacion.estadoEfecto != 'Parcial')) {
      return const PlanRespuestaExcepcionalCronificacionMesa(
        estado: 'No requerido',
        tipoRespuesta: 'Sin respuesta excepcional',
        criterioRespuesta: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar una respuesta excepcional de cronificacion.',
      );
    }

    final modulosCriticos = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias =
        seguimientoPlanContencionCronificacion.estadoEfecto == 'Sin efecto'
        ? planContencionCronificacion.horizonteDias + 14
        : planContencionCronificacion.horizonteDias + 7;
    final tipoRespuesta =
        seguimientoPlanContencionCronificacion.estadoEfecto == 'Sin efecto'
        ? 'Respuesta excepcional critica'
        : 'Respuesta excepcional focalizada';
    final criterioRespuesta =
        'Durante el siguiente ciclo excepcional, sostener una intervencion institucional cerrada sobre ${modulosCriticos.join(' y ')}, con absorcion prioritaria de casos rojos cronicos, horizonte extendido y criterio unico de excepcion.';
    final lecturaEjecutiva =
        seguimientoPlanContencionCronificacion.estadoEfecto == 'Sin efecto'
        ? 'La contencion de cronificacion tampoco alcanza; conviene pasar a una respuesta excepcional critica sobre ${modulosCriticos.join(', ')} para evitar una fijacion institucional del deterioro.'
        : 'La contencion todavia queda corta; conviene abrir una respuesta excepcional focalizada sobre ${modulosCriticos.join(', ')} antes de que la cronificacion se vuelva estructural.';

    return PlanRespuestaExcepcionalCronificacionMesa(
      estado: 'Activar',
      tipoRespuesta: tipoRespuesta,
      criterioRespuesta: criterioRespuesta,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Sostener una respuesta excepcional sobre ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Absorber casos rojos cronicos antes de habilitar nuevas aperturas operativas en esos modulos.',
        'Cerrar cada semana con una lectura unica de excepcion y alivio de cronificacion por modulo.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoPlanRespuestaExcepcionalCronificacionMesa>
  _cargarSeguimientoPlanRespuestaExcepcionalCronificacion({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    required SeguimientoPlanContencionCronificacionMesa
    seguimientoPlanContencionCronificacion,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_respuesta_excepcional_cronificacion_preset',
                      'plan_respuesta_excepcional_cronificacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where(
          (row) =>
              row.accion == 'plan_respuesta_excepcional_cronificacion_preset',
        )
        .length;
    final ejecuciones = rows
        .where(
          (row) =>
              row.accion ==
              'plan_respuesta_excepcional_cronificacion_ejecutado',
        )
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado != 'Cronificada'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoPlanContencionCronificacion.estadoEfecto ==
                            'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay respuestas excepcionales de cronificacion aplicadas en los ultimos 30 dias.'
        : 'La cabecera aplico $presets respuestas excepcionales y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanRespuestaExcepcionalCronificacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  PlanCierreExtremoCronificacionMesa _construirPlanCierreExtremoCronificacion({
    required SeguimientoPlanRespuestaExcepcionalCronificacionMesa
    seguimientoPlanRespuestaExcepcionalCronificacion,
    required PlanRespuestaExcepcionalCronificacionMesa
    planRespuestaExcepcionalCronificacion,
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (seguimientoPlanRespuestaExcepcionalCronificacion.presetsAplicados == 0 ||
        (seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto !=
                'Sin efecto' &&
            seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto !=
                'Parcial')) {
      return const PlanCierreExtremoCronificacionMesa(
        estado: 'No requerido',
        tipoCierre: 'Sin cierre extremo',
        criterioCierre: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un cierre extremo de cronificacion.',
      );
    }

    final modulosCriticos = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias =
        seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto ==
                'Sin efecto'
            ? planRespuestaExcepcionalCronificacion.horizonteDias + 14
            : planRespuestaExcepcionalCronificacion.horizonteDias + 7;
    final tipoCierre =
        seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto ==
                'Sin efecto'
            ? 'Cierre extremo critico'
            : 'Cierre extremo focalizado';
    final criterioCierre =
        'Durante el siguiente ciclo extremo, concentrar el cierre operativo sobre ${modulosCriticos.join(' y ')}, congelar aperturas no criticas, absorber solo urgentes rojos y sostener una unica lectura institucional de cierre.';
    final lecturaEjecutiva =
        seguimientoPlanRespuestaExcepcionalCronificacion.estadoEfecto ==
                'Sin efecto'
            ? 'La respuesta excepcional tampoco alcanza; conviene pasar a un cierre extremo critico sobre ${modulosCriticos.join(', ')} para cortar la fijacion cronica del deterioro.'
            : 'La respuesta excepcional sigue quedando corta; conviene activar un cierre extremo focalizado sobre ${modulosCriticos.join(', ')} para proteger la cabecera antes de una cronificacion total.';

    return PlanCierreExtremoCronificacionMesa(
      estado: 'Activar',
      tipoCierre: tipoCierre,
      criterioCierre: criterioCierre,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Sostener un cierre extremo sobre ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Congelar aperturas no criticas y absorber solo urgencias rojas mientras baja la concentracion cronica.',
        'Cerrar cada semana con una lectura institucional unica de cierre y alivio sobre los modulos foco.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoPlanCierreExtremoCronificacionMesa>
  _cargarSeguimientoPlanCierreExtremoCronificacion({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    required SeguimientoPlanRespuestaExcepcionalCronificacionMesa
    seguimientoPlanRespuestaExcepcionalCronificacion,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_cierre_extremo_cronificacion_preset',
                      'plan_cierre_extremo_cronificacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_cierre_extremo_cronificacion_preset')
        .length;
    final ejecuciones = rows
        .where(
          (row) => row.accion == 'plan_cierre_extremo_cronificacion_ejecutado',
        )
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado != 'Cronificada'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoPlanRespuestaExcepcionalCronificacion
                                .estadoEfecto ==
                            'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay cierres extremos de cronificacion aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets cierres extremos y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanCierreExtremoCronificacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  PlanCorteTotalCronificacionMesa _construirPlanCorteTotalCronificacion({
    required SeguimientoPlanCierreExtremoCronificacionMesa
    seguimientoPlanCierreExtremoCronificacion,
    required PlanCierreExtremoCronificacionMesa planCierreExtremoCronificacion,
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (seguimientoPlanCierreExtremoCronificacion.presetsAplicados == 0 ||
        (seguimientoPlanCierreExtremoCronificacion.estadoEfecto !=
                'Sin efecto' &&
            seguimientoPlanCierreExtremoCronificacion.estadoEfecto !=
                'Parcial')) {
      return const PlanCorteTotalCronificacionMesa(
        estado: 'No requerido',
        tipoCorte: 'Sin corte total',
        criterioCorte: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un corte total de cronificacion.',
      );
    }

    final modulosCriticos = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias =
        seguimientoPlanCierreExtremoCronificacion.estadoEfecto == 'Sin efecto'
            ? planCierreExtremoCronificacion.horizonteDias + 14
            : planCierreExtremoCronificacion.horizonteDias + 7;
    final tipoCorte =
        seguimientoPlanCierreExtremoCronificacion.estadoEfecto == 'Sin efecto'
            ? 'Corte total critico'
            : 'Corte total focalizado';
    final criterioCorte =
        'Durante el siguiente ciclo final, imponer un corte total sobre ${modulosCriticos.join(' y ')}, sostener solo urgencias rojas inevitables, congelar reingresos no criticos y concentrar una unica lectura institucional de salida.';
    final lecturaEjecutiva =
        seguimientoPlanCierreExtremoCronificacion.estadoEfecto == 'Sin efecto'
            ? 'El cierre extremo tampoco alcanza; conviene pasar a un corte total critico sobre ${modulosCriticos.join(', ')} para detener la cronificacion aun al costo de restringir fuertemente la operatoria.'
            : 'El cierre extremo mejora poco; conviene activar un corte total focalizado sobre ${modulosCriticos.join(', ')} para cortar la persistencia cronica antes de una fijacion definitiva.';

    return PlanCorteTotalCronificacionMesa(
      estado: 'Activar',
      tipoCorte: tipoCorte,
      criterioCorte: criterioCorte,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Sostener un corte total sobre ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Congelar reingresos no criticos y absorber solo urgencias rojas inevitables mientras baja la concentracion extrema.',
        'Cerrar cada semana con una sola lectura institucional de corte y alivio sobre los modulos foco.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoPlanCorteTotalCronificacionMesa>
  _cargarSeguimientoPlanCorteTotalCronificacion({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    required SeguimientoPlanCierreExtremoCronificacionMesa
    seguimientoPlanCierreExtremoCronificacion,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_corte_total_cronificacion_preset',
                      'plan_corte_total_cronificacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_corte_total_cronificacion_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'plan_corte_total_cronificacion_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado != 'Cronificada'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoPlanCierreExtremoCronificacion.estadoEfecto ==
                            'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay cortes totales de cronificacion aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets cortes totales y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanCorteTotalCronificacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  ProtocoloFinalClausuraInstitucionalMesa
  _construirProtocoloFinalClausuraInstitucional({
    required SeguimientoPlanCorteTotalCronificacionMesa
    seguimientoPlanCorteTotalCronificacion,
    required PlanCorteTotalCronificacionMesa planCorteTotalCronificacion,
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (seguimientoPlanCorteTotalCronificacion.presetsAplicados == 0 ||
        (seguimientoPlanCorteTotalCronificacion.estadoEfecto != 'Sin efecto' &&
            seguimientoPlanCorteTotalCronificacion.estadoEfecto != 'Parcial')) {
      return const ProtocoloFinalClausuraInstitucionalMesa(
        estado: 'No requerido',
        tipoClausura: 'Sin clausura final',
        criterioClausura: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un protocolo final de clausura institucional.',
      );
    }

    final modulosCriticos = consolidadoCronificacion.modulosConcentrados.isEmpty
        ? _modulosPrioritariosParaEstabilizacion(incidencias)
        : consolidadoCronificacion.modulosConcentrados;
    final horizonteDias =
        seguimientoPlanCorteTotalCronificacion.estadoEfecto == 'Sin efecto'
            ? planCorteTotalCronificacion.horizonteDias + 14
            : planCorteTotalCronificacion.horizonteDias + 7;
    final tipoClausura =
        seguimientoPlanCorteTotalCronificacion.estadoEfecto == 'Sin efecto'
            ? 'Clausura institucional terminal'
            : 'Clausura institucional focalizada';
    final criterioClausura =
        'Durante el siguiente ciclo terminal, sostener una clausura institucional sobre ${modulosCriticos.join(' y ')}, mantener solo urgencias criticas inevitables, cerrar aperturas no esenciales y concentrar una unica lectura final de salida.';
    final lecturaEjecutiva =
        seguimientoPlanCorteTotalCronificacion.estadoEfecto == 'Sin efecto'
            ? 'El corte total tampoco alcanza; conviene pasar a una clausura institucional terminal sobre ${modulosCriticos.join(', ')} para cortar definitivamente la persistencia cronica.'
            : 'El corte total sigue quedando corto; conviene activar una clausura institucional focalizada sobre ${modulosCriticos.join(', ')} para forzar una salida final del circuito excepcional.';

    return ProtocoloFinalClausuraInstitucionalMesa(
      estado: 'Activar',
      tipoClausura: tipoClausura,
      criterioClausura: criterioClausura,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Sostener una clausura institucional sobre ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Mantener solo urgencias criticas inevitables y cerrar aperturas no esenciales mientras baja la concentracion extrema.',
        'Cerrar cada semana con una sola lectura final de clausura y alivio sobre los modulos foco.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoProtocoloFinalClausuraInstitucionalMesa>
  _cargarSeguimientoProtocoloFinalClausuraInstitucional({
    required ConsolidadoCronificacionInstitucionalMesa consolidadoCronificacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
    required SeguimientoPlanCorteTotalCronificacionMesa
    seguimientoPlanCorteTotalCronificacion,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'protocolo_final_clausura_preset',
                      'protocolo_final_clausura_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'protocolo_final_clausura_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'protocolo_final_clausura_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                consolidadoCronificacion.estado != 'Cronificada'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso' ||
                    consolidadoCronificacion.estado == 'Cronificada'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoPlanCorteTotalCronificacion.estadoEfecto ==
                            'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay protocolos finales de clausura aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets clausuras finales y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoProtocoloFinalClausuraInstitucionalMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  PlanEstabilizacionEjecutivaMesa _construirPlanEstabilizacionEjecutiva({
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
    required ConsolidadoHistoricoRecomendacionMesa consolidadoHistorico,
    required RecomendacionHistoricaMesaIncidencias recomendacionHistorica,
  }) {
    if (consolidadoHistorico.estado == 'Saludable') {
      return const PlanEstabilizacionEjecutivaMesa(
        estado: 'No requerido',
        criterio: 'Sostener la cabecera ejecutiva actual.',
        horizonteDias: 0,
        modulosPrioritarios: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'La mesa no necesita un plan de estabilizacion adicional mientras sostenga el patron saludable actual.',
      );
    }

    final modulosPrioritarios = _modulosPrioritariosParaEstabilizacion(
      incidencias,
    );
    final estado = consolidadoHistorico.estado == 'Critico'
        ? 'Urgente'
        : 'Preventivo';
    final horizonteDias = consolidadoHistorico.estado == 'Critico' ? 14 : 7;
    final criterio = _criterioEstabilizacion(
      recomendacionEjecutiva.tipoAlertaOrigen,
      recomendacionHistorica: recomendacionHistorica,
    );
    final acciones = _accionesPlanEstabilizacion(
      recomendacionEjecutiva.tipoAlertaOrigen,
      modulosPrioritarios,
    );
    final lectura = consolidadoHistorico.estado == 'Critico'
        ? 'La mesa necesita un plan breve de estabilizacion para sostener un criterio unico durante los proximos $horizonteDias dias y cortar la oscilacion ejecutiva.'
        : 'Conviene ordenar la cabecera con un plan preventivo de $horizonteDias dias antes de que la rotacion de foco se vuelva cronica.';

    return PlanEstabilizacionEjecutivaMesa(
      estado: estado,
      criterio: criterio,
      horizonteDias: horizonteDias,
      modulosPrioritarios: modulosPrioritarios,
      accionesSugeridas: acciones,
      lecturaEjecutiva: lectura,
    );
  }

  Future<SeguimientoPlanEstabilizacionMesa> _cargarSeguimientoPlanEstabilizacion({
    required ConsolidadoHistoricoRecomendacionMesa consolidadoHistorico,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_estabilizacion_preset',
                      'plan_estabilizacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_estabilizacion_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'plan_estabilizacion_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : consolidadoHistorico.estado == 'Saludable' &&
                comparativaCabecera.estadoConversion != 'Retroceso'
            ? 'Mejora'
            : consolidadoHistorico.estado == 'Critico'
                ? 'Sin efecto'
                : pendientes > 0 || conversion < 70
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay planes de estabilizacion aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets planes de estabilizacion y ejecuto $ejecuciones, con $conversion% de conversion y estado $estadoEfecto.';

    return SeguimientoPlanEstabilizacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  AjusteSugeridoPlanEstabilizacionMesa _construirAjusteSugeridoPlanEstabilizacion({
    required PlanEstabilizacionEjecutivaMesa planActual,
    required SeguimientoPlanEstabilizacionMesa seguimientoPlan,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
    required List<IncidenciaTransversal> incidencias,
  }) {
    if (planActual.estado == 'No requerido' ||
        (seguimientoPlan.estadoEfecto != 'Sin efecto' &&
            seguimientoPlan.estadoEfecto != 'Parcial')) {
      return const AjusteSugeridoPlanEstabilizacionMesa(
        estado: 'No requerido',
        tipoAjuste: 'Sin ajuste',
        criterioAjustado: '',
        horizonteDiasSugerido: 0,
        modulosRefuerzo: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta ajustar el plan de estabilizacion actual.',
      );
    }

    final modulosRefuerzo = _modulosPrioritariosParaEstabilizacion(incidencias);
    final horizonteDiasSugerido = seguimientoPlan.estadoEfecto == 'Sin efecto'
        ? planActual.horizonteDias + 14
        : planActual.horizonteDias + 7;
    final tipoAjuste = seguimientoPlan.estadoEfecto == 'Sin efecto'
        ? 'Reformular criterio'
        : 'Extender y enfocar';
    final criterioAjustado = switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'plan_estabilizacion_inefectivo' ||
      'oscilacion_cronica_cabecera' =>
        'Durante el siguiente ciclo, limitar la cabecera a un unico criterio: priorizar incidencias urgentes y vencidas de ${modulosRefuerzo.join(' y ')} antes de abrir nuevos focos o derivaciones.',
      'presion_documental_elevada' =>
        'Durante el siguiente ciclo, sostener resolucion en origen y habilitar Legajos solo para casos con bloqueo operativo real.',
      _ =>
        'Durante el siguiente ciclo, sostener el foco actual sobre ${modulosRefuerzo.join(' y ')} y medir resultados solo al cierre del nuevo horizonte.',
    };
    final lecturaEjecutiva = seguimientoPlan.estadoEfecto == 'Sin efecto'
        ? 'El plan actual ya no alcanza: conviene reformular criterio, extender horizonte y concentrar la cabecera en menos frentes operativos.'
        : 'El plan actual necesita un ajuste fino: conviene sostenerlo un poco mas, pero con modulos foco mas claros y sin volver a rotar criterio.';

    return AjusteSugeridoPlanEstabilizacionMesa(
      estado: 'Sugerido',
      tipoAjuste: tipoAjuste,
      criterioAjustado: criterioAjustado,
      horizonteDiasSugerido: horizonteDiasSugerido,
      modulosRefuerzo: modulosRefuerzo,
      accionesSugeridas: [
        'Revisar primero ${modulosRefuerzo.join(' y ')} durante el nuevo horizonte.',
        'Sostener un unico criterio ejecutivo durante $horizonteDiasSugerido dias.',
        'Volver a medir conversion y efecto del plan al cierre del ciclo.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  EscalamientoEstrategicoCabeceraMesa _construirEscalamientoCabecera({
    required SeguimientoAjustePlanEstabilizacionMesa seguimientoAjuste,
    required AjusteSugeridoPlanEstabilizacionMesa ajustePlan,
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
  }) {
    if (seguimientoAjuste.presetsAplicados == 0 ||
        (seguimientoAjuste.estadoEfecto != 'Sin efecto' &&
            seguimientoAjuste.estadoEfecto != 'Parcial')) {
      return const EscalamientoEstrategicoCabeceraMesa(
        estado: 'No requerido',
        tipoIntervencion: 'Sin escalamiento',
        criterioEjecutivo: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta escalar la intervencion de cabecera.',
      );
    }

    final modulosCriticos = _modulosPrioritariosParaEstabilizacion(incidencias);
    final horizonteDias = seguimientoAjuste.estadoEfecto == 'Sin efecto' ? 21 : 14;
    final tipoIntervencion = seguimientoAjuste.estadoEfecto == 'Sin efecto'
        ? 'Intervencion ejecutiva intensiva'
        : 'Refuerzo critico focalizado';
    final criterioEjecutivo = switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'ajuste_plan_inefectivo' ||
      'plan_estabilizacion_inefectivo' =>
        'Durante el siguiente ciclo, la cabecera debe operar solo sobre incidencias rojas o vencidas de ${modulosCriticos.join(' y ')}, con revision diaria y sin abrir nuevos criterios hasta recuperar conversion.',
      _ =>
        'Durante el siguiente ciclo, concentrar la cabecera en ${modulosCriticos.join(' y ')} y sostener un unico criterio critico hasta normalizar la respuesta ejecutiva.',
    };
    final lecturaEjecutiva = seguimientoAjuste.estadoEfecto == 'Sin efecto'
        ? 'El ajuste tambien quedo corto; conviene escalar la cabecera hacia una intervencion ejecutiva intensiva, mas corta y con modulos criticos explicitamente acotados.'
        : 'El ajuste no termino de consolidarse; conviene pasar a un refuerzo critico focalizado para evitar una nueva deriva de criterio.';

    return EscalamientoEstrategicoCabeceraMesa(
      estado: 'Escalar',
      tipoIntervencion: tipoIntervencion,
      criterioEjecutivo: ajustePlan.estado == 'No requerido'
          ? criterioEjecutivo
          : criterioEjecutivo,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Limitar la cabecera a ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Revisar primero incidencias rojas o vencidas antes de cualquier otra accion.',
        'Medir conversion ejecutiva al cierre de cada jornada critica.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  ProtocoloContingenciaCabeceraMesa _construirProtocoloContingencia({
    required SeguimientoEscalamientoCabeceraMesa seguimientoEscalamiento,
    required EscalamientoEstrategicoCabeceraMesa escalamientoCabecera,
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
  }) {
    if (seguimientoEscalamiento.presetsAplicados == 0 ||
        (seguimientoEscalamiento.estadoEfecto != 'Sin efecto' &&
            seguimientoEscalamiento.estadoEfecto != 'Parcial')) {
      return const ProtocoloContingenciaCabeceraMesa(
        estado: 'No requerido',
        tipoProtocolo: 'Sin contingencia',
        criterioInstitucional: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un protocolo institucional de contingencia.',
      );
    }

    final modulosCriticos = _modulosPrioritariosParaEstabilizacion(incidencias);
    final horizonteDias = seguimientoEscalamiento.estadoEfecto == 'Sin efecto'
        ? 10
        : 7;
    final tipoProtocolo = seguimientoEscalamiento.estadoEfecto == 'Sin efecto'
        ? 'Contingencia institucional intensiva'
        : 'Contingencia focalizada';
    final criterioInstitucional = switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'escalamiento_insuficiente' ||
      'ajuste_plan_inefectivo' =>
        'Durante el siguiente ciclo, la cabecera solo debe operar sobre incidencias rojas o vencidas de ${modulosCriticos.join(' y ')}, con seguimiento diario, criterio unico y sin abrir nuevos circuitos hasta normalizar la respuesta.',
      _ =>
        'Durante el siguiente ciclo, sostener una contingencia institucional breve sobre ${modulosCriticos.join(' y ')} hasta recuperar la conversion de la cabecera.',
    };
    final lecturaEjecutiva = seguimientoEscalamiento.estadoEfecto == 'Sin efecto'
        ? 'El escalamiento tambien quedo corto; conviene pasar a un protocolo institucional de contingencia con foco breve, critico y sin dispersion de criterios.'
        : 'El escalamiento no termina de consolidarse; conviene activar una contingencia focalizada para evitar una nueva deriva de la cabecera.';

    return ProtocoloContingenciaCabeceraMesa(
      estado: 'Activar',
      tipoProtocolo: tipoProtocolo,
      criterioInstitucional: criterioInstitucional,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Limitar la cabecera a ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Revisar solo incidencias rojas o vencidas mientras dure la contingencia.',
        'Cerrar cada jornada con una lectura unica de conversion ejecutiva.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  MesaCrisisInstitucionalCabecera _construirMesaCrisisInstitucional({
    required SeguimientoProtocoloContingenciaMesa seguimientoProtocolo,
    required ProtocoloContingenciaCabeceraMesa protocoloContingencia,
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
  }) {
    if (seguimientoProtocolo.presetsAplicados == 0 ||
        (seguimientoProtocolo.estadoEfecto != 'Sin efecto' &&
            seguimientoProtocolo.estadoEfecto != 'Parcial')) {
      return const MesaCrisisInstitucionalCabecera(
        estado: 'No requerida',
        tipoMesa: 'Sin crisis',
        criterioCrisis: '',
        horizonteDias: 0,
        modulosCriticos: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar una mesa de crisis institucional.',
      );
    }

    final modulosCriticos = _modulosPrioritariosParaEstabilizacion(incidencias);
    final horizonteDias = seguimientoProtocolo.estadoEfecto == 'Sin efecto'
        ? 5
        : 7;
    final tipoMesa = seguimientoProtocolo.estadoEfecto == 'Sin efecto'
        ? 'Crisis institucional plena'
        : 'Crisis institucional preventiva';
    final criterioCrisis = switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'contingencia_insuficiente' ||
      'escalamiento_insuficiente' =>
        'Durante el siguiente ciclo, la cabecera debe operar solo sobre incidencias rojas y vencidas de ${modulosCriticos.join(' y ')}, con corte diario, criterio unico y sin abrir nuevos frentes hasta recuperar control.',
      _ =>
        'Durante el siguiente ciclo, sostener una mesa de crisis breve sobre ${modulosCriticos.join(' y ')} hasta recomponer la conversion institucional.',
    };
    final lecturaEjecutiva = seguimientoProtocolo.estadoEfecto == 'Sin efecto'
        ? 'La contingencia tambien quedo corta; conviene pasar a una mesa de crisis institucional con foco diario, criterio unico y modulos criticos explicitamente acotados.'
        : 'La contingencia no termina de consolidarse; conviene activar una mesa de crisis preventiva para evitar una profundizacion del cuadro.';

    return MesaCrisisInstitucionalCabecera(
      estado: 'Activar',
      tipoMesa: tipoMesa,
      criterioCrisis: protocoloContingencia.estado == 'No requerido'
          ? criterioCrisis
          : criterioCrisis,
      horizonteDias: horizonteDias,
      modulosCriticos: modulosCriticos,
      accionesSugeridas: [
        'Limitar la cabecera a ${modulosCriticos.join(' y ')} durante $horizonteDias dias.',
        'Revisar solo incidencias rojas y vencidas mientras dure la crisis.',
        'Cerrar cada jornada con una lectura institucional unica del estado de conversion.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  ProtocoloRecuperacionInstitucionalMesa _construirProtocoloRecuperacionInstitucional({
    required SeguimientoMesaCrisisInstitucionalMesa seguimientoMesaCrisis,
    required MesaCrisisInstitucionalCabecera mesaCrisis,
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
  }) {
    if (seguimientoMesaCrisis.presetsAplicados == 0 ||
        (seguimientoMesaCrisis.estadoEfecto != 'Sin efecto' &&
            seguimientoMesaCrisis.estadoEfecto != 'Parcial')) {
      return const ProtocoloRecuperacionInstitucionalMesa(
        estado: 'No requerido',
        tipoRecuperacion: 'Sin recuperacion',
        criterioRecuperacion: '',
        horizonteDias: 0,
        modulosPrioritarios: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un protocolo de recuperacion institucional.',
      );
    }

    final modulosPrioritarios = _modulosPrioritariosParaEstabilizacion(incidencias);
    final horizonteDias = seguimientoMesaCrisis.estadoEfecto == 'Sin efecto'
        ? 21
        : 14;
    final tipoRecuperacion = seguimientoMesaCrisis.estadoEfecto == 'Sin efecto'
        ? 'Recuperacion institucional intensiva'
        : 'Recuperacion institucional guiada';
    final criterioRecuperacion =
        switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'crisis_sostenida' =>
        'Durante el siguiente ciclo, la cabecera debe sostener una recomposicion guiada sobre ${modulosPrioritarios.join(' y ')}, con criterio unico, horizonte compartido y salida progresiva de la urgencia mas critica.',
      _ =>
        'Durante el siguiente ciclo, concentrar la recuperacion sobre ${modulosPrioritarios.join(' y ')} para bajar la urgencia critica y reconstruir una respuesta estable de la cabecera.',
    };
    final lecturaEjecutiva = seguimientoMesaCrisis.estadoEfecto == 'Sin efecto'
        ? 'La crisis ya se sostiene incluso despues de activar la mesa de crisis; conviene pasar a un protocolo de recuperacion institucional con horizonte mas largo y salida ordenada de la urgencia.'
        : 'La mesa de crisis no termina de recomponer la cabecera; conviene abrir un protocolo de recuperacion guiada para estabilizar criterio y carga durante el siguiente ciclo.';

    return ProtocoloRecuperacionInstitucionalMesa(
      estado: 'Activar',
      tipoRecuperacion: tipoRecuperacion,
      criterioRecuperacion:
          mesaCrisis.estado == 'No requerida' ? criterioRecuperacion : criterioRecuperacion,
      horizonteDias: horizonteDias,
      modulosPrioritarios: modulosPrioritarios,
      accionesSugeridas: [
        'Sostener una unica lectura ejecutiva sobre ${modulosPrioritarios.join(' y ')} durante $horizonteDias dias.',
        'Reducir primero incidencias rojas y vencidas antes de abrir nuevos frentes operativos.',
        'Cerrar cada semana con una lectura unica de recuperacion institucional y conversion de cabecera.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoProtocoloRecuperacionInstitucionalMesa>
  _cargarSeguimientoProtocoloRecuperacionInstitucional({
    required SeguimientoMesaCrisisInstitucionalMesa seguimientoMesaCrisis,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'protocolo_recuperacion_preset',
                      'protocolo_recuperacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'protocolo_recuperacion_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'protocolo_recuperacion_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoMesaCrisis.estadoEfecto == 'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay protocolos de recuperacion institucional aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets protocolos de recuperacion y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoProtocoloRecuperacionInstitucionalMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  PlanEstructuralRecomposicionMesa _construirPlanEstructuralRecomposicion({
    required SeguimientoProtocoloRecuperacionInstitucionalMesa seguimientoRecuperacion,
    required ProtocoloRecuperacionInstitucionalMesa protocoloRecuperacion,
    required List<IncidenciaTransversal> incidencias,
    required RecomendacionEjecutivaMesaIncidencias recomendacionEjecutiva,
  }) {
    if (seguimientoRecuperacion.presetsAplicados == 0 ||
        (seguimientoRecuperacion.estadoEfecto != 'Sin efecto' &&
            seguimientoRecuperacion.estadoEfecto != 'Parcial')) {
      return const PlanEstructuralRecomposicionMesa(
        estado: 'No requerido',
        tipoPlan: 'Sin recomposicion',
        criterioEstructural: '',
        horizonteDias: 0,
        modulosPrioritarios: <String>[],
        accionesSugeridas: <String>[],
        lecturaEjecutiva:
            'Todavia no hace falta activar un plan estructural de recomposicion.',
      );
    }

    final modulosPrioritarios = _modulosPrioritariosParaEstabilizacion(incidencias);
    final horizonteDias = seguimientoRecuperacion.estadoEfecto == 'Sin efecto'
        ? 45
        : 30;
    final tipoPlan = seguimientoRecuperacion.estadoEfecto == 'Sin efecto'
        ? 'Recomposicion estructural intensiva'
        : 'Recomposicion estructural guiada';
    final criterioEstructural =
        switch (recomendacionEjecutiva.tipoAlertaOrigen) {
      'recuperacion_insuficiente' =>
        'Durante el siguiente ciclo extendido, la cabecera debe sostener una recomposicion estructural sobre ${modulosPrioritarios.join(' y ')}, con criterio unico, horizonte compartido y reduccion progresiva de la urgencia critica.',
      _ =>
        'Durante el siguiente ciclo extendido, ordenar la recomposicion de ${modulosPrioritarios.join(' y ')} con una salida institucional mas profunda y estable que la simple recuperacion operativa.',
    };
    final lecturaEjecutiva = seguimientoRecuperacion.estadoEfecto == 'Sin efecto'
        ? 'La recuperacion institucional tambien quedo corta; conviene pasar a un plan estructural de recomposicion, mas largo y con salida institucional profunda.'
        : 'La recuperacion no termina de consolidarse; conviene abrir una recomposicion estructural guiada para bajar urgencia y estabilizar la cabecera de forma sostenida.';

    return PlanEstructuralRecomposicionMesa(
      estado: 'Activar',
      tipoPlan: tipoPlan,
      criterioEstructural: protocoloRecuperacion.estado == 'No requerido'
          ? criterioEstructural
          : criterioEstructural,
      horizonteDias: horizonteDias,
      modulosPrioritarios: modulosPrioritarios,
      accionesSugeridas: [
        'Sostener una unica lectura estructural sobre ${modulosPrioritarios.join(' y ')} durante $horizonteDias dias.',
        'Reducir urgencias rojas y vencidas antes de reabrir criterios nuevos en la cabecera.',
        'Cerrar cada quincena con una lectura institucional de recomposicion y estabilidad.',
      ],
      lecturaEjecutiva: lecturaEjecutiva,
    );
  }

  Future<SeguimientoPlanEstructuralRecomposicionMesa>
  _cargarSeguimientoPlanEstructuralRecomposicion({
    required SeguimientoProtocoloRecuperacionInstitucionalMesa seguimientoRecuperacion,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'plan_estructural_preset',
                      'plan_estructural_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'plan_estructural_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'plan_estructural_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoRecuperacion.estadoEfecto == 'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay planes estructurales de recomposicion aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets planes estructurales y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoPlanEstructuralRecomposicionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  Future<SeguimientoMesaCrisisInstitucionalMesa>
  _cargarSeguimientoMesaCrisisInstitucional({
    required SeguimientoProtocoloContingenciaMesa seguimientoProtocolo,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'mesa_crisis_preset',
                      'mesa_crisis_ejecutada',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'mesa_crisis_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'mesa_crisis_ejecutada')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso'
                ? 'Sin efecto'
                : pendientes > 0 ||
                        conversion < 70 ||
                        seguimientoProtocolo.estadoEfecto == 'Sin efecto'
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay mesas de crisis institucionales aplicadas en los ultimos 30 dias.'
        : 'La cabecera aplico $presets mesas de crisis y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoMesaCrisisInstitucionalMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  Future<SeguimientoProtocoloContingenciaMesa>
  _cargarSeguimientoProtocoloContingencia({
    required SeguimientoEscalamientoCabeceraMesa seguimientoEscalamiento,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'protocolo_contingencia_preset',
                      'protocolo_contingencia_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'protocolo_contingencia_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'protocolo_contingencia_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                seguimientoEscalamiento.estadoEfecto != 'Sin efecto'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso'
                ? 'Sin efecto'
                : pendientes > 0 || conversion < 70
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay protocolos de contingencia aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets protocolos de contingencia y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoProtocoloContingenciaMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  Future<SeguimientoEscalamientoCabeceraMesa>
  _cargarSeguimientoEscalamientoCabecera({
    required SeguimientoAjustePlanEstabilizacionMesa seguimientoAjuste,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'escalamiento_cabecera_preset',
                      'escalamiento_cabecera_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'escalamiento_cabecera_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'escalamiento_cabecera_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                seguimientoAjuste.estadoEfecto != 'Sin efecto'
            ? 'Mejora'
            : comparativaCabecera.estadoConversion == 'Retroceso'
                ? 'Sin efecto'
                : pendientes > 0 || conversion < 70
                    ? 'Parcial'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay escalamientos estrategicos aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets escalamientos estrategicos y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoEscalamientoCabeceraMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  Future<SeguimientoAjustePlanEstabilizacionMesa>
  _cargarSeguimientoAjustePlanEstabilizacion({
    required SeguimientoPlanEstabilizacionMesa seguimientoPlan,
    required ComparativaCabeceraEjecutivaMesa comparativaCabecera,
  }) async {
    final desde = DateTime.now().subtract(const Duration(days: 30));
    final rows =
        await (_db.select(_db.tablaIncidenciasTransversalesHistorial)
              ..where(
                (t) =>
                    t.creadoEn.isBiggerOrEqualValue(desde) &
                    t.accion.isIn(const [
                      'ajuste_plan_estabilizacion_preset',
                      'ajuste_plan_estabilizacion_ejecutado',
                    ]),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.creadoEn)]))
            .get();

    final presets = rows
        .where((row) => row.accion == 'ajuste_plan_estabilizacion_preset')
        .length;
    final ejecuciones = rows
        .where((row) => row.accion == 'ajuste_plan_estabilizacion_ejecutado')
        .length;
    final pendientes = presets > ejecuciones ? presets - ejecuciones : 0;
    final conversion = presets == 0 ? 100 : ((ejecuciones / presets) * 100).round();

    final estadoEfecto = presets == 0
        ? 'Sin seguimiento'
        : comparativaCabecera.estadoConversion == 'Mejora' &&
                seguimientoPlan.estadoEfecto != 'Sin efecto'
            ? 'Mejora'
            : pendientes > 0 || conversion < 70
                ? 'Parcial'
                : comparativaCabecera.estadoConversion == 'Retroceso'
                    ? 'Sin efecto'
                    : 'Estable';

    final lectura = presets == 0
        ? 'Todavia no hay ajustes del plan aplicados en los ultimos 30 dias.'
        : 'La cabecera aplico $presets ajustes del plan y ejecuto $ejecuciones, con $conversion% de conversion y efecto $estadoEfecto.';

    return SeguimientoAjustePlanEstabilizacionMesa(
      presetsAplicados: presets,
      ejecucionesRegistradas: ejecuciones,
      conversionPorcentaje: conversion,
      pendientes: pendientes,
      estadoEfecto: estadoEfecto,
      lecturaEjecutiva: lectura,
    );
  }

  Future<List<IncidenciaTransversal>> _incidenciasSecretaria(
    ContextoInstitucional contexto,
    Map<String, TablaLegajosDocumentale> legajos,
  ) async {
    final rows =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    return rows.where((item) {
      return legajos.containsKey(item.codigo) ||
          item.observaciones.contains('Actualizado desde Legajos:');
    }).map((item) {
      final legajo = legajos[item.codigo];
      return IncidenciaTransversal(
        origen: 'Secretaria',
        referencia: item.codigo,
        titulo: item.asunto,
        detalle: item.observaciones,
        estadoOperativo: item.estado,
        estadoDocumental: legajo?.estado,
        prioridad: item.prioridad,
        responsable: item.responsable,
        codigoLegajo: legajo?.codigo,
        devueltaDesdeLegajos: item.observaciones.contains(
          'Actualizado desde Legajos:',
        ),
        vencida: item.fechaLimite != null &&
            item.fechaLimite!.isBefore(DateTime.now()),
        fechaCompromiso: item.fechaLimite,
      );
    }).toList(growable: false);
  }

  Future<List<IncidenciaTransversal>> _incidenciasPreceptoria(
    ContextoInstitucional contexto,
    Map<int, TablaLegajosDocumentale> legajos,
  ) async {
    final rows =
        await (_db.select(_db.tablaNovedadesPreceptoria)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    return rows.where((item) {
      return legajos.containsKey(item.id) ||
          item.observaciones.contains('Actualizado desde Legajos:');
    }).map((item) {
      final legajo = legajos[item.id];
      return IncidenciaTransversal(
        origen: 'Preceptoria',
        referencia: '${item.id}',
        titulo: '${item.tipoNovedad} - ${item.alumnoReferencia ?? item.cursoReferencia ?? 'Seguimiento general'}',
        detalle: item.observaciones,
        estadoOperativo: item.estado,
        estadoDocumental: legajo?.estado,
        prioridad: item.prioridad,
        responsable: item.responsable,
        codigoLegajo: legajo?.codigo,
        devueltaDesdeLegajos: item.observaciones.contains(
          'Actualizado desde Legajos:',
        ),
        vencida: item.fechaSeguimiento != null &&
            item.fechaSeguimiento!.isBefore(DateTime.now()),
        fechaCompromiso: item.fechaSeguimiento,
      );
    }).toList(growable: false);
  }

  Future<List<IncidenciaTransversal>> _incidenciasBiblioteca(
    ContextoInstitucional contexto,
    Map<String, TablaLegajosDocumentale> legajos,
  ) async {
    final rows =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) =>
                    t.activo.equals(true) &
                    t.nivelDestino.equals(contexto.nivel.name) &
                    t.dependenciaDestino.equals(contexto.dependencia.name),
              ))
            .get();

    return rows.where((item) {
      return legajos.containsKey(item.codigo) ||
          item.observaciones.contains('Actualizado desde Legajos:');
    }).map((item) {
      final legajo = legajos[item.codigo];
      final detalle = [
        item.observaciones,
        if ((item.destinatario ?? '').trim().isNotEmpty)
          'Destinatario: ${item.destinatario}',
        if ((item.cursoReferencia ?? '').trim().isNotEmpty)
          'Curso: ${item.cursoReferencia}',
      ].where((text) => text.trim().isNotEmpty).join('\n');
      return IncidenciaTransversal(
        origen: 'Biblioteca',
        referencia: item.codigo,
        titulo: item.titulo,
        detalle: detalle,
        estadoOperativo: item.estado,
        estadoDocumental: legajo?.estado,
        prioridad: _prioridadBiblioteca(item),
        responsable: item.responsable,
        codigoLegajo: legajo?.codigo,
        devueltaDesdeLegajos: item.observaciones.contains(
          'Actualizado desde Legajos:',
        ),
        vencida: item.fechaVencimiento != null &&
            item.fechaVencimiento!.isBefore(DateTime.now()),
        fechaCompromiso: item.fechaVencimiento,
      );
    }).toList(growable: false);
  }

  int _pesoUrgencia(IncidenciaTransversal item) {
    final prioridad = switch (item.prioridad) {
      'Alta' => 4,
      'Media' => 3,
      'Baja' => 2,
      _ => 1,
    };
    return prioridad +
        (item.vencida ? 3 : 0) +
        (item.devueltaDesdeLegajos ? 2 : 0) +
        (item.estadoDocumental == 'Critico' ? 2 : 0);
  }

  int _idPreceptoria(String codigoLegajo) {
    final match = RegExp(r'^PRE-(\d+)').firstMatch(codigoLegajo);
    return int.tryParse(match?.group(1) ?? '') ?? -1;
  }

  String _prioridadBiblioteca(TablaRecursosBibliotecaData item) {
    if (item.observaciones.contains('Priorizado desde Incidencias:')) {
      return 'Alta';
    }
    if (item.fechaVencimiento != null &&
        item.fechaVencimiento!.isBefore(DateTime.now())) {
      return 'Alta';
    }
    if (item.estado == 'Reservado') return 'Media';
    return 'Baja';
  }

  Future<bool> _priorizarSecretaria(
    IncidenciaTransversal item, {
    String? criterio,
    DateTime? fechaObjetivo,
  }) async {
    final row =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(item.referencia),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaTramitesSecretaria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaTramitesSecretariaCompanion(
            prioridad: const Value('Alta'),
            estado: Value(row.estado == 'Urgente' ? row.estado : 'Urgente'),
            fechaLimite: Value(fechaObjetivo ?? row.fechaLimite),
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                _notaPriorizacion(
                  criterio: criterio,
                  fechaObjetivo: fechaObjetivo,
                  fallback: 'requiere atencion institucional.',
                ),
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _priorizarPreceptoria(
    IncidenciaTransversal item, {
    String? criterio,
    DateTime? fechaObjetivo,
  }) async {
    final id = int.tryParse(item.referencia);
    if (id == null) return false;
    final row =
        await (_db.select(_db.tablaNovedadesPreceptoria)
              ..where((t) => t.activo.equals(true) & t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaNovedadesPreceptoria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaNovedadesPreceptoriaCompanion(
            prioridad: const Value('Alta'),
            estado: Value(row.estado == 'Urgente' ? row.estado : 'Urgente'),
            fechaSeguimiento: Value(fechaObjetivo ?? row.fechaSeguimiento),
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                _notaPriorizacion(
                  criterio: criterio,
                  fechaObjetivo: fechaObjetivo,
                  fallback: 'requiere seguimiento inmediato.',
                ),
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _priorizarBiblioteca(
    IncidenciaTransversal item, {
    String? criterio,
    DateTime? fechaObjetivo,
  }) async {
    final row =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(item.referencia),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaRecursosBiblioteca)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaRecursosBibliotecaCompanion(
            fechaVencimiento: Value(fechaObjetivo ?? row.fechaVencimiento),
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                _notaPriorizacion(
                  criterio: criterio,
                  fechaObjetivo: fechaObjetivo,
                  fallback: 'revisar devolucion o disponibilidad.',
                ),
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _devolverSecretaria(
    IncidenciaTransversal item, {
    String? motivo,
  }) async {
    final row =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(item.referencia),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaTramitesSecretaria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaTramitesSecretariaCompanion(
            estado: Value(item.urgente ? 'Urgente' : 'En verificacion'),
            prioridad: Value(item.urgente ? 'Alta' : row.prioridad),
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                [
                  'Actualizado desde mesa de incidencias: ${item.estadoDocumental ?? item.estadoOperativo}.',
                  if ((motivo ?? '').trim().isNotEmpty)
                    'Motivo de devolucion: ${motivo!.trim()}',
                ].join(' '),
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _devolverPreceptoria(
    IncidenciaTransversal item, {
    String? motivo,
  }) async {
    final id = int.tryParse(item.referencia);
    if (id == null) return false;
    final row =
        await (_db.select(_db.tablaNovedadesPreceptoria)
              ..where((t) => t.activo.equals(true) & t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaNovedadesPreceptoria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaNovedadesPreceptoriaCompanion(
            estado: Value(item.urgente ? 'Urgente' : 'En seguimiento'),
            prioridad: Value(item.urgente ? 'Alta' : row.prioridad),
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                [
                  'Actualizado desde mesa de incidencias: ${item.estadoDocumental ?? item.estadoOperativo}.',
                  if ((motivo ?? '').trim().isNotEmpty)
                    'Motivo de devolucion: ${motivo!.trim()}',
                ].join(' '),
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _devolverBiblioteca(
    IncidenciaTransversal item, {
    String? motivo,
  }) async {
    final row =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(item.referencia),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaRecursosBiblioteca)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaRecursosBibliotecaCompanion(
            estado: Value(item.urgente ? 'Prestado' : 'Reservado'),
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                [
                  'Actualizado desde mesa de incidencias: ${item.estadoDocumental ?? item.estadoOperativo}.',
                  if ((motivo ?? '').trim().isNotEmpty)
                    'Motivo de devolucion: ${motivo!.trim()}',
                ].join(' '),
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _registrarObservacionSecretaria(
    IncidenciaTransversal item,
    String observacion,
  ) async {
    final row =
        await (_db.select(_db.tablaTramitesSecretaria)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(item.referencia),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaTramitesSecretaria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaTramitesSecretariaCompanion(
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                'Observacion desde Incidencias: $observacion',
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _registrarObservacionPreceptoria(
    IncidenciaTransversal item,
    String observacion,
  ) async {
    final id = int.tryParse(item.referencia);
    if (id == null) return false;
    final row =
        await (_db.select(_db.tablaNovedadesPreceptoria)
              ..where((t) => t.activo.equals(true) & t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaNovedadesPreceptoria)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaNovedadesPreceptoriaCompanion(
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                'Observacion desde Incidencias: $observacion',
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  Future<bool> _registrarObservacionBiblioteca(
    IncidenciaTransversal item,
    String observacion,
  ) async {
    final row =
        await (_db.select(_db.tablaRecursosBiblioteca)
              ..where(
                (t) => t.activo.equals(true) & t.codigo.equals(item.referencia),
              )
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return false;
    await (_db.update(_db.tablaRecursosBiblioteca)
          ..where((t) => t.id.equals(row.id)))
        .write(
          TablaRecursosBibliotecaCompanion(
            observaciones: Value(
              _agregarNota(
                row.observaciones,
                'Observacion desde Incidencias: $observacion',
              ),
            ),
            actualizadoEn: Value(DateTime.now()),
          ),
        );
    return true;
  }

  String _codigoLegajo(IncidenciaTransversal item) {
    switch (item.origen) {
      case 'Secretaria':
        return 'SEC-${item.referencia}';
      case 'Preceptoria':
        return 'PRE-${item.referencia}';
      case 'Biblioteca':
        return 'BIB-${item.referencia}';
      default:
        return item.referencia;
    }
  }

  String _tipoRegistro(IncidenciaTransversal item) {
    if (item.origen == 'Biblioteca' || item.origen == 'Secretaria') {
      return 'documento';
    }
    return 'expediente';
  }

  String _categoria(IncidenciaTransversal item) {
    return switch (item.origen) {
      'Secretaria' => 'institucional',
      'Biblioteca' => 'institucional',
      'Preceptoria' => 'alumnos',
      _ => 'institucional',
    };
  }

  String _detalleLegajo(
    IncidenciaTransversal item, {
    String? justificacion,
  }) {
    return [
      'Origen: ${item.origen}',
      'Referencia: ${item.referencia}',
      'Estado operativo: ${item.estadoOperativo}',
      if ((justificacion ?? '').trim().isNotEmpty)
        'Justificacion de derivacion: ${justificacion!.trim()}',
      if (item.detalle.trim().isNotEmpty) item.detalle.trim(),
    ].join('\n');
  }

  Future<void> _registrarJustificacionDerivacion(
    IncidenciaTransversal item,
    String? justificacion,
  ) async {
    final texto = justificacion?.trim();
    if (texto == null || texto.isEmpty) return;
    switch (item.origen) {
      case 'Secretaria':
        await _registrarObservacionSecretaria(
          item,
          'Derivado a Legajos desde Incidencias: $texto',
        );
        break;
      case 'Preceptoria':
        await _registrarObservacionPreceptoria(
          item,
          'Derivado a Legajos desde Incidencias: $texto',
        );
        break;
      case 'Biblioteca':
        await _registrarObservacionBiblioteca(
          item,
          'Derivado a Legajos desde Incidencias: $texto',
        );
        break;
    }
  }

  String _estadoLegajo(IncidenciaTransversal item) {
    return item.urgente ? 'Critico' : 'En revision';
  }

  String _severidad(IncidenciaTransversal item) {
    if (item.prioridad == 'Alta' || item.vencida) return 'Alta';
    if (item.prioridad == 'Media') return 'Media';
    return 'Baja';
  }

  int? _horasHastaCompromiso(DateTime? fecha) {
    if (fecha == null) return null;
    final horas = fecha.difference(DateTime.now()).inHours;
    return horas <= 0 ? 0 : horas;
  }

  String _agregarNota(String actual, String nota) {
    if (actual.contains(nota)) return actual;
    return [actual.trim(), nota].where((item) => item.isNotEmpty).join('\n');
  }

  String _notaPriorizacion({
    required String fallback,
    String? criterio,
    DateTime? fechaObjetivo,
  }) {
    final partes = <String>[
      'Priorizado desde Incidencias:',
      (criterio ?? '').trim().isNotEmpty ? criterio!.trim() : fallback,
      if (fechaObjetivo != null)
        'Horizonte de atencion: ${_formatearFecha(fechaObjetivo)}.',
    ];
    return partes.join(' ');
  }

  String _detallePriorizacion(String? criterio, DateTime? fechaObjetivo) {
    final detalleBase = (criterio ?? '').trim().isNotEmpty
        ? 'La mesa transversal priorizo el caso. Criterio: ${criterio!.trim()}.'
        : 'La mesa transversal priorizo el caso para atencion inmediata.';
    if (fechaObjetivo == null) return detalleBase;
    return '$detalleBase Horizonte comun: ${_formatearFecha(fechaObjetivo)}.';
  }

  String _formatearFecha(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return '$dd/$mm/$yyyy';
  }

  IconData _iconoOrigen(String origen) => switch (origen) {
    'Secretaria' => Icons.work_history_outlined,
    'Preceptoria' => Icons.fact_check_outlined,
    'Biblioteca' => Icons.menu_book_outlined,
    _ => Icons.hub_outlined,
  };

  int _pesoSeveridadAlerta(String severidad) {
    switch (severidad) {
      case 'Alta':
        return 3;
      case 'Media':
        return 2;
      default:
        return 1;
    }
  }

  int _pesoTipoAlertaDominante(String tipo) {
    switch (tipo) {
      case 'clausura_final_insuficiente':
        return 23;
      case 'corte_total_insuficiente':
        return 22;
      case 'cierre_extremo_insuficiente':
        return 21;
      case 'respuesta_excepcional_insuficiente':
        return 20;
      case 'contencion_insuficiente':
        return 19;
      case 'reforzamiento_desacople_insuficiente':
        return 18;
      case 'desacople_insuficiente':
        return 17;
      case 'cronificacion_institucional_critica':
        return 16;
      case 'recomposicion_insuficiente':
        return 15;
      case 'recuperacion_insuficiente':
        return 14;
      case 'crisis_sostenida':
        return 13;
      case 'contingencia_insuficiente':
        return 12;
      case 'escalamiento_insuficiente':
        return 11;
      case 'ajuste_plan_inefectivo':
        return 10;
      case 'plan_estabilizacion_inefectivo':
        return 9;
      case 'oscilacion_cronica_cabecera':
        return 8;
      case 'recomendacion_ejecutiva_inestable':
        return 7;
      case 'baja_conversion_operativa':
        return 6;
      case 'deterioro_conversion_temporal':
        return 5;
      case 'deterioro_presion_temporal':
        return 4;
      case 'intervencion_roja':
        return 3;
      case 'devoluciones_recurrentes':
        return 2;
      case 'presion_documental_elevada':
        return 1;
      default:
        return 0;
    }
  }

  int _extraerCantidadCasos(String? detalle) {
    final match = RegExp(r'(\d+) casos').firstMatch(detalle ?? '');
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  bool _esAccionMasiva(String accion) {
    return const {
      'priorizacion_masiva',
      'derivacion_masiva',
      'devolucion_masiva',
      'observacion_masiva',
    }.contains(accion);
  }

  int _porcentajeConversion(
    List<TablaIncidenciasTransversalesHistorialData> rows,
  ) {
    final presets = rows
        .where((row) => row.accion.startsWith('preset_alerta_'))
        .length;
    final acciones = rows
        .where((row) => row.accion.startsWith('accion_sugerida_'))
        .length;
    if (presets == 0) return 100;
    return ((acciones / presets) * 100).round();
  }

  String _lecturaComparativaTemporal({
    required int accionesActuales,
    required int accionesPrevias,
    required int conversionActual,
    required int conversionPrevia,
    required String estadoActividad,
    required String estadoConversion,
  }) {
    if (accionesActuales == 0 && accionesPrevias == 0) {
      return 'La mesa todavia no tiene actividad suficiente para comparar periodos consecutivos.';
    }
    return 'Frente al periodo anterior, la mesa muestra $estadoActividad en acciones masivas y $estadoConversion en conversion operativa ($conversionActual% vs $conversionPrevia%).';
  }

  bool _esEventoCabeceraEjecutiva(String accion) {
    return accion.startsWith('foco_dominante_') ||
        accion.startsWith('accion_rapida_dominante_');
  }

  String? _tipoEventoCabecera(String accion) {
    if (accion.startsWith('foco_dominante_')) {
      return accion.replaceFirst('foco_dominante_', '');
    }
    if (accion.startsWith('accion_rapida_dominante_')) {
      return accion.replaceFirst('accion_rapida_dominante_', '');
    }
    return null;
  }

  String? _tipoDominanteEventosCabecera(
    List<TablaIncidenciasTransversalesHistorialData> rows,
  ) {
    if (rows.isEmpty) return null;
    final conteos = <String, int>{};
    for (final row in rows) {
      final tipo = _tipoEventoCabecera(row.accion);
      if (tipo == null || tipo.isEmpty) continue;
      conteos.update(tipo, (actual) => actual + 1, ifAbsent: () => 1);
    }
    if (conteos.isEmpty) return null;
    final ordenados = conteos.entries.toList(growable: false)
      ..sort((a, b) {
        final porCantidad = b.value.compareTo(a.value);
        if (porCantidad != 0) return porCantidad;
        return _pesoTipoAlertaDominante(b.key).compareTo(
          _pesoTipoAlertaDominante(a.key),
        );
      });
    return ordenados.first.key;
  }

  int _contarCambiosFoco(List<TablaIncidenciasTransversalesHistorialData> rows) {
    String? ultimoTipo;
    var cambios = 0;
    for (final row in rows) {
      final tipo = _tipoEventoCabecera(row.accion);
      if (tipo == null || tipo.isEmpty) continue;
      if (ultimoTipo != null && ultimoTipo != tipo) {
        cambios += 1;
      }
      ultimoTipo = tipo;
    }
    return cambios;
  }

  String _etiquetaTipoAlertaMesa(
    String tipo, {
    String? fallback,
  }) {
    switch (tipo) {
      case 'clausura_final_insuficiente':
        return 'Clausura final insuficiente';
      case 'corte_total_insuficiente':
        return 'Corte total insuficiente';
      case 'cierre_extremo_insuficiente':
        return 'Cierre extremo insuficiente';
      case 'respuesta_excepcional_insuficiente':
        return 'Respuesta excepcional insuficiente';
      case 'contencion_insuficiente':
        return 'Contencion de cronificacion insuficiente';
      case 'reforzamiento_desacople_insuficiente':
        return 'Reforzamiento del desacople insuficiente';
      case 'desacople_insuficiente':
        return 'Desacople de cronificacion insuficiente';
      case 'devoluciones_recurrentes':
        return 'Devoluciones recurrentes';
      case 'presion_documental_elevada':
        return 'Presion documental elevada';
      case 'intervencion_roja':
        return 'Intervencion roja';
      case 'baja_conversion_operativa':
        return 'Baja conversion operativa';
      case 'deterioro_presion_temporal':
        return 'Presion operativa en aumento';
      case 'deterioro_conversion_temporal':
        return 'Conversion operativa en retroceso';
      case 'baja_conversion_recomendacion_dominante':
        return 'Baja conversion de recomendacion dominante';
      case 'deterioro_cabecera_ejecutiva':
        return 'Deterioro de cabecera ejecutiva';
      case 'recomendacion_ejecutiva_inestable':
        return 'Recomendacion ejecutiva inestable';
      case 'oscilacion_cronica_cabecera':
        return 'Oscilacion cronica de cabecera';
      case 'plan_estabilizacion_inefectivo':
        return 'Plan de estabilizacion inefectivo';
      case 'ajuste_plan_inefectivo':
        return 'Ajuste del plan inefectivo';
      case 'escalamiento_insuficiente':
        return 'Escalamiento estrategico insuficiente';
      case 'contingencia_insuficiente':
        return 'Contingencia institucional insuficiente';
      case 'cronificacion_institucional_critica':
        return 'Cronificacion institucional critica';
      case 'recuperacion_insuficiente':
        return 'Recuperacion institucional insuficiente';
      case 'recomposicion_insuficiente':
        return 'Recomposicion estructural insuficiente';
      case 'crisis_sostenida':
        return 'Crisis institucional sostenida';
      case 'sin_alerta':
        return fallback ?? 'Mesa estable';
      default:
        return fallback ?? 'Foco ejecutivo';
    }
  }

  List<String> _modulosPrioritariosParaEstabilizacion(
    List<IncidenciaTransversal> incidencias,
  ) {
    final conteos = <String, int>{};
    for (final item in incidencias.where((item) => item.urgente || item.vencida)) {
      conteos.update(item.origen, (actual) => actual + 1, ifAbsent: () => 1);
    }
    if (conteos.isEmpty) {
      return const ['Mesa transversal'];
    }
    final ordenados = conteos.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    return ordenados.take(2).map((item) => item.key).toList(growable: false);
  }

  String _criterioEstabilizacion(
    String tipoAlerta, {
    required RecomendacionHistoricaMesaIncidencias recomendacionHistorica,
  }) {
    switch (tipoAlerta) {
      case 'oscilacion_cronica_cabecera':
      case 'recomendacion_ejecutiva_inestable':
      case 'baja_conversion_recomendacion_dominante':
      case 'deterioro_cabecera_ejecutiva':
        return 'Durante el proximo periodo, toda decision ejecutiva debe comenzar por incidencias urgentes y vencidas antes de abrir nuevos criterios o escalamientos.';
      case 'presion_documental_elevada':
        return 'Durante el proximo periodo, priorizar resolucion en origen y usar Legajos solo para casos que ya agotaron la respuesta operativa del modulo.';
      case 'devoluciones_recurrentes':
        return 'Durante el proximo periodo, sostener un unico criterio de devolucion y responder cada retorno con una instruccion operativa comun.';
      default:
        return recomendacionHistorica.estadoConsistencia == 'Cambio'
            ? 'Durante el proximo periodo, sostener el foco actual sin rotar nuevamente de criterio hasta medir su efecto.'
            : 'Sostener un unico criterio ejecutivo breve y medible durante el proximo periodo de trabajo.';
    }
  }

  List<String> _accionesPlanEstabilizacion(
    String tipoAlerta,
    List<String> modulosPrioritarios,
  ) {
    final modulo = modulosPrioritarios.first;
    switch (tipoAlerta) {
      case 'oscilacion_cronica_cabecera':
      case 'recomendacion_ejecutiva_inestable':
        return [
          'Priorizar primero los casos urgentes visibles de $modulo.',
          'Evitar cambiar el foco ejecutivo durante los proximos dias salvo nueva alerta critica.',
          'Revisar la conversion de la cabecera al cierre del periodo.',
        ];
      case 'presion_documental_elevada':
        return [
          'Revisar en $modulo que casos realmente requieren Legajos.',
          'Reducir derivaciones nuevas hasta normalizar la carga documental.',
          'Cerrar en origen los casos que ya tienen respuesta operativa suficiente.',
        ];
      default:
        return [
          'Ordenar la revision diaria por urgencia y vencimiento.',
          'Aplicar el mismo criterio ejecutivo sobre ${modulosPrioritarios.join(' y ')}.',
          'Medir si el foco elegido mejora la conversion de acciones rapidas.',
        ];
    }
  }

  Future<void> _registrarHistorial({
    required IncidenciaTransversal item,
    required String accion,
    String? estadoDocumental,
    String? detalle,
  }) async {
    await _db.into(_db.tablaIncidenciasTransversalesHistorial).insert(
      TablaIncidenciasTransversalesHistorialCompanion.insert(
        origen: item.origen,
        referencia: item.referencia,
        accion: accion,
        estadoOperativo: Value(item.estadoOperativo),
        estadoDocumental: Value(estadoDocumental ?? item.estadoDocumental),
        detalle: Value(detalle),
      ),
    );
  }
}
