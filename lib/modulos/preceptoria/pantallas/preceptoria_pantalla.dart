import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/legajos/modelos/legajo_documental.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/preceptoria/modelos/novedad_preceptoria.dart';

class PreceptoriaPantalla extends StatefulWidget {
  const PreceptoriaPantalla({super.key});

  @override
  State<PreceptoriaPantalla> createState() => _PreceptoriaPantallaState();
}

class _PreceptoriaPantallaState extends State<PreceptoriaPantalla> {
  String _filtro = 'asistencia';
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ContextoInstitucional>(
      valueListenable: Proveedores.contextoInstitucional,
      builder: (context, contexto, _) {
        return FutureBuilder<DashboardPreceptoria>(
          key: ValueKey('${contexto.rol.name}-$_filtro-$_refreshToken'),
          future: Proveedores.preceptoriaRepositorio.cargarDashboard(
            contexto: contexto,
            categoria: _filtro,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _EstadoPreceptoria(
                icono: Icons.fact_check_outlined,
                titulo: 'Cargando preceptoria',
                descripcion:
                    'Preparando novedades, justificaciones y alertas operativas.',
              );
            }
            if (snapshot.hasError) {
              return _EstadoPreceptoria(
                icono: Icons.error_outline,
                titulo: 'No se pudo abrir preceptoria',
                descripcion: '${snapshot.error}',
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return const _EstadoPreceptoria(
                icono: Icons.assignment_late_outlined,
                titulo: 'Sin novedades cargadas',
                descripcion:
                    'Todavia no hay novedades registradas para este contexto preceptorial.',
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
    DashboardPreceptoria data,
  ) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SelloPreceptoria(icono: contexto.rol.icono, etiqueta: contexto.rol.etiqueta),
              _SelloPreceptoria(icono: Icons.school_outlined, etiqueta: contexto.nivel.etiqueta),
              _SelloPreceptoria(
                icono: Icons.apartment_outlined,
                etiqueta: contexto.dependencia.etiqueta,
              ),
              const _SelloPreceptoria(
                icono: Icons.assignment_late_outlined,
                etiqueta: 'Seguimiento persistente',
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
                      'Preceptoria',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _descripcionPara(contexto),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _editarNovedad(contexto),
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Nueva novedad'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaPreceptoria(
                titulo: 'Novedades activas',
                valor: '${data.resumen.novedadesActivas}',
                descripcion: 'Casos operativos abiertos para seguimiento.',
                icono: Icons.assignment_late_outlined,
              ),
              _MetricaPreceptoria(
                titulo: 'Urgentes',
                valor: '${data.resumen.urgentes}',
                descripcion: 'Seguimientos con prioridad alta o estado urgente.',
                icono: Icons.priority_high_outlined,
              ),
              _MetricaPreceptoria(
                titulo: 'Sin documento',
                valor: '${data.resumen.alumnosSinDocumento}',
                descripcion: 'Alumnos activos sin DNI cargado.',
                icono: Icons.badge_outlined,
              ),
              _MetricaPreceptoria(
                titulo: 'Riesgo de inasistencia',
                valor: '${data.resumen.alumnosConInasistenciasRiesgo}',
                descripcion: 'Alumnos con faltas reiteradas en 14 dias.',
                icono: Icons.event_busy_outlined,
              ),
              _MetricaPreceptoria(
                titulo: 'Con legajo',
                valor: '${data.resumen.vinculadasALegajos}',
                descripcion: 'Novedades que ya tocaron el circuito documental.',
                icono: Icons.link_outlined,
              ),
              _MetricaPreceptoria(
                titulo: 'Devueltas',
                valor: '${data.resumen.devueltasDesdeLegajos}',
                descripcion: 'Casos que volvieron desde Legajos para accion operativa.',
                icono: Icons.reply_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Alertas operativas',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: data.alertas
                .map((item) => _TarjetaAlertaPreceptoria(item: item))
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['asistencia', 'trayectoria', 'convivencia', 'documental']
                .map(
                  (item) => ChoiceChip(
                    label: Text(item[0].toUpperCase() + item.substring(1)),
                    selected: _filtro == item,
                    onSelected: (_) => setState(() => _filtro = item),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          Text(
            'Mesa diaria de seguimiento',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.novedades.isEmpty)
            const _EstadoPreceptoria(
              icono: Icons.inbox_outlined,
              titulo: 'Sin novedades en esta categoria',
              descripcion:
                  'No hay registros abiertos en la categoria seleccionada.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.novedades
                  .map(
                    (item) => _TarjetaNovedadPreceptoria(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarNovedad(contexto, actual: item),
                      onDerivar: () => _derivarALegajos(contexto, item),
                      onArchivar: () => _archivar(item.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          const SizedBox(height: 18),
          Text(
            'Derivadas y devueltas por Legajos',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.novedadesDerivadas.isEmpty)
            const _EstadoPreceptoria(
              icono: Icons.link_off_outlined,
              titulo: 'Sin cruces documentales activos',
              descripcion:
                  'Todavia no hay novedades derivadas o devueltas desde Legajos.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.novedadesDerivadas
                  .map(
                    (item) => _TarjetaNovedadPreceptoria(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarNovedad(contexto, actual: item),
                      onDerivar: () => _derivarALegajos(contexto, item),
                      onArchivar: () => _archivar(item.id),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  String _descripcionPara(ContextoInstitucional contexto) {
    switch (contexto.rol) {
      case RolInstitucional.preceptor:
        return 'La preceptoria ya puede centralizar justificaciones, seguimientos, convivencia y control diario de estudiantes.';
      case RolInstitucional.director:
      case RolInstitucional.rector:
        return 'Direccion y rectorado pueden revisar el pulso operativo diario de cursos y estudiantes desde una misma bandeja.';
      default:
        return 'Este modulo organiza novedades diarias, alertas de asistencia y seguimiento estudiantil.';
    }
  }

  Future<void> _editarNovedad(
    ContextoInstitucional contexto, {
    NovedadPreceptoria? actual,
  }) async {
    final borrador =
        actual != null
            ? NovedadPreceptoriaBorrador.desdeNovedad(actual)
            : NovedadPreceptoriaBorrador(
                tipoNovedad: 'justificativo',
                categoria: _filtro,
                cursoReferencia: null,
                alumnoReferencia: null,
                estado: 'Pendiente de control',
                prioridad: 'Media',
                responsable: contexto.rol.etiqueta,
                observaciones: '',
                fechaSeguimiento: DateTime.now().add(const Duration(days: 1)),
                rolDestino: contexto.rol.name,
                nivelDestino: contexto.nivel.name,
                dependenciaDestino: contexto.dependencia.name,
              );

    final resultado = await showDialog<NovedadPreceptoriaBorrador>(
      context: context,
      builder: (context) => _DialogoNovedadPreceptoria(borrador: borrador),
    );
    if (resultado == null) return;
    await Proveedores.preceptoriaRepositorio.guardarNovedad(resultado);
    if (!mounted) return;
    setState(() => _refreshToken++);
  }

  Future<void> _archivar(int id) async {
    await Proveedores.preceptoriaRepositorio.archivarNovedad(id);
    if (!mounted) return;
    setState(() => _refreshToken++);
  }

  Future<void> _derivarALegajos(
    ContextoInstitucional contexto,
    NovedadPreceptoria item,
  ) async {
    final rolDestino = _rolDestinoParaLegajo(contexto, item);
    final registro = LegajoDocumentalBorrador(
      tipoRegistro: item.categoria == 'documental' ? 'documento' : 'expediente',
      categoria: _categoriaLegajo(item),
      codigo: _codigoLegajo(item),
      titulo: _tituloLegajo(item),
      detalle: _detalleLegajo(item),
      responsable: item.responsable,
      estado: item.estado,
      severidad: item.prioridad,
      rolDestino: rolDestino.name,
      nivelDestino: contexto.nivel.name,
      dependenciaDestino: contexto.dependencia.name,
      horasHastaVencimiento: _horasHastaSeguimiento(item.fechaSeguimiento),
    );

    await Proveedores.legajosRepositorio.guardarRegistro(registro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se derivo la novedad de ${_referenciaNovedad(item)} a Legajos.',
        ),
      ),
    );
  }

  RolInstitucional _rolDestinoParaLegajo(
    ContextoInstitucional contexto,
    NovedadPreceptoria item,
  ) {
    if (contexto.tienePermiso(PermisoModulo.legajos)) {
      return contexto.rol;
    }
    if (item.categoria == 'documental' || item.tipoNovedad == 'documentacion') {
      return RolInstitucional.secretario;
    }
    return RolInstitucional.director;
  }

  String _categoriaLegajo(NovedadPreceptoria item) {
    switch (item.categoria) {
      case 'documental':
        return (item.alumnoReferencia ?? '').trim().isEmpty
            ? 'institucional'
            : 'alumnos';
      default:
        return 'alumnos';
    }
  }

  String _codigoLegajo(NovedadPreceptoria item) {
    final referencia = _referenciaNovedad(item)
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '')
        .toUpperCase();
    return 'PRE-${item.id}-${referencia.isEmpty ? 'CASO' : referencia}';
  }

  String _tituloLegajo(NovedadPreceptoria item) {
    final referencia = _referenciaNovedad(item);
    return '${_etiquetaNovedad(item.tipoNovedad)} - $referencia';
  }

  String _detalleLegajo(NovedadPreceptoria item) {
    final partes = <String>[
      'Origen: Preceptoria',
      'Categoria operativa: ${item.categoria}',
      'Tipo de novedad: ${_etiquetaNovedad(item.tipoNovedad)}',
      if ((item.cursoReferencia ?? '').trim().isNotEmpty)
        'Curso: ${item.cursoReferencia!.trim()}',
      if ((item.alumnoReferencia ?? '').trim().isNotEmpty)
        'Alumno o referencia: ${item.alumnoReferencia!.trim()}',
      'Estado de seguimiento: ${item.estado}',
      if (item.observaciones.trim().isNotEmpty)
        'Observaciones: ${item.observaciones.trim()}',
    ];
    return partes.join('\n');
  }

  String _referenciaNovedad(NovedadPreceptoria item) {
    final alumno = item.alumnoReferencia?.trim() ?? '';
    if (alumno.isNotEmpty) return alumno;
    final curso = item.cursoReferencia?.trim() ?? '';
    if (curso.isNotEmpty) return curso;
    return 'seguimiento general';
  }

  String _etiquetaNovedad(String tipoNovedad) {
    switch (tipoNovedad) {
      case 'justificativo':
        return 'Justificativo';
      case 'seguimiento':
        return 'Seguimiento';
      case 'convivencia':
        return 'Convivencia';
      case 'documentacion':
        return 'Documentacion';
      default:
        return tipoNovedad;
    }
  }

  int? _horasHastaSeguimiento(DateTime? fechaSeguimiento) {
    if (fechaSeguimiento == null) return null;
    final horas = fechaSeguimiento.difference(DateTime.now()).inHours;
    return horas <= 0 ? 0 : horas;
  }
}

class _EstadoPreceptoria extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _EstadoPreceptoria({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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

class _SelloPreceptoria extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloPreceptoria({required this.icono, required this.etiqueta});

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

class _MetricaPreceptoria extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const _MetricaPreceptoria({
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

class _TarjetaAlertaPreceptoria extends StatelessWidget {
  final AlertaPreceptoria item;

  const _TarjetaAlertaPreceptoria({required this.item});

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
          Text(
            item.valor,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.titulo,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.descripcion,
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

class _TarjetaNovedadPreceptoria extends StatelessWidget {
  final NovedadPreceptoria item;
  final String codigoLegajo;
  final VoidCallback onEditar;
  final VoidCallback onDerivar;
  final VoidCallback onArchivar;

  const _TarjetaNovedadPreceptoria({
    required this.item,
    required this.codigoLegajo,
    required this.onEditar,
    required this.onDerivar,
    required this.onArchivar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 290, maxWidth: 360),
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
              Expanded(
                child: Text(
                  item.tipoNovedad,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ChipPreceptoria(icono: Icons.flag_outlined, texto: item.prioridad),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipPreceptoria(icono: Icons.schedule_outlined, texto: item.estado),
              if (item.actualizadaDesdeLegajos)
                const _ChipPreceptoria(
                  icono: Icons.reply_outlined,
                  texto: 'Devuelta desde legajos',
                ),
              if ((item.cursoReferencia ?? '').trim().isNotEmpty)
                _ChipPreceptoria(
                  icono: Icons.groups_outlined,
                  texto: item.cursoReferencia!,
                ),
              if ((item.alumnoReferencia ?? '').trim().isNotEmpty)
                _ChipPreceptoria(
                  icono: Icons.person_outline,
                  texto: item.alumnoReferencia!,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Responsable: ${item.responsable}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          if (item.fechaSeguimiento != null) ...[
            const SizedBox(height: 6),
            Text(
              _textoFecha(item),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: item.vencida ? const Color(0xFFB42318) : cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (item.observaciones.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.observaciones,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.42,
              ),
            ),
          ],
          const SizedBox(height: 10),
          FutureBuilder<EstadoCruceLegajo?>(
            future: Proveedores.legajosRepositorio.buscarVinculoPorCodigo(
              codigoLegajo,
            ),
            builder: (context, snapshot) {
              final vinculo = snapshot.data;
              return _ResumenCrucePreceptoria(
                titulo:
                    vinculo == null
                        ? 'Sin legajo derivado todavia'
                        : vinculo.activo
                        ? 'Seguimiento derivado a Legajos'
                        : 'Legajo archivado',
                descripcion:
                    vinculo == null
                        ? 'La novedad sigue solo en la mesa operativa de preceptoria.'
                        : '${vinculo.tipoRegistro} ${vinculo.codigoLegajo} en estado ${vinculo.estado}.',
                resaltado: vinculo != null,
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: onDerivar,
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Derivar a legajo'),
              ),
              TextButton.icon(
                onPressed: onArchivar,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archivar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _textoFecha(NovedadPreceptoria item) {
    final fecha = item.fechaSeguimiento!;
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    if (item.vencida) return 'Seguimiento vencido $dd/$mm/$yyyy';
    return 'Seguimiento $dd/$mm/$yyyy';
  }
}

class _ResumenCrucePreceptoria extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final bool resaltado;

  const _ResumenCrucePreceptoria({
    required this.titulo,
    required this.descripcion,
    required this.resaltado,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            resaltado
                ? cs.tertiaryContainer.withValues(alpha: 0.52)
                : cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color:
              resaltado
                  ? cs.tertiary.withValues(alpha: 0.26)
                  : cs.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: resaltado ? cs.tertiary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPreceptoria extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ChipPreceptoria({required this.icono, required this.texto});

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

class _DialogoNovedadPreceptoria extends StatefulWidget {
  final NovedadPreceptoriaBorrador borrador;

  const _DialogoNovedadPreceptoria({required this.borrador});

  @override
  State<_DialogoNovedadPreceptoria> createState() =>
      _DialogoNovedadPreceptoriaState();
}

class _DialogoNovedadPreceptoriaState
    extends State<_DialogoNovedadPreceptoria> {
  late final TextEditingController _cursoCtrl;
  late final TextEditingController _alumnoCtrl;
  late final TextEditingController _responsableCtrl;
  late final TextEditingController _obsCtrl;
  late String _tipoNovedad;
  late String _categoria;
  late String _estado;
  late String _prioridad;
  DateTime? _fechaSeguimiento;

  @override
  void initState() {
    super.initState();
    final item = widget.borrador;
    _cursoCtrl = TextEditingController(text: item.cursoReferencia ?? '');
    _alumnoCtrl = TextEditingController(text: item.alumnoReferencia ?? '');
    _responsableCtrl = TextEditingController(text: item.responsable);
    _obsCtrl = TextEditingController(text: item.observaciones);
    _tipoNovedad = item.tipoNovedad;
    _categoria = item.categoria;
    _estado = item.estado;
    _prioridad = item.prioridad;
    _fechaSeguimiento = item.fechaSeguimiento;
  }

  @override
  void dispose() {
    _cursoCtrl.dispose();
    _alumnoCtrl.dispose();
    _responsableCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.borrador.id == null ? 'Nueva novedad' : 'Editar novedad'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipoNovedad,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        'justificativo',
                        'seguimiento',
                        'convivencia',
                        'documentacion',
                      ]
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _tipoNovedad = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: const [
                        'asistencia',
                        'trayectoria',
                        'convivencia',
                        'documental',
                      ]
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _categoria = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cursoCtrl,
                decoration: const InputDecoration(labelText: 'Curso o division'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _alumnoCtrl,
                decoration: const InputDecoration(labelText: 'Alumno o referencia'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _responsableCtrl,
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: const [
                        'Pendiente de control',
                        'En seguimiento',
                        'Urgente',
                        'Resuelto',
                      ]
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _estado = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _prioridad,
                      decoration: const InputDecoration(labelText: 'Prioridad'),
                      items: const ['Baja', 'Media', 'Alta']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _prioridad = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _obsCtrl,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaSeguimiento == null
                          ? 'Sin fecha de seguimiento'
                          : 'Seguimiento: ${_fechaTexto(_fechaSeguimiento!)}',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _confirmar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeguimiento ?? hoy.add(const Duration(days: 1)),
      firstDate: hoy.subtract(const Duration(days: 30)),
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Fecha de seguimiento',
    );
    if (fecha == null || !mounted) return;
    setState(() => _fechaSeguimiento = fecha);
  }

  void _confirmar() {
    if (_responsableCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa al menos el responsable de seguimiento.')),
      );
      return;
    }

    Navigator.of(context).pop(
      NovedadPreceptoriaBorrador(
        id: widget.borrador.id,
        tipoNovedad: _tipoNovedad,
        categoria: _categoria,
        cursoReferencia: _cursoCtrl.text.trim().isEmpty ? null : _cursoCtrl.text.trim(),
        alumnoReferencia: _alumnoCtrl.text.trim().isEmpty ? null : _alumnoCtrl.text.trim(),
        estado: _estado,
        prioridad: _prioridad,
        responsable: _responsableCtrl.text.trim(),
        observaciones: _obsCtrl.text.trim(),
        fechaSeguimiento: _fechaSeguimiento,
        rolDestino: widget.borrador.rolDestino,
        nivelDestino: widget.borrador.nivelDestino,
        dependenciaDestino: widget.borrador.dependenciaDestino,
      ),
    );
  }

  String _fechaTexto(DateTime fecha) {
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    return '$dd/$mm/$yyyy';
  }
}
