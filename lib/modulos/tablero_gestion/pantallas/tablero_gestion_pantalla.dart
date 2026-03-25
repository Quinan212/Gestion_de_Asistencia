import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/tablero_gestion/modelos/responsable_gestion.dart';
import 'package:gestion_de_asistencias/modulos/tablero_gestion/modelos/tablero_gestion_item.dart';

class TableroGestionPantalla extends StatefulWidget {
  const TableroGestionPantalla({super.key});

  @override
  State<TableroGestionPantalla> createState() => _TableroGestionPantallaState();
}

class _TableroGestionPantallaState extends State<TableroGestionPantalla> {
  int _refreshToken = 0;
  _FiltroSeguimientoEstado _filtroSeguimiento = _FiltroSeguimientoEstado.todos;
  String? _responsableFiltro;
  String? _areaResponsableFiltro;
  PeriodoProductividadGestion _periodoProductividad =
      PeriodoProductividadGestion.mensual;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ContextoInstitucional>(
      valueListenable: Proveedores.contextoInstitucional,
      builder: (context, contexto, _) {
        return FutureBuilder<TableroGestionItem>(
          key: ValueKey(
            '${contexto.rol.name}-${contexto.nivel.name}-${contexto.dependencia.name}-${_periodoProductividad.name}-$_refreshToken',
          ),
          future: Proveedores.tableroGestionRepositorio.cargar(
            contexto,
            periodoProductividad: _periodoProductividad,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _EstadoGestion(
                icono: Icons.error_outline,
                titulo: 'No se pudo cargar el tablero directivo',
                descripcion: '${snapshot.error}',
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const _EstadoGestion(
                icono: Icons.insights_outlined,
                titulo: 'Sin datos para gestionar',
                descripcion:
                    'Todavia no hay informacion suficiente para el tablero ejecutivo.',
              );
            }

            final seguimientosFiltrados = _filtrarSeguimientos(
              data.seguimientos,
            );
            final responsables = data.seguimientos
                .map((e) => e.responsable.trim())
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: EstilosAplicacion.decoracionHeroPanel(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _SelloGestion(
                                icono: contexto.rol.icono,
                                etiqueta: contexto.rol.etiqueta,
                              ),
                              _SelloGestion(
                                icono: Icons.location_city_outlined,
                                etiqueta: contexto.nivel.etiqueta,
                              ),
                              const _SelloGestion(
                                icono: Icons.insights_outlined,
                                etiqueta: 'Tablero ejecutivo',
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Gestion institucional',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Text(
                              _descripcionPara(contexto),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    height: 1.45,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: data.indicadores
                                .map(
                                  (item) => _TarjetaIndicadorGestion(
                                    item: item,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _bloqueSemaforos(context, data.semaforos),
                  const SizedBox(height: 18),
                  _bloqueProductividad(context, data.productividad),
                  const SizedBox(height: 18),
                  _bloqueEscalamientos(context, data.escalamientos),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final doble = constraints.maxWidth >= 1120;
                      if (!doble) {
                        return Column(
                          children: [
                            _bloqueAlertas(context, data.alertas),
                            const SizedBox(height: 18),
                            _bloqueHitos(context, data.hitos),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _bloqueAlertas(context, data.alertas)),
                          const SizedBox(width: 18),
                          Expanded(child: _bloqueHitos(context, data.hitos)),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _bloqueSeguimientos(
                    context,
                    seguimientosFiltrados,
                    responsables,
                  ),
                  const SizedBox(height: 18),
                  _bloqueResponsables(context, contexto),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _bloqueAlertas(BuildContext context, List<AlertaGestion> alertas) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas institucionales',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Desvios operativos que conviene seguir desde direccion o rectorado.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            if (alertas.isEmpty)
              const _EstadoGestion(
                icono: Icons.verified_outlined,
                titulo: 'Sin alertas relevantes',
                descripcion:
                    'El tablero no detecta riesgos inmediatos para este perfil.',
              )
            else
              ...alertas.map(
                (alerta) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaAlertaGestion(
                    alerta: alerta,
                    onVerDetalle: () => _verDetalleAlerta(alerta),
                    onVerHistorial: () =>
                        _verHistorialAlerta(alerta.clave, alerta.titulo),
                    onDerivar: () => _derivarAlerta(alerta),
                    onAplicarPlan: (alerta.accionSugerida ?? '').trim().isEmpty
                        ? null
                        : () => _derivarAlerta(alerta, aplicarPlanSugerido: true),
                    onAtender: () => _atenderAlerta(alerta.clave),
                    onPosponer: () => _posponerAlerta(alerta.clave),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueEscalamientos(
    BuildContext context,
    List<SeguimientoGestion> escalamientos,
  ) {
    final vencidos = escalamientos.where((item) => item.estaVencido).length;
    final reabiertos = escalamientos
        .where((item) => item.estado == 'reabierta')
        .length;
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bandeja institucional de escalamiento',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Casos que ya requieren intervencion ejecutiva por vencimiento operativo o reapertura del circuito de seguimiento.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipUrgenciaSeguimiento(
                  urgencia: vencidos > 0 ? 'Vencida' : 'Planificada',
                  texto: '$vencidos vencidas',
                ),
                _ChipUrgenciaSeguimiento(
                  urgencia: reabiertos > 0 ? 'Alta' : 'Media',
                  texto: '$reabiertos reabiertas',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (escalamientos.isEmpty)
              const _EstadoGestion(
                icono: Icons.verified_outlined,
                titulo: 'Sin escalamiento pendiente',
                descripcion:
                    'La bandeja ejecutiva no registra casos vencidos o reabiertos en este momento.',
              )
            else
              ...escalamientos.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaEscalamientoGestion(
                    item: item,
                    onVerDetalle: () => _verDetalleSeguimiento(item),
                    onVerHistorial: () =>
                        _verHistorialAlerta(item.clave, item.titulo),
                    onReasignar: () => _reasignarSeguimiento(item),
                    onRegistrarAccion: () => _registrarAccionSeguimiento(item),
                    onReplanificar: item.tienePlanMejoraCorrectiva &&
                            item.estado != 'resuelta'
                        ? () => _replanificarPlanMejora(item)
                        : null,
                    onResolver: () => _cerrarEjecutivamente(item),
                    onReabrir: null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueProductividad(
    BuildContext context,
    ProductividadGestion productividad,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productividad institucional',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PeriodoProductividadGestion.values
                  .map(
                    (periodo) => ChoiceChip(
                      label: Text(periodo.etiqueta),
                      selected: productividad.periodo == periodo,
                      onSelected: (selected) {
                        if (!selected || _periodoProductividad == periodo) {
                          return;
                        }
                        setState(() => _periodoProductividad = periodo);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(
              'Lectura operativa de cierres, reaperturas y tiempos de resolucion de los ultimos ${productividad.periodo.etiqueta}.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TarjetaIndicadorProductividad(
                  titulo: 'Cierres ejecutivos',
                  valor: '${productividad.cierresEjecutivos}',
                  descripcion: 'Casos escalados cerrados con constancia formal.',
                  icono: Icons.assignment_turned_in_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Resoluciones ${productividad.periodo.etiqueta}',
                  valor: '${productividad.resoluciones}',
                  descripcion: 'Cierres totales registrados en el periodo.',
                  icono: Icons.task_alt_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Reaperturas ${productividad.periodo.etiqueta}',
                  valor: '${productividad.reaberturas}',
                  descripcion: 'Casos que volvieron a entrar en gestion.',
                  icono: Icons.restart_alt_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Promedio resolucion',
                  valor:
                      '${productividad.promedioHorasResolucion.toStringAsFixed(1)} h',
                  descripcion: 'Tiempo medio entre apertura operativa y cierre.',
                  icono: Icons.timelapse_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes correctivos activos',
                  valor: '${productividad.planesCorrectivosActivos}',
                  descripcion:
                      'Seguimientos abiertos que nacieron desde alertas de calidad.',
                  icono: Icons.playlist_add_check_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes resueltos',
                  valor: '${productividad.planesCorrectivosResueltos}',
                  descripcion:
                      'Planes correctivos cerrados dentro del periodo activo.',
                  icono: Icons.rule_folder_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes reabiertos',
                  valor: '${productividad.planesCorrectivosReabiertos}',
                  descripcion:
                      'Planes correctivos que necesitaron volver a seguimiento.',
                  icono: Icons.assignment_late_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Efectividad de planes correctivos',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TarjetaComparativaPlanCorrectivo(
                  item: productividad.comparativaPlanesCorrectivos.conPlanCorrectivo,
                ),
                _TarjetaComparativaPlanCorrectivo(
                  item: productividad.comparativaPlanesCorrectivos.sinPlanCorrectivo,
                ),
                _ResumenComparativaPlanCorrectivo(
                  item: productividad.comparativaPlanesCorrectivos,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Revisiones correctivas',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TarjetaIndicadorProductividad(
                  titulo: 'Revisiones registradas',
                  valor:
                      '${productividad.resumenRevisionesCorrectivas.revisionesRegistradas}',
                  descripcion:
                      'Entradas de auditoria correctiva registradas en la bitacora del periodo.',
                  icono: Icons.fact_check_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes auditados',
                  valor:
                      '${productividad.resumenRevisionesCorrectivas.planesAuditados}',
                  descripcion:
                      'Planes correctivos que ya cuentan con al menos una revision estructurada.',
                  icono: Icons.rule_folder_outlined,
                ),
                _ResumenRevisionCorrectiva(
                  item: productividad.resumenRevisionesCorrectivas,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (productividad
                    .resumenRevisionesCorrectivas.bloqueosFrecuentes.isNotEmpty ||
                productividad
                    .resumenRevisionesCorrectivas.areasComprometidas.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _TarjetaPatronesRevisionCorrectiva(
                    titulo: 'Bloqueos frecuentes',
                    vacio:
                        'Todavia no hay bloqueos repetidos para resumir en este periodo.',
                    items: productividad
                        .resumenRevisionesCorrectivas.bloqueosFrecuentes,
                  ),
                  _TarjetaPatronesRevisionCorrectiva(
                    titulo: 'Areas comprometidas',
                    vacio:
                        'Todavia no hay areas con concentracion de revisiones correctivas.',
                    items: productividad
                        .resumenRevisionesCorrectivas.areasComprometidas,
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Text(
              'Cumplimiento de planes de mejora',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TarjetaIndicadorProductividad(
                  titulo: 'Replanificaciones',
                  valor:
                      '${productividad.resumenCumplimientoPlanMejora.replanificacionesRegistradas}',
                  descripcion:
                      'Ajustes de fecha objetivo registrados en el periodo activo.',
                  icono: Icons.event_repeat_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes reprogramados',
                  valor:
                      '${productividad.resumenCumplimientoPlanMejora.planesReplanificados}',
                  descripcion:
                      'Planes de mejora que ya necesitaron al menos una reprogramacion.',
                  icono: Icons.edit_calendar_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes vencidos activos',
                  valor:
                      '${productividad.resumenCumplimientoPlanMejora.planesVencidosActivos}',
                  descripcion:
                      'Compromisos que siguen abiertos fuera de su fecha objetivo.',
                  icono: Icons.event_busy_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes cronificados',
                  valor:
                      '${productividad.resumenCumplimientoPlanMejora.planesCronificados}',
                  descripcion:
                      'Planes con dos o mas reprogramaciones dentro del periodo.',
                  icono: Icons.history_toggle_off_outlined,
                ),
                _ResumenCumplimientoPlanMejora(
                  item: productividad.resumenCumplimientoPlanMejora,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (productividad
                    .resumenCumplimientoPlanMejora
                    .responsablesReprogramados
                    .isNotEmpty ||
                productividad
                    .resumenCumplimientoPlanMejora
                    .planesCronificadosDetalle
                    .isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _TarjetaPatronesCumplimientoPlan(
                    titulo: 'Responsables con mas reprogramaciones',
                    vacio:
                        'Todavia no hay reprogramaciones suficientes para construir concentracion por responsable.',
                    items: productividad
                        .resumenCumplimientoPlanMejora
                        .responsablesReprogramados,
                  ),
                  _TarjetaPatronesCumplimientoPlan(
                    titulo: 'Planes cronificados',
                    vacio:
                        'Todavia no hay planes con reprogramaciones repetidas en este periodo.',
                    items: productividad
                        .resumenCumplimientoPlanMejora
                        .planesCronificadosDetalle,
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Text(
              'Efectividad post-replanificacion',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TarjetaIndicadorProductividad(
                  titulo: 'Planes observados',
                  valor:
                      '${productividad.resumenPostReplanificacion.planesObservados}',
                  descripcion:
                      'Planes con al menos una replanificacion dentro del periodo.',
                  icono: Icons.visibility_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Estabilizados',
                  valor:
                      '${productividad.resumenPostReplanificacion.estabilizados}',
                  descripcion:
                      'Planes que no volvieron a reabrirse ni quedaron vencidos tras el ajuste.',
                  icono: Icons.verified_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Reabiertos post-ajuste',
                  valor:
                      '${productividad.resumenPostReplanificacion.reabiertos}',
                  descripcion:
                      'Planes que volvieron a reabrirse despues de reprogramar.',
                  icono: Icons.restart_alt_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Vencidos post-ajuste',
                  valor:
                      '${productividad.resumenPostReplanificacion.vencidosActivos}',
                  descripcion:
                      'Planes que siguen activos y vencidos aun despues de la replanificacion.',
                  icono: Icons.event_busy_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'En seguimiento',
                  valor:
                      '${productividad.resumenPostReplanificacion.enSeguimiento}',
                  descripcion:
                      'Planes reprogramados que siguen abiertos dentro de su nueva ventana.',
                  icono: Icons.pending_actions_outlined,
                ),
                _ResumenPostReplanificacion(
                  item: productividad.resumenPostReplanificacion,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (productividad
                .resumenPostReplanificacion
                .responsablesEnRiesgo
                .isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _TarjetaPatronesCumplimientoPlan(
                    titulo: 'Responsables post-replanificacion en riesgo',
                    vacio:
                        'Todavia no hay concentracion de casos en riesgo despues de reprogramar.',
                    items: productividad
                        .resumenPostReplanificacion
                        .responsablesEnRiesgo,
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Text(
              'Comparativa de riesgo replanificado',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _TarjetaIndicadorProductividad(
                  titulo: 'Presion de cronificacion',
                  valor:
                      '${productividad.comparativaRiesgoReplanificacion.presionCronificacion}',
                  descripcion:
                      'Peso ejecutivo del exceso de reprogramaciones, planes cronificados y vencidos activos.',
                  icono: Icons.history_toggle_off_outlined,
                ),
                _TarjetaIndicadorProductividad(
                  titulo: 'Riesgo post-ajuste',
                  valor:
                      '${productividad.comparativaRiesgoReplanificacion.riesgoPostAjuste}',
                  descripcion:
                      'Peso ejecutivo de reaperturas, vencimientos y seguimiento frágil despues de reprogramar.',
                  icono: Icons.restart_alt_outlined,
                ),
                _ResumenComparativaRiesgoReplanificacion(
                  item: productividad.comparativaRiesgoReplanificacion,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Estrategias correctivas',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (productividad.resumenEstrategiasCorrectivas.estrategias.isEmpty)
              _ResumenVacioEstrategiasCorrectivas(
                lectura: productividad
                    .resumenEstrategiasCorrectivas
                    .lecturaEjecutiva,
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _RecomendacionEstrategiaCorrectiva(
                    item: productividad
                        .resumenEstrategiasCorrectivas
                        .recomendacion,
                  ),
                  _ResumenVacioEstrategiasCorrectivas(
                    lectura: productividad
                        .resumenEstrategiasCorrectivas
                        .lecturaEjecutiva,
                  ),
                  ...productividad.resumenEstrategiasCorrectivas.estrategias.map(
                    (item) => _TarjetaEstrategiaCorrectiva(item: item),
                  ),
                ],
              ),
            if (productividad.resumenEstrategiasCorrectivas.tendencias.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: productividad.resumenEstrategiasCorrectivas.tendencias
                    .map(
                      (item) => _TarjetaTendenciaEstrategiaCorrectiva(item: item),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'Decisiones estrategicas',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (productividad.resumenDecisionesEstrategicas.decisiones.isEmpty)
              _ResumenVacioDecisionesEstrategicas(
                lectura: productividad
                    .resumenDecisionesEstrategicas
                    .lecturaEjecutiva,
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ResumenVacioDecisionesEstrategicas(
                    lectura: productividad
                        .resumenDecisionesEstrategicas
                        .lecturaEjecutiva,
                  ),
                  ...productividad.resumenDecisionesEstrategicas.decisiones.map(
                    (item) => _TarjetaDecisionEstrategica(item: item),
                  ),
                ],
              ),
            const SizedBox(height: 18),
            Text(
              'Tendencias vs ${productividad.periodo.comparacionEtiqueta}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: productividad.tendencias
                  .map(
                    (item) => _TarjetaTendenciaProductividad(
                      item: item,
                      onVerDetalle: () => _verDetalleTendencia(item),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            Text(
              'Carga por responsable',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (productividad.responsables.isEmpty)
              const _EstadoGestion(
                icono: Icons.insights_outlined,
                titulo: 'Sin productividad registrada',
                descripcion:
                    'Todavia no hay suficiente historial para construir esta lectura.',
              )
            else
              ...productividad.responsables.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FilaProductividadResponsable(
                    item: item,
                    periodo: productividad.periodo,
                  ),
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'Consolidado de cierres ejecutivos',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (productividad.cierresPatrones.isEmpty)
              const _EstadoGestion(
                icono: Icons.assignment_turned_in_outlined,
                titulo: 'Sin cierres ejecutivos en el periodo',
                descripcion:
                    'Cuando se documenten cierres ejecutivos, aca vas a ver patrones por plantilla, tipo de caso e impacto.',
              )
            else
              ...productividad.cierresPatrones.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FilaCierreEjecutivoPatron(item: item),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueSemaforos(
    BuildContext context,
    List<SemaforoGestion> semaforos,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semaforo ejecutivo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Lectura rapida del estado operativo de los seguimientos y la productividad institucional para direccion o rectorado.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: semaforos
                  .map((item) => _TarjetaSemaforoGestion(item: item))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueHitos(BuildContext context, List<HitoGestion> hitos) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pulso institucional',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Indicadores complementarios para leer escala, carga operativa y trazabilidad.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            ...hitos.map(
              (hito) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FilaHitoGestion(hito: hito),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueSeguimientos(
    BuildContext context,
    List<SeguimientoGestion> seguimientos,
    List<String> responsables,
  ) {
    final vencidos = seguimientos.where((item) => item.estaVencido).length;
    final altaPrioridad = seguimientos
        .where((item) => item.urgencia == 'Vencida' || item.urgencia == 'Alta')
        .length;
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agenda de seguimiento institucional',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Bandeja de alertas derivadas para no perder continuidad entre lectura ejecutiva y accion concreta.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipUrgenciaSeguimiento(
                  urgencia: vencidos > 0 ? 'Vencida' : 'Planificada',
                  texto: '$vencidos vencidas',
                ),
                _ChipUrgenciaSeguimiento(
                  urgencia: altaPrioridad > 0 ? 'Alta' : 'Media',
                  texto: '$altaPrioridad alta prioridad',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _FiltroSeguimientoEstado.values.map((filtro) {
                return ChoiceChip(
                  label: Text(filtro.etiqueta),
                  selected: _filtroSeguimiento == filtro,
                  onSelected: (_) {
                    setState(() => _filtroSeguimiento = filtro);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _responsableFiltro,
              decoration: const InputDecoration(
                labelText: 'Filtrar por responsable',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...responsables.map(
                  (responsable) => DropdownMenuItem<String?>(
                    value: responsable,
                    child: Text(responsable),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _responsableFiltro = value);
              },
            ),
            const SizedBox(height: 16),
            if (seguimientos.isEmpty)
              const _EstadoGestion(
                icono: Icons.assignment_turned_in_outlined,
                titulo: 'Sin seguimientos derivados',
                descripcion:
                    'Todavia no hay alertas asignadas a responsables para este perfil.',
              )
            else
              ...seguimientos.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaSeguimientoGestion(
                    item: item,
                    onRegistrarAccion: () => _registrarAccionSeguimiento(item),
                    onReplanificar: item.tienePlanMejoraCorrectiva &&
                            item.estado != 'resuelta'
                        ? () => _replanificarPlanMejora(item)
                        : null,
                    onResolver: item.estado == 'resuelta'
                        ? null
                        : () => _resolverSeguimiento(item),
                    onReabrir: item.estado == 'resuelta'
                        ? () => _reabrirSeguimiento(item)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueResponsables(
    BuildContext context,
    ContextoInstitucional contexto,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: FutureBuilder<List<ResponsableGestion>>(
          key: ValueKey(
            'responsables-${contexto.rol.name}-${contexto.nivel.name}-${contexto.dependencia.name}-$_refreshToken',
          ),
          future: Proveedores.responsablesGestionRepositorio
              .listarAdministrables(contexto),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <ResponsableGestion>[];
            final areas = items
                .map((item) => item.area.trim())
                .where((item) => item.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
            final itemsFiltrados = items.where((item) {
              if ((_areaResponsableFiltro ?? '').trim().isEmpty) return true;
              return item.area.trim() == _areaResponsableFiltro;
            }).toList(growable: false);
            final activos = items.where((item) => item.activo).length;
            final alertasActivas = items.fold<int>(
              0,
              (total, item) => total + item.alertasActivas,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Responsables y areas',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nomina operativa para derivar alertas y ordenar el seguimiento institucional del contexto activo.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.42,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _crearResponsable(contexto),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Nuevo responsable'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipSeguimiento(
                      icono: Icons.badge_outlined,
                      texto: '$activos activos',
                    ),
                    _ChipSeguimiento(
                      icono: Icons.apartment_outlined,
                      texto: '${areas.length} areas cargadas',
                    ),
                    _ChipSeguimiento(
                      icono: Icons.assignment_late_outlined,
                      texto: '$alertasActivas alertas activas',
                    ),
                    _ChipSeguimiento(
                      icono: contexto.rol.icono,
                      texto: contexto.rol.etiqueta,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (areas.isNotEmpty)
                  DropdownButtonFormField<String?>(
                    initialValue: _areaResponsableFiltro,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por area',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...areas.map(
                        (area) => DropdownMenuItem<String?>(
                          value: area,
                          child: Text(area),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _areaResponsableFiltro = value);
                    },
                  ),
                if (areas.isNotEmpty) const SizedBox(height: 16),
                if (snapshot.connectionState != ConnectionState.done)
                  const _EstadoGestion(
                    icono: Icons.sync_outlined,
                    titulo: 'Cargando responsables',
                    descripcion:
                        'Se esta preparando la nomina institucional para este contexto.',
                  )
                else if (snapshot.hasError)
                  _EstadoGestion(
                    icono: Icons.error_outline,
                    titulo: 'No se pudo cargar la nomina',
                    descripcion: '${snapshot.error}',
                  )
                else if (items.isEmpty)
                  const _EstadoGestion(
                    icono: Icons.group_off_outlined,
                    titulo: 'Sin responsables configurados',
                    descripcion:
                        'Todavia no hay areas o responsables definidos para este contexto institucional.',
                  )
                else if (itemsFiltrados.isEmpty)
                  const _EstadoGestion(
                    icono: Icons.filter_alt_off_outlined,
                    titulo: 'Sin resultados para el filtro',
                    descripcion:
                        'No hay responsables cargados para el area seleccionada.',
                  )
                else
                  ...itemsFiltrados.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TarjetaResponsableGestion(
                        item: item,
                        onVerAgenda: () => _verAgendaResponsable(contexto, item),
                        onEditar: () => _editarResponsable(item),
                        onCambiarEstado: () => _cambiarEstadoResponsable(item),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _descripcionPara(ContextoInstitucional contexto) {
    switch (contexto.rol) {
      case RolInstitucional.director:
        return 'Direccion necesita una lectura transversal del funcionamiento academico, administrativo y documental para intervenir a tiempo.';
      case RolInstitucional.rector:
        return 'Rectorado requiere una vista de gobierno institucional con foco en riesgos, trazabilidad y capacidad de decision.';
      default:
        return 'Este tablero resume el pulso ejecutivo de la institucion y prioriza alertas accionables.';
    }
  }

  Future<void> _atenderAlerta(String clave) async {
    await Proveedores.tableroGestionRepositorio.atenderAlerta(clave);
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta marcada como atendida.')),
    );
  }

  Future<void> _posponerAlerta(String clave) async {
    await Proveedores.tableroGestionRepositorio.posponerAlerta(
      clave,
      duracion: const Duration(hours: 24),
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alerta pospuesta por 24 horas.')),
    );
  }

  Future<void> _verDetalleAlerta(AlertaGestion alerta) async {
    final contexto = Proveedores.contextoInstitucional.value;
    final detalle = await Proveedores.tableroGestionRepositorio
        .obtenerDetalleAlerta(alerta.clave, contexto);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoDetalleAlerta(detalle: detalle),
    );
  }

  Future<void> _verDetalleSeguimiento(SeguimientoGestion item) async {
    final contexto = Proveedores.contextoInstitucional.value;
    final detalle = await Proveedores.tableroGestionRepositorio
        .obtenerDetalleAlerta(item.clave, contexto);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoDetalleAlerta(detalle: detalle),
    );
  }

  Future<void> _verHistorialAlerta(String clave, String titulo) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoHistorialAlerta(
        clave: clave,
        titulo: titulo,
      ),
    );
  }

  Future<void> _verDetalleTendencia(TendenciaProductividad item) async {
    final contexto = Proveedores.contextoInstitucional.value;
    final detalle = await Proveedores.tableroGestionRepositorio
        .obtenerDetalleTendenciaProductividad(
          item.clave,
          contexto,
          _periodoProductividad,
        );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoDetalleAlerta(detalle: detalle),
    );
  }

  Future<void> _derivarAlerta(
    AlertaGestion alerta, {
    bool aplicarPlanSugerido = false,
  }) async {
    final resultado = await showDialog<_DerivacionResultado>(
      context: context,
      builder: (context) => _DialogoDerivacionAlerta(
        alerta: alerta,
        contexto: Proveedores.contextoInstitucional.value,
        aplicarPlanSugerido: aplicarPlanSugerido,
      ),
    );
    if (resultado == null) return;
    await Proveedores.tableroGestionRepositorio.derivarAlerta(
      alerta.clave,
      derivadaA: resultado.responsable,
      comentario: resultado.comentario,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alerta derivada a ${resultado.responsable}.'),
      ),
    );
  }

  Future<void> _resolverSeguimiento(SeguimientoGestion item) async {
    await Proveedores.tableroGestionRepositorio.resolverAlerta(
      item.clave,
      derivadaA: item.responsable,
      comentario: item.comentario,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seguimiento marcado como resuelto.')),
    );
  }

  Future<void> _reabrirSeguimiento(SeguimientoGestion item) async {
    await Proveedores.tableroGestionRepositorio.reabrirAlerta(
      item.clave,
      derivadaA: item.responsable,
      comentario: item.comentario,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seguimiento reabierto.')),
    );
  }

  Future<void> _registrarAccionSeguimiento(SeguimientoGestion item) async {
    final resultado = await showDialog<_AccionSeguimientoResultado>(
      context: context,
      builder: (context) => _DialogoAccionSeguimiento(
        seguimiento: item,
      ),
    );
    if (resultado == null) return;
    await Proveedores.tableroGestionRepositorio.registrarAccionSeguimiento(
      item.clave,
      accion: resultado.accion,
      comentario: resultado.comentario,
      derivadaA: item.responsable,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultado.mensajeConfirmacion)),
    );
  }

  Future<void> _replanificarPlanMejora(SeguimientoGestion item) async {
    final resultado = await showDialog<_ReplanificacionPlanResultado>(
      context: context,
      builder: (context) => _DialogoReplanificacionPlanMejora(
        seguimiento: item,
      ),
    );
    if (resultado == null) return;
    await Proveedores.tableroGestionRepositorio.registrarAccionSeguimiento(
      item.clave,
      accion: 'replanificacion_mejora',
      comentario: resultado.comentario,
      derivadaA: item.responsable,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan de mejora replanificado y registrado.'),
      ),
    );
  }

  Future<void> _reasignarSeguimiento(SeguimientoGestion item) async {
    final contexto = Proveedores.contextoInstitucional.value;
    final resultado = await showDialog<_ReasignacionSeguimientoResultado>(
      context: context,
      builder: (context) => _DialogoReasignacionSeguimiento(
        contexto: contexto,
        seguimiento: item,
      ),
    );
    if (resultado == null) return;

    await Proveedores.tableroGestionRepositorio.reasignarSeguimiento(
      item.clave,
      derivadaA: resultado.responsable,
      comentario: resultado.comentario,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Caso reasignado a ${resultado.responsable}.'),
      ),
    );
  }

  Future<void> _cerrarEjecutivamente(SeguimientoGestion item) async {
    final resultado = await showDialog<_CierreEjecutivoResultado>(
      context: context,
      builder: (context) => _DialogoCierreEjecutivo(
        seguimiento: item,
      ),
    );
    if (resultado == null) return;

    await Proveedores.tableroGestionRepositorio.cerrarSeguimientoEjecutivo(
      item.clave,
      derivadaA: item.responsable,
      conclusion: resultado.conclusion,
      decision: resultado.decision,
      proximoPaso: resultado.proximoPaso,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cierre ejecutivo registrado para el caso escalado.'),
      ),
    );
  }

  Future<void> _crearResponsable(ContextoInstitucional contexto) async {
    final areasDisponibles = await Proveedores.responsablesGestionRepositorio
        .listarAreasDisponibles(contexto);
    if (!mounted) return;
    final resultado = await showDialog<ResponsableGestionBorrador>(
      context: context,
      builder: (context) => _DialogoResponsableGestion(
        titulo: 'Nuevo responsable',
        borrador: ResponsableGestionBorrador.desdeContexto(contexto),
        areasDisponibles: areasDisponibles,
      ),
    );
    if (resultado == null) return;
    await Proveedores.responsablesGestionRepositorio.guardarResponsable(
      resultado,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${resultado.nombre} fue incorporado a la nomina.')),
    );
  }

  Future<void> _editarResponsable(ResponsableGestion item) async {
    final borradorBase = ResponsableGestionBorrador.desdeResponsable(item);
    final contexto = ContextoInstitucional(
      rol: borradorBase.rol,
      nivel: borradorBase.nivel,
      dependencia: borradorBase.dependencia,
    );
    final areasDisponibles = await Proveedores.responsablesGestionRepositorio
        .listarAreasDisponibles(contexto);
    if (!mounted) return;
    final resultado = await showDialog<ResponsableGestionBorrador>(
      context: context,
      builder: (context) => _DialogoResponsableGestion(
        titulo: 'Editar responsable',
        borrador: borradorBase,
        areasDisponibles: areasDisponibles,
      ),
    );
    if (resultado == null) return;
    await Proveedores.responsablesGestionRepositorio.guardarResponsable(
      resultado,
    );
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${resultado.nombre} fue actualizado.')),
    );
  }

  Future<void> _cambiarEstadoResponsable(ResponsableGestion item) async {
    if (item.activo) {
      await Proveedores.responsablesGestionRepositorio.desactivarResponsable(
        item.id,
      );
    } else {
      await Proveedores.responsablesGestionRepositorio.reactivarResponsable(
        item.id,
      );
    }
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.activo
              ? '${item.nombre} fue desactivado.'
              : '${item.nombre} fue reactivado.',
        ),
      ),
    );
  }

  Future<void> _verAgendaResponsable(
    ContextoInstitucional contexto,
    ResponsableGestion item,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoAgendaResponsable(
        contexto: contexto,
        responsable: item,
        onActualizado: () {
          if (!mounted) return;
          setState(() => _refreshToken++);
        },
      ),
    );
  }

  List<SeguimientoGestion> _filtrarSeguimientos(
    List<SeguimientoGestion> items,
  ) {
    return items.where((item) {
      if (_filtroSeguimiento != _FiltroSeguimientoEstado.todos &&
          item.estado != _filtroSeguimiento.valorEstado) {
        return false;
      }
      if ((_responsableFiltro ?? '').trim().isNotEmpty &&
          item.responsable.trim() != _responsableFiltro) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }
}

enum _FiltroSeguimientoEstado { todos, derivada, resuelta, reabierta }

extension on _FiltroSeguimientoEstado {
  String get etiqueta => switch (this) {
    _FiltroSeguimientoEstado.todos => 'Todos',
    _FiltroSeguimientoEstado.derivada => 'Derivadas',
    _FiltroSeguimientoEstado.resuelta => 'Resueltas',
    _FiltroSeguimientoEstado.reabierta => 'Reabiertas',
  };

  String? get valorEstado => switch (this) {
    _FiltroSeguimientoEstado.todos => null,
    _FiltroSeguimientoEstado.derivada => 'derivada',
    _FiltroSeguimientoEstado.resuelta => 'resuelta',
    _FiltroSeguimientoEstado.reabierta => 'reabierta',
  };
}

class _SelloGestion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloGestion({required this.icono, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: cs.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            etiqueta,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaIndicadorGestion extends StatelessWidget {
  final IndicadorGestion item;

  const _TarjetaIndicadorGestion({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.76),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icono, size: 20, color: cs.primary),
          ),
          const SizedBox(height: 12),
          Text(
            item.valor,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.descripcion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSemaforoGestion extends StatelessWidget {
  final SemaforoGestion item;

  const _TarjetaSemaforoGestion({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto) = switch (item.estado) {
      'Rojo' => (
        const Color(0xFFFEE4E2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
      ),
      'Amarillo' => (
        const Color(0xFFFEF3C7),
        const Color(0xFFFCD34D),
        const Color(0xFF92400E),
      ),
      'Verde' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 260),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.valor,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.estado,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.descripcion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto.withValues(alpha: 0.9),
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaIndicadorProductividad extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const _TarjetaIndicadorProductividad({
    required this.titulo,
    required this.valor,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: cs.primary),
          const SizedBox(height: 12),
          Text(
            valor,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaComparativaPlanCorrectivo extends StatelessWidget {
  final SegmentoEfectividadPlanCorrectivo item;

  const _TarjetaComparativaPlanCorrectivo({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 290),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.etiqueta,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.task_alt_outlined,
                texto: '${item.casosResueltos} cierres',
              ),
              _ChipSeguimiento(
                icono: Icons.restart_alt_outlined,
                texto:
                    '${item.tasaReapertura.toStringAsFixed(1)}% reapertura',
              ),
              _ChipSeguimiento(
                icono: Icons.timelapse_outlined,
                texto:
                    '${item.promedioHorasResolucion.toStringAsFixed(1)} h promedio',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${item.reaperturas} reaperturas sobre ${item.casosResueltos} cierres observados.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.descripcion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenComparativaPlanCorrectivo extends StatelessWidget {
  final ComparativaPlanCorrectivo item;

  const _ResumenComparativaPlanCorrectivo({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.estado) {
      'Favorable' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
        Icons.verified_outlined,
      ),
      'Atencion' => (
        const Color(0xFFFFF3F2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.warning_amber_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.balance_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lectura ejecutiva',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.estado,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenRevisionCorrectiva extends StatelessWidget {
  final ResumenRevisionCorrectiva item;

  const _ResumenRevisionCorrectiva({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lectura de auditoria correctiva',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenCumplimientoPlanMejora extends StatelessWidget {
  final ResumenCumplimientoPlanMejora item;

  const _ResumenCumplimientoPlanMejora({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.planesVencidosActivos) {
      > 0 => (
        const Color(0xFFFFF3F2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.event_busy_outlined,
      ),
      _ when item.planesCronificados > 0 => (
        const Color(0xFFFFFAEB),
        const Color(0xFFFEC84B),
        const Color(0xFFB54708),
        Icons.history_toggle_off_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.event_available_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lectura de cumplimiento',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenPostReplanificacion extends StatelessWidget {
  final ResumenPostReplanificacion item;

  const _ResumenPostReplanificacion({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.estado) {
      'Atencion' => (
        const Color(0xFFFFF3F2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.warning_amber_outlined,
      ),
      'Favorable' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
        Icons.verified_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.balance_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lectura post-replanificacion',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.estado,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenComparativaRiesgoReplanificacion extends StatelessWidget {
  final ComparativaRiesgoReplanificacion item;

  const _ResumenComparativaRiesgoReplanificacion({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.foco) {
      'Reprogramacion excesiva' => (
        const Color(0xFFFFFAEB),
        const Color(0xFFFEC84B),
        const Color(0xFFB54708),
        Icons.history_toggle_off_outlined,
      ),
      'Reprogramacion inefectiva' => (
        const Color(0xFFFFF3F2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.restart_alt_outlined,
      ),
      'Riesgo mixto' => (
        const Color(0xFFFFF7ED),
        const Color(0xFFFDBA74),
        const Color(0xFF9A3412),
        Icons.balance_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.verified_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Foco prioritario',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.foco,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.accionSugerida,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorTexto.withValues(alpha: 0.92),
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenVacioEstrategiasCorrectivas extends StatelessWidget {
  final String lectura;

  const _ResumenVacioEstrategiasCorrectivas({required this.lectura});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Text(
        lectura,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
          height: 1.42,
        ),
      ),
    );
  }
}

class _ResumenVacioDecisionesEstrategicas extends StatelessWidget {
  final String lectura;

  const _ResumenVacioDecisionesEstrategicas({required this.lectura});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Text(
        lectura,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
          height: 1.42,
        ),
      ),
    );
  }
}

class _RecomendacionEstrategiaCorrectiva extends StatelessWidget {
  final RecomendacionEstrategiaCorrectiva item;

  const _RecomendacionEstrategiaCorrectiva({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.estado) {
      'Promover' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
        Icons.verified_outlined,
      ),
      'Sostener' => (
        const Color(0xFFE0F2FE),
        const Color(0xFF7DD3FC),
        const Color(0xFF075985),
        Icons.balance_outlined,
      ),
      'Revisar' => (
        const Color(0xFFFFF3F2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.rule_folder_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.insights_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Estrategia recomendada',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.estado,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (item.esInestable) ...[
            const SizedBox(height: 6),
            _ChipSeguimiento(
              icono: Icons.warning_amber_outlined,
              texto: 'Recomendacion inestable',
            ),
          ],
          if (item.estrategia.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.estrategia,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorTexto,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (item.estrategiaAnterior.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Referencia anterior: ${item.estrategiaAnterior}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorTexto.withValues(alpha: 0.92),
                height: 1.38,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.accionSugerida,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorTexto.withValues(alpha: 0.92),
              height: 1.42,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaEstrategiaCorrectiva extends StatelessWidget {
  final EstrategiaCorrectivaItem item;

  const _TarjetaEstrategiaCorrectiva({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 320),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.estrategia,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.pending_actions_outlined,
                texto: '${item.activas} activas',
              ),
              _ChipSeguimiento(
                icono: Icons.task_alt_outlined,
                texto: '${item.resueltasPeriodo} resueltas',
              ),
              _ChipSeguimiento(
                icono: Icons.restart_alt_outlined,
                texto: '${item.reabiertasPeriodo} reabiertas',
              ),
              _ChipSeguimiento(
                icono: Icons.event_busy_outlined,
                texto: '${item.vencidasActivas} vencidas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaTendenciaEstrategiaCorrectiva extends StatelessWidget {
  final TendenciaEstrategiaCorrectiva item;

  const _TarjetaTendenciaEstrategiaCorrectiva({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.estado) {
      'Mejora' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
        Icons.trending_up_outlined,
      ),
      'Alerta' => (
        const Color(0xFFFFF3F2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.trending_down_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.trending_flat_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 360),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.estrategia,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.estado,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resueltas ${item.resueltasActual}/${item.resueltasAnterior} | Reabiertas ${item.reabiertasActual}/${item.reabiertasAnterior}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w700,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.lectura,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorTexto.withValues(alpha: 0.92),
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaDecisionEstrategica extends StatelessWidget {
  final DecisionEstrategicaItem item;

  const _TarjetaDecisionEstrategica({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 320),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.decision,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.pending_actions_outlined,
                texto: '${item.activas} activas',
              ),
              _ChipSeguimiento(
                icono: Icons.task_alt_outlined,
                texto: '${item.resueltasPeriodo} resueltas',
              ),
              _ChipSeguimiento(
                icono: Icons.restart_alt_outlined,
                texto: '${item.reabiertasPeriodo} reabiertas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaPatronesRevisionCorrectiva extends StatelessWidget {
  final String titulo;
  final String vacio;
  final List<PatronRevisionCorrectiva> items;

  const _TarjetaPatronesRevisionCorrectiva({
    required this.titulo,
    required this.vacio,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 380),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              vacio,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.38,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FilaPatronRevisionCorrectiva(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaPatronesCumplimientoPlan extends StatelessWidget {
  final String titulo;
  final String vacio;
  final List<PatronCumplimientoPlanMejora> items;

  const _TarjetaPatronesCumplimientoPlan({
    required this.titulo,
    required this.vacio,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 380),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              vacio,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.38,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FilaPatronCumplimientoPlan(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilaPatronCumplimientoPlan extends StatelessWidget {
  final PatronCumplimientoPlanMejora item;

  const _FilaPatronCumplimientoPlan({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            '${item.cantidad}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.etiqueta,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitulo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaTendenciaProductividad extends StatelessWidget {
  final TendenciaProductividad item;
  final VoidCallback onVerDetalle;

  const _TarjetaTendenciaProductividad({
    required this.item,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (item.estado) {
      'Mejora' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
        Icons.trending_up_outlined,
      ),
      'Alerta' => (
        const Color(0xFFFEE4E2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.trending_down_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.84),
        cs.onSurfaceVariant,
        Icons.trending_flat_outlined,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: colorTexto),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.variacion,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Actual: ${item.valorActual}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto,
            ),
          ),
          Text(
            'Anterior: ${item.valorAnterior}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorTexto.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.descripcion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorTexto.withValues(alpha: 0.9),
              height: 1.38,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onVerDetalle,
              icon: Icon(Icons.insights_outlined, size: 18, color: colorTexto),
              label: Text(
                'Ver detalle',
                style: TextStyle(color: colorTexto),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaAlertaGestion extends StatelessWidget {
  final AlertaGestion alerta;
  final VoidCallback onVerDetalle;
  final VoidCallback onVerHistorial;
  final VoidCallback onDerivar;
  final VoidCallback? onAplicarPlan;
  final VoidCallback onAtender;
  final VoidCallback onPosponer;

  const _TarjetaAlertaGestion({
    required this.alerta,
    required this.onVerDetalle,
    required this.onVerHistorial,
    required this.onDerivar,
    this.onAplicarPlan,
    required this.onAtender,
    required this.onPosponer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = alerta.severidad == 'Alta'
        ? const Color(0xFFB42318)
        : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(alerta.icono, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alerta.titulo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      alerta.severidad,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alerta.descripcion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.42,
                  ),
                ),
                if ((alerta.accionSugerida ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: EstilosAplicacion.radioSuave,
                      border: Border.all(color: color.withValues(alpha: 0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accion correctiva sugerida',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          alerta.accionSugerida!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.42,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
                if ((alerta.derivadaA ?? '').trim().isNotEmpty ||
                    (alerta.comentario ?? '').trim().isNotEmpty ||
                    (alerta.estadoSeguimiento ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if ((alerta.estadoSeguimiento ?? '').trim().isNotEmpty)
                        _ChipSeguimiento(
                          icono: Icons.flag_outlined,
                          texto: alerta.estadoSeguimiento!,
                        ),
                      if ((alerta.derivadaA ?? '').trim().isNotEmpty)
                        _ChipSeguimiento(
                          icono: Icons.forward_to_inbox_outlined,
                          texto: 'Derivada a ${alerta.derivadaA}',
                        ),
                    ],
                  ),
                  if ((alerta.comentario ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      alerta.comentario!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: onVerDetalle,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver detalle'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onVerHistorial,
                      icon: const Icon(Icons.history_outlined),
                      label: const Text('Historial'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDerivar,
                      icon: const Icon(Icons.assignment_ind_outlined),
                      label: const Text('Derivar'),
                    ),
                    if (onAplicarPlan != null)
                      TextButton.icon(
                        onPressed: onAplicarPlan,
                        icon: const Icon(Icons.playlist_add_check_outlined),
                        label: const Text('Aplicar plan'),
                      ),
                    TextButton.icon(
                      onPressed: onAtender,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Atender'),
                    ),
                    TextButton.icon(
                      onPressed: onPosponer,
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Posponer 24 h'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaProductividadResponsable extends StatelessWidget {
  final ProductividadResponsable item;
  final PeriodoProductividadGestion periodo;

  const _FilaProductividadResponsable({
    required this.item,
    required this.periodo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.responsable,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.assignment_late_outlined,
                texto: '${item.activos} activos',
              ),
              _ChipSeguimiento(
                icono: Icons.task_alt_outlined,
                texto: '${item.resueltosPeriodo} resueltos ${periodo.etiqueta}',
              ),
              _ChipSeguimiento(
                icono: Icons.restart_alt_outlined,
                texto:
                    '${item.reabiertosPeriodo} reabiertos ${periodo.etiqueta}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaCierreEjecutivoPatron extends StatelessWidget {
  final CierreEjecutivoPatron item;

  const _FilaCierreEjecutivoPatron({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.tipoCaso,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${item.cantidad} cierres',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.auto_awesome_outlined,
                texto: item.plantilla,
              ),
              _ChipImpactoProductividad(
                impacto: item.impacto,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaPatronRevisionCorrectiva extends StatelessWidget {
  final PatronRevisionCorrectiva item;

  const _FilaPatronRevisionCorrectiva({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.etiqueta,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitulo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ChipSeguimiento(
            icono: Icons.analytics_outlined,
            texto: '${item.cantidad}',
          ),
        ],
      ),
    );
  }
}

class _ChipSeguimiento extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ChipSeguimiento({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.78)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipUrgenciaSeguimiento extends StatelessWidget {
  final String urgencia;
  final String texto;

  const _ChipUrgenciaSeguimiento({
    required this.urgencia,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, icono) = switch (urgencia) {
      'Vencida' => (
        const Color(0xFFFEE4E2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
      ),
      'Alta' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFFDBA74),
        const Color(0xFFB45309),
      ),
      'Media' => (
        const Color(0xFFFEF3C7),
        const Color(0xFFFCD34D),
        const Color(0xFF92400E),
      ),
      'Resuelta' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF86EFAC),
        const Color(0xFF166534),
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.78),
        cs.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high_outlined, size: 14, color: icono),
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: icono,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipImpactoProductividad extends StatelessWidget {
  final String impacto;

  const _ChipImpactoProductividad({required this.impacto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (fondo, borde, colorTexto, icono) = switch (impacto) {
      'Critico' => (
        const Color(0xFFFEE4E2),
        const Color(0xFFFDA29B),
        const Color(0xFFB42318),
        Icons.monitor_heart_outlined,
      ),
      'Alto' => (
        const Color(0xFFFFF3E0),
        const Color(0xFFFDBA74),
        const Color(0xFFB45309),
        Icons.trending_down_outlined,
      ),
      'Medio' => (
        const Color(0xFFFEF3C7),
        const Color(0xFFFCD34D),
        const Color(0xFF92400E),
        Icons.insights_outlined,
      ),
      _ => (
        cs.surfaceContainer,
        cs.outlineVariant.withValues(alpha: 0.78),
        cs.onSurfaceVariant,
        Icons.trending_flat_outlined,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: colorTexto),
          const SizedBox(width: 6),
          Text(
            'Impacto $impacto',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorTexto,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

String _fechaObjetivoPlan(SeguimientoGestion item) {
  final fecha = item.fechaObjetivoPlan;
  if (fecha == null) return 'sin fecha';
  final dd = fecha.day.toString().padLeft(2, '0');
  final mm = fecha.month.toString().padLeft(2, '0');
  final yyyy = fecha.year.toString();
  if (item.planMejoraVencido) {
    return '$dd/$mm/$yyyy';
  }
  if (item.planMejoraPorVencer) {
    return 'por vencer $dd/$mm/$yyyy';
  }
  return '$dd/$mm/$yyyy';
}

class _DerivacionResultado {
  final String responsable;
  final String comentario;

  const _DerivacionResultado({
    required this.responsable,
    required this.comentario,
  });
}

class _DialogoDerivacionAlerta extends StatefulWidget {
  final AlertaGestion alerta;
  final ContextoInstitucional contexto;
  final bool aplicarPlanSugerido;

  const _DialogoDerivacionAlerta({
    required this.alerta,
    required this.contexto,
    this.aplicarPlanSugerido = false,
  });

  @override
  State<_DialogoDerivacionAlerta> createState() =>
      _DialogoDerivacionAlertaState();
}

class _DialogoDerivacionAlertaState extends State<_DialogoDerivacionAlerta> {
  late final TextEditingController _responsableCtrl;
  late final TextEditingController _comentarioCtrl;
  late final TextEditingController _compromisoCtrl;
  late final TextEditingController _indicadorCtrl;
  String? _decisionEstrategica;
  int? _responsableSugeridoId;
  bool _sugerenciaAplicada = false;
  DateTime? _fechaObjetivo;

  @override
  void initState() {
    super.initState();
    _responsableCtrl = TextEditingController(text: widget.alerta.derivadaA);
    _comentarioCtrl = TextEditingController(text: widget.alerta.comentario);
    _compromisoCtrl = TextEditingController(text: _compromisoInicial());
    _indicadorCtrl = TextEditingController(text: _indicadorInicial());
    _decisionEstrategica = _decisionEstrategicaInicial();
    if (_usaPlanMejoraCorrectiva) {
      _fechaObjetivo = DateTime.now().add(const Duration(days: 14));
    }
  }

  @override
  void dispose() {
    _responsableCtrl.dispose();
    _comentarioCtrl.dispose();
    _compromisoCtrl.dispose();
    _indicadorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.aplicarPlanSugerido ? 'Aplicar plan sugerido' : 'Derivar alerta',
      ),
      content: SizedBox(
        width: 520,
        child: FutureBuilder<List<ResponsableGestion>>(
          future: Proveedores.responsablesGestionRepositorio.listarParaContexto(
            widget.contexto,
            claveCaso: widget.alerta.clave,
            impactoProductividad: _impactoDesdeTipo(
              widget.alerta.clave.split(':').last,
            ),
          ),
          builder: (context, snapshot) {
            final responsables = snapshot.data ?? const <ResponsableGestion>[];
            final haySugeridos = responsables.isNotEmpty;
            if (!_sugerenciaAplicada &&
                snapshot.connectionState == ConnectionState.done &&
                haySugeridos) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _sugerenciaAplicada) return;
                _aplicarSugerenciaAutomatica(responsables);
              });
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (snapshot.connectionState != ConnectionState.done)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  )
                else if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'No se pudieron cargar responsables sugeridos. Se mantiene la derivacion manual.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        height: 1.4,
                      ),
                    ),
                  )
                else if (haySugeridos) ...[
                  DropdownButtonFormField<int?>(
                    initialValue: _responsableSugeridoId,
                    decoration: const InputDecoration(
                      labelText: 'Responsable sugerido',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Seleccion manual'),
                      ),
                      ...responsables.map(
                        (item) => DropdownMenuItem<int?>(
                          value: item.id,
                          child: Text(item.etiqueta),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _responsableSugeridoId = value);
                      if (value == null) return;
                      ResponsableGestion? seleccionado;
                      for (final item in responsables) {
                        if (item.id == value) {
                          seleccionado = item;
                          break;
                        }
                      }
                      if (seleccionado == null) return;
                      _responsableCtrl.text = seleccionado.nombre;
                      _aplicarComentarioBase(
                        seleccionado.nombre,
                        forzar: widget.aplicarPlanSugerido,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _textoSugerenciaAutomatica(responsables.first),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Todavia no hay responsables institucionales sugeridos para este contexto. Podes derivar manualmente.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _responsableCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Responsable o area destinataria',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _comentarioCtrl,
                  minLines: 3,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Comentario de seguimiento',
                  ),
                ),
                if (_usaPlanMejoraCorrectiva) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _compromisoCtrl,
                    minLines: 2,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Compromiso de mejora',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _indicadorCtrl,
                    minLines: 2,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Indicador de cumplimiento',
                    ),
                  ),
                  if (_usaDecisionEstrategica) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _decisionEstrategica,
                      decoration: const InputDecoration(
                        labelText: 'Decision estrategica',
                      ),
                      items: _opcionesDecisionEstrategica
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        setState(() => _decisionEstrategica = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fechaObjetivo == null
                              ? 'Fecha objetivo pendiente'
                              : 'Fecha objetivo: ${_fechaCorta(_fechaObjetivo!)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _seleccionarFechaObjetivo,
                        icon: const Icon(Icons.event_outlined),
                        label: const Text('Elegir fecha'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  _textoAyudaDialogo(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: Text(
            widget.aplicarPlanSugerido ? 'Aplicar plan' : 'Guardar derivacion',
          ),
        ),
      ],
    );
  }

  void _confirmar() {
    final responsable = _responsableCtrl.text.trim();
    if (responsable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica un responsable para derivar.')),
      );
      return;
    }
    if (_usaPlanMejoraCorrectiva) {
      if (_compromisoCtrl.text.trim().isEmpty ||
          _indicadorCtrl.text.trim().isEmpty ||
          (_usaDecisionEstrategica &&
              (_decisionEstrategica ?? '').trim().isEmpty) ||
          _fechaObjetivo == null) {
        final mensaje = _usaDecisionEstrategica
            ? 'Completa compromiso, indicador, decision estrategica y fecha objetivo para aplicar el plan de mejora.'
            : 'Completa compromiso, indicador y fecha objetivo para aplicar el plan de mejora.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensaje)));
        return;
      }
    }
    Navigator.of(context).pop(
      _DerivacionResultado(
        responsable: responsable,
        comentario: _comentarioFinal(),
      ),
    );
  }

  void _aplicarSugerenciaAutomatica(List<ResponsableGestion> responsables) {
    _sugerenciaAplicada = true;
    if (_responsableCtrl.text.trim().isNotEmpty) return;
    final sugerido = responsables.first;
    setState(() => _responsableSugeridoId = sugerido.id);
    _responsableCtrl.text = sugerido.nombre;
    _aplicarComentarioBase(
      sugerido.nombre,
      forzar: widget.aplicarPlanSugerido,
    );
  }

  String _textoSugerenciaAutomatica(ResponsableGestion sugerido) {
    final tipo = widget.alerta.clave.split(':').last;
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para validar si la estrategia recomendada sigue siendo confiable o si hace falta redefinir el patron institucional.';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para revisar una estrategia que empeora frente al periodo anterior y decidir si debe reforzarse o reemplazarse.';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para revisar una estrategia correctiva que esta acumulando riesgo y decidir si conviene reforzarla o cambiarla.';
    }
    if (tipo.startsWith('foco_replanificacion_excesiva_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para recortar reprogramaciones repetidas, redefinir compromisos y ordenar una cartera de planes que se sobredimensiono.';
    }
    if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para auditar por que las replanificaciones no estabilizan los casos y corregir el control posterior.';
    }
    if (tipo.startsWith('post_replanificacion_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para revisar por que los planes reprogramados siguen reabriendo o vencidos despues del ajuste.';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para recortar reprogramaciones repetidas y redefinir compromisos que se estan cronificando.';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para intervenir sobre bloqueos correctivos recurrentes y ordenar una respuesta comun.';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para revisar el circuito de planes correctivos y su desempeno operativo.';
    }
    if (tipo.startsWith('calidad_cierre_')) {
      return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para reforzar criterios de cierre institucional y seguimiento correctivo.';
    }
    return 'Sugerencia automatica: ${sugerido.nombre} (${sugerido.area}) para un caso con impacto ${_impactoDesdeTipo(tipo)}.';
  }

  String _impactoDesdeTipo(String tipo) {
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Critico';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Critico';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Critico';
    }
    if (tipo.startsWith('foco_replanificacion_')) {
      return 'Critico';
    }
    if (tipo.startsWith('post_replanificacion_')) {
      return 'Critico';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Critico';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Critico';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Critico';
    }
    if (tipo.startsWith('calidad_cierre_critico_concentrado_')) {
      return 'Critico';
    }
    if (tipo.startsWith('calidad_cierre_general_')) {
      return 'Alto';
    }
    if (tipo.startsWith('productividad_')) {
      if (tipo.contains('reaperturas') || tipo.contains('tiempo_resolucion')) {
        return 'Critico';
      }
      return 'Alto';
    }
    switch (tipo) {
      case 'seguimientos_vencidos':
      case 'seguimientos_reabiertos':
        return 'Alto';
      case 'cursos_sin_clase':
      case 'asistencia_en_riesgo':
      case 'legajos_criticos':
        return 'Medio';
      default:
        return 'Bajo';
    }
  }

  void _aplicarComentarioBase(String responsable, {required bool forzar}) {
    if (!forzar && _comentarioCtrl.text.trim().isNotEmpty) return;
    _comentarioCtrl.text = widget.aplicarPlanSugerido
        ? _comentarioPlanSugerido(responsable)
        : _comentarioSugerido(responsable);
  }

  String _comentarioSugerido(String responsable) {
    final tipo = widget.alerta.clave.split(':').last;
    final impacto = _impactoDesdeTipo(tipo);
    final motivo = switch (tipo) {
      _ when tipo.startsWith('recomendacion_estrategica_') =>
        'Intervenir porque la estrategia recomendada no se mantiene estable entre periodos o todavia requiere revision antes de consolidarse como patron institucional.',
      _ when tipo.startsWith('estrategia_deterioro_') =>
        'Intervenir sobre una estrategia correctiva que empeora frente al periodo anterior y revisar si todavia conviene sostenerla como enfoque institucional.',
      _ when tipo.startsWith('estrategia_correctiva_') =>
        'Intervenir sobre una estrategia correctiva que esta acumulando reaperturas, planes vencidos o demasiada carga activa frente a su resultado.',
      _ when tipo.startsWith('foco_replanificacion_excesiva_') =>
        'Intervenir sobre el exceso de reprogramaciones, redefinir compromisos sobredimensionados y recortar planes que se estan cronificando.',
      _ when tipo.startsWith('foco_replanificacion_inefectiva_') =>
        'Intervenir sobre replanificaciones que no logran estabilizar los casos y revisar la calidad del ajuste y del control posterior.',
      _ when tipo.startsWith('post_replanificacion_') =>
        'Intervenir sobre planes reprogramados que no lograron estabilizarse y siguen reabriendo o vencidos despues del ajuste.',
      _ when tipo.startsWith('cronificacion_plan_mejora_') =>
        'Intervenir sobre planes que se reprograman repetidamente, revisar capacidad real de ejecucion y redefinir compromisos cronificados.',
      _ when tipo.startsWith('revision_correctiva_') =>
        'Intervenir sobre bloqueos correctivos que se estan repitiendo y definir una respuesta comun para los planes afectados.',
      _ when tipo.startsWith('efectividad_correctiva_') =>
        'Revisar por que los planes correctivos estan reabriendo o demorando mas que los casos generales del mismo periodo.',
      _ when tipo.startsWith('calidad_cierre_general_') =>
        'Reducir cierres genericos y exigir una conclusion institucional mas especifica para cada tipo de caso.',
      _ when tipo.startsWith('calidad_cierre_critico_concentrado_') =>
        'Intervenir sobre el tipo de caso critico dominante y unificar criterios de respuesta correctiva.',
      'legajos_criticos' =>
        'Regularizar documentacion prioritaria y evitar bloqueo administrativo.',
      'cursos_sin_clase' =>
        'Recuperar trazabilidad academica y revisar continuidad pedagogica.',
      'alumnos_sin_documento' =>
        'Completar legajos estudiantiles para sostener consistencia institucional.',
      'asistencia_en_riesgo' =>
        'Intervenir sobre inasistencias y sostener seguimiento de trayectorias.',
      'seguimientos_vencidos' =>
        'Retomar casos fuera de ventana operativa y evitar nueva escalada.',
      'seguimientos_reabiertos' =>
        'Revisar causas de reapertura y estabilizar el circuito de resolucion.',
      _ when tipo.startsWith('productividad_') =>
        'Corregir desvio de productividad detectado en el periodo activo.',
      _ => 'Dar continuidad institucional al caso y registrar avance concreto.',
    };
    final accion = switch (impacto) {
      'Critico' =>
        'Prioridad critica. Definir accion hoy y reportar avance ejecutivo.',
      'Alto' =>
        'Prioridad alta. Confirmar responsable operativo y proximo hito.',
      'Medio' =>
        'Prioridad media. Ordenar seguimiento y registrar intervencion inicial.',
      _ => 'Prioridad baja. Incorporar el caso a la agenda y monitorear.',
    };
    final proximoPaso = switch (tipo) {
      _ when tipo.startsWith('recomendacion_estrategica_') =>
        'Proximo paso sugerido: revisar la recomendacion actual frente a la referencia anterior, comparar estrategias activas y validar si conviene sostener el cambio o volver a una alternativa mas estable.',
      _ when tipo.startsWith('estrategia_deterioro_') =>
        'Proximo paso sugerido: comparar esa estrategia con las que mejoran, revisar sus ultimos casos y definir si se refuerza, se acota o se reemplaza.',
      _ when tipo.startsWith('estrategia_correctiva_') =>
        'Proximo paso sugerido: auditar esa estrategia, comparar sus resultados con otras activas y decidir si conviene reforzarla, acotarla o reemplazarla.',
      _ when tipo.startsWith('foco_replanificacion_excesiva_') =>
        'Proximo paso sugerido: revisar cartera de planes reprogramados, bajar alcance, confirmar capacidad real y frenar nuevas reprogramaciones innecesarias.',
      _ when tipo.startsWith('foco_replanificacion_inefectiva_') =>
        'Proximo paso sugerido: auditar las ultimas replanificaciones, verificar hitos incumplidos y redefinir control ejecutivo sobre los casos que siguen inestables.',
      _ when tipo.startsWith('post_replanificacion_') =>
        'Proximo paso sugerido: revisar el ultimo ajuste, validar si hubo avance real y redefinir control ejecutivo o cierre del plan si sigue en riesgo.',
      _ when tipo.startsWith('cronificacion_plan_mejora_') =>
        'Proximo paso sugerido: revisar los planes reprogramados, ajustar alcance/fecha objetivo y definir control ejecutivo mas corto.',
      _ when tipo.startsWith('revision_correctiva_') =>
        'Proximo paso sugerido: auditar el bloqueo recurrente, acordar compromiso de mejora y fijar fecha objetivo de seguimiento.',
      _ when tipo.startsWith('efectividad_correctiva_') =>
        'Proximo paso sugerido: relevar responsables, hitos y criterios de cierre de los planes correctivos abiertos.',
      _ when tipo.startsWith('calidad_cierre_general_') =>
        'Proximo paso sugerido: revisar cierres recientes y redefinir plantilla/especificidad antes de nuevos cierres.',
      _ when tipo.startsWith('calidad_cierre_critico_concentrado_') =>
        'Proximo paso sugerido: auditar el caso critico dominante y acordar una respuesta correctiva comun.',
      _ =>
        'Proximo paso sugerido: registrar recepcion, responsable operativo y primer avance verificable.',
    };
    return 'Derivacion sugerida a $responsable.\nMotivo: $motivo\n$accion\n$proximoPaso';
  }

  String _comentarioPlanSugerido(String responsable) {
    final base = _comentarioSugerido(responsable);
    final accion = (widget.alerta.accionSugerida ?? '').trim();
    if (accion.isEmpty) return base;
    return '$base\nPlan correctivo: $accion';
  }

  bool get _usaPlanMejoraCorrectiva {
    if (!widget.aplicarPlanSugerido) return false;
    final tipo = widget.alerta.clave.split(':').last;
    return tipo.startsWith('recomendacion_estrategica_') ||
        tipo.startsWith('estrategia_deterioro_') ||
        tipo.startsWith('estrategia_correctiva_') ||
        tipo.startsWith('foco_replanificacion_') ||
        tipo.startsWith('post_replanificacion_') ||
        tipo.startsWith('cronificacion_plan_mejora_') ||
        tipo.startsWith('revision_correctiva_') ||
        tipo.startsWith('efectividad_correctiva_') ||
        tipo.startsWith('calidad_cierre_');
  }

  bool get _usaDecisionEstrategica {
    if (!_usaPlanMejoraCorrectiva) return false;
    final tipo = widget.alerta.clave.split(':').last;
    return tipo.startsWith('recomendacion_estrategica_') ||
        tipo.startsWith('estrategia_deterioro_') ||
        tipo.startsWith('estrategia_correctiva_') ||
        tipo.startsWith('foco_replanificacion_') ||
        tipo.startsWith('post_replanificacion_') ||
        tipo.startsWith('cronificacion_plan_mejora_') ||
        tipo.startsWith('efectividad_correctiva_');
  }

  String _compromisoInicial() {
    final tipo = widget.alerta.clave.split(':').last;
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Validar si la estrategia recomendada debe consolidarse o si conviene volver a una alternativa mas estable segun la comparativa entre periodos.';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Revisar por que la estrategia empeora frente al periodo anterior, contrastar resultados y redefinir su uso institucional en nuevos planes.';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Auditar la estrategia correctiva observada, contrastar resultados y redefinir hitos o alcance antes de seguir aplicandola a nuevos casos.';
    }
    if (tipo.startsWith('foco_replanificacion_excesiva_')) {
      return 'Reducir reprogramaciones, redefinir compromisos sobredimensionados y ordenar una cartera mas realista de planes de mejora.';
    }
    if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
      return 'Auditar las replanificaciones recientes, corregir hitos y asegurar control posterior hasta estabilizar los casos en riesgo.';
    }
    if (tipo.startsWith('post_replanificacion_')) {
      return 'Verificar si la ultima replanificacion produjo avance real, corregir el circuito si sigue en riesgo y definir una ventana ejecutiva mas corta.';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Redefinir el alcance del compromiso, acortar la ventana de control y estabilizar los planes con reprogramaciones repetidas.';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Acordar respuesta comun para el bloqueo recurrente y revisar responsables/hitos de los planes afectados.';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Reordenar el circuito de planes correctivos con hitos intermedios y responsable de control ejecutivo.';
    }
    if (tipo.startsWith('calidad_cierre_')) {
      return 'Revisar criterios de cierre y aplicar plantilla especifica antes de nuevos cierres ejecutivos.';
    }
    return '';
  }

  String _indicadorInicial() {
    final tipo = widget.alerta.clave.split(':').last;
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Sostener una recomendacion estable entre periodos o justificar con evidencia el cambio de estrategia dominante.';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Mejorar la relacion entre cierres y reaperturas de esta estrategia en el siguiente corte comparativo.';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Reducir reaperturas y vencimientos dentro de la estrategia observada en el siguiente corte de seguimiento.';
    }
    if (tipo.startsWith('foco_replanificacion_excesiva_')) {
      return 'Reducir la cantidad de planes cronificados y la necesidad de nuevas reprogramaciones en el siguiente corte.';
    }
    if (tipo.startsWith('foco_replanificacion_inefectiva_')) {
      return 'Bajar reaperturas y vencimientos posteriores a la replanificacion en los casos bajo auditoria.';
    }
    if (tipo.startsWith('post_replanificacion_')) {
      return 'Reducir reaperturas y vencimientos posteriores a la replanificacion en el siguiente corte de seguimiento.';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Reducir replanificaciones y bajar la cantidad de planes vencidos o cronificados en el siguiente corte.';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Reducir la repeticion del bloqueo principal en las proximas revisiones correctivas.';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Bajar reaperturas y tiempo medio de resolucion en planes correctivos del proximo periodo.';
    }
    if (tipo.startsWith('calidad_cierre_')) {
      return 'Disminuir cierres generales o concentraciones criticas en el siguiente corte de productividad.';
    }
    return '';
  }

  String _textoAyudaDialogo() {
    if (_usaPlanMejoraCorrectiva) {
      if (_usaDecisionEstrategica) {
        return 'La app arma un plan de mejora correctiva editable con compromiso, decision estrategica, fecha objetivo e indicador de cumplimiento.';
      }
      return 'La app arma un plan de mejora correctiva editable con compromiso, fecha objetivo e indicador de cumplimiento.';
    }
    if (widget.aplicarPlanSugerido) {
      return 'La app precarga un plan de accion editable con responsable y comentario correctivo sugeridos.';
    }
    return 'La app propone una justificacion inicial editable segun impacto, tipo de caso y responsable sugerido.';
  }

  String _comentarioFinal() {
    final base = _comentarioCtrl.text.trim();
    if (!_usaPlanMejoraCorrectiva) return base;
    final fecha = _fechaObjetivo == null ? '' : _fechaCorta(_fechaObjetivo!);
    final estrategia = _estrategiaPlanMejora();
    final partes = <String>[
      if (base.isNotEmpty) base,
      'Plan de mejora correctiva:',
      if (estrategia.isNotEmpty) 'Estrategia correctiva: $estrategia',
      if ((_decisionEstrategica ?? '').trim().isNotEmpty)
        'Decision estrategica: ${_decisionEstrategica!.trim()}',
      'Compromiso: ${_compromisoCtrl.text.trim()}',
      'Fecha objetivo: $fecha',
      'Indicador de cumplimiento: ${_indicadorCtrl.text.trim()}',
    ];
    return partes.join('\n');
  }

  String _estrategiaPlanMejora() {
    final tipo = widget.alerta.clave.split(':').last;
    if (tipo.startsWith('foco_replanificacion_excesiva_')) {
      return 'Contencion de alcance';
    }
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Validacion de estrategia dominante';
    }
    if (tipo.startsWith('estrategia_deterioro_')) {
      return 'Revision historica de estrategia';
    }
    if (tipo.startsWith('estrategia_correctiva_')) {
      return 'Auditoria de estrategia';
    }
    if (tipo.startsWith('foco_replanificacion_inefectiva_') ||
        tipo.startsWith('post_replanificacion_')) {
      return 'Auditoria post-ajuste';
    }
    if (tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Saneamiento de cartera';
    }
    if (tipo.startsWith('revision_correctiva_')) {
      return 'Correccion de bloqueo recurrente';
    }
    if (tipo.startsWith('efectividad_correctiva_')) {
      return 'Reordenamiento del circuito';
    }
    if (tipo.startsWith('calidad_cierre_')) {
      return 'Refuerzo de calidad de cierre';
    }
    return 'Mejora correctiva general';
  }

  List<String> get _opcionesDecisionEstrategica => const [
    'Promover',
    'Sostener',
    'Reemplazar',
    'Descartar',
  ];

  String? _decisionEstrategicaInicial() {
    final existente = _extraerCampo(
      widget.alerta.comentario ?? '',
      'Decision estrategica:',
    );
    if (existente.isNotEmpty) return existente;

    final tipo = widget.alerta.clave.split(':').last;
    if (tipo.startsWith('recomendacion_estrategica_')) {
      return 'Sostener';
    }
    if (tipo.startsWith('estrategia_deterioro_') ||
        tipo.startsWith('estrategia_correctiva_') ||
        tipo.startsWith('foco_replanificacion_inefectiva_') ||
        tipo.startsWith('post_replanificacion_') ||
        tipo.startsWith('efectividad_correctiva_')) {
      return 'Reemplazar';
    }
    if (tipo.startsWith('foco_replanificacion_excesiva_') ||
        tipo.startsWith('cronificacion_plan_mejora_')) {
      return 'Descartar';
    }
    if (_usaDecisionEstrategica) {
      return 'Promover';
    }
    return null;
  }

  String _extraerCampo(String comentario, String etiqueta) {
    final lineas = comentario.split('\n');
    for (final linea in lineas) {
      final texto = linea.trim();
      if (!texto.startsWith(etiqueta)) continue;
      return texto.substring(etiqueta.length).trim();
    }
    return '';
  }

  String _fechaCorta(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _seleccionarFechaObjetivo() async {
    final hoy = DateTime.now();
    final inicial = _fechaObjetivo ?? hoy.add(const Duration(days: 14));
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Fecha objetivo del plan',
    );
    if (fecha == null || !mounted) return;
    setState(() => _fechaObjetivo = fecha);
  }
}

class _DialogoDetalleAlerta extends StatelessWidget {
  final DetalleAlertaGestion detalle;

  const _DialogoDetalleAlerta({required this.detalle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(detalle.titulo),
      content: SizedBox(
        width: 760,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detalle.descripcion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: detalle.filas.isEmpty
                  ? const _EstadoGestion(
                      icono: Icons.info_outline,
                      titulo: 'Sin evidencia adicional',
                      descripcion:
                          'No hay registros concretos para mostrar en este momento.',
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: detalle.filas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final fila = detalle.filas[index];
                        return _FilaDetalleAlerta(fila: fila);
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DialogoHistorialAlerta extends StatelessWidget {
  final String clave;
  final String titulo;

  const _DialogoHistorialAlerta({
    required this.clave,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Historial | $titulo'),
      content: SizedBox(
        width: 760,
        child: FutureBuilder<List<HistorialAlertaGestion>>(
          future: Proveedores.tableroGestionRepositorio.obtenerHistorialAlerta(
            clave,
          ),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <HistorialAlertaGestion>[];
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bitacora cronologica de acciones aplicadas sobre la alerta institucional.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.42,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: snapshot.connectionState != ConnectionState.done
                      ? const _EstadoGestion(
                          icono: Icons.sync_outlined,
                          titulo: 'Cargando historial',
                          descripcion:
                              'Se esta reconstruyendo la trazabilidad de la alerta.',
                        )
                      : snapshot.hasError
                      ? _EstadoGestion(
                          icono: Icons.error_outline,
                          titulo: 'No se pudo cargar el historial',
                          descripcion: '${snapshot.error}',
                        )
                      : items.isEmpty
                      ? const _EstadoGestion(
                          icono: Icons.history_toggle_off_outlined,
                          titulo: 'Sin historial registrado',
                          descripcion:
                              'Todavia no se registraron acciones sobre esta alerta.',
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _FilaHistorialAlerta(item: items[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _DialogoAgendaResponsable extends StatefulWidget {
  final ContextoInstitucional contexto;
  final ResponsableGestion responsable;
  final VoidCallback onActualizado;

  const _DialogoAgendaResponsable({
    required this.contexto,
    required this.responsable,
    required this.onActualizado,
  });

  @override
  State<_DialogoAgendaResponsable> createState() =>
      _DialogoAgendaResponsableState();
}

class _DialogoAgendaResponsableState extends State<_DialogoAgendaResponsable> {
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agenda de ${widget.responsable.nombre}'),
      content: SizedBox(
        width: 860,
        child: FutureBuilder<List<SeguimientoGestion>>(
          key: ValueKey(
            '${widget.responsable.id}-${widget.contexto.rol.name}-${widget.contexto.nivel.name}-${widget.contexto.dependencia.name}-$_refreshToken',
          ),
          future: Proveedores.responsablesGestionRepositorio
              .listarAgendaResponsable(
                widget.contexto,
                widget.responsable.nombre,
              ),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <SeguimientoGestion>[];
            final activas = items
                .where((item) => item.estado == 'derivada' || item.estado == 'reabierta')
                .length;
            final resueltas =
                items.where((item) => item.estado == 'resuelta').length;
            final vencidas = items.where((item) => item.estaVencido).length;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seguimientos institucionales asignados al responsable seleccionado dentro del contexto activo.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.42,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipSeguimiento(
                      icono: Icons.apartment_outlined,
                      texto: widget.responsable.area,
                    ),
                    _ChipSeguimiento(
                      icono: Icons.assignment_late_outlined,
                      texto: '$activas activas',
                    ),
                    _ChipSeguimiento(
                      icono: Icons.task_alt_outlined,
                      texto: '$resueltas resueltas',
                    ),
                    _ChipUrgenciaSeguimiento(
                      urgencia: vencidas > 0 ? 'Vencida' : 'Planificada',
                      texto: '$vencidas vencidas',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: snapshot.connectionState != ConnectionState.done
                      ? const _EstadoGestion(
                          icono: Icons.sync_outlined,
                          titulo: 'Cargando agenda operativa',
                          descripcion:
                              'Se estan reuniendo los seguimientos del responsable.',
                        )
                      : snapshot.hasError
                      ? _EstadoGestion(
                          icono: Icons.error_outline,
                          titulo: 'No se pudo cargar la agenda',
                          descripcion: '${snapshot.error}',
                        )
                      : items.isEmpty
                      ? const _EstadoGestion(
                          icono: Icons.assignment_turned_in_outlined,
                          titulo: 'Sin seguimientos para este responsable',
                          descripcion:
                              'Todavia no hay alertas derivadas a este actor institucional.',
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _TarjetaAgendaResponsable(
                              item: item,
                              onVerDetalle: () => _verDetalle(item),
                              onVerHistorial: () =>
                                  _verHistorial(item.clave, item.titulo),
                              onRegistrarAccion: () => _registrarAccion(item),
                              onReplanificar: item.tienePlanMejoraCorrectiva &&
                                      item.estado != 'resuelta'
                                  ? () => _replanificar(item)
                                  : null,
                              onResolver: item.estado == 'resuelta'
                                  ? null
                                  : () => _resolver(item),
                              onReabrir: item.estado == 'resuelta'
                                  ? () => _reabrir(item)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }

  Future<void> _resolver(SeguimientoGestion item) async {
    await Proveedores.tableroGestionRepositorio.resolverAlerta(
      item.clave,
      derivadaA: item.responsable,
      comentario: item.comentario,
    );
    if (!mounted) return;
    widget.onActualizado();
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.titulo} fue marcado como resuelto.')),
    );
  }

  Future<void> _reabrir(SeguimientoGestion item) async {
    await Proveedores.tableroGestionRepositorio.reabrirAlerta(
      item.clave,
      derivadaA: item.responsable,
      comentario: item.comentario,
    );
    if (!mounted) return;
    widget.onActualizado();
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.titulo} fue reabierto.')),
    );
  }

  Future<void> _verDetalle(SeguimientoGestion item) async {
    final detalle = await Proveedores.tableroGestionRepositorio
        .obtenerDetalleAlerta(item.clave, widget.contexto);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoDetalleAlerta(detalle: detalle),
    );
  }

  Future<void> _verHistorial(String clave, String titulo) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoHistorialAlerta(
        clave: clave,
        titulo: titulo,
      ),
    );
  }

  Future<void> _registrarAccion(SeguimientoGestion item) async {
    final resultado = await showDialog<_AccionSeguimientoResultado>(
      context: context,
      builder: (context) => _DialogoAccionSeguimiento(
        seguimiento: item,
      ),
    );
    if (resultado == null) return;
    await Proveedores.tableroGestionRepositorio.registrarAccionSeguimiento(
      item.clave,
      accion: resultado.accion,
      comentario: resultado.comentario,
      derivadaA: item.responsable,
    );
    if (!mounted) return;
    widget.onActualizado();
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultado.mensajeConfirmacion)),
    );
  }

  Future<void> _replanificar(SeguimientoGestion item) async {
    final resultado = await showDialog<_ReplanificacionPlanResultado>(
      context: context,
      builder: (context) => _DialogoReplanificacionPlanMejora(
        seguimiento: item,
      ),
    );
    if (resultado == null) return;
    await Proveedores.tableroGestionRepositorio.registrarAccionSeguimiento(
      item.clave,
      accion: 'replanificacion_mejora',
      comentario: resultado.comentario,
      derivadaA: item.responsable,
    );
    if (!mounted) return;
    widget.onActualizado();
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan de mejora replanificado y registrado.'),
      ),
    );
  }
}

class _FilaDetalleAlerta extends StatelessWidget {
  final DetalleAlertaGestionFila fila;

  const _FilaDetalleAlerta({required this.fila});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fila.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fila.subtitulo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            fila.valor,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaHitoGestion extends StatelessWidget {
  final HitoGestion hito;

  const _FilaHitoGestion({required this.hito});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hito.etiqueta,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hito.ayuda,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            hito.valor,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaResponsableGestion extends StatelessWidget {
  final ResponsableGestion item;
  final VoidCallback onVerAgenda;
  final VoidCallback onEditar;
  final VoidCallback onCambiarEstado;

  const _TarjetaResponsableGestion({
    required this.item,
    required this.onVerAgenda,
    required this.onEditar,
    required this.onCambiarEstado,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color: item.activo
              ? cs.outlineVariant.withValues(alpha: 0.84)
              : cs.outlineVariant.withValues(alpha: 0.44),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nombre,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ChipSeguimiento(
                icono: item.activo
                    ? Icons.verified_user_outlined
                    : Icons.pause_circle_outline,
                texto: item.estadoEtiqueta,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.area,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.apartment_outlined,
                texto: item.area,
              ),
              _ChipSeguimiento(
                icono: Icons.badge_outlined,
                texto: _rolEtiqueta(item.rolDestino),
              ),
              _ChipSeguimiento(
                icono: Icons.school_outlined,
                texto: _nivelEtiqueta(item.nivelDestino),
              ),
              _ChipSeguimiento(
                icono: Icons.account_balance_outlined,
                texto: _dependenciaEtiqueta(item.dependenciaDestino),
              ),
              _ChipSeguimiento(
                icono: Icons.assignment_late_outlined,
                texto: '${item.alertasActivas} activas',
              ),
              _ChipSeguimiento(
                icono: Icons.task_alt_outlined,
                texto: '${item.seguimientosResueltos} resueltas',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onVerAgenda,
                icon: const Icon(Icons.view_list_outlined),
                label: const Text('Ver agenda'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onCambiarEstado,
                icon: Icon(
                  item.activo
                      ? Icons.person_off_outlined
                      : Icons.person_add_alt_1_outlined,
                ),
                label: Text(item.activo ? 'Desactivar' : 'Reactivar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _rolEtiqueta(String valor) {
    for (final item in RolInstitucional.values) {
      if (item.name == valor) return item.etiqueta;
    }
    return valor;
  }

  String _nivelEtiqueta(String valor) {
    for (final item in NivelInstitucional.values) {
      if (item.name == valor) return item.etiqueta;
    }
    return valor;
  }

  String _dependenciaEtiqueta(String valor) {
    for (final item in DependenciaInstitucional.values) {
      if (item.name == valor) return item.etiqueta;
    }
    return valor;
  }
}

class _TarjetaAgendaResponsable extends StatelessWidget {
  final SeguimientoGestion item;
  final VoidCallback onVerDetalle;
  final VoidCallback onVerHistorial;
  final VoidCallback onRegistrarAccion;
  final VoidCallback? onReplanificar;
  final VoidCallback? onResolver;
  final VoidCallback? onReabrir;

  const _TarjetaAgendaResponsable({
    required this.item,
    required this.onVerDetalle,
    required this.onVerHistorial,
    required this.onRegistrarAccion,
    this.onReplanificar,
    this.onResolver,
    this.onReabrir,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ChipSeguimiento(
                icono: Icons.flag_outlined,
                texto: item.estado,
              ),
              const SizedBox(width: 8),
              _ChipImpactoProductividad(
                impacto: item.impactoProductividad,
              ),
              if (item.esPlanCorrectivo)
                const _ChipSeguimiento(
                  icono: Icons.playlist_add_check_outlined,
                  texto: 'Plan correctivo',
                ),
              if (item.tienePlanMejoraCorrectiva)
                _ChipSeguimiento(
                  icono: Icons.assignment_outlined,
                  texto: item.planMejoraVencido
                      ? 'Plan vencido ${_fechaObjetivoPlan(item)}'
                      : 'Plan ${_fechaObjetivoPlan(item)}',
                ),
              if ((item.estrategiaCorrectiva ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.route_outlined,
                  texto: item.estrategiaCorrectiva!,
                ),
              if ((item.decisionEstrategica ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.account_tree_outlined,
                  texto: item.decisionEstrategica!,
                ),
              const SizedBox(width: 8),
              _ChipUrgenciaSeguimiento(
                urgencia: item.urgencia,
                texto: item.urgencia,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _fechaTexto(item.actualizadoEn),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _textoVencimiento(item),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: item.estaVencido ? const Color(0xFFB42318) : cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.comentario.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.comentario,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onVerDetalle,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver detalle'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onVerHistorial,
                icon: const Icon(Icons.history_outlined),
                label: const Text('Historial'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRegistrarAccion,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Registrar accion'),
              ),
              if (onReplanificar != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onReplanificar,
                  icon: const Icon(Icons.event_repeat_outlined),
                  label: const Text('Replanificar'),
                ),
              ],
              if (onResolver != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onResolver,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Resolver'),
                ),
              ],
              if (onReabrir != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onReabrir,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reabrir'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _fechaTexto(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return 'Actualizado $dd/$mm a las $hh:$min';
  }

  String _textoVencimiento(SeguimientoGestion item) {
    final dd = item.venceEn.day.toString().padLeft(2, '0');
    final mm = item.venceEn.month.toString().padLeft(2, '0');
    final hh = item.venceEn.hour.toString().padLeft(2, '0');
    final min = item.venceEn.minute.toString().padLeft(2, '0');
    final prefijo = item.estaVencido ? 'Vencida' : 'Vence';
    return '$prefijo $dd/$mm $hh:$min';
  }
}

class _TarjetaEscalamientoGestion extends StatelessWidget {
  final SeguimientoGestion item;
  final VoidCallback onVerDetalle;
  final VoidCallback onVerHistorial;
  final VoidCallback onReasignar;
  final VoidCallback onRegistrarAccion;
  final VoidCallback? onReplanificar;
  final VoidCallback onResolver;
  final VoidCallback? onReabrir;

  const _TarjetaEscalamientoGestion({
    required this.item,
    required this.onVerDetalle,
    required this.onVerHistorial,
    required this.onReasignar,
    required this.onRegistrarAccion,
    this.onReplanificar,
    required this.onResolver,
    this.onReabrir,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorBorde = item.estaVencido
        ? const Color(0xFFFDA29B)
        : const Color(0xFFFCD34D);
    final colorFondo = item.estaVencido
        ? const Color(0xFFFFF3F2)
        : const Color(0xFFFFFBEB);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: colorBorde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.estaVencido
                      ? const Color(0xFFFEE4E2)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.estaVencido
                      ? Icons.notifications_active_outlined
                      : Icons.restart_alt_outlined,
                  color: item.estaVencido
                      ? const Color(0xFFB42318)
                      : const Color(0xFF92400E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.responsable,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ChipUrgenciaSeguimiento(
                urgencia: item.urgencia,
                texto: item.urgencia,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.flag_outlined,
                texto: item.estado,
              ),
              _ChipImpactoProductividad(
                impacto: item.impactoProductividad,
              ),
              if (item.esPlanCorrectivo)
                const _ChipSeguimiento(
                  icono: Icons.playlist_add_check_outlined,
                  texto: 'Plan correctivo',
                ),
              if (item.tienePlanMejoraCorrectiva)
                _ChipSeguimiento(
                  icono: Icons.assignment_outlined,
                  texto: item.planMejoraVencido
                      ? 'Plan vencido ${_fechaObjetivoPlan(item)}'
                      : 'Plan ${_fechaObjetivoPlan(item)}',
                ),
              if ((item.estrategiaCorrectiva ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.route_outlined,
                  texto: item.estrategiaCorrectiva!,
                ),
              if ((item.decisionEstrategica ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.account_tree_outlined,
                  texto: item.decisionEstrategica!,
                ),
              _ChipSeguimiento(
                icono: Icons.schedule_outlined,
                texto: _textoVencimiento(item),
              ),
            ],
          ),
          if (item.comentario.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.comentario,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onVerDetalle,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver detalle'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onVerHistorial,
                icon: const Icon(Icons.history_outlined),
                label: const Text('Historial'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onReasignar,
                icon: const Icon(Icons.swap_horiz_outlined),
                label: const Text('Reasignar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRegistrarAccion,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Registrar accion'),
              ),
              if (onReplanificar != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onReplanificar,
                  icon: const Icon(Icons.event_repeat_outlined),
                  label: const Text('Replanificar'),
                ),
              ],
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onResolver,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Cerrar caso'),
              ),
              if (onReabrir != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onReabrir,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reabrir'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _textoVencimiento(SeguimientoGestion item) {
    final dd = item.venceEn.day.toString().padLeft(2, '0');
    final mm = item.venceEn.month.toString().padLeft(2, '0');
    final hh = item.venceEn.hour.toString().padLeft(2, '0');
    final min = item.venceEn.minute.toString().padLeft(2, '0');
    final prefijo = item.estaVencido ? 'Vencida' : 'Vence';
    return '$prefijo $dd/$mm $hh:$min';
  }
}

class _FilaHistorialAlerta extends StatelessWidget {
  final HistorialAlertaGestion item;

  const _FilaHistorialAlerta({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _etiquetaAccion(item.accion),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _fechaTexto(item.creadoEn),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if ((item.estadoAnterior ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.undo_outlined,
                  texto: 'Antes: ${item.estadoAnterior}',
                ),
              _ChipSeguimiento(
                icono: Icons.flag_outlined,
                texto: 'Ahora: ${item.estadoNuevo}',
              ),
              if ((item.derivadaA ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.forward_to_inbox_outlined,
                  texto: item.derivadaA!,
                ),
            ],
          ),
          if (item.comentario.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.comentario,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _etiquetaAccion(String accion) {
    switch (accion) {
      case 'cierre_ejecutivo':
        return 'Cierre ejecutivo documentado';
      case 'reasignada':
        return 'Seguimiento reasignado';
      case 'comentario':
        return 'Comentario operativo';
      case 'llamada':
        return 'Llamado registrado';
      case 'reunion':
        return 'Reunion de seguimiento';
      case 'recordatorio':
        return 'Recordatorio operativo';
      case 'revision_correctiva':
        return 'Revision correctiva';
      case 'replanificacion_mejora':
        return 'Plan de mejora replanificado';
      case 'derivada':
        return 'Alerta derivada';
      case 'resuelta':
        return 'Alerta resuelta';
      case 'reabierta':
        return 'Alerta reabierta';
      case 'pospuesta':
        return 'Alerta pospuesta';
      case 'atendida':
        return 'Alerta atendida';
      default:
        return 'Actualizacion de alerta';
    }
  }

  String _fechaTexto(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dd/$mm $hh:$min';
  }
}

class _CierreEjecutivoResultado {
  final String conclusion;
  final String decision;
  final String proximoPaso;

  const _CierreEjecutivoResultado({
    required this.conclusion,
    required this.decision,
    required this.proximoPaso,
  });
}

class _DialogoCierreEjecutivo extends StatefulWidget {
  final SeguimientoGestion seguimiento;

  const _DialogoCierreEjecutivo({required this.seguimiento});

  @override
  State<_DialogoCierreEjecutivo> createState() =>
      _DialogoCierreEjecutivoState();
}

class _DialogoCierreEjecutivoState extends State<_DialogoCierreEjecutivo> {
  late final TextEditingController _conclusionCtrl;
  late final TextEditingController _decisionCtrl;
  late final TextEditingController _proximoPasoCtrl;
  late final _PlantillaCierreEjecutivo _plantillaInicial;

  @override
  void initState() {
    super.initState();
    _plantillaInicial = _plantillaSugerida();
    _conclusionCtrl = TextEditingController(text: _plantillaInicial.conclusion);
    _decisionCtrl = TextEditingController(text: _plantillaInicial.decision);
    _proximoPasoCtrl = TextEditingController(
      text: _plantillaInicial.proximoPaso,
    );
  }

  @override
  void dispose() {
    _conclusionCtrl.dispose();
    _decisionCtrl.dispose();
    _proximoPasoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cerrar caso escalado'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este cierre deja una constancia ejecutiva mas rica que una resolucion comun y queda disponible en la bitacora.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            _ChipSeguimiento(
              icono: Icons.assignment_turned_in_outlined,
              texto: widget.seguimiento.titulo,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipImpactoProductividad(
                  impacto: widget.seguimiento.impactoProductividad,
                ),
                _ChipSeguimiento(
                  icono: Icons.auto_awesome_outlined,
                  texto: _plantillaInicial.etiqueta,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'La app propone una plantilla inicial editable segun tipo de caso e impacto institucional.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _reaplicarPlantilla,
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reaplicar plantilla sugerida'),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _conclusionCtrl,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Conclusion del caso',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _decisionCtrl,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Decision institucional',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _proximoPasoCtrl,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Proximo paso opcional',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Guardar cierre'),
        ),
      ],
    );
  }

  void _reaplicarPlantilla() {
    final plantilla = _plantillaSugerida();
    _conclusionCtrl.text = plantilla.conclusion;
    _decisionCtrl.text = plantilla.decision;
    _proximoPasoCtrl.text = plantilla.proximoPaso;
  }

  _PlantillaCierreEjecutivo _plantillaSugerida() {
    final tipo = widget.seguimiento.clave.split(':').last;
    final impacto = widget.seguimiento.impactoProductividad;

    if (tipo.startsWith('productividad_')) {
      return _PlantillaCierreEjecutivo(
        etiqueta: 'Plantilla de productividad',
        conclusion:
            'Se reviso el desvio de productividad detectado y se definio una respuesta institucional para estabilizar el circuito.',
        decision:
            'Direccion valida el plan correctivo, mantiene monitoreo del indicador y deja trazabilidad del cierre ejecutivo.',
        proximoPaso: impacto == 'Critico'
            ? 'Verificar recuperacion del indicador en la proxima ventana operativa y registrar avance en seguimiento.'
            : 'Monitorear el indicador en el proximo periodo y consolidar evidencia de mejora.',
      );
    }

    switch (tipo) {
      case 'legajos_criticos':
      case 'alumnos_sin_documento':
        return const _PlantillaCierreEjecutivo(
          etiqueta: 'Plantilla documental',
          conclusion:
              'Se normalizo la situacion documental prioritaria y el caso deja de comprometer la trazabilidad administrativa.',
          decision:
              'La institucion da por regularizado el circuito documental y resguarda constancia del cierre.',
          proximoPaso:
              'Controlar la documentacion vinculada en el proximo corte administrativo.',
        );
      case 'cursos_sin_clase':
      case 'asistencia_en_riesgo':
        return const _PlantillaCierreEjecutivo(
          etiqueta: 'Plantilla academica',
          conclusion:
              'Se recupero el seguimiento academico del caso y se definieron acciones para sostener continuidad pedagogica.',
          decision:
              'Direccion valida la intervencion pedagogica y cierra el escalamiento con monitoreo posterior.',
          proximoPaso:
              'Verificar impacto de la medida en la proxima revision academica.',
        );
      case 'seguimientos_vencidos':
      case 'seguimientos_reabiertos':
        return const _PlantillaCierreEjecutivo(
          etiqueta: 'Plantilla ejecutiva',
          conclusion:
              'Se recompuso el circuito de seguimiento y el caso vuelve a una situacion operativa controlada.',
          decision:
              'Rectorado o direccion deja documentada la resolucion y cierra el escalamiento extraordinario.',
          proximoPaso:
              'Supervisar un hito posterior para evitar nueva reapertura del caso.',
        );
      case 'sin_estructura':
        return const _PlantillaCierreEjecutivo(
          etiqueta: 'Plantilla institucional',
          conclusion:
              'Se completo la definicion institucional necesaria para sostener gestion y trazabilidad basica.',
          decision:
              'La institucion valida la configuracion minima y habilita seguimiento operativo normal.',
          proximoPaso:
              'Revisar consistencia de estructura y responsables en el proximo corte de gestion.',
        );
      default:
        return const _PlantillaCierreEjecutivo(
          etiqueta: 'Plantilla general',
          conclusion:
              'Se resolvio el caso escalado y la situacion queda institucionalmente contenida.',
          decision:
              'La institucion documenta el cierre ejecutivo y restablece el seguimiento ordinario.',
          proximoPaso:
              'Registrar verificacion posterior para consolidar el cierre.',
        );
    }
  }

  void _confirmar() {
    final conclusion = _conclusionCtrl.text.trim();
    final decision = _decisionCtrl.text.trim();
    if (conclusion.isEmpty || decision.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá conclusion y decision para cerrar el caso.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      _CierreEjecutivoResultado(
        conclusion: conclusion,
        decision: decision,
        proximoPaso: _proximoPasoCtrl.text.trim(),
      ),
    );
  }
}

class _ReasignacionSeguimientoResultado {
  final String responsable;
  final String comentario;

  const _ReasignacionSeguimientoResultado({
    required this.responsable,
    required this.comentario,
  });
}

class _DialogoReasignacionSeguimiento extends StatefulWidget {
  final ContextoInstitucional contexto;
  final SeguimientoGestion seguimiento;

  const _DialogoReasignacionSeguimiento({
    required this.contexto,
    required this.seguimiento,
  });

  @override
  State<_DialogoReasignacionSeguimiento> createState() =>
      _DialogoReasignacionSeguimientoState();
}

class _DialogoReasignacionSeguimientoState
    extends State<_DialogoReasignacionSeguimiento> {
  static const String _comentarioInicial =
      'Reasignacion ejecutiva del seguimiento escalado.';
  late final TextEditingController _responsableCtrl;
  late final TextEditingController _comentarioCtrl;
  int? _responsableSugeridoId;
  bool _sugerenciaAplicada = false;

  @override
  void initState() {
    super.initState();
    _responsableCtrl = TextEditingController(
      text: widget.seguimiento.responsable,
    );
    _comentarioCtrl = TextEditingController(
      text: _comentarioInicial,
    );
  }

  @override
  void dispose() {
    _responsableCtrl.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reasignar seguimiento escalado'),
      content: SizedBox(
        width: 520,
        child: FutureBuilder<List<ResponsableGestion>>(
          future: Proveedores.responsablesGestionRepositorio.listarParaContexto(
            widget.contexto,
            claveCaso: widget.seguimiento.clave,
            impactoProductividad: widget.seguimiento.impactoProductividad,
            responsableActual: widget.seguimiento.responsable,
          ),
          builder: (context, snapshot) {
            final responsables = snapshot.data ?? const <ResponsableGestion>[];
            if (!_sugerenciaAplicada &&
                snapshot.connectionState == ConnectionState.done &&
                responsables.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted || _sugerenciaAplicada) return;
                _aplicarSugerenciaAutomatica(responsables);
              });
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La reasignacion conserva el estado actual y deja trazabilidad ejecutiva en la bitacora.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                if (snapshot.connectionState != ConnectionState.done)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  )
                else if (responsables.isNotEmpty) ...[
                  Text(
                    'Sugerencia automatica: ${responsables.first.nombre} (${responsables.first.area}) para un caso con impacto ${widget.seguimiento.impactoProductividad}.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    initialValue: _responsableSugeridoId,
                    decoration: const InputDecoration(
                      labelText: 'Responsable sugerido',
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Seleccion manual'),
                      ),
                      ...responsables.map(
                        (item) => DropdownMenuItem<int?>(
                          value: item.id,
                          child: Text(item.etiqueta),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _responsableSugeridoId = value);
                      if (value == null) return;
                      for (final item in responsables) {
                        if (item.id == value) {
                          _responsableCtrl.text = item.nombre;
                          if (_debeReemplazarComentario()) {
                            _comentarioCtrl.text = _comentarioSugerido(
                              item.nombre,
                            );
                          }
                          break;
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _responsableCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo responsable o area',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _comentarioCtrl,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Motivo de la reasignacion',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La app propone una justificacion inicial editable segun impacto, tipo de caso y nuevo responsable.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Reasignar'),
        ),
      ],
    );
  }

  void _aplicarSugerenciaAutomatica(List<ResponsableGestion> responsables) {
    _sugerenciaAplicada = true;
    final sugerido = responsables.first;
    if (sugerido.nombre.trim().toLowerCase() ==
        widget.seguimiento.responsable.trim().toLowerCase()) {
      return;
    }
    setState(() => _responsableSugeridoId = sugerido.id);
    _responsableCtrl.text = sugerido.nombre;
    if (_debeReemplazarComentario()) {
      _comentarioCtrl.text = _comentarioSugerido(sugerido.nombre);
    }
  }

  bool _debeReemplazarComentario() {
    final comentario = _comentarioCtrl.text.trim();
    return comentario.isEmpty || comentario == _comentarioInicial;
  }

  String _comentarioSugerido(String responsable) {
    final impacto = widget.seguimiento.impactoProductividad;
    final motivo = switch (impacto) {
      'Critico' =>
        'Se reasigna para frenar un desvio critico de productividad y acelerar la resolucion.',
      'Alto' =>
        'Se reasigna para recuperar traccion operativa y evitar nueva escalada.',
      'Medio' =>
        'Se reasigna para redistribuir seguimiento y sostener continuidad institucional.',
      _ =>
        'Se reasigna para ordenar la agenda y mejorar cobertura del caso.',
    };
    final accion = switch (impacto) {
      'Critico' =>
        'Solicitar respuesta inmediata y registrar avance en la misma jornada.',
      'Alto' =>
        'Confirmar nuevo responsable y proximo hito dentro de la ventana vigente.',
      _ => 'Registrar recepcion del caso y primer avance operativo.',
    };
    return 'Reasignacion sugerida a $responsable.\nMotivo: $motivo\nAccion esperada: $accion';
  }

  void _confirmar() {
    final responsable = _responsableCtrl.text.trim();
    final comentario = _comentarioCtrl.text.trim();
    if (responsable.isEmpty || comentario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá responsable y motivo para reasignar.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _ReasignacionSeguimientoResultado(
        responsable: responsable,
        comentario: comentario,
      ),
    );
  }
}

class _PlantillaCierreEjecutivo {
  final String etiqueta;
  final String conclusion;
  final String decision;
  final String proximoPaso;

  const _PlantillaCierreEjecutivo({
    required this.etiqueta,
    required this.conclusion,
    required this.decision,
    required this.proximoPaso,
  });
}

class _AccionSeguimientoResultado {
  final String accion;
  final String comentario;

  const _AccionSeguimientoResultado({
    required this.accion,
    required this.comentario,
  });

  String get mensajeConfirmacion => switch (accion) {
    'comentario' => 'Comentario agregado al seguimiento.',
    'llamada' => 'Llamado registrado en la bitacora.',
    'reunion' => 'Reunion registrada en la bitacora.',
    'recordatorio' => 'Recordatorio agregado al seguimiento.',
    'revision_correctiva' => 'Revision correctiva registrada en la bitacora.',
    'replanificacion_mejora' =>
      'Replanificacion del plan de mejora registrada en la bitacora.',
    _ => 'Accion registrada en el seguimiento.',
  };
}

class _ReplanificacionPlanResultado {
  final String comentario;

  const _ReplanificacionPlanResultado({required this.comentario});
}

class _DialogoAccionSeguimiento extends StatefulWidget {
  final SeguimientoGestion seguimiento;

  const _DialogoAccionSeguimiento({required this.seguimiento});

  @override
  State<_DialogoAccionSeguimiento> createState() =>
      _DialogoAccionSeguimientoState();
}

class _DialogoAccionSeguimientoState extends State<_DialogoAccionSeguimiento> {
  late final TextEditingController _comentarioCtrl;
  late final TextEditingController _hallazgoCtrl;
  late final TextEditingController _bloqueoCtrl;
  late final TextEditingController _decisionCtrl;
  late final TextEditingController _proximoPasoCtrl;
  String _accion = 'comentario';

  @override
  void initState() {
    super.initState();
    _comentarioCtrl = TextEditingController();
    _hallazgoCtrl = TextEditingController();
    _bloqueoCtrl = TextEditingController();
    _decisionCtrl = TextEditingController();
    _proximoPasoCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    _hallazgoCtrl.dispose();
    _bloqueoCtrl.dispose();
    _decisionCtrl.dispose();
    _proximoPasoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar accion de seguimiento'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _esRevisionCorrectiva
                  ? 'La revision correctiva deja una mini auditoria del circuito sin cambiar el estado actual del seguimiento.'
                  : 'La accion se agregara a la bitacora sin cambiar el estado del seguimiento actual.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (widget.seguimiento.esPlanCorrectivo) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _ChipSeguimiento(
                    icono: Icons.playlist_add_check_outlined,
                    texto: 'Plan correctivo',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _accion,
              decoration: const InputDecoration(
                labelText: 'Tipo de accion',
              ),
              items: [
                DropdownMenuItem(
                  value: 'comentario',
                  child: Text('Comentario operativo'),
                ),
                DropdownMenuItem(
                  value: 'llamada',
                  child: Text('Llamado'),
                ),
                DropdownMenuItem(
                  value: 'reunion',
                  child: Text('Reunion'),
                ),
                DropdownMenuItem(
                  value: 'recordatorio',
                  child: Text('Recordatorio'),
                ),
                if (widget.seguimiento.esPlanCorrectivo)
                  DropdownMenuItem(
                    value: 'revision_correctiva',
                    child: Text('Revision correctiva'),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _accion = value);
              },
            ),
            const SizedBox(height: 12),
            if (_esRevisionCorrectiva) ...[
              TextField(
                controller: _hallazgoCtrl,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Hallazgo de la revision',
                  hintText: 'Responsable actual: ${widget.seguimiento.responsable}',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bloqueoCtrl,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Bloqueo o causa detectada',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _decisionCtrl,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Decision correctiva',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _proximoPasoCtrl,
                minLines: 2,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Proximo paso y responsable esperado',
                ),
              ),
            ] else
              TextField(
                controller: _comentarioCtrl,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: _labelComentario(),
                  hintText:
                      'Responsable actual: ${widget.seguimiento.responsable}',
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Registrar'),
        ),
      ],
    );
  }

  String _labelComentario() {
    switch (_accion) {
      case 'llamada':
        return 'Detalle del llamado';
      case 'reunion':
        return 'Detalle de la reunion';
      case 'recordatorio':
        return 'Recordatorio';
      case 'revision_correctiva':
        return 'Revision correctiva';
      default:
        return 'Comentario';
    }
  }

  bool get _esRevisionCorrectiva => _accion == 'revision_correctiva';

  String _comentarioRevisionCorrectiva() {
    final hallazgo = _hallazgoCtrl.text.trim();
    final bloqueo = _bloqueoCtrl.text.trim();
    final decision = _decisionCtrl.text.trim();
    final proximoPaso = _proximoPasoCtrl.text.trim();
    return [
      'Revision correctiva:',
      'Hallazgo: $hallazgo',
      'Bloqueo: $bloqueo',
      'Decision: $decision',
      'Proximo paso: $proximoPaso',
    ].join('\n');
  }

  void _confirmar() {
    final comentario = _esRevisionCorrectiva
        ? _comentarioRevisionCorrectiva()
        : _comentarioCtrl.text.trim();
    if (_esRevisionCorrectiva) {
      if (_hallazgoCtrl.text.trim().isEmpty ||
          _bloqueoCtrl.text.trim().isEmpty ||
          _decisionCtrl.text.trim().isEmpty ||
          _proximoPasoCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Completá hallazgo, bloqueo, decision y proximo paso para registrar la revision.',
            ),
          ),
        );
        return;
      }
    }
    if (comentario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribi un detalle para registrar la accion.'),
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      _AccionSeguimientoResultado(
        accion: _accion,
        comentario: comentario,
      ),
    );
  }
}

class _DialogoReplanificacionPlanMejora extends StatefulWidget {
  final SeguimientoGestion seguimiento;

  const _DialogoReplanificacionPlanMejora({required this.seguimiento});

  @override
  State<_DialogoReplanificacionPlanMejora> createState() =>
      _DialogoReplanificacionPlanMejoraState();
}

class _DialogoReplanificacionPlanMejoraState
    extends State<_DialogoReplanificacionPlanMejora> {
  late final TextEditingController _compromisoCtrl;
  late final TextEditingController _indicadorCtrl;
  late final TextEditingController _motivoCtrl;
  DateTime? _fechaObjetivo;

  @override
  void initState() {
    super.initState();
    _compromisoCtrl = TextEditingController(
      text: _extraerCampo(widget.seguimiento.comentario, 'Compromiso:'),
    );
    _indicadorCtrl = TextEditingController(
      text: _extraerCampo(
        widget.seguimiento.comentario,
        'Indicador de cumplimiento:',
      ),
    );
    _motivoCtrl = TextEditingController(
      text: widget.seguimiento.planMejoraVencido
          ? 'La fecha objetivo fue superada y el compromiso necesita una nueva ventana de ejecucion.'
          : 'Se ajusta la fecha objetivo para sostener el compromiso y evitar vencimiento.',
    );
    _fechaObjetivo = widget.seguimiento.fechaObjetivoPlan
            ?.add(const Duration(days: 7)) ??
        DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _compromisoCtrl.dispose();
    _indicadorCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Replanificar plan de mejora'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta accion actualiza el compromiso vigente, redefine la fecha objetivo y deja trazabilidad de la replanificacion en la bitacora.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _compromisoCtrl,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Compromiso actualizado',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _indicadorCtrl,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Indicador de cumplimiento',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _motivoCtrl,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Motivo de la replanificacion',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaObjetivo == null
                        ? 'Fecha objetivo pendiente'
                        : 'Nueva fecha objetivo: ${_fechaPlan(_fechaObjetivo!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.event_outlined),
                  label: const Text('Elegir fecha'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Replanificar'),
        ),
      ],
    );
  }

  String _extraerCampo(String comentario, String etiqueta) {
    final lineas = comentario.split('\n');
    for (final linea in lineas) {
      final texto = linea.trim();
      if (!texto.startsWith(etiqueta)) continue;
      return texto.substring(etiqueta.length).trim();
    }
    return '';
  }

  String _comentarioBaseSinPlan() {
    final marcador = 'Plan de mejora correctiva:';
    final indice = widget.seguimiento.comentario.indexOf(marcador);
    if (indice < 0) return widget.seguimiento.comentario.trim();
    return widget.seguimiento.comentario.substring(0, indice).trimRight();
  }

  String _fechaPlan(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return '$dd/$mm/$yyyy';
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final inicial = _fechaObjetivo ?? hoy.add(const Duration(days: 7));
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Nueva fecha objetivo',
    );
    if (fecha == null || !mounted) return;
    setState(() => _fechaObjetivo = fecha);
  }

  void _confirmar() {
    if (_compromisoCtrl.text.trim().isEmpty ||
        _indicadorCtrl.text.trim().isEmpty ||
        _motivoCtrl.text.trim().isEmpty ||
        _fechaObjetivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completá compromiso, indicador, motivo y nueva fecha objetivo para replanificar.',
          ),
        ),
      );
      return;
    }

    final comentario = [
      if (_comentarioBaseSinPlan().isNotEmpty) _comentarioBaseSinPlan(),
      'Plan de mejora correctiva:',
      if (_extraerCampo(widget.seguimiento.comentario, 'Estrategia correctiva:')
          .isNotEmpty)
        'Estrategia correctiva: ${_extraerCampo(widget.seguimiento.comentario, 'Estrategia correctiva:')}',
      if (_extraerCampo(widget.seguimiento.comentario, 'Decision estrategica:')
          .isNotEmpty)
        'Decision estrategica: ${_extraerCampo(widget.seguimiento.comentario, 'Decision estrategica:')}',
      'Compromiso: ${_compromisoCtrl.text.trim()}',
      'Fecha objetivo: ${_fechaPlan(_fechaObjetivo!)}',
      'Indicador de cumplimiento: ${_indicadorCtrl.text.trim()}',
      'Replanificacion: ${_motivoCtrl.text.trim()}',
    ].join('\n');

    Navigator.of(context).pop(
      _ReplanificacionPlanResultado(comentario: comentario),
    );
  }
}

class _TarjetaSeguimientoGestion extends StatelessWidget {
  final SeguimientoGestion item;
  final VoidCallback onRegistrarAccion;
  final VoidCallback? onReplanificar;
  final VoidCallback? onResolver;
  final VoidCallback? onReabrir;

  const _TarjetaSeguimientoGestion({
    required this.item,
    required this.onRegistrarAccion,
    this.onReplanificar,
    this.onResolver,
    this.onReabrir,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _fechaTexto(item.actualizadoEn),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipSeguimiento(
                icono: Icons.forward_to_inbox_outlined,
                texto: item.responsable,
              ),
              _ChipSeguimiento(
                icono: Icons.flag_outlined,
                texto: item.estado,
              ),
              _ChipImpactoProductividad(
                impacto: item.impactoProductividad,
              ),
              if (item.esPlanCorrectivo)
                const _ChipSeguimiento(
                  icono: Icons.playlist_add_check_outlined,
                  texto: 'Plan correctivo',
                ),
              if (item.tienePlanMejoraCorrectiva)
                _ChipSeguimiento(
                  icono: Icons.assignment_outlined,
                  texto: item.planMejoraVencido
                      ? 'Plan vencido ${_fechaObjetivoPlan(item)}'
                      : 'Plan ${_fechaObjetivoPlan(item)}',
                ),
              if ((item.estrategiaCorrectiva ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.route_outlined,
                  texto: item.estrategiaCorrectiva!,
                ),
              if ((item.decisionEstrategica ?? '').trim().isNotEmpty)
                _ChipSeguimiento(
                  icono: Icons.account_tree_outlined,
                  texto: item.decisionEstrategica!,
                ),
              _ChipUrgenciaSeguimiento(
                urgencia: item.urgencia,
                texto: item.urgencia,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _textoVencimiento(item),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: item.estaVencido ? const Color(0xFFB42318) : cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.comentario.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.comentario,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onRegistrarAccion,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Registrar accion'),
              ),
              if (onReplanificar != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onReplanificar,
                  icon: const Icon(Icons.event_repeat_outlined),
                  label: const Text('Replanificar'),
                ),
              ],
              if (onResolver != null || onReabrir != null)
                const SizedBox(width: 8),
              if (onResolver != null)
                TextButton.icon(
                  onPressed: onResolver,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('Marcar resuelta'),
                ),
              if (onResolver != null && onReabrir != null)
                const SizedBox(width: 8),
              if (onReabrir != null)
                TextButton.icon(
                  onPressed: onReabrir,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reabrir'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _fechaTexto(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dd/$mm $hh:$min';
  }

  String _textoVencimiento(SeguimientoGestion item) {
    final dd = item.venceEn.day.toString().padLeft(2, '0');
    final mm = item.venceEn.month.toString().padLeft(2, '0');
    final hh = item.venceEn.hour.toString().padLeft(2, '0');
    final min = item.venceEn.minute.toString().padLeft(2, '0');
    final prefijo = item.estaVencido ? 'Vencida' : 'Vence';
    return '$prefijo $dd/$mm $hh:$min';
  }
}

class _DialogoResponsableGestion extends StatefulWidget {
  final String titulo;
  final ResponsableGestionBorrador borrador;
  final List<String> areasDisponibles;

  const _DialogoResponsableGestion({
    required this.titulo,
    required this.borrador,
    required this.areasDisponibles,
  });

  @override
  State<_DialogoResponsableGestion> createState() =>
      _DialogoResponsableGestionState();
}

class _DialogoResponsableGestionState extends State<_DialogoResponsableGestion> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _areaCtrl;
  String? _areaSugerida;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.borrador.nombre);
    _areaCtrl = TextEditingController(text: widget.borrador.area);
    final areaActual = widget.borrador.area.trim();
    if (areaActual.isNotEmpty && widget.areasDisponibles.contains(areaActual)) {
      _areaSugerida = areaActual;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este responsable quedara asociado al contexto institucional activo para ordenar derivaciones y seguimientos.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del responsable',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _areaCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Area o funcion',
              ),
            ),
            if (widget.areasDisponibles.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _areaSugerida,
                decoration: const InputDecoration(
                  labelText: 'Reutilizar area existente',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Escribir manualmente'),
                  ),
                  ...widget.areasDisponibles.map(
                    (area) => DropdownMenuItem<String?>(
                      value: area,
                      child: Text(area),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _areaSugerida = value);
                  if ((value ?? '').trim().isEmpty) return;
                  _areaCtrl.text = value!;
                },
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipSeguimiento(
                  icono: widget.borrador.rol.icono,
                  texto: widget.borrador.rol.etiqueta,
                ),
                _ChipSeguimiento(
                  icono: Icons.school_outlined,
                  texto: widget.borrador.nivel.etiqueta,
                ),
                _ChipSeguimiento(
                  icono: Icons.account_balance_outlined,
                  texto: widget.borrador.dependencia.etiqueta,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Guardar responsable'),
        ),
      ],
    );
  }

  void _confirmar() {
    final nombre = _nombreCtrl.text.trim();
    final area = _areaCtrl.text.trim();
    if (nombre.isEmpty || area.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá nombre y area para guardar el responsable.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      ResponsableGestionBorrador(
        id: widget.borrador.id,
        nombre: nombre,
        area: area,
        rol: widget.borrador.rol,
        nivel: widget.borrador.nivel,
        dependencia: widget.borrador.dependencia,
        activo: widget.borrador.activo,
      ),
    );
  }
}

class _EstadoGestion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _EstadoGestion({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.82)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 22, color: cs.primary),
          const SizedBox(height: 10),
          Text(
            titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.42,
            ),
          ),
        ],
      ),
    );
  }
}
