import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/incidencias/modelos/incidencia_transversal.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class IncidenciasTransversalesPantalla extends StatefulWidget {
  const IncidenciasTransversalesPantalla({super.key});

  @override
  State<IncidenciasTransversalesPantalla> createState() =>
      _IncidenciasTransversalesPantallaState();
}

class _IncidenciasTransversalesPantallaState
    extends State<IncidenciasTransversalesPantalla> {
  String _filtroOrigen = 'todas';
  bool _soloUrgentes = false;
  bool _soloDevueltas = false;
  bool _soloVencidas = false;
  bool _soloConLegajo = false;
  String _filtroSemaforo = 'todos';
  _OrdenIncidencias _orden = _OrdenIncidencias.prioridad;
  int _refreshToken = 0;
  final Set<String> _seleccionadas = <String>{};
  AlertaMesaIncidencias? _alertaActiva;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ContextoInstitucional>(
      valueListenable: Proveedores.contextoInstitucional,
      builder: (context, contexto, _) {
        return FutureBuilder<DashboardIncidencias>(
          key: ValueKey('${contexto.rol.name}-${contexto.nivel.name}-$_filtroOrigen-$_refreshToken'),
          future: Proveedores.incidenciasTransversalesRepositorio.cargarDashboard(
            contexto: contexto,
            origen: _filtroOrigen,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _EstadoIncidencias(
                icono: Icons.hub_outlined,
                titulo: 'Cargando incidencias institucionales',
                descripcion:
                    'Unificando cruces entre Secretaria, Preceptoria, Biblioteca y Legajos.',
              );
            }
            if (snapshot.hasError) {
              return _EstadoIncidencias(
                icono: Icons.error_outline,
                titulo: 'No se pudo abrir la mesa transversal',
                descripcion: '${snapshot.error}',
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return const _EstadoIncidencias(
                icono: Icons.inbox_outlined,
                titulo: 'Sin incidencias cruzadas',
                descripcion:
                    'Todavia no hay casos vinculados entre modulos para este contexto institucional.',
              );
            }
            return _contenido(context, contexto, data);
          },
        );
      },
    );
  }

  Widget _contenido(
    BuildContext context,
    ContextoInstitucional contexto,
    DashboardIncidencias data,
  ) {
    final cs = Theme.of(context).colorScheme;
    final incidenciasVisibles = _aplicarFiltrosYOrden(data.incidencias);
    final seleccionadasVisibles = incidenciasVisibles
        .where((item) => _seleccionadas.contains(_claveCaso(item)))
        .toList(growable: false);
    final derivablesSeleccionadas = seleccionadasVisibles
        .where((item) => item.codigoLegajo == null)
        .toList(growable: false);
    final devolviblesSeleccionadas = seleccionadasVisibles
        .where((item) => item.codigoLegajo != null || item.estadoDocumental != null)
        .toList(growable: false);
    final resumenesPorModulo = _resumenesPorModulo(incidenciasVisibles);
    final focoPrincipal = _focoPrincipal(resumenesPorModulo);
    final rojas = incidenciasVisibles
        .where((item) => item.semaforo == SemaforoIncidenciaTransversal.rojo)
        .length;
    final amarillas = incidenciasVisibles
        .where((item) => item.semaforo == SemaforoIncidenciaTransversal.amarillo)
        .length;
    final verdes = incidenciasVisibles
        .where((item) => item.semaforo == SemaforoIncidenciaTransversal.verde)
        .length;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SelloIncidencias(icono: Icons.hub_outlined, etiqueta: 'Mesa transversal'),
              _SelloIncidencias(icono: contexto.rol.icono, etiqueta: contexto.rol.etiqueta),
              _SelloIncidencias(icono: Icons.school_outlined, etiqueta: contexto.nivel.etiqueta),
              _SelloIncidencias(
                icono: Icons.apartment_outlined,
                etiqueta: contexto.dependencia.etiqueta,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incidencias institucionales',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta mesa unifica los casos que ya cruzaron modulos y necesitan seguimiento coordinado entre la operatoria diaria y la capa documental.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _actualizarVista(() => _refreshToken++),
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Actualizar'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Casos cruzados',
                valor: '${data.resumen.total}',
                descripcion: 'Incidencias que ya tocaron mas de un modulo.',
                icono: Icons.hub_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Urgentes',
                valor: '${data.resumen.urgentes}',
                descripcion: 'Casos vencidos, altos o con tension documental.',
                icono: Icons.priority_high_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Devueltos',
                valor: '${data.resumen.devueltas}',
                descripcion: 'Casos que regresaron desde Legajos al origen.',
                icono: Icons.reply_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Con legajo',
                valor: '${data.resumen.conLegajo}',
                descripcion: 'Incidencias que ya tienen codigo documental asociado.',
                icono: Icons.folder_open_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Recomendacion ejecutiva dominante',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _TarjetaRecomendacionEjecutivaMesa(
            item: data.recomendacionEjecutiva,
            onVerFoco: () => _aplicarRecomendacionDominante(data),
            onEjecutar:
                () => _ejecutarRecomendacionDominante(contexto, data),
          ),
          const SizedBox(height: 12),
          Text(
            data.historialEjecutivo.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Focos consultados',
                valor: '${data.historialEjecutivo.focosConsultados}',
                descripcion: 'Consultas ejecutivas desde la recomendacion dominante.',
                icono: Icons.visibility_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Acciones rapidas',
                valor: '${data.historialEjecutivo.accionesRapidas}',
                descripcion: 'Intervenciones disparadas desde la cabecera ejecutiva.',
                icono: Icons.bolt_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Conversion dominante',
                valor: '${data.historialEjecutivo.conversionPorcentaje}%',
                descripcion:
                    'Estado ${data.historialEjecutivo.estadoConversion.toLowerCase()} con ${data.historialEjecutivo.pendientesConversion} pendientes.',
                icono: Icons.speed_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.comparativaCabecera.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Conversion actual',
                valor: '${data.comparativaCabecera.conversionActual}%',
                descripcion:
                    'Periodo previo: ${data.comparativaCabecera.conversionPrevia}%.',
                icono: Icons.query_stats_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Estado de cabecera',
                valor: data.comparativaCabecera.estadoConversion,
                descripcion:
                    'Focos ${data.comparativaCabecera.focosActuales} vs ${data.comparativaCabecera.focosPrevios}.',
                icono: Icons.monitor_heart_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.recomendacionHistorica.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Consistencia historica',
                valor: data.recomendacionHistorica.estadoConsistencia,
                descripcion:
                    'Foco previo: ${data.recomendacionHistorica.focoPrevio}.',
                icono: Icons.history_toggle_off_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Cambios recientes',
                valor: '${data.recomendacionHistorica.cambiosRecientes}',
                descripcion:
                    'Eventos ${data.recomendacionHistorica.eventosActuales} vs ${data.recomendacionHistorica.eventosPrevios}.',
                icono: Icons.sync_problem_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.consolidadoHistorico.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Patron historico',
                valor: data.consolidadoHistorico.patron,
                descripcion:
                    'Estado ${data.consolidadoHistorico.estado.toLowerCase()} del criterio ejecutivo.',
                icono: Icons.insights_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Riesgo de oscilacion',
                valor: '${data.consolidadoHistorico.riesgoOscilacion}',
                descripcion:
                    'Integra cambios recientes, conversion y continuidad entre periodos.',
                icono: Icons.multiline_chart_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.consolidadoCronificacion.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Cronificacion',
                valor: data.consolidadoCronificacion.patron,
                descripcion:
                    'Estado ${data.consolidadoCronificacion.estado.toLowerCase()} de la tension institucional.',
                icono: Icons.timeline_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Riesgo cronico',
                valor: '${data.consolidadoCronificacion.riesgoCronificacion}',
                descripcion:
                    'Modulos concentrados: ${data.consolidadoCronificacion.modulosConcentrados.join(', ')}.',
                icono: Icons.domain_verification_outlined,
              ),
            ],
          ),
          if (data.planEstabilizacion.estado != 'No requerido') ...[
            const SizedBox(height: 12),
            Text(
              data.planEstabilizacion.lecturaEjecutiva,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricaIncidencias(
                  titulo: 'Plan sugerido',
                  valor: data.planEstabilizacion.estado,
                  descripcion: data.planEstabilizacion.criterio,
                  icono: Icons.alt_route_outlined,
                ),
                _MetricaIncidencias(
                  titulo: 'Horizonte',
                  valor: '${data.planEstabilizacion.horizonteDias} dias',
                  descripcion:
                      'Modulos foco: ${data.planEstabilizacion.modulosPrioritarios.join(', ')}.',
                  icono: Icons.event_available_outlined,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.seguimientoPlan.lecturaEjecutiva,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricaIncidencias(
                  titulo: 'Planes aplicados',
                  valor: '${data.seguimientoPlan.presetsAplicados}',
                  descripcion:
                      'Ejecuciones ${data.seguimientoPlan.ejecucionesRegistradas} en los ultimos 30 dias.',
                  icono: Icons.playlist_add_outlined,
                ),
                _MetricaIncidencias(
                  titulo: 'Conversion del plan',
                  valor: '${data.seguimientoPlan.conversionPorcentaje}%',
                  descripcion:
                      'Pendientes ${data.seguimientoPlan.pendientes}.',
                  icono: Icons.rule_outlined,
                ),
                _MetricaIncidencias(
                  titulo: 'Efecto actual',
                  valor: data.seguimientoPlan.estadoEfecto,
                  descripcion: 'Impacto observado sobre la cabecera ejecutiva.',
                  icono: Icons.monitor_heart_outlined,
                ),
              ],
            ),
            if (data.ajustePlan.estado != 'No requerido') ...[
              const SizedBox(height: 12),
              Text(
                data.ajustePlan.lecturaEjecutiva,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricaIncidencias(
                    titulo: 'Ajuste sugerido',
                    valor: data.ajustePlan.tipoAjuste,
                    descripcion: data.ajustePlan.criterioAjustado,
                    icono: Icons.tune_outlined,
                  ),
                  _MetricaIncidencias(
                    titulo: 'Nuevo horizonte',
                    valor: '${data.ajustePlan.horizonteDiasSugerido} dias',
                    descripcion:
                        'Refuerzo sobre: ${data.ajustePlan.modulosRefuerzo.join(', ')}.',
                    icono: Icons.update_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.seguimientoAjuste.lecturaEjecutiva,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricaIncidencias(
                    titulo: 'Ajustes aplicados',
                    valor: '${data.seguimientoAjuste.presetsAplicados}',
                    descripcion:
                        'Ejecuciones ${data.seguimientoAjuste.ejecucionesRegistradas} en los ultimos 30 dias.',
                    icono: Icons.tune_outlined,
                  ),
                  _MetricaIncidencias(
                    titulo: 'Conversion del ajuste',
                    valor: '${data.seguimientoAjuste.conversionPorcentaje}%',
                    descripcion:
                        'Pendientes ${data.seguimientoAjuste.pendientes}.',
                    icono: Icons.auto_fix_high_outlined,
                  ),
                  _MetricaIncidencias(
                    titulo: 'Efecto del ajuste',
                    valor: data.seguimientoAjuste.estadoEfecto,
                    descripcion: 'Impacto observado despues del ajuste sugerido.',
                    icono: Icons.monitor_heart_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: data.ajustePlan.accionesSugeridas
                    .map(
                      (item) => Chip(
                        avatar: const Icon(Icons.auto_fix_high_outlined, size: 18),
                        label: Text(item),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => _aplicarAjustePlanEstabilizacion(data),
                    icon: const Icon(Icons.tune_outlined),
                    label: const Text('Aplicar ajuste'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _ejecutarAjustePlanEstabilizacion(data),
                    icon: const Icon(Icons.build_circle_outlined),
                    label: const Text('Ejecutar ajuste'),
                  ),
                ],
              ),
              if (data.escalamientoCabecera.estado != 'No requerido') ...[
                const SizedBox(height: 12),
                Text(
                  data.escalamientoCabecera.lecturaEjecutiva,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricaIncidencias(
                      titulo: 'Escalamiento',
                      valor: data.escalamientoCabecera.tipoIntervencion,
                      descripcion: data.escalamientoCabecera.criterioEjecutivo,
                      icono: Icons.vertical_align_top_outlined,
                    ),
                    _MetricaIncidencias(
                      titulo: 'Horizonte critico',
                      valor: '${data.escalamientoCabecera.horizonteDias} dias',
                      descripcion:
                          'Modulos criticos: ${data.escalamientoCabecera.modulosCriticos.join(', ')}.',
                      icono: Icons.crisis_alert_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data.seguimientoEscalamiento.lecturaEjecutiva,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricaIncidencias(
                      titulo: 'Escalamientos aplicados',
                      valor: '${data.seguimientoEscalamiento.presetsAplicados}',
                      descripcion:
                          'Ejecuciones ${data.seguimientoEscalamiento.ejecucionesRegistradas} en los ultimos 30 dias.',
                      icono: Icons.vertical_align_top_outlined,
                    ),
                    _MetricaIncidencias(
                      titulo: 'Conversion del escalamiento',
                      valor: '${data.seguimientoEscalamiento.conversionPorcentaje}%',
                      descripcion:
                          'Pendientes ${data.seguimientoEscalamiento.pendientes}.',
                      icono: Icons.rocket_launch_outlined,
                    ),
                    _MetricaIncidencias(
                      titulo: 'Efecto del escalamiento',
                      valor: data.seguimientoEscalamiento.estadoEfecto,
                      descripcion:
                          'Impacto observado despues de la intervencion critica.',
                      icono: Icons.monitor_heart_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.escalamientoCabecera.accionesSugeridas
                      .map(
                        (item) => Chip(
                          avatar: const Icon(Icons.warning_amber_outlined, size: 18),
                          label: Text(item),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _aplicarEscalamientoCabecera(data),
                      icon: const Icon(Icons.vertical_align_top_outlined),
                      label: const Text('Aplicar escalamiento'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _ejecutarEscalamientoCabecera(data),
                      icon: const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Ejecutar escalamiento'),
                    ),
                  ],
                ),
                if (data.protocoloContingencia.estado != 'No requerido') ...[
                  const SizedBox(height: 12),
                  Text(
                    data.protocoloContingencia.lecturaEjecutiva,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricaIncidencias(
                        titulo: 'Contingencia',
                        valor: data.protocoloContingencia.tipoProtocolo,
                        descripcion:
                            data.protocoloContingencia.criterioInstitucional,
                        icono: Icons.policy_outlined,
                      ),
                      _MetricaIncidencias(
                        titulo: 'Horizonte excepcional',
                        valor: '${data.protocoloContingencia.horizonteDias} dias',
                        descripcion:
                            'Modulos criticos: ${data.protocoloContingencia.modulosCriticos.join(', ')}.',
                        icono: Icons.gpp_maybe_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.protocoloContingencia.accionesSugeridas
                        .map(
                          (item) => Chip(
                            avatar: const Icon(Icons.emergency_outlined, size: 18),
                            label: Text(item),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.seguimientoProtocolo.lecturaEjecutiva,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricaIncidencias(
                        titulo: 'Contingencias aplicadas',
                        valor: '${data.seguimientoProtocolo.presetsAplicados}',
                        descripcion:
                            'Ejecuciones ${data.seguimientoProtocolo.ejecucionesRegistradas} en los ultimos 30 dias.',
                        icono: Icons.policy_outlined,
                      ),
                      _MetricaIncidencias(
                        titulo: 'Conversion de contingencia',
                        valor: '${data.seguimientoProtocolo.conversionPorcentaje}%',
                        descripcion:
                            'Pendientes ${data.seguimientoProtocolo.pendientes}.',
                        icono: Icons.local_fire_department_outlined,
                      ),
                      _MetricaIncidencias(
                        titulo: 'Efecto de contingencia',
                        valor: data.seguimientoProtocolo.estadoEfecto,
                        descripcion:
                            'Impacto observado despues de la respuesta excepcional.',
                        icono: Icons.monitor_heart_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _aplicarProtocoloContingencia(data),
                        icon: const Icon(Icons.policy_outlined),
                        label: const Text('Aplicar contingencia'),
                      ),
                      FilledButton.icon(
                        onPressed: () => _ejecutarProtocoloContingencia(data),
                        icon: const Icon(Icons.local_fire_department_outlined),
                        label: const Text('Ejecutar contingencia'),
                      ),
                    ],
                  ),
                  if (data.mesaCrisis.estado != 'No requerida') ...[
                    const SizedBox(height: 12),
                    Text(
                      data.mesaCrisis.lecturaEjecutiva,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricaIncidencias(
                          titulo: 'Mesa de crisis',
                          valor: data.mesaCrisis.tipoMesa,
                          descripcion: data.mesaCrisis.criterioCrisis,
                          icono: Icons.domain_disabled_outlined,
                        ),
                        _MetricaIncidencias(
                          titulo: 'Horizonte de crisis',
                          valor: '${data.mesaCrisis.horizonteDias} dias',
                          descripcion:
                              'Modulos criticos: ${data.mesaCrisis.modulosCriticos.join(', ')}.',
                          icono: Icons.warning_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.mesaCrisis.accionesSugeridas
                          .map(
                            (item) => Chip(
                              avatar: const Icon(Icons.crisis_alert_outlined, size: 18),
                              label: Text(item),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.seguimientoMesaCrisis.lecturaEjecutiva,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MetricaIncidencias(
                          titulo: 'Mesas aplicadas',
                          valor: '${data.seguimientoMesaCrisis.presetsAplicados}',
                          descripcion:
                              'Ejecuciones ${data.seguimientoMesaCrisis.ejecucionesRegistradas} en los ultimos 30 dias.',
                          icono: Icons.domain_disabled_outlined,
                        ),
                        _MetricaIncidencias(
                          titulo: 'Conversion de crisis',
                          valor:
                              '${data.seguimientoMesaCrisis.conversionPorcentaje}%',
                          descripcion:
                              'Pendientes ${data.seguimientoMesaCrisis.pendientes}.',
                          icono: Icons.crisis_alert_outlined,
                        ),
                        _MetricaIncidencias(
                          titulo: 'Efecto de crisis',
                          valor: data.seguimientoMesaCrisis.estadoEfecto,
                          descripcion:
                              'Impacto observado despues de activar la mesa de crisis.',
                          icono: Icons.monitor_heart_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => _aplicarMesaCrisis(data),
                          icon: const Icon(Icons.domain_disabled_outlined),
                          label: const Text('Aplicar mesa de crisis'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _ejecutarMesaCrisis(data),
                          icon: const Icon(Icons.crisis_alert_outlined),
                          label: const Text('Ejecutar mesa de crisis'),
                        ),
                      ],
                    ),
                    if (data.protocoloRecuperacion.estado != 'No requerido') ...[
                      const SizedBox(height: 12),
                      Text(
                        data.protocoloRecuperacion.lecturaEjecutiva,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricaIncidencias(
                            titulo: 'Recuperacion',
                            valor: data.protocoloRecuperacion.tipoRecuperacion,
                            descripcion:
                                data.protocoloRecuperacion.criterioRecuperacion,
                            icono: Icons.health_and_safety_outlined,
                          ),
                          _MetricaIncidencias(
                            titulo: 'Horizonte de recuperacion',
                            valor:
                                '${data.protocoloRecuperacion.horizonteDias} dias',
                            descripcion:
                                'Modulos foco: ${data.protocoloRecuperacion.modulosPrioritarios.join(', ')}.',
                            icono: Icons.restore_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.protocoloRecuperacion.accionesSugeridas
                            .map(
                              (item) => Chip(
                                avatar: const Icon(
                                  Icons.health_and_safety_outlined,
                                  size: 18,
                                ),
                                label: Text(item),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.seguimientoRecuperacion.lecturaEjecutiva,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricaIncidencias(
                            titulo: 'Recuperaciones aplicadas',
                            valor:
                                '${data.seguimientoRecuperacion.presetsAplicados}',
                            descripcion:
                                'Ejecuciones ${data.seguimientoRecuperacion.ejecucionesRegistradas} en los ultimos 30 dias.',
                            icono: Icons.restore_outlined,
                          ),
                          _MetricaIncidencias(
                            titulo: 'Conversion de recuperacion',
                            valor:
                                '${data.seguimientoRecuperacion.conversionPorcentaje}%',
                            descripcion:
                                'Pendientes ${data.seguimientoRecuperacion.pendientes}.',
                            icono: Icons.health_and_safety_outlined,
                          ),
                          _MetricaIncidencias(
                            titulo: 'Efecto de recuperacion',
                            valor: data.seguimientoRecuperacion.estadoEfecto,
                            descripcion:
                                'Impacto observado despues de activar la salida institucional.',
                            icono: Icons.monitor_heart_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => _aplicarProtocoloRecuperacion(data),
                            icon: const Icon(Icons.restore_outlined),
                            label: const Text('Aplicar recuperacion'),
                          ),
                          FilledButton.icon(
                            onPressed: () => _ejecutarProtocoloRecuperacion(data),
                            icon: const Icon(Icons.health_and_safety_outlined),
                            label: const Text('Ejecutar recuperacion'),
                          ),
                        ],
                      ),
                      if (data.planEstructural.estado != 'No requerido') ...[
                        const SizedBox(height: 12),
                        Text(
                          data.planEstructural.lecturaEjecutiva,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricaIncidencias(
                              titulo: 'Plan estructural',
                              valor: data.planEstructural.tipoPlan,
                              descripcion:
                                  data.planEstructural.criterioEstructural,
                              icono: Icons.account_tree_outlined,
                            ),
                            _MetricaIncidencias(
                              titulo: 'Horizonte estructural',
                              valor:
                                  '${data.planEstructural.horizonteDias} dias',
                              descripcion:
                                  'Modulos foco: ${data.planEstructural.modulosPrioritarios.join(', ')}.',
                              icono: Icons.schema_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: data.planEstructural.accionesSugeridas
                              .map(
                                (item) => Chip(
                                  avatar: const Icon(
                                    Icons.account_tree_outlined,
                                    size: 18,
                                  ),
                                  label: Text(item),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.seguimientoPlanEstructural.lecturaEjecutiva,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricaIncidencias(
                              titulo: 'Planes estructurales',
                              valor:
                                  '${data.seguimientoPlanEstructural.presetsAplicados}',
                              descripcion:
                                  'Ejecuciones ${data.seguimientoPlanEstructural.ejecucionesRegistradas} en los ultimos 30 dias.',
                              icono: Icons.schema_outlined,
                            ),
                            _MetricaIncidencias(
                              titulo: 'Conversion estructural',
                              valor:
                                  '${data.seguimientoPlanEstructural.conversionPorcentaje}%',
                              descripcion:
                                  'Pendientes ${data.seguimientoPlanEstructural.pendientes}.',
                              icono: Icons.account_tree_outlined,
                            ),
                            _MetricaIncidencias(
                              titulo: 'Efecto estructural',
                              valor: data.seguimientoPlanEstructural.estadoEfecto,
                              descripcion:
                                  'Impacto observado despues de activar la recomposicion profunda.',
                              icono: Icons.monitor_heart_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () => _aplicarPlanEstructural(data),
                              icon: const Icon(Icons.schema_outlined),
                              label: const Text('Aplicar recomposicion'),
                            ),
                            FilledButton.icon(
                              onPressed: () => _ejecutarPlanEstructural(data),
                              icon: const Icon(Icons.account_tree_outlined),
                              label: const Text('Ejecutar recomposicion'),
                            ),
                          ],
                        ),
                      ],
                      if (data.planDesacople.estado != 'No requerido') ...[
                        const SizedBox(height: 12),
                        Text(
                          data.planDesacople.lecturaEjecutiva,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricaIncidencias(
                              titulo: 'Plan de desacople',
                              valor: data.planDesacople.tipoDesacople,
                              descripcion:
                                  data.planDesacople.criterioDesacople,
                              icono: Icons.call_split_outlined,
                            ),
                            _MetricaIncidencias(
                              titulo: 'Horizonte de desacople',
                              valor:
                                  '${data.planDesacople.horizonteDias} dias',
                              descripcion:
                                  'Modulos foco: ${data.planDesacople.modulosDesacople.join(', ')}.',
                              icono: Icons.timeline_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: data.planDesacople.accionesSugeridas
                              .map(
                                (item) => Chip(
                                  avatar: const Icon(
                                    Icons.call_split_outlined,
                                    size: 18,
                                  ),
                                  label: Text(item),
                                ),
                              )
                              .toList(growable: false),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () => _aplicarPlanDesacople(data),
                              icon: const Icon(Icons.call_split_outlined),
                              label: const Text('Aplicar desacople'),
                            ),
                            FilledButton.icon(
                              onPressed: () => _ejecutarPlanDesacople(data),
                              icon: const Icon(Icons.alt_route_outlined),
                              label: const Text('Ejecutar desacople'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.seguimientoPlanDesacople.lecturaEjecutiva,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _MetricaIncidencias(
                              titulo: 'Planes de desacople',
                              valor:
                                  '${data.seguimientoPlanDesacople.presetsAplicados}',
                              descripcion:
                                  'Ejecuciones ${data.seguimientoPlanDesacople.ejecucionesRegistradas} en los ultimos 30 dias.',
                              icono: Icons.call_split_outlined,
                            ),
                            _MetricaIncidencias(
                              titulo: 'Conversion de desacople',
                              valor:
                                  '${data.seguimientoPlanDesacople.conversionPorcentaje}%',
                              descripcion:
                                  'Pendientes ${data.seguimientoPlanDesacople.pendientes}.',
                              icono: Icons.alt_route_outlined,
                            ),
                            _MetricaIncidencias(
                              titulo: 'Efecto del desacople',
                              valor: data.seguimientoPlanDesacople.estadoEfecto,
                              descripcion:
                                  'Impacto observado sobre la concentracion critica por modulo.',
                              icono: Icons.monitor_heart_outlined,
                            ),
                          ],
                        ),
                        if (data.planReforzamientoDesacople.estado !=
                            'No requerido') ...[
                          const SizedBox(height: 12),
                          Text(
                            data.planReforzamientoDesacople.lecturaEjecutiva,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _MetricaIncidencias(
                                titulo: 'Refuerzo de desacople',
                                valor: data
                                    .planReforzamientoDesacople.tipoReforzamiento,
                                descripcion: data.planReforzamientoDesacople
                                    .criterioReforzamiento,
                                icono: Icons.rule_folder_outlined,
                              ),
                              _MetricaIncidencias(
                                titulo: 'Horizonte reforzado',
                                valor:
                                    '${data.planReforzamientoDesacople.horizonteDias} dias',
                                descripcion:
                                    'Modulos foco: ${data.planReforzamientoDesacople.modulosCriticos.join(', ')}.',
                                icono: Icons.event_repeat_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: data
                                .planReforzamientoDesacople.accionesSugeridas
                                .map(
                                  (item) => Chip(
                                    avatar: const Icon(
                                      Icons.rule_folder_outlined,
                                      size: 18,
                                    ),
                                    label: Text(item),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed:
                                    () => _aplicarPlanReforzamientoDesacople(
                                      data,
                                    ),
                                icon: const Icon(Icons.rule_folder_outlined),
                                label: const Text('Aplicar refuerzo'),
                              ),
                              FilledButton.icon(
                                onPressed:
                                    () => _ejecutarPlanReforzamientoDesacople(
                                      data,
                                    ),
                                icon: const Icon(Icons.layers_clear_outlined),
                                label: const Text('Ejecutar refuerzo'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data
                                .seguimientoPlanReforzamientoDesacople
                                .lecturaEjecutiva,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _MetricaIncidencias(
                                titulo: 'Refuerzos aplicados',
                                valor:
                                    '${data.seguimientoPlanReforzamientoDesacople.presetsAplicados}',
                                descripcion:
                                    'Ejecuciones ${data.seguimientoPlanReforzamientoDesacople.ejecucionesRegistradas} en los ultimos 30 dias.',
                                icono: Icons.rule_folder_outlined,
                              ),
                              _MetricaIncidencias(
                                titulo: 'Conversion del refuerzo',
                                valor:
                                    '${data.seguimientoPlanReforzamientoDesacople.conversionPorcentaje}%',
                                descripcion:
                                    'Pendientes ${data.seguimientoPlanReforzamientoDesacople.pendientes}.',
                                icono: Icons.layers_clear_outlined,
                              ),
                              _MetricaIncidencias(
                                titulo: 'Efecto del refuerzo',
                                valor: data
                                    .seguimientoPlanReforzamientoDesacople
                                    .estadoEfecto,
                                descripcion:
                                    'Impacto observado despues de endurecer el desacople sobre modulos cronicos.',
                                icono: Icons.monitor_heart_outlined,
                              ),
                            ],
                          ),
                          if (data.planContencionCronificacion.estado !=
                              'No requerido') ...[
                            const SizedBox(height: 12),
                            Text(
                              data.planContencionCronificacion.lecturaEjecutiva,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _MetricaIncidencias(
                                  titulo: 'Plan de contencion',
                                  valor: data
                                      .planContencionCronificacion
                                      .tipoContencion,
                                  descripcion: data
                                      .planContencionCronificacion
                                      .criterioContencion,
                                  icono: Icons.shield_moon_outlined,
                                ),
                                _MetricaIncidencias(
                                  titulo: 'Horizonte de contencion',
                                  valor:
                                      '${data.planContencionCronificacion.horizonteDias} dias',
                                  descripcion:
                                      'Modulos foco: ${data.planContencionCronificacion.modulosCriticos.join(', ')}.',
                                  icono: Icons.shield_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: data
                                  .planContencionCronificacion.accionesSugeridas
                                  .map(
                                    (item) => Chip(
                                      avatar: const Icon(
                                        Icons.shield_moon_outlined,
                                        size: 18,
                                      ),
                                      label: Text(item),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.tonalIcon(
                                  onPressed:
                                      () => _aplicarPlanContencionCronificacion(
                                        data,
                                      ),
                                  icon: const Icon(Icons.shield_moon_outlined),
                                  label: const Text('Aplicar contencion'),
                                ),
                                FilledButton.icon(
                                  onPressed:
                                      () =>
                                          _ejecutarPlanContencionCronificacion(
                                            data,
                                          ),
                                  icon: const Icon(Icons.gpp_good_outlined),
                                  label: const Text('Ejecutar contencion'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data
                                  .seguimientoPlanContencionCronificacion
                                  .lecturaEjecutiva,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _MetricaIncidencias(
                                  titulo: 'Contenciones aplicadas',
                                  valor:
                                      '${data.seguimientoPlanContencionCronificacion.presetsAplicados}',
                                  descripcion:
                                      'Ejecuciones ${data.seguimientoPlanContencionCronificacion.ejecucionesRegistradas} en los ultimos 30 dias.',
                                  icono: Icons.shield_moon_outlined,
                                ),
                                _MetricaIncidencias(
                                  titulo: 'Conversion de contencion',
                                  valor:
                                      '${data.seguimientoPlanContencionCronificacion.conversionPorcentaje}%',
                                  descripcion:
                                      'Pendientes ${data.seguimientoPlanContencionCronificacion.pendientes}.',
                                  icono: Icons.gpp_good_outlined,
                                ),
                                _MetricaIncidencias(
                                  titulo: 'Efecto de contencion',
                                  valor: data
                                      .seguimientoPlanContencionCronificacion
                                      .estadoEfecto,
                                  descripcion:
                                      'Impacto observado despues de contener la cronificacion sobre modulos criticos.',
                                  icono: Icons.monitor_heart_outlined,
                                ),
                              ],
                            ),
                            if (data
                                    .planRespuestaExcepcionalCronificacion
                                    .estado !=
                                'No requerido') ...[
                              const SizedBox(height: 12),
                              Text(
                                data
                                    .planRespuestaExcepcionalCronificacion
                                    .lecturaEjecutiva,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _MetricaIncidencias(
                                    titulo: 'Respuesta excepcional',
                                    valor: data
                                        .planRespuestaExcepcionalCronificacion
                                        .tipoRespuesta,
                                    descripcion: data
                                        .planRespuestaExcepcionalCronificacion
                                        .criterioRespuesta,
                                    icono: Icons.local_fire_department_outlined,
                                  ),
                                  _MetricaIncidencias(
                                    titulo: 'Horizonte excepcional',
                                    valor:
                                        '${data.planRespuestaExcepcionalCronificacion.horizonteDias} dias',
                                    descripcion:
                                        'Modulos foco: ${data.planRespuestaExcepcionalCronificacion.modulosCriticos.join(', ')}.',
                                    icono: Icons.policy_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: data
                                    .planRespuestaExcepcionalCronificacion
                                    .accionesSugeridas
                                    .map(
                                      (item) => Chip(
                                        avatar: const Icon(
                                          Icons.local_fire_department_outlined,
                                          size: 18,
                                        ),
                                        label: Text(item),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.tonalIcon(
                                    onPressed:
                                        () =>
                                            _aplicarRespuestaExcepcionalCronificacion(
                                              data,
                                            ),
                                    icon: const Icon(
                                      Icons.local_fire_department_outlined,
                                    ),
                                    label: const Text(
                                      'Aplicar respuesta excepcional',
                                    ),
                                  ),
                                  FilledButton.icon(
                                    onPressed:
                                        () =>
                                            _ejecutarRespuestaExcepcionalCronificacion(
                                              data,
                                            ),
                                    icon: const Icon(Icons.policy_outlined),
                                    label: const Text(
                                      'Ejecutar respuesta excepcional',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                data
                                    .seguimientoPlanRespuestaExcepcionalCronificacion
                                    .lecturaEjecutiva,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _MetricaIncidencias(
                                    titulo: 'Respuestas aplicadas',
                                    valor:
                                        '${data.seguimientoPlanRespuestaExcepcionalCronificacion.presetsAplicados}',
                                    descripcion:
                                        'Ejecuciones ${data.seguimientoPlanRespuestaExcepcionalCronificacion.ejecucionesRegistradas} en los ultimos 30 dias.',
                                    icono: Icons.local_fire_department_outlined,
                                  ),
                                  _MetricaIncidencias(
                                    titulo: 'Conversion excepcional',
                                    valor:
                                        '${data.seguimientoPlanRespuestaExcepcionalCronificacion.conversionPorcentaje}%',
                                    descripcion:
                                        'Pendientes ${data.seguimientoPlanRespuestaExcepcionalCronificacion.pendientes}.',
                                    icono: Icons.policy_outlined,
                                  ),
                                  _MetricaIncidencias(
                                    titulo: 'Efecto excepcional',
                                    valor: data
                                        .seguimientoPlanRespuestaExcepcionalCronificacion
                                        .estadoEfecto,
                                    descripcion:
                                        'Impacto observado despues de activar la respuesta excepcional sobre modulos cronificados.',
                                    icono: Icons.monitor_heart_outlined,
                                  ),
                                ],
                              ),
                              if (data.planCierreExtremoCronificacion.estado !=
                                  'No requerido') ...[
                                const SizedBox(height: 12),
                                Text(
                                  data.planCierreExtremoCronificacion
                                      .lecturaEjecutiva,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _MetricaIncidencias(
                                      titulo: 'Cierre extremo',
                                      valor: data
                                          .planCierreExtremoCronificacion
                                          .tipoCierre,
                                      descripcion: data
                                          .planCierreExtremoCronificacion
                                          .criterioCierre,
                                      icono: Icons.lock_reset_outlined,
                                    ),
                                    _MetricaIncidencias(
                                      titulo: 'Horizonte de cierre',
                                      valor:
                                          '${data.planCierreExtremoCronificacion.horizonteDias} dias',
                                      descripcion:
                                          'Modulos foco: ${data.planCierreExtremoCronificacion.modulosCriticos.join(', ')}.',
                                      icono: Icons.gpp_maybe_outlined,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: data
                                      .planCierreExtremoCronificacion
                                      .accionesSugeridas
                                      .map(
                                        (item) => Chip(
                                          avatar: const Icon(
                                            Icons.lock_reset_outlined,
                                            size: 18,
                                          ),
                                          label: Text(item),
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.tonalIcon(
                                      onPressed:
                                          () =>
                                              _aplicarPlanCierreExtremoCronificacion(
                                                data,
                                              ),
                                      icon: const Icon(
                                        Icons.lock_reset_outlined,
                                      ),
                                      label: const Text(
                                        'Aplicar cierre extremo',
                                      ),
                                    ),
                                    FilledButton.icon(
                                      onPressed:
                                          () =>
                                              _ejecutarPlanCierreExtremoCronificacion(
                                                data,
                                              ),
                                      icon: const Icon(
                                        Icons.gpp_maybe_outlined,
                                      ),
                                      label: const Text(
                                        'Ejecutar cierre extremo',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data
                                      .seguimientoPlanCierreExtremoCronificacion
                                      .lecturaEjecutiva,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _MetricaIncidencias(
                                      titulo: 'Cierres aplicados',
                                      valor:
                                          '${data.seguimientoPlanCierreExtremoCronificacion.presetsAplicados}',
                                      descripcion:
                                          'Ejecuciones ${data.seguimientoPlanCierreExtremoCronificacion.ejecucionesRegistradas} en los ultimos 30 dias.',
                                      icono: Icons.lock_reset_outlined,
                                    ),
                                    _MetricaIncidencias(
                                      titulo: 'Conversion del cierre',
                                      valor:
                                          '${data.seguimientoPlanCierreExtremoCronificacion.conversionPorcentaje}%',
                                      descripcion:
                                          'Pendientes ${data.seguimientoPlanCierreExtremoCronificacion.pendientes}.',
                                      icono: Icons.gpp_maybe_outlined,
                                    ),
                                    _MetricaIncidencias(
                                      titulo: 'Efecto del cierre',
                                      valor: data
                                          .seguimientoPlanCierreExtremoCronificacion
                                          .estadoEfecto,
                                      descripcion:
                                          'Impacto observado despues de activar el cierre extremo sobre modulos cronificados.',
                                      icono: Icons.monitor_heart_outlined,
                                    ),
                                  ],
                                ),
                                if (data.planCorteTotalCronificacion.estado !=
                                    'No requerido') ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    data.planCorteTotalCronificacion
                                        .lecturaEjecutiva,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _MetricaIncidencias(
                                        titulo: 'Corte total',
                                        valor: data
                                            .planCorteTotalCronificacion
                                            .tipoCorte,
                                        descripcion: data
                                            .planCorteTotalCronificacion
                                            .criterioCorte,
                                        icono: Icons.block_outlined,
                                      ),
                                      _MetricaIncidencias(
                                        titulo: 'Horizonte de corte',
                                        valor:
                                            '${data.planCorteTotalCronificacion.horizonteDias} dias',
                                        descripcion:
                                            'Modulos foco: ${data.planCorteTotalCronificacion.modulosCriticos.join(', ')}.',
                                        icono: Icons.cancel_schedule_send_outlined,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: data
                                        .planCorteTotalCronificacion
                                        .accionesSugeridas
                                        .map(
                                          (item) => Chip(
                                            avatar: const Icon(
                                              Icons.block_outlined,
                                              size: 18,
                                            ),
                                            label: Text(item),
                                          ),
                                        )
                                        .toList(growable: false),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      FilledButton.tonalIcon(
                                        onPressed:
                                            () =>
                                                _aplicarPlanCorteTotalCronificacion(
                                                  data,
                                                ),
                                        icon: const Icon(
                                          Icons.block_outlined,
                                        ),
                                        label: const Text(
                                          'Aplicar corte total',
                                        ),
                                      ),
                                      FilledButton.icon(
                                        onPressed:
                                            () =>
                                                _ejecutarPlanCorteTotalCronificacion(
                                                  data,
                                                ),
                                        icon: const Icon(
                                          Icons.cancel_schedule_send_outlined,
                                        ),
                                        label: const Text(
                                          'Ejecutar corte total',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    data
                                        .seguimientoPlanCorteTotalCronificacion
                                        .lecturaEjecutiva,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: cs.onSurfaceVariant,
                                          height: 1.4,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      _MetricaIncidencias(
                                        titulo: 'Cortes aplicados',
                                        valor:
                                            '${data.seguimientoPlanCorteTotalCronificacion.presetsAplicados}',
                                        descripcion:
                                            'Ejecuciones ${data.seguimientoPlanCorteTotalCronificacion.ejecucionesRegistradas} en los ultimos 30 dias.',
                                        icono: Icons.block_outlined,
                                      ),
                                      _MetricaIncidencias(
                                        titulo: 'Conversion del corte',
                                        valor:
                                            '${data.seguimientoPlanCorteTotalCronificacion.conversionPorcentaje}%',
                                        descripcion:
                                            'Pendientes ${data.seguimientoPlanCorteTotalCronificacion.pendientes}.',
                                        icono: Icons.cancel_schedule_send_outlined,
                                      ),
                                      _MetricaIncidencias(
                                        titulo: 'Efecto del corte',
                                        valor: data
                                            .seguimientoPlanCorteTotalCronificacion
                                            .estadoEfecto,
                                        descripcion:
                                            'Impacto observado despues de activar el corte total sobre modulos cronificados.',
                                        icono: Icons.monitor_heart_outlined,
                                      ),
                                    ],
                                  ),
                                  if (data.protocoloFinalClausura.estado !=
                                      'No requerido') ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      data.protocoloFinalClausura
                                          .lecturaEjecutiva,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        _MetricaIncidencias(
                                          titulo: 'Clausura final',
                                          valor: data
                                              .protocoloFinalClausura
                                              .tipoClausura,
                                          descripcion: data
                                              .protocoloFinalClausura
                                              .criterioClausura,
                                          icono: Icons.domain_disabled_outlined,
                                        ),
                                        _MetricaIncidencias(
                                          titulo: 'Horizonte de clausura',
                                          valor:
                                              '${data.protocoloFinalClausura.horizonteDias} dias',
                                          descripcion:
                                              'Modulos foco: ${data.protocoloFinalClausura.modulosCriticos.join(', ')}.',
                                          icono:
                                              Icons.remove_circle_outline_outlined,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: data
                                          .protocoloFinalClausura
                                          .accionesSugeridas
                                          .map(
                                            (item) => Chip(
                                              avatar: const Icon(
                                                Icons.domain_disabled_outlined,
                                                size: 18,
                                              ),
                                              label: Text(item),
                                            ),
                                          )
                                          .toList(growable: false),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        FilledButton.tonalIcon(
                                          onPressed:
                                              () =>
                                                  _aplicarProtocoloFinalClausura(
                                                    data,
                                                  ),
                                          icon: const Icon(
                                            Icons.domain_disabled_outlined,
                                          ),
                                          label: const Text(
                                            'Aplicar clausura final',
                                          ),
                                        ),
                                        FilledButton.icon(
                                          onPressed:
                                              () =>
                                                  _ejecutarProtocoloFinalClausura(
                                                    data,
                                                  ),
                                          icon: const Icon(
                                            Icons.remove_circle_outline_outlined,
                                          ),
                                          label: const Text(
                                            'Ejecutar clausura final',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      data
                                          .seguimientoProtocoloFinalClausura
                                          .lecturaEjecutiva,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            height: 1.4,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        _MetricaIncidencias(
                                          titulo: 'Clausuras aplicadas',
                                          valor:
                                              '${data.seguimientoProtocoloFinalClausura.presetsAplicados}',
                                          descripcion:
                                              'Ejecuciones ${data.seguimientoProtocoloFinalClausura.ejecucionesRegistradas} en los ultimos 30 dias.',
                                          icono: Icons.domain_disabled_outlined,
                                        ),
                                        _MetricaIncidencias(
                                          titulo: 'Conversion de clausura',
                                          valor:
                                              '${data.seguimientoProtocoloFinalClausura.conversionPorcentaje}%',
                                          descripcion:
                                              'Pendientes ${data.seguimientoProtocoloFinalClausura.pendientes}.',
                                          icono:
                                              Icons.remove_circle_outline_outlined,
                                        ),
                                        _MetricaIncidencias(
                                          titulo: 'Efecto de clausura',
                                          valor: data
                                              .seguimientoProtocoloFinalClausura
                                              .estadoEfecto,
                                          descripcion:
                                              'Impacto observado despues de activar la clausura institucional final sobre modulos cronificados.',
                                          icono: Icons.monitor_heart_outlined,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ],
                            ],
                          ],
                        ],
                      ],
                    ],
                  ],
                ],
              ],
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.planEstabilizacion.accionesSugeridas
                  .map(
                    (item) => Chip(
                      avatar: const Icon(Icons.task_alt_outlined, size: 18),
                      label: Text(item),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => _aplicarPlanEstabilizacion(data),
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text('Aplicar plan'),
                ),
                FilledButton.icon(
                  onPressed: () => _ejecutarPlanEstabilizacion(data),
                  icon: const Icon(Icons.playlist_add_check_circle_outlined),
                  label: const Text('Ejecutar plan'),
                ),
              ],
            ),
          ],
          if (data.historialEjecutivo.eventos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.historialEjecutivo.eventos
                  .map((item) => _TarjetaEventoEjecutivoMesa(item: item))
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Actividad masiva reciente',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            data.accionesMasivas.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Intervenciones en lote',
                valor: '${data.accionesMasivas.totalReciente}',
                descripcion: 'Acciones masivas registradas en los ultimos 14 dias.',
                icono: Icons.stacked_line_chart_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Priorizaciones',
                valor: '${data.accionesMasivas.priorizaciones}',
                descripcion: 'Casos escalados con criterio comun.',
                icono: Icons.priority_high_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Derivaciones',
                valor: '${data.accionesMasivas.derivaciones}',
                descripcion: 'Casos empujados a Legajos en lote.',
                icono: Icons.folder_open_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Devoluciones y notas',
                valor:
                    '${data.accionesMasivas.devoluciones + data.accionesMasivas.observaciones}',
                descripcion: 'Acciones de reactivacion y observacion comun.',
                icono: Icons.move_up_outlined,
              ),
            ],
          ),
          if (data.accionesMasivas.impactosPorModulo.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.accionesMasivas.impactosPorModulo
                  .map((item) => _TarjetaImpactoMasivoModulo(item: item))
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Seguimiento de alertas sugeridas',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            data.seguimientoAlertas.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Presets aplicados',
                valor: '${data.seguimientoAlertas.presetsAplicados}',
                descripcion: 'Alertas que ya reconfiguraron la mesa recientemente.',
                icono: Icons.filter_alt_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Acciones ejecutadas',
                valor: '${data.seguimientoAlertas.accionesEjecutadas}',
                descripcion: 'Presets que avanzaron hacia una accion sugerida real.',
                icono: Icons.playlist_add_check_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Pendientes',
                valor: '${data.seguimientoAlertas.pendientes}',
                descripcion: 'Presets aplicados sin accion sugerida registrada aun.',
                icono: Icons.pending_actions_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Comparativa temporal',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            data.comparativaTemporal.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaIncidencias(
                titulo: 'Acciones actuales',
                valor: '${data.comparativaTemporal.accionesActuales}',
                descripcion:
                    'Periodo actual vs previo: ${data.comparativaTemporal.accionesPrevias}.',
                icono: Icons.compare_arrows_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Conversion actual',
                valor: '${data.comparativaTemporal.conversionActual}%',
                descripcion:
                    'Periodo previo: ${data.comparativaTemporal.conversionPrevia}%.',
                icono: Icons.insights_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Presion operativa',
                valor: data.comparativaTemporal.estadoActividad,
                descripcion: 'Lectura de la actividad masiva entre periodos.',
                icono: Icons.stacked_line_chart_outlined,
              ),
              _MetricaIncidencias(
                titulo: 'Conversion',
                valor: data.comparativaTemporal.estadoConversion,
                descripcion: 'Lectura de respuesta operativa entre periodos.',
                icono: Icons.trending_up_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Alertas automaticas de la mesa',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            data.alertasMesa.isEmpty
                ? 'La actividad reciente no muestra desbordes operativos relevantes en la mesa transversal.'
                : 'La mesa detecto senales ejecutivas sobre modulos con devoluciones, derivaciones o intervenciones intensas recientes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (data.alertasMesa.isEmpty)
            const _EstadoIncidencias(
              icono: Icons.health_and_safety_outlined,
              titulo: 'Sin alertas ejecutivas recientes',
              descripcion:
                  'La mesa transversal no detecto presiones operativas criticas en los ultimos movimientos masivos.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.alertasMesa
                  .map(
                    (item) => _TarjetaAlertaMesaIncidencias(
                      item: item,
                      onVerCasos: () => _aplicarAlertaMesa(item, data.incidencias),
                    ),
                  )
                  .toList(growable: false),
            ),
          if (_alertaActiva != null) ...[
            const SizedBox(height: 12),
            _BarraAccionSugeridaAlertaMesa(
              alerta: _alertaActiva!,
              casosVisibles: incidenciasVisibles.length,
              etiquetaAccion: _etiquetaAccionSugeridaAlerta(_alertaActiva!),
              onAplicar:
                  incidenciasVisibles.isEmpty
                      ? null
                      : () => _ejecutarAccionSugeridaAlerta(
                        contexto,
                        _alertaActiva!,
                        incidenciasVisibles,
                      ),
              onLimpiar: _limpiarPresetAlerta,
            ),
          ],
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['todas', 'secretaria', 'preceptoria', 'biblioteca']
                .map(
                  (item) => ChoiceChip(
                    label: Text(item[0].toUpperCase() + item.substring(1)),
                    selected: _filtroOrigen == item,
                    onSelected: (_) => _actualizarVista(() => _filtroOrigen = item),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: EstilosAplicacion.radioSuave,
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtros y semaforizacion',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Urgentes'),
                        selected: _soloUrgentes,
                        onSelected: (value) =>
                            _actualizarVista(() => _soloUrgentes = value),
                      ),
                      FilterChip(
                        label: const Text('Devueltas'),
                        selected: _soloDevueltas,
                        onSelected: (value) =>
                            _actualizarVista(() => _soloDevueltas = value),
                      ),
                      FilterChip(
                        label: const Text('Vencidas'),
                        selected: _soloVencidas,
                        onSelected: (value) =>
                            _actualizarVista(() => _soloVencidas = value),
                      ),
                      FilterChip(
                        label: const Text('Con legajo'),
                        selected: _soloConLegajo,
                        onSelected: (value) =>
                            _actualizarVista(() => _soloConLegajo = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['todos', 'rojo', 'amarillo', 'verde']
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item[0].toUpperCase() + item.substring(1)),
                            selected: _filtroSemaforo == item,
                            onSelected: (_) =>
                                _actualizarVista(() => _filtroSemaforo = item),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<_OrdenIncidencias>(
                          initialValue: _orden,
                          decoration: const InputDecoration(
                            labelText: 'Ordenar por',
                          ),
                          items: _OrdenIncidencias.values
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value.etiqueta),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            if (value == null) return;
                            _actualizarVista(() => _orden = value);
                          },
                        ),
                      ),
                      _ChipSemaforoResumen(
                        semaforo: SemaforoIncidenciaTransversal.rojo,
                        valor: '$rojas',
                      ),
                      _ChipSemaforoResumen(
                        semaforo: SemaforoIncidenciaTransversal.amarillo,
                        valor: '$amarillas',
                      ),
                      _ChipSemaforoResumen(
                        semaforo: SemaforoIncidenciaTransversal.verde,
                        valor: '$verdes',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Resumen ejecutivo por modulo',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            focoPrincipal,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (resumenesPorModulo.isEmpty)
            const _EstadoIncidencias(
              icono: Icons.dashboard_outlined,
              titulo: 'Sin resumen disponible',
              descripcion:
                  'No hay incidencias visibles para construir una lectura ejecutiva por modulo.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: resumenesPorModulo
                  .map((item) => _TarjetaResumenModulo(item: item))
                  .toList(growable: false),
            ),
          const SizedBox(height: 18),
          Text(
            'Bandeja priorizada',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (incidenciasVisibles.isNotEmpty) ...[
            _BarraAccionesMasivasIncidencias(
              seleccionadas: seleccionadasVisibles.length,
              visibles: incidenciasVisibles.length,
              derivables: derivablesSeleccionadas.length,
              devolvibles: devolviblesSeleccionadas.length,
              onSeleccionarTodas: () =>
                  _seleccionarTodasLasVisibles(incidenciasVisibles),
              onLimpiarSeleccion:
                  seleccionadasVisibles.isEmpty ? null : _limpiarSeleccion,
              onPriorizar:
                  seleccionadasVisibles.isEmpty
                      ? null
                      : () => _priorizarSeleccionadas(seleccionadasVisibles),
              onRegistrarObservacion:
                  seleccionadasVisibles.isEmpty
                      ? null
                      : () => _registrarObservacionSeleccionadas(
                        seleccionadasVisibles,
                      ),
              onDerivar:
                  derivablesSeleccionadas.isEmpty
                      ? null
                      : () => _derivarSeleccionadasALegajos(
                        contexto,
                        derivablesSeleccionadas,
                      ),
              onDevolver:
                  devolviblesSeleccionadas.isEmpty
                      ? null
                      : () => _devolverSeleccionadasAlOrigen(
                        devolviblesSeleccionadas,
                      ),
            ),
            const SizedBox(height: 12),
          ],
          if (incidenciasVisibles.isEmpty)
            const _EstadoIncidencias(
              icono: Icons.filter_alt_off_outlined,
              titulo: 'Sin incidencias para este filtro',
              descripcion:
                  'Cambia el origen activo para revisar otros cruces institucionales.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: incidenciasVisibles
                  .map(
                    (item) => _TarjetaIncidencia(
                      item: item,
                      seleccionada: _seleccionadas.contains(_claveCaso(item)),
                      onSeleccionar:
                          (value) => _actualizarSeleccion(item, value),
                      onPriorizar: () => _priorizar(item),
                      onVerHistorial: () => _verHistorial(item),
                      onDerivarALegajos:
                          item.codigoLegajo == null
                              ? () => _derivarALegajos(contexto, item)
                              : null,
                      onDevolver:
                          item.codigoLegajo != null || item.estadoDocumental != null
                              ? () => _devolverAlOrigen(item)
                              : null,
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  List<IncidenciaTransversal> _aplicarFiltrosYOrden(
    List<IncidenciaTransversal> incidencias,
  ) {
    final filtradas = incidencias.where((item) {
      if (_soloUrgentes && !item.urgente) return false;
      if (_soloDevueltas && !item.devueltaDesdeLegajos) return false;
      if (_soloVencidas && !item.vencida) return false;
      if (_soloConLegajo && item.codigoLegajo == null) return false;
      if (_filtroSemaforo == 'rojo' &&
          item.semaforo != SemaforoIncidenciaTransversal.rojo) {
        return false;
      }
      if (_filtroSemaforo == 'amarillo' &&
          item.semaforo != SemaforoIncidenciaTransversal.amarillo) {
        return false;
      }
      if (_filtroSemaforo == 'verde' &&
          item.semaforo != SemaforoIncidenciaTransversal.verde) {
        return false;
      }
      return true;
    }).toList(growable: false);

    filtradas.sort((a, b) {
      switch (_orden) {
        case _OrdenIncidencias.prioridad:
          return _pesoOrden(b).compareTo(_pesoOrden(a));
        case _OrdenIncidencias.vencimiento:
          final fechaA = a.fechaCompromiso ?? DateTime(2100);
          final fechaB = b.fechaCompromiso ?? DateTime(2100);
          return fechaA.compareTo(fechaB);
        case _OrdenIncidencias.origen:
          final cmp = a.origen.compareTo(b.origen);
          if (cmp != 0) return cmp;
          return _pesoOrden(b).compareTo(_pesoOrden(a));
        case _OrdenIncidencias.estadoDocumental:
          return (a.estadoDocumental ?? 'Sin legajo').compareTo(
            b.estadoDocumental ?? 'Sin legajo',
          );
      }
    });
    return filtradas;
  }

  String _claveCaso(IncidenciaTransversal item) => '${item.origen}|${item.referencia}';

  void _actualizarVista(VoidCallback cambios, {bool limpiarAlerta = true}) {
    setState(() {
      cambios();
      _seleccionadas.clear();
      if (limpiarAlerta) {
        _alertaActiva = null;
      }
    });
  }

  void _actualizarSeleccion(IncidenciaTransversal item, bool seleccionada) {
    setState(() {
      final clave = _claveCaso(item);
      if (seleccionada) {
        _seleccionadas.add(clave);
      } else {
        _seleccionadas.remove(clave);
      }
    });
  }

  void _seleccionarTodasLasVisibles(List<IncidenciaTransversal> items) {
    setState(() {
      final claves = items.map(_claveCaso).toSet();
      final todasSeleccionadas = claves.isNotEmpty &&
          claves.every((clave) => _seleccionadas.contains(clave));
      if (todasSeleccionadas) {
        _seleccionadas.removeAll(claves);
      } else {
        _seleccionadas.addAll(claves);
      }
    });
  }

  void _limpiarSeleccion() {
    setState(_seleccionadas.clear);
  }

  Future<void> _aplicarAlertaMesa(
    AlertaMesaIncidencias alerta,
    List<IncidenciaTransversal> incidenciasBase,
  ) async {
    final afectados = _incidenciasAfectadasPorAlerta(alerta, incidenciasBase);
    await Proveedores.incidenciasTransversalesRepositorio.registrarPresetAlerta(
      tipoAlerta: alerta.tipo,
      items: afectados,
    );
    if (!mounted) return;
    _actualizarVista(() {
      _filtroOrigen =
          alerta.tipo == 'baja_conversion_operativa' ||
                  alerta.tipo == 'clausura_final_insuficiente' ||
                  alerta.tipo == 'corte_total_insuficiente' ||
                  alerta.tipo == 'cierre_extremo_insuficiente' ||
                  alerta.tipo == 'respuesta_excepcional_insuficiente' ||
                  alerta.tipo == 'contencion_insuficiente' ||
                  alerta.tipo == 'reforzamiento_desacople_insuficiente' ||
                  alerta.tipo == 'desacople_insuficiente' ||
                  alerta.tipo == 'cronificacion_institucional_critica' ||
                  alerta.tipo == 'recomposicion_insuficiente' ||
                  alerta.tipo == 'recuperacion_insuficiente' ||
                  alerta.tipo == 'crisis_sostenida' ||
                  alerta.tipo == 'contingencia_insuficiente' ||
                  alerta.tipo == 'escalamiento_insuficiente' ||
                  alerta.tipo == 'ajuste_plan_inefectivo' ||
                  alerta.tipo == 'plan_estabilizacion_inefectivo' ||
                  alerta.tipo == 'oscilacion_cronica_cabecera' ||
                  alerta.tipo == 'baja_conversion_recomendacion_dominante' ||
                  alerta.tipo == 'deterioro_cabecera_ejecutiva' ||
                  alerta.tipo == 'recomendacion_ejecutiva_inestable' ||
                  alerta.tipo == 'deterioro_presion_temporal' ||
                  alerta.tipo == 'deterioro_conversion_temporal'
              ? 'todas'
              : alerta.origen.toLowerCase();
      _soloUrgentes = false;
      _soloDevueltas = false;
      _soloVencidas = false;
      _soloConLegajo = false;
      _filtroSemaforo = 'todos';
      _orden = _OrdenIncidencias.prioridad;

      switch (alerta.tipo) {
        case 'devoluciones_recurrentes':
          _soloDevueltas = true;
          break;
        case 'presion_documental_elevada':
          _soloConLegajo = true;
          break;
        case 'intervencion_roja':
          _soloUrgentes = true;
          _soloVencidas = true;
          _filtroSemaforo = 'rojo';
          break;
        case 'baja_conversion_operativa':
        case 'clausura_final_insuficiente':
        case 'corte_total_insuficiente':
        case 'cierre_extremo_insuficiente':
        case 'respuesta_excepcional_insuficiente':
        case 'contencion_insuficiente':
        case 'reforzamiento_desacople_insuficiente':
        case 'desacople_insuficiente':
        case 'cronificacion_institucional_critica':
        case 'recomposicion_insuficiente':
        case 'recuperacion_insuficiente':
        case 'crisis_sostenida':
        case 'contingencia_insuficiente':
        case 'escalamiento_insuficiente':
        case 'ajuste_plan_inefectivo':
        case 'plan_estabilizacion_inefectivo':
        case 'oscilacion_cronica_cabecera':
        case 'baja_conversion_recomendacion_dominante':
        case 'deterioro_cabecera_ejecutiva':
        case 'recomendacion_ejecutiva_inestable':
        case 'deterioro_presion_temporal':
        case 'deterioro_conversion_temporal':
          _soloUrgentes = true;
          break;
      }
      _alertaActiva = alerta;
    }, limpiarAlerta: false);
  }

  List<IncidenciaTransversal> _incidenciasAfectadasPorAlerta(
    AlertaMesaIncidencias alerta,
    List<IncidenciaTransversal> incidenciasBase,
  ) {
    final porOrigen = incidenciasBase
        .where((item) => item.origen == alerta.origen)
        .toList(growable: false);
    switch (alerta.tipo) {
      case 'devoluciones_recurrentes':
        return porOrigen
            .where((item) => item.devueltaDesdeLegajos)
            .toList(growable: false);
      case 'presion_documental_elevada':
        return porOrigen
            .where((item) => item.codigoLegajo != null)
            .toList(growable: false);
      case 'intervencion_roja':
        return porOrigen
            .where(
              (item) =>
                  item.urgente &&
                  item.vencida &&
                  item.semaforo == SemaforoIncidenciaTransversal.rojo,
            )
            .toList(growable: false);
      case 'baja_conversion_operativa':
      case 'clausura_final_insuficiente':
      case 'corte_total_insuficiente':
      case 'cierre_extremo_insuficiente':
      case 'respuesta_excepcional_insuficiente':
      case 'contencion_insuficiente':
      case 'reforzamiento_desacople_insuficiente':
      case 'desacople_insuficiente':
      case 'cronificacion_institucional_critica':
      case 'recomposicion_insuficiente':
      case 'recuperacion_insuficiente':
      case 'crisis_sostenida':
      case 'contingencia_insuficiente':
      case 'escalamiento_insuficiente':
      case 'ajuste_plan_inefectivo':
      case 'plan_estabilizacion_inefectivo':
      case 'oscilacion_cronica_cabecera':
      case 'baja_conversion_recomendacion_dominante':
      case 'deterioro_cabecera_ejecutiva':
      case 'recomendacion_ejecutiva_inestable':
      case 'deterioro_presion_temporal':
      case 'deterioro_conversion_temporal':
        return incidenciasBase
            .where((item) => item.urgente)
            .toList(growable: false);
      default:
        return porOrigen;
    }
  }

  AlertaMesaIncidencias? _buscarAlertaPorTipo(
    List<AlertaMesaIncidencias> alertas,
    String tipo,
  ) {
    for (final alerta in alertas) {
      if (alerta.tipo == tipo) return alerta;
    }
    return null;
  }

  Future<void> _aplicarRecomendacionDominante(DashboardIncidencias data) async {
    final tipo = data.recomendacionEjecutiva.tipoAlertaOrigen;
    if (tipo == 'sin_alerta') return;
    final alerta = _buscarAlertaPorTipo(data.alertasMesa, tipo);
    if (alerta == null) return;
    final afectados = _incidenciasAfectadasPorAlerta(alerta, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarFocoRecomendacionDominante(
          tipoAlerta: tipo,
          items: afectados,
        );
    await _aplicarAlertaMesa(alerta, data.incidencias);
  }

  Future<void> _ejecutarRecomendacionDominante(
    ContextoInstitucional contexto,
    DashboardIncidencias data,
  ) async {
    final tipo = data.recomendacionEjecutiva.tipoAlertaOrigen;
    if (tipo == 'sin_alerta') return;
    final alerta = _buscarAlertaPorTipo(data.alertasMesa, tipo);
    if (alerta == null) return;
    final afectados = _incidenciasAfectadasPorAlerta(alerta, data.incidencias);
    if (afectados.isEmpty) return;
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarAccionRapidaRecomendacionDominante(
          tipoAlerta: tipo,
          items: afectados,
        );
    await _ejecutarAccionSugeridaAlerta(contexto, alerta, afectados);
  }

  List<IncidenciaTransversal> _incidenciasAfectadasPorPlan(
    PlanEstabilizacionEjecutivaMesa plan,
    List<IncidenciaTransversal> incidenciasBase,
  ) {
    final modulos = plan.modulosPrioritarios
        .where((item) => item != 'Mesa transversal')
        .toSet();
    final base = modulos.isEmpty
        ? incidenciasBase
        : incidenciasBase
              .where((item) => modulos.contains(item.origen))
              .toList(growable: false);
    final urgentes = base
        .where((item) => item.urgente || item.vencida)
        .toList(growable: false);
    return urgentes.isEmpty ? base : urgentes;
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeAjuste(
    AjusteSugeridoPlanEstabilizacionMesa ajuste,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: ajuste.estado,
      criterio: ajuste.criterioAjustado,
      horizonteDias: ajuste.horizonteDiasSugerido,
      modulosPrioritarios: ajuste.modulosRefuerzo,
      accionesSugeridas: ajuste.accionesSugeridas,
      lecturaEjecutiva: ajuste.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeEscalamiento(
    EscalamientoEstrategicoCabeceraMesa escalamiento,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: escalamiento.estado,
      criterio: escalamiento.criterioEjecutivo,
      horizonteDias: escalamiento.horizonteDias,
      modulosPrioritarios: escalamiento.modulosCriticos,
      accionesSugeridas: escalamiento.accionesSugeridas,
      lecturaEjecutiva: escalamiento.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeProtocolo(
    ProtocoloContingenciaCabeceraMesa protocolo,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: protocolo.estado,
      criterio: protocolo.criterioInstitucional,
      horizonteDias: protocolo.horizonteDias,
      modulosPrioritarios: protocolo.modulosCriticos,
      accionesSugeridas: protocolo.accionesSugeridas,
      lecturaEjecutiva: protocolo.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeMesaCrisis(
    MesaCrisisInstitucionalCabecera mesa,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: mesa.estado,
      criterio: mesa.criterioCrisis,
      horizonteDias: mesa.horizonteDias,
      modulosPrioritarios: mesa.modulosCriticos,
      accionesSugeridas: mesa.accionesSugeridas,
      lecturaEjecutiva: mesa.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeProtocoloRecuperacion(
    ProtocoloRecuperacionInstitucionalMesa protocolo,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: protocolo.estado,
      criterio: protocolo.criterioRecuperacion,
      horizonteDias: protocolo.horizonteDias,
      modulosPrioritarios: protocolo.modulosPrioritarios,
      accionesSugeridas: protocolo.accionesSugeridas,
      lecturaEjecutiva: protocolo.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdePlanEstructural(
    PlanEstructuralRecomposicionMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioEstructural,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosPrioritarios,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeDesacopleCronificacion(
    PlanDesacopleCronificacionMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioDesacople,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosDesacople,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeReforzamientoDesacople(
    PlanReforzamientoDesacopleMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioReforzamiento,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosCriticos,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeContencionCronificacion(
    PlanContencionCronificacionMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioContencion,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosCriticos,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeRespuestaExcepcionalCronificacion(
    PlanRespuestaExcepcionalCronificacionMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioRespuesta,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosCriticos,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeCierreExtremoCronificacion(
    PlanCierreExtremoCronificacionMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioCierre,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosCriticos,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeCorteTotalCronificacion(
    PlanCorteTotalCronificacionMesa plan,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: plan.estado,
      criterio: plan.criterioCorte,
      horizonteDias: plan.horizonteDias,
      modulosPrioritarios: plan.modulosCriticos,
      accionesSugeridas: plan.accionesSugeridas,
      lecturaEjecutiva: plan.lecturaEjecutiva,
    );
  }

  PlanEstabilizacionEjecutivaMesa _planDesdeProtocoloFinalClausura(
    ProtocoloFinalClausuraInstitucionalMesa protocolo,
  ) {
    return PlanEstabilizacionEjecutivaMesa(
      estado: protocolo.estado,
      criterio: protocolo.criterioClausura,
      horizonteDias: protocolo.horizonteDias,
      modulosPrioritarios: protocolo.modulosCriticos,
      accionesSugeridas: protocolo.accionesSugeridas,
      lecturaEjecutiva: protocolo.lecturaEjecutiva,
    );
  }

  Future<void> _aplicarPlanEstabilizacion(DashboardIncidencias data) async {
    final plan = data.planEstabilizacion;
    if (plan.estado == 'No requerido') return;
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanEstabilizacion(plan: plan, items: afectados);
    if (!mounted) return;
    setState(() {
      final modulos = plan.modulosPrioritarios
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = data.consolidadoHistorico.estado == 'Critico';
      _soloConLegajo = false;
      _filtroSemaforo =
          data.consolidadoHistorico.estado == 'Critico' ? 'rojo' : 'todos';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanEstabilizacion(DashboardIncidencias data) async {
    final plan = data.planEstabilizacion;
    if (plan.estado == 'No requerido') return;
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = plan.horizonteDias <= 0
        ? null
        : DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanEstabilizacion(plan: plan, items: afectados);
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el plan de estabilizacion sobre $exitos casos priorizados.'
              : 'No se pudo ejecutar el plan de estabilizacion sobre los casos seleccionados.',
        ),
      ),
    );
  }

  Future<void> _aplicarAjustePlanEstabilizacion(DashboardIncidencias data) async {
    final ajuste = data.ajustePlan;
    if (ajuste.estado == 'No requerido') return;
    final plan = _planDesdeAjuste(ajuste);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetAjustePlanEstabilizacion(
          ajuste: ajuste,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = ajuste.modulosRefuerzo
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = data.seguimientoPlan.estadoEfecto == 'Sin efecto'
          ? 'rojo'
          : 'todos';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarAjustePlanEstabilizacion(DashboardIncidencias data) async {
    final ajuste = data.ajustePlan;
    if (ajuste.estado == 'No requerido') return;
    final plan = _planDesdeAjuste(ajuste);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = plan.horizonteDias <= 0
        ? null
        : DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionAjustePlanEstabilizacion(
          ajuste: ajuste,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el ajuste sugerido sobre $exitos casos priorizados.'
              : 'No se pudo ejecutar el ajuste sugerido sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarEscalamientoCabecera(DashboardIncidencias data) async {
    final escalamiento = data.escalamientoCabecera;
    if (escalamiento.estado == 'No requerido') return;
    final plan = _planDesdeEscalamiento(escalamiento);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetEscalamientoCabecera(
          escalamiento: escalamiento,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = escalamiento.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarEscalamientoCabecera(DashboardIncidencias data) async {
    final escalamiento = data.escalamientoCabecera;
    if (escalamiento.estado == 'No requerido') return;
    final plan = _planDesdeEscalamiento(escalamiento);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionEscalamientoCabecera(
          escalamiento: escalamiento,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el escalamiento estrategico sobre $exitos casos criticos.'
              : 'No se pudo ejecutar el escalamiento estrategico sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarProtocoloContingencia(DashboardIncidencias data) async {
    final protocolo = data.protocoloContingencia;
    if (protocolo.estado == 'No requerido') return;
    final plan = _planDesdeProtocolo(protocolo);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetProtocoloContingencia(
          protocolo: protocolo,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = protocolo.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarProtocoloContingencia(DashboardIncidencias data) async {
    final protocolo = data.protocoloContingencia;
    if (protocolo.estado == 'No requerido') return;
    final plan = _planDesdeProtocolo(protocolo);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionProtocoloContingencia(
          protocolo: protocolo,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el protocolo de contingencia sobre $exitos casos criticos.'
              : 'No se pudo ejecutar el protocolo de contingencia sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarMesaCrisis(DashboardIncidencias data) async {
    final mesa = data.mesaCrisis;
    if (mesa.estado == 'No requerida') return;
    final plan = _planDesdeMesaCrisis(mesa);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio.registrarPresetMesaCrisis(
      mesa: mesa,
      items: afectados,
    );
    if (!mounted) return;
    setState(() {
      final modulos = mesa.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarMesaCrisis(DashboardIncidencias data) async {
    final mesa = data.mesaCrisis;
    if (mesa.estado == 'No requerida') return;
    final plan = _planDesdeMesaCrisis(mesa);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionMesaCrisis(
          mesa: mesa,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto la mesa de crisis institucional sobre $exitos casos criticos.'
              : 'No se pudo ejecutar la mesa de crisis institucional sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarProtocoloRecuperacion(DashboardIncidencias data) async {
    final protocolo = data.protocoloRecuperacion;
    if (protocolo.estado == 'No requerido') return;
    final plan = _planDesdeProtocoloRecuperacion(protocolo);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetProtocoloRecuperacion(
          protocolo: protocolo,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = protocolo.modulosPrioritarios
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarProtocoloRecuperacion(DashboardIncidencias data) async {
    final protocolo = data.protocoloRecuperacion;
    if (protocolo.estado == 'No requerido') return;
    final plan = _planDesdeProtocoloRecuperacion(protocolo);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionProtocoloRecuperacion(
          protocolo: protocolo,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el protocolo de recuperacion institucional sobre $exitos casos foco.'
              : 'No se pudo ejecutar el protocolo de recuperacion institucional sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarPlanEstructural(DashboardIncidencias data) async {
    final planEstructural = data.planEstructural;
    if (planEstructural.estado == 'No requerido') return;
    final plan = _planDesdePlanEstructural(planEstructural);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanEstructural(
          plan: planEstructural,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planEstructural.modulosPrioritarios
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanEstructural(DashboardIncidencias data) async {
    final planEstructural = data.planEstructural;
    if (planEstructural.estado == 'No requerido') return;
    final plan = _planDesdePlanEstructural(planEstructural);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanEstructural(
          plan: planEstructural,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el plan estructural de recomposicion sobre $exitos casos foco.'
              : 'No se pudo ejecutar el plan estructural de recomposicion sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarPlanDesacople(DashboardIncidencias data) async {
    final planDesacople = data.planDesacople;
    if (planDesacople.estado == 'No requerido') return;
    final plan = _planDesdeDesacopleCronificacion(planDesacople);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanDesacopleCronificacion(
          plan: planDesacople,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planDesacople.modulosDesacople
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanDesacople(DashboardIncidencias data) async {
    final planDesacople = data.planDesacople;
    if (planDesacople.estado == 'No requerido') return;
    final plan = _planDesdeDesacopleCronificacion(planDesacople);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanDesacopleCronificacion(
          plan: planDesacople,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el plan de desacople de cronificacion sobre $exitos casos foco.'
              : 'No se pudo ejecutar el plan de desacople de cronificacion sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarPlanReforzamientoDesacople(
    DashboardIncidencias data,
  ) async {
    final planReforzamiento = data.planReforzamientoDesacople;
    if (planReforzamiento.estado == 'No requerido') return;
    final plan = _planDesdeReforzamientoDesacople(planReforzamiento);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanReforzamientoDesacople(
          plan: planReforzamiento,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planReforzamiento.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanReforzamientoDesacople(
    DashboardIncidencias data,
  ) async {
    final planReforzamiento = data.planReforzamientoDesacople;
    if (planReforzamiento.estado == 'No requerido') return;
    final plan = _planDesdeReforzamientoDesacople(planReforzamiento);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanReforzamientoDesacople(
          plan: planReforzamiento,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el reforzamiento del desacople sobre $exitos casos foco.'
              : 'No se pudo ejecutar el reforzamiento del desacople sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarPlanContencionCronificacion(
    DashboardIncidencias data,
  ) async {
    final planContencion = data.planContencionCronificacion;
    if (planContencion.estado == 'No requerido') return;
    final plan = _planDesdeContencionCronificacion(planContencion);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanContencionCronificacion(
          plan: planContencion,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planContencion.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanContencionCronificacion(
    DashboardIncidencias data,
  ) async {
    final planContencion = data.planContencionCronificacion;
    if (planContencion.estado == 'No requerido') return;
    final plan = _planDesdeContencionCronificacion(planContencion);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanContencionCronificacion(
          plan: planContencion,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el plan de contencion de cronificacion sobre $exitos casos foco.'
              : 'No se pudo ejecutar el plan de contencion de cronificacion sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarRespuestaExcepcionalCronificacion(
    DashboardIncidencias data,
  ) async {
    final planExcepcional = data.planRespuestaExcepcionalCronificacion;
    if (planExcepcional.estado == 'No requerido') return;
    final plan = _planDesdeRespuestaExcepcionalCronificacion(planExcepcional);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanRespuestaExcepcionalCronificacion(
          plan: planExcepcional,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planExcepcional.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarRespuestaExcepcionalCronificacion(
    DashboardIncidencias data,
  ) async {
    final planExcepcional = data.planRespuestaExcepcionalCronificacion;
    if (planExcepcional.estado == 'No requerido') return;
    final plan = _planDesdeRespuestaExcepcionalCronificacion(planExcepcional);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanRespuestaExcepcionalCronificacion(
          plan: planExcepcional,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto la respuesta excepcional de cronificacion sobre $exitos casos foco.'
              : 'No se pudo ejecutar la respuesta excepcional de cronificacion sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarPlanCierreExtremoCronificacion(
    DashboardIncidencias data,
  ) async {
    final planCierre = data.planCierreExtremoCronificacion;
    if (planCierre.estado == 'No requerido') return;
    final plan = _planDesdeCierreExtremoCronificacion(planCierre);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanCierreExtremoCronificacion(
          plan: planCierre,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planCierre.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanCierreExtremoCronificacion(
    DashboardIncidencias data,
  ) async {
    final planCierre = data.planCierreExtremoCronificacion;
    if (planCierre.estado == 'No requerido') return;
    final plan = _planDesdeCierreExtremoCronificacion(planCierre);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanCierreExtremoCronificacion(
          plan: planCierre,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el cierre extremo de cronificacion sobre $exitos casos foco.'
              : 'No se pudo ejecutar el cierre extremo de cronificacion sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarPlanCorteTotalCronificacion(
    DashboardIncidencias data,
  ) async {
    final planCorte = data.planCorteTotalCronificacion;
    if (planCorte.estado == 'No requerido') return;
    final plan = _planDesdeCorteTotalCronificacion(planCorte);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetPlanCorteTotalCronificacion(
          plan: planCorte,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = planCorte.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarPlanCorteTotalCronificacion(
    DashboardIncidencias data,
  ) async {
    final planCorte = data.planCorteTotalCronificacion;
    if (planCorte.estado == 'No requerido') return;
    final plan = _planDesdeCorteTotalCronificacion(planCorte);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionPlanCorteTotalCronificacion(
          plan: planCorte,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto el corte total de cronificacion sobre $exitos casos foco.'
              : 'No se pudo ejecutar el corte total de cronificacion sobre los casos foco.',
        ),
      ),
    );
  }

  Future<void> _aplicarProtocoloFinalClausura(
    DashboardIncidencias data,
  ) async {
    final protocolo = data.protocoloFinalClausura;
    if (protocolo.estado == 'No requerido') return;
    final plan = _planDesdeProtocoloFinalClausura(protocolo);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarPresetProtocoloFinalClausura(
          protocolo: protocolo,
          items: afectados,
        );
    if (!mounted) return;
    setState(() {
      final modulos = protocolo.modulosCriticos
          .where((item) => item != 'Mesa transversal')
          .toList(growable: false);
      _filtroOrigen = modulos.length == 1 ? modulos.first.toLowerCase() : 'todas';
      _soloUrgentes = true;
      _soloDevueltas = false;
      _soloVencidas = true;
      _soloConLegajo = false;
      _filtroSemaforo = 'rojo';
      _orden = _OrdenIncidencias.prioridad;
      _alertaActiva = null;
      _seleccionadas
        ..clear()
        ..addAll(afectados.map(_claveCaso));
    });
  }

  Future<void> _ejecutarProtocoloFinalClausura(
    DashboardIncidencias data,
  ) async {
    final protocolo = data.protocoloFinalClausura;
    if (protocolo.estado == 'No requerido') return;
    final plan = _planDesdeProtocoloFinalClausura(protocolo);
    final afectados = _incidenciasAfectadasPorPlan(plan, data.incidencias);
    if (afectados.isEmpty) return;
    final fechaObjetivo = DateTime.now().add(Duration(days: plan.horizonteDias));
    var exitos = 0;
    for (final item in afectados) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: plan.criterio,
        fechaObjetivo: fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarEjecucionProtocoloFinalClausura(
          protocolo: protocolo,
          items: afectados,
        );
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se ejecuto la clausura institucional final sobre $exitos casos foco.'
              : 'No se pudo ejecutar la clausura institucional final sobre los casos foco.',
        ),
      ),
    );
  }

  void _limpiarPresetAlerta() {
    _actualizarVista(() {
      _filtroOrigen = 'todas';
      _soloUrgentes = false;
      _soloDevueltas = false;
      _soloVencidas = false;
      _soloConLegajo = false;
      _filtroSemaforo = 'todos';
      _orden = _OrdenIncidencias.prioridad;
    });
  }

  String _etiquetaAccionSugeridaAlerta(AlertaMesaIncidencias alerta) {
    switch (alerta.tipo) {
      case 'intervencion_roja':
      case 'baja_conversion_operativa':
      case 'clausura_final_insuficiente':
      case 'corte_total_insuficiente':
      case 'cierre_extremo_insuficiente':
      case 'respuesta_excepcional_insuficiente':
      case 'contencion_insuficiente':
      case 'reforzamiento_desacople_insuficiente':
      case 'desacople_insuficiente':
      case 'cronificacion_institucional_critica':
      case 'recomposicion_insuficiente':
      case 'recuperacion_insuficiente':
      case 'crisis_sostenida':
      case 'contingencia_insuficiente':
      case 'escalamiento_insuficiente':
      case 'ajuste_plan_inefectivo':
      case 'plan_estabilizacion_inefectivo':
      case 'oscilacion_cronica_cabecera':
      case 'baja_conversion_recomendacion_dominante':
      case 'deterioro_cabecera_ejecutiva':
      case 'recomendacion_ejecutiva_inestable':
      case 'deterioro_presion_temporal':
        return 'Priorizar visibles';
      case 'deterioro_conversion_temporal':
        return 'Registrar observacion comun';
      case 'devoluciones_recurrentes':
      case 'presion_documental_elevada':
        return 'Registrar observacion comun';
      default:
        return 'Aplicar accion sugerida';
    }
  }

  Future<void> _ejecutarAccionSugeridaAlerta(
    ContextoInstitucional contexto,
    AlertaMesaIncidencias alerta,
    List<IncidenciaTransversal> incidenciasVisibles,
  ) async {
    if (incidenciasVisibles.isEmpty) return;
    switch (alerta.tipo) {
      case 'intervencion_roja':
      case 'baja_conversion_operativa':
      case 'clausura_final_insuficiente':
      case 'corte_total_insuficiente':
      case 'cierre_extremo_insuficiente':
      case 'respuesta_excepcional_insuficiente':
      case 'contencion_insuficiente':
      case 'reforzamiento_desacople_insuficiente':
      case 'desacople_insuficiente':
      case 'cronificacion_institucional_critica':
      case 'recomposicion_insuficiente':
      case 'recuperacion_insuficiente':
      case 'crisis_sostenida':
      case 'contingencia_insuficiente':
      case 'escalamiento_insuficiente':
      case 'ajuste_plan_inefectivo':
      case 'plan_estabilizacion_inefectivo':
      case 'oscilacion_cronica_cabecera':
      case 'baja_conversion_recomendacion_dominante':
      case 'deterioro_cabecera_ejecutiva':
      case 'recomendacion_ejecutiva_inestable':
      case 'deterioro_presion_temporal':
        await _priorizarSeleccionadas(incidenciasVisibles);
        break;
      case 'devoluciones_recurrentes':
      case 'presion_documental_elevada':
      case 'deterioro_conversion_temporal':
        await _registrarObservacionSeleccionadas(incidenciasVisibles);
        break;
    }
    await Proveedores.incidenciasTransversalesRepositorio
        .registrarAccionSugeridaAlerta(
          tipoAlerta: alerta.tipo,
          items: incidenciasVisibles,
        );
  }

  List<_ResumenModuloIncidencias> _resumenesPorModulo(
    List<IncidenciaTransversal> incidencias,
  ) {
    final grupos = <String, List<IncidenciaTransversal>>{};
    for (final item in incidencias) {
      grupos.putIfAbsent(item.origen, () => <IncidenciaTransversal>[]).add(item);
    }

    final resumenes = grupos.entries.map((entry) {
      final items = entry.value;
      final rojas = items
          .where((item) => item.semaforo == SemaforoIncidenciaTransversal.rojo)
          .length;
      final amarillas = items
          .where(
            (item) => item.semaforo == SemaforoIncidenciaTransversal.amarillo,
          )
          .length;
      final devueltas = items.where((item) => item.devueltaDesdeLegajos).length;
      final vencidas = items.where((item) => item.vencida).length;
      return _ResumenModuloIncidencias(
        origen: entry.key,
        total: items.length,
        rojas: rojas,
        amarillas: amarillas,
        devueltas: devueltas,
        vencidas: vencidas,
        icono: items.first.iconoOrigen,
      );
    }).toList(growable: false);

    resumenes.sort((a, b) {
      final peso = b.pesoRiesgo.compareTo(a.pesoRiesgo);
      if (peso != 0) return peso;
      return b.total.compareTo(a.total);
    });
    return resumenes;
  }

  String _focoPrincipal(List<_ResumenModuloIncidencias> resumenes) {
    if (resumenes.isEmpty) {
      return 'La mesa todavia no tiene suficientes casos visibles para identificar un foco institucional.';
    }
    final principal = resumenes.first;
    if (principal.rojas > 0) {
      return '${principal.origen} concentra la mayor tension actual, con ${principal.rojas} casos rojos y ${principal.vencidas} vencidos visibles.';
    }
    if (principal.devueltas > 0) {
      return '${principal.origen} lidera las devoluciones desde Legajos, con ${principal.devueltas} casos que requieren reactivacion operativa.';
    }
    return '${principal.origen} concentra hoy el mayor volumen transversal, con ${principal.total} casos visibles en seguimiento.';
  }

  int _pesoOrden(IncidenciaTransversal item) {
    final prioridad = switch (item.prioridad) {
      'Alta' => 4,
      'Media' => 3,
      'Baja' => 2,
      _ => 1,
    };
    final semaforo = switch (item.semaforo) {
      SemaforoIncidenciaTransversal.rojo => 3,
      SemaforoIncidenciaTransversal.amarillo => 2,
      SemaforoIncidenciaTransversal.verde => 1,
    };
    return prioridad +
        (item.vencida ? 3 : 0) +
        (item.devueltaDesdeLegajos ? 2 : 0) +
        semaforo;
  }

  Future<void> _priorizar(IncidenciaTransversal item) async {
    final criterio = await showDialog<_CriterioPriorizacionIncidencias>(
      context: context,
      builder:
          (context) => _DialogoPriorizacionIncidencias(
            titulo: item.titulo,
            descripcion:
                'La priorizacion va a dejar un criterio comun y una fecha objetivo en ${item.origen}.',
          ),
    );
    if (!mounted || criterio == null) return;
    final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
      item,
      criterio: criterio.criterio,
      fechaObjetivo: criterio.fechaObjetivo,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _refreshToken++;
        _seleccionadas.remove(_claveCaso(item));
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'La incidencia quedo priorizada en ${item.origen} con criterio operativo.'
              : 'No se pudo priorizar la incidencia.',
        ),
      ),
    );
  }

  Future<void> _derivarALegajos(
    ContextoInstitucional contexto,
    IncidenciaTransversal item,
  ) async {
    final justificacion = await showDialog<String>(
      context: context,
      builder:
          (context) => _DialogoJustificacionDerivacionIncidencias(
            titulo: item.titulo,
            descripcion:
                'Esta justificacion se agregara al legajo y a la trazabilidad del caso en ${item.origen}.',
          ),
    );
    if (!mounted || justificacion == null) return;
    final ok = await Proveedores.incidenciasTransversalesRepositorio
        .derivarALegajos(
          item: item,
          contexto: contexto,
          justificacion: justificacion,
        );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _refreshToken++;
        _seleccionadas.remove(_claveCaso(item));
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'La incidencia se derivo a Legajos con justificacion operativa.'
              : 'La incidencia ya tenia un legajo activo o no pudo derivarse.',
        ),
      ),
    );
  }

  Future<void> _devolverAlOrigen(IncidenciaTransversal item) async {
    final motivo = await showDialog<String>(
      context: context,
      builder:
          (context) => _DialogoMotivoDevolucionIncidencias(
            titulo: item.titulo,
            descripcion:
                'La devolucion actualizara ${item.origen} y dejara este motivo en la trazabilidad transversal.',
          ),
    );
    if (!mounted || motivo == null) return;
    final ok = await Proveedores.incidenciasTransversalesRepositorio
        .devolverAlOrigen(item, motivo: motivo);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _refreshToken++;
        _seleccionadas.remove(_claveCaso(item));
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'La incidencia se devolvio a ${item.origen} con motivo operativo.'
              : 'No se pudo devolver la incidencia al modulo origen.',
        ),
      ),
    );
  }

  Future<void> _verHistorial(IncidenciaTransversal item) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _DialogoHistorialIncidencia(item: item),
    );
  }

  Future<void> _priorizarSeleccionadas(List<IncidenciaTransversal> items) async {
    final criterio = await showDialog<_CriterioPriorizacionIncidencias>(
      context: context,
      builder:
          (context) => const _DialogoPriorizacionIncidencias(
            titulo: 'Priorizacion masiva',
            descripcion:
                'El mismo criterio y la misma fecha objetivo se aplicaran a todas las incidencias seleccionadas.',
          ),
    );
    if (!mounted || criterio == null) return;
    var exitos = 0;
    for (final item in items) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio.priorizar(
        item,
        criterio: criterio.criterio,
        fechaObjetivo: criterio.fechaObjetivo,
        enLote: true,
      );
      if (ok) {
        exitos++;
      }
    }
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se priorizaron $exitos de ${items.length} incidencias seleccionadas con criterio comun.'
              : 'No se pudo priorizar ninguna incidencia seleccionada.',
        ),
      ),
    );
  }

  Future<void> _registrarObservacionSeleccionadas(
    List<IncidenciaTransversal> items,
  ) async {
    final observacion = await showDialog<String>(
      context: context,
      builder: (context) => const _DialogoObservacionMasivaIncidencias(),
    );
    if (!mounted || observacion == null || observacion.trim().isEmpty) return;

    var exitos = 0;
    for (final item in items) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio
          .registrarObservacion(
            item: item,
            observacion: observacion,
            enLote: true,
          );
      if (ok) {
        exitos++;
      }
    }
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se registro una observacion comun en $exitos de ${items.length} incidencias seleccionadas.'
              : 'No se pudo registrar la observacion en las incidencias seleccionadas.',
        ),
      ),
    );
  }

  Future<void> _derivarSeleccionadasALegajos(
    ContextoInstitucional contexto,
    List<IncidenciaTransversal> items,
  ) async {
    final justificacion = await showDialog<String>(
      context: context,
      builder:
          (context) => _DialogoJustificacionDerivacionIncidencias(
            titulo: 'Derivacion masiva a Legajos',
            descripcion:
                'La misma justificacion operativa se agregara a todas las incidencias seleccionadas que aun no tengan legajo.',
          ),
    );
    if (!mounted || justificacion == null) return;
    var exitos = 0;
    for (final item in items) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio
          .derivarALegajos(
            item: item,
            contexto: contexto,
            justificacion: justificacion,
            enLote: true,
          );
      if (ok) {
        exitos++;
      }
    }
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se derivaron $exitos de ${items.length} incidencias seleccionadas a Legajos con criterio comun.'
              : 'No se pudo derivar ninguna incidencia seleccionada.',
        ),
      ),
    );
  }

  Future<void> _devolverSeleccionadasAlOrigen(
    List<IncidenciaTransversal> items,
  ) async {
    final motivo = await showDialog<String>(
      context: context,
      builder:
          (context) => _DialogoMotivoDevolucionIncidencias(
            titulo: 'Devolucion masiva al origen',
            descripcion:
                'El mismo motivo operativo se agregara a todas las incidencias seleccionadas que vuelvan a su modulo origen.',
          ),
    );
    if (!mounted || motivo == null) return;
    var exitos = 0;
    for (final item in items) {
      final ok = await Proveedores.incidenciasTransversalesRepositorio
          .devolverAlOrigen(item, motivo: motivo, enLote: true);
      if (ok) {
        exitos++;
      }
    }
    if (!mounted) return;
    if (exitos > 0) {
      setState(() {
        _refreshToken++;
        _seleccionadas.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          exitos > 0
              ? 'Se devolvieron $exitos de ${items.length} incidencias seleccionadas con motivo comun.'
              : 'No se pudo devolver ninguna incidencia seleccionada.',
        ),
      ),
    );
  }
}

class _EstadoIncidencias extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _EstadoIncidencias({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 44, color: cs.primary),
              const SizedBox(height: 14),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                descripcion,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelloIncidencias extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloIncidencias({required this.icono, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
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

class _MetricaIncidencias extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const _MetricaIncidencias({
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
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaIncidencia extends StatelessWidget {
  final IncidenciaTransversal item;
  final bool seleccionada;
  final ValueChanged<bool> onSeleccionar;
  final VoidCallback onPriorizar;
  final VoidCallback onVerHistorial;
  final VoidCallback? onDerivarALegajos;
  final VoidCallback? onDevolver;

  const _TarjetaIncidencia({
    required this.item,
    required this.seleccionada,
    required this.onSeleccionar,
    required this.onPriorizar,
    required this.onVerHistorial,
    required this.onDerivarALegajos,
    required this.onDevolver,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorSemaforo = _colorSemaforo(item.semaforo);
    return Container(
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 390),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: seleccionada
            ? cs.primaryContainer.withValues(alpha: 0.22)
            : cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color: seleccionada
              ? cs.primary.withValues(alpha: 0.82)
              : colorSemaforo.withValues(alpha: 0.42),
          width: seleccionada ? 1.5 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: seleccionada,
                visualDensity: VisualDensity.compact,
                onChanged: (value) => onSeleccionar(value ?? false),
              ),
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ChipSemaforoIncidencia(item: item),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(icono: item.iconoOrigen, texto: item.origen),
              _ChipIncidencia(icono: Icons.badge_outlined, texto: item.referencia),
              _ChipIncidencia(
                icono: Icons.schedule_outlined,
                texto: item.estadoOperativo,
              ),
              if (item.devueltaDesdeLegajos)
                const _ChipIncidencia(
                  icono: Icons.reply_outlined,
                  texto: 'Devuelta',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detalle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(
                icono: Icons.person_outline,
                texto: item.responsable,
              ),
              if (item.codigoLegajo != null)
                _ChipIncidencia(
                  icono: Icons.folder_open_outlined,
                  texto: item.codigoLegajo!,
                ),
              if (item.estadoDocumental != null)
                _ChipIncidencia(
                  icono: Icons.rule_folder_outlined,
                  texto: item.estadoDocumental!,
                ),
            ],
          ),
          if (item.fechaCompromiso != null) ...[
            const SizedBox(height: 10),
            Text(
              _textoFecha(item.fechaCompromiso!, item.vencida),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: item.vencida ? const Color(0xFFB42318) : cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onPriorizar,
                icon: const Icon(Icons.priority_high_outlined),
                label: const Text('Priorizar'),
              ),
              TextButton.icon(
                onPressed: onVerHistorial,
                icon: const Icon(Icons.history_outlined),
                label: const Text('Historial'),
              ),
              if (onDerivarALegajos != null)
                TextButton.icon(
                  onPressed: onDerivarALegajos,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Derivar a legajo'),
                ),
              if (onDevolver != null)
                TextButton.icon(
                  onPressed: onDevolver,
                  icon: const Icon(Icons.reply_outlined),
                  label: Text('Devolver a ${item.origen}'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _textoFecha(DateTime fecha, bool vencida) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return vencida ? 'Compromiso vencido $dd/$mm/$yyyy' : 'Compromiso $dd/$mm/$yyyy';
  }

  Color _colorSemaforo(SemaforoIncidenciaTransversal semaforo) {
    switch (semaforo) {
      case SemaforoIncidenciaTransversal.rojo:
        return const Color(0xFFB42318);
      case SemaforoIncidenciaTransversal.amarillo:
        return const Color(0xFFB45309);
      case SemaforoIncidenciaTransversal.verde:
        return const Color(0xFF067647);
    }
  }
}

class _BarraAccionesMasivasIncidencias extends StatelessWidget {
  final int seleccionadas;
  final int visibles;
  final int derivables;
  final int devolvibles;
  final VoidCallback onSeleccionarTodas;
  final VoidCallback? onLimpiarSeleccion;
  final VoidCallback? onPriorizar;
  final VoidCallback? onRegistrarObservacion;
  final VoidCallback? onDerivar;
  final VoidCallback? onDevolver;

  const _BarraAccionesMasivasIncidencias({
    required this.seleccionadas,
    required this.visibles,
    required this.derivables,
    required this.devolvibles,
    required this.onSeleccionarTodas,
    required this.onLimpiarSeleccion,
    required this.onPriorizar,
    required this.onRegistrarObservacion,
    required this.onDerivar,
    required this.onDevolver,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final haySeleccion = seleccionadas > 0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: haySeleccion
            ? cs.primaryContainer.withValues(alpha: 0.2)
            : cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color: haySeleccion
              ? cs.primary.withValues(alpha: 0.28)
              : cs.outlineVariant.withValues(alpha: 0.84),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones masivas',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              haySeleccion
                  ? 'Hay $seleccionadas incidencias seleccionadas. Podes priorizarlas, derivar $derivables a Legajos o devolver $devolvibles al modulo origen.'
                  : 'Selecciona varias incidencias para operar en lote desde esta misma mesa transversal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onSeleccionarTodas,
                  icon: const Icon(Icons.select_all_outlined),
                  label: Text(
                    haySeleccion && seleccionadas == visibles
                        ? 'Quitar visibles'
                        : 'Seleccionar visibles',
                  ),
                ),
                if (haySeleccion)
                  TextButton.icon(
                    onPressed: onLimpiarSeleccion,
                    icon: const Icon(Icons.deselect_outlined),
                    label: const Text('Limpiar seleccion'),
                  ),
                FilledButton.tonalIcon(
                  onPressed: onPriorizar,
                  icon: const Icon(Icons.priority_high_outlined),
                  label: const Text('Priorizar'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onRegistrarObservacion,
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Observacion comun'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onDerivar,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: Text('Derivar a legajo ($derivables)'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onDevolver,
                  icon: const Icon(Icons.reply_outlined),
                  label: Text('Devolver ($devolvibles)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraAccionSugeridaAlertaMesa extends StatelessWidget {
  final AlertaMesaIncidencias alerta;
  final int casosVisibles;
  final String etiquetaAccion;
  final VoidCallback? onAplicar;
  final VoidCallback onLimpiar;

  const _BarraAccionSugeridaAlertaMesa({
    required this.alerta,
    required this.casosVisibles,
    required this.etiquetaAccion,
    required this.onAplicar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = alerta.severidad == 'Alta'
        ? const Color(0xFFB42318)
        : const Color(0xFFB45309);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preset activo por alerta',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${alerta.titulo} dejo la mesa enfocada en ${alerta.origen}. Hay $casosVisibles casos visibles dentro de este preset.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onAplicar,
                  icon: const Icon(Icons.playlist_add_check_outlined),
                  label: Text(etiquetaAccion),
                ),
                TextButton.icon(
                  onPressed: onLimpiar,
                  icon: const Icon(Icons.clear_all_outlined),
                  label: const Text('Salir del preset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaImpactoMasivoModulo extends StatelessWidget {
  final ImpactoAccionMasivaModulo item;

  const _TarjetaImpactoMasivoModulo({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 300),
      padding: const EdgeInsets.all(16),
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
              Icon(item.icono, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.origen,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${item.total}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(
                icono: Icons.priority_high_outlined,
                texto: 'P ${item.priorizaciones}',
              ),
              _ChipIncidencia(
                icono: Icons.folder_open_outlined,
                texto: 'L ${item.derivaciones}',
              ),
              _ChipIncidencia(
                icono: Icons.reply_outlined,
                texto: 'D ${item.devoluciones}',
              ),
              _ChipIncidencia(
                icono: Icons.note_add_outlined,
                texto: 'N ${item.observaciones}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaRecomendacionEjecutivaMesa extends StatelessWidget {
  final RecomendacionEjecutivaMesaIncidencias item;
  final VoidCallback? onVerFoco;
  final VoidCallback? onEjecutar;

  const _TarjetaRecomendacionEjecutivaMesa({
    required this.item,
    required this.onVerFoco,
    required this.onEjecutar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (item.severidad) {
      'Alta' => const Color(0xFFB42318),
      'Media' => const Color(0xFFB45309),
      _ => cs.primary,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icono, size: 20, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.foco,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _ChipIncidencia(
                icono: Icons.priority_high_outlined,
                texto: item.severidad,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.lecturaEjecutiva,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.accionSugerida,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: item.tipoAlertaOrigen == 'sin_alerta' ? null : onVerFoco,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Ver foco'),
              ),
              FilledButton.icon(
                onPressed:
                    item.tipoAlertaOrigen == 'sin_alerta' ? null : onEjecutar,
                icon: const Icon(Icons.bolt_outlined),
                label: const Text('Ejecutar recomendacion'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaEventoEjecutivoMesa extends StatelessWidget {
  final EventoEjecutivoMesaIncidencias item;

  const _TarjetaEventoEjecutivoMesa({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 340),
      padding: const EdgeInsets.all(16),
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
              Icon(
                item.accion == 'Accion rapida'
                    ? Icons.bolt_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.accion,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(
                icono: Icons.hub_outlined,
                texto: item.tipoAlerta,
              ),
              if (item.cantidadCasos > 0)
                _ChipIncidencia(
                  icono: Icons.layers_outlined,
                  texto: '${item.cantidadCasos} casos',
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.detalle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _textoFecha(item.creadoEn),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _textoFecha(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }
}

class _TarjetaAlertaMesaIncidencias extends StatelessWidget {
  final AlertaMesaIncidencias item;
  final VoidCallback onVerCasos;

  const _TarjetaAlertaMesaIncidencias({
    required this.item,
    required this.onVerCasos,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = item.severidad == 'Alta'
        ? const Color(0xFFB42318)
        : const Color(0xFFB45309);
    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 360),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icono, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(
                icono: Icons.apartment_outlined,
                texto: item.origen,
              ),
              _ChipIncidencia(
                icono: Icons.priority_high_outlined,
                texto: item.severidad,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.descripcion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.accionSugerida,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: onVerCasos,
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Ver casos afectados'),
          ),
        ],
      ),
    );
  }
}

class _DialogoObservacionMasivaIncidencias extends StatefulWidget {
  const _DialogoObservacionMasivaIncidencias();

  @override
  State<_DialogoObservacionMasivaIncidencias> createState() =>
      _DialogoObservacionMasivaIncidenciasState();
}

class _DialogoObservacionMasivaIncidenciasState
    extends State<_DialogoObservacionMasivaIncidencias> {
  late final TextEditingController _observacionCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _observacionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Observacion masiva'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'La nota se agregara al caso operativo de origen y tambien quedara registrada en el historial transversal.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionCtrl,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observacion comun',
                  hintText:
                      'Ej.: Contactar a las areas involucradas antes de las 48 h y dejar respuesta en el circuito documental.',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa una observacion para continuar.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_observacionCtrl.text.trim());
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Registrar'),
        ),
      ],
    );
  }
}

class _DialogoJustificacionDerivacionIncidencias extends StatefulWidget {
  final String titulo;
  final String descripcion;

  const _DialogoJustificacionDerivacionIncidencias({
    required this.titulo,
    required this.descripcion,
  });

  @override
  State<_DialogoJustificacionDerivacionIncidencias> createState() =>
      _DialogoJustificacionDerivacionIncidenciasState();
}

class _DialogoJustificacionDerivacionIncidenciasState
    extends State<_DialogoJustificacionDerivacionIncidencias> {
  late final TextEditingController _justificacionCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _justificacionCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _justificacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.descripcion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _justificacionCtrl,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Justificacion operativa',
                  hintText:
                      'Ej.: Se deriva para consolidar respaldo documental y definir resolucion institucional antes del vencimiento.',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa una justificacion para derivar.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_justificacionCtrl.text.trim());
          },
          icon: const Icon(Icons.folder_open_outlined),
          label: const Text('Derivar'),
        ),
      ],
    );
  }
}

class _DialogoMotivoDevolucionIncidencias extends StatefulWidget {
  final String titulo;
  final String descripcion;

  const _DialogoMotivoDevolucionIncidencias({
    required this.titulo,
    required this.descripcion,
  });

  @override
  State<_DialogoMotivoDevolucionIncidencias> createState() =>
      _DialogoMotivoDevolucionIncidenciasState();
}

class _DialogoMotivoDevolucionIncidenciasState
    extends State<_DialogoMotivoDevolucionIncidencias> {
  late final TextEditingController _motivoCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _motivoCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.descripcion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoCtrl,
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Motivo de devolucion',
                  hintText:
                      'Ej.: Requiere regularizacion operativa en el modulo origen antes de continuar el circuito documental.',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa un motivo para devolver.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_motivoCtrl.text.trim());
          },
          icon: const Icon(Icons.reply_outlined),
          label: const Text('Devolver'),
        ),
      ],
    );
  }
}

class _CriterioPriorizacionIncidencias {
  final String criterio;
  final DateTime fechaObjetivo;

  const _CriterioPriorizacionIncidencias({
    required this.criterio,
    required this.fechaObjetivo,
  });
}

class _DialogoPriorizacionIncidencias extends StatefulWidget {
  final String titulo;
  final String descripcion;

  const _DialogoPriorizacionIncidencias({
    required this.titulo,
    required this.descripcion,
  });

  @override
  State<_DialogoPriorizacionIncidencias> createState() =>
      _DialogoPriorizacionIncidenciasState();
}

class _DialogoPriorizacionIncidenciasState
    extends State<_DialogoPriorizacionIncidencias> {
  late final TextEditingController _criterioCtrl;
  final _formKey = GlobalKey<FormState>();
  late DateTime _fechaObjetivo;

  @override
  void initState() {
    super.initState();
    _criterioCtrl = TextEditingController();
    _fechaObjetivo = DateTime.now().add(const Duration(days: 2));
  }

  @override
  void dispose() {
    _criterioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.descripcion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _criterioCtrl,
                maxLines: 3,
                minLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Criterio de priorizacion',
                  hintText:
                      'Ej.: Resolver antes del proximo cierre institucional por impacto documental y vencimiento cercano.',
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Ingresa un criterio para priorizar.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _seleccionarFecha,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  'Fecha objetivo: ${_formatearFecha(_fechaObjetivo)}',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              _CriterioPriorizacionIncidencias(
                criterio: _criterioCtrl.text.trim(),
                fechaObjetivo: _fechaObjetivo,
              ),
            );
          },
          icon: const Icon(Icons.priority_high_outlined),
          label: const Text('Priorizar'),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaObjetivo,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );
    if (seleccionada == null || !mounted) return;
    setState(() {
      _fechaObjetivo = DateTime(
        seleccionada.year,
        seleccionada.month,
        seleccionada.day,
      );
    });
  }

  String _formatearFecha(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return '$dd/$mm/$yyyy';
  }
}

class _DialogoHistorialIncidencia extends StatelessWidget {
  final IncidenciaTransversal item;

  const _DialogoHistorialIncidencia({required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Historial | ${item.titulo}'),
      content: SizedBox(
        width: 720,
        child: FutureBuilder<List<HistorialIncidenciaTransversal>>(
          future: Proveedores.incidenciasTransversalesRepositorio
              .obtenerHistorial(item),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _EstadoIncidencias(
                icono: Icons.history_outlined,
                titulo: 'Cargando historial',
                descripcion:
                    'Recuperando acciones registradas para esta incidencia.',
              );
            }
            if (snapshot.hasError) {
              return _EstadoIncidencias(
                icono: Icons.error_outline,
                titulo: 'No se pudo cargar el historial',
                descripcion: '${snapshot.error}',
              );
            }
            final items = snapshot.data ?? const <HistorialIncidenciaTransversal>[];
            if (items.isEmpty) {
              return const _EstadoIncidencias(
                icono: Icons.history_toggle_off_outlined,
                titulo: 'Sin historial registrado',
                descripcion:
                    'Todavia no hay acciones guardadas desde la mesa transversal para este caso.',
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _FilaHistorialIncidencia(item: items[index]);
              },
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

class _FilaHistorialIncidencia extends StatelessWidget {
  final HistorialIncidenciaTransversal item;

  const _FilaHistorialIncidencia({required this.item});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(
                icono: Icons.history_outlined,
                texto: _etiquetaAccion(item.accion),
              ),
              if ((item.estadoOperativo ?? '').trim().isNotEmpty)
                _ChipIncidencia(
                  icono: Icons.schedule_outlined,
                  texto: item.estadoOperativo!,
                ),
              if ((item.estadoDocumental ?? '').trim().isNotEmpty)
                _ChipIncidencia(
                  icono: Icons.folder_open_outlined,
                  texto: item.estadoDocumental!,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _textoFecha(item.creadoEn),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((item.detalle ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.detalle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _etiquetaAccion(String accion) {
    switch (accion) {
      case 'priorizada':
        return 'Priorizada';
      case 'priorizacion_masiva':
        return 'Priorizacion masiva';
      case 'derivada_a_legajos':
        return 'Derivada a legajos';
      case 'derivacion_masiva':
        return 'Derivacion masiva';
      case 'devuelta_al_origen':
        return 'Devuelta al origen';
      case 'devolucion_masiva':
        return 'Devolucion masiva';
      case 'observacion_operativa':
        return 'Observacion operativa';
      case 'observacion_masiva':
        return 'Observacion masiva';
      default:
        return accion;
    }
  }

  String _textoFecha(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    final hh = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }
}

class _ChipIncidencia extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ChipIncidencia({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: cs.primary),
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

enum _OrdenIncidencias {
  prioridad('Prioridad y riesgo'),
  vencimiento('Vencimiento'),
  origen('Origen'),
  estadoDocumental('Estado documental');

  final String etiqueta;

  const _OrdenIncidencias(this.etiqueta);
}

class _ChipSemaforoResumen extends StatelessWidget {
  final SemaforoIncidenciaTransversal semaforo;
  final String valor;

  const _ChipSemaforoResumen({
    required this.semaforo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorSemaforo(semaforo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(semaforo.icono, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '${semaforo.etiqueta}: $valor',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipSemaforoIncidencia extends StatelessWidget {
  final IncidenciaTransversal item;

  const _ChipSemaforoIncidencia({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _colorSemaforo(item.semaforo);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.semaforo.icono, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            '${item.semaforo.etiqueta} | ${item.prioridad}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

Color _colorSemaforo(SemaforoIncidenciaTransversal semaforo) {
  switch (semaforo) {
    case SemaforoIncidenciaTransversal.rojo:
      return const Color(0xFFB42318);
    case SemaforoIncidenciaTransversal.amarillo:
      return const Color(0xFFB45309);
    case SemaforoIncidenciaTransversal.verde:
      return const Color(0xFF067647);
  }
}

class _ResumenModuloIncidencias {
  final String origen;
  final int total;
  final int rojas;
  final int amarillas;
  final int devueltas;
  final int vencidas;
  final IconData icono;

  const _ResumenModuloIncidencias({
    required this.origen,
    required this.total,
    required this.rojas,
    required this.amarillas,
    required this.devueltas,
    required this.vencidas,
    required this.icono,
  });

  int get pesoRiesgo => (rojas * 4) + (vencidas * 3) + (devueltas * 2) + amarillas;
}

class _TarjetaResumenModulo extends StatelessWidget {
  final _ResumenModuloIncidencias item;

  const _TarjetaResumenModulo({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = item.rojas > 0
        ? _colorSemaforo(SemaforoIncidenciaTransversal.rojo)
        : item.amarillas > 0
        ? _colorSemaforo(SemaforoIncidenciaTransversal.amarillo)
        : _colorSemaforo(SemaforoIncidenciaTransversal.verde);
    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 320),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icono, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.origen,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${item.total}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipIncidencia(
                icono: SemaforoIncidenciaTransversal.rojo.icono,
                texto: 'Rojas ${item.rojas}',
              ),
              _ChipIncidencia(
                icono: SemaforoIncidenciaTransversal.amarillo.icono,
                texto: 'Amarillas ${item.amarillas}',
              ),
              _ChipIncidencia(
                icono: Icons.reply_outlined,
                texto: 'Devueltas ${item.devueltas}',
              ),
              _ChipIncidencia(
                icono: Icons.event_busy_outlined,
                texto: 'Vencidas ${item.vencidas}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _lectura(item),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _lectura(_ResumenModuloIncidencias item) {
    if (item.rojas > 0) {
      return 'Modulo con foco critico activo. Conviene revisar primero los casos rojos y vencidos.';
    }
    if (item.devueltas > 0) {
      return 'Modulo con devoluciones operativas desde Legajos que requieren reactivacion.';
    }
    return 'Modulo estable dentro del circuito transversal actual.';
  }
}
