import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/legajos/modelos/legajo_documental.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/secretaria/modelos/tramite_secretaria.dart';

class SecretariaPantalla extends StatefulWidget {
  const SecretariaPantalla({super.key});

  @override
  State<SecretariaPantalla> createState() => _SecretariaPantallaState();
}

class _SecretariaPantallaState extends State<SecretariaPantalla> {
  String _filtro = 'alumnos';
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ContextoInstitucional>(
      valueListenable: Proveedores.contextoInstitucional,
      builder: (context, contexto, _) {
        return FutureBuilder<DashboardSecretaria>(
          key: ValueKey('${contexto.rol.name}-$_filtro-$_refreshToken'),
          future: Proveedores.tramitesSecretariaRepositorio.cargarDashboard(
            contexto: contexto,
            categoria: _filtro,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _EstadoSecretaria(
                icono: Icons.work_history_outlined,
                titulo: 'Cargando mesa de secretaria',
                descripcion:
                    'Preparando tramites, emisiones y pendientes administrativos.',
              );
            }
            if (snapshot.hasError) {
              return _EstadoSecretaria(
                icono: Icons.error_outline,
                titulo: 'No se pudo abrir la mesa de secretaria',
                descripcion: '${snapshot.error}',
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return const _EstadoSecretaria(
                icono: Icons.inventory_2_outlined,
                titulo: 'Sin tramites cargados',
                descripcion:
                    'La secretaria todavia no tiene tramites registrados para este contexto.',
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
    DashboardSecretaria data,
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
              _SelloSecretaria(icono: contexto.rol.icono, etiqueta: contexto.rol.etiqueta),
              _SelloSecretaria(icono: Icons.school_outlined, etiqueta: contexto.nivel.etiqueta),
              _SelloSecretaria(
                icono: Icons.apartment_outlined,
                etiqueta: contexto.dependencia.etiqueta,
              ),
              const _SelloSecretaria(
                icono: Icons.work_history_outlined,
                etiqueta: 'Tramites persistentes',
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
                      'Mesa de secretaria',
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => _editarTramite(
                      contexto,
                      tipoTramiteInicial: 'tramite',
                    ),
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Nuevo tramite'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _editarTramite(
                      contexto,
                      tipoTramiteInicial: 'emision',
                    ),
                    icon: const Icon(Icons.outbox_outlined),
                    label: const Text('Nueva emision'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricaSecretaria(
                titulo: 'Tramites activos',
                valor: '${data.resumen.tramitesActivos}',
                descripcion: 'Bandeja administrativa vigente para este contexto.',
                icono: Icons.inventory_2_outlined,
              ),
              _MetricaSecretaria(
                titulo: 'Urgentes',
                valor: '${data.resumen.urgentes}',
                descripcion: 'Casos con prioridad alta o estado urgente.',
                icono: Icons.priority_high_outlined,
              ),
              _MetricaSecretaria(
                titulo: 'Por vencer',
                valor: '${data.resumen.porVencer}',
                descripcion: 'Tramites con ventana administrativa corta.',
                icono: Icons.event_busy_outlined,
              ),
              _MetricaSecretaria(
                titulo: 'Listos para emitir',
                valor: '${data.resumen.listosParaEmitir}',
                descripcion: 'Constancias, salidas o certificados casi cerrados.',
                icono: Icons.verified_outlined,
              ),
              _MetricaSecretaria(
                titulo: 'Con legajo',
                valor: '${data.resumen.vinculadosALegajos}',
                descripcion: 'Tramites que ya ingresaron o volvieron del circuito documental.',
                icono: Icons.link_outlined,
              ),
              _MetricaSecretaria(
                titulo: 'Devueltos',
                valor: '${data.resumen.devueltosDesdeLegajos}',
                descripcion: 'Casos que regresaron desde Legajos para accion administrativa.',
                icono: Icons.reply_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['alumnos', 'personal', 'institucional']
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
            'Bandeja operativa',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.tramitesPendientes.isEmpty)
            const _EstadoSecretaria(
              icono: Icons.inbox_outlined,
              titulo: 'Sin pendientes visibles',
              descripcion:
                  'No hay tramites pendientes para la categoria seleccionada.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.tramitesPendientes
                  .map(
                    (item) => _TarjetaTramiteSecretaria(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarTramite(contexto, actual: item),
                      onDerivar: () => _derivarALegajos(contexto, item),
                      onArchivar: () => _archivar(item.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          const SizedBox(height: 18),
          Text(
            'Derivados y devueltos por Legajos',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.tramitesDerivados.isEmpty)
            const _EstadoSecretaria(
              icono: Icons.link_off_outlined,
              titulo: 'Sin cruces documentales activos',
              descripcion:
                  'Los tramites todavia no ingresaron o no regresaron desde la mesa de Legajos.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.tramitesDerivados
                  .map(
                    (item) => _TarjetaTramiteSecretaria(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarTramite(contexto, actual: item),
                      onDerivar: () => _derivarALegajos(contexto, item),
                      onArchivar: () => _archivar(item.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          const SizedBox(height: 18),
          Text(
            'Emisiones y salidas',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.emisiones.isEmpty)
            const _EstadoSecretaria(
              icono: Icons.outbox_outlined,
              titulo: 'Sin emisiones registradas',
              descripcion:
                  'Todavia no hay constancias, certificaciones o salidas en este contexto.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.emisiones
                  .map(
                    (item) => _TarjetaTramiteSecretaria(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarTramite(contexto, actual: item),
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
      case RolInstitucional.secretario:
        return 'La secretaria ya puede administrar constancias, pases, equivalencias, certificaciones y salidas con trazabilidad local.';
      case RolInstitucional.rector:
        return 'Rectorado puede supervisar la carga administrativa superior, emisiones listas y tramites sensibles del circuito academico.';
      case RolInstitucional.director:
        return 'Direccion puede revisar el pulso administrativo y ordenar tramites institucionales sin salir del sistema.';
      default:
        return 'Esta mesa organiza tramites, certificaciones y emisiones administrativas del contexto institucional.';
    }
  }

  Future<void> _editarTramite(
    ContextoInstitucional contexto, {
    TramiteSecretaria? actual,
    String? tipoTramiteInicial,
  }) async {
    final borrador =
        actual != null
            ? TramiteSecretariaBorrador.desdeTramite(actual)
            : TramiteSecretariaBorrador(
                tipoTramite: tipoTramiteInicial ?? 'tramite',
                categoria: _filtro,
                codigo: '',
                asunto: '',
                solicitante: '',
                cursoReferencia: null,
                estado:
                    tipoTramiteInicial == 'emision'
                        ? 'Pendiente de firma'
                        : 'En preparacion',
                prioridad: 'Media',
                responsable: contexto.rol.etiqueta,
                observaciones: '',
                fechaLimite: DateTime.now().add(const Duration(days: 3)),
                rolDestino: contexto.rol.name,
                nivelDestino: contexto.nivel.name,
                dependenciaDestino: contexto.dependencia.name,
              );

    final resultado = await showDialog<TramiteSecretariaBorrador>(
      context: context,
      builder: (context) => _DialogoTramiteSecretaria(borrador: borrador),
    );
    if (resultado == null) return;
    await Proveedores.tramitesSecretariaRepositorio.guardarTramite(resultado);
    if (!mounted) return;
    setState(() => _refreshToken++);
  }

  Future<void> _archivar(int id) async {
    await Proveedores.tramitesSecretariaRepositorio.archivarTramite(id);
    if (!mounted) return;
    setState(() => _refreshToken++);
  }

  Future<void> _derivarALegajos(
    ContextoInstitucional contexto,
    TramiteSecretaria item,
  ) async {
    final registro = LegajoDocumentalBorrador(
      tipoRegistro: _tipoRegistroParaTramite(item),
      categoria: item.categoria,
      codigo: _codigoLegajo(item),
      titulo: item.asunto,
      detalle: _detalleLegajo(item),
      responsable: item.responsable,
      estado: item.estado,
      severidad: item.prioridad,
      rolDestino: contexto.rol.name,
      nivelDestino: contexto.nivel.name,
      dependenciaDestino: contexto.dependencia.name,
      horasHastaVencimiento: _horasHastaFechaLimite(item.fechaLimite),
    );

    await Proveedores.legajosRepositorio.guardarRegistro(registro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se derivo "${item.asunto}" a Legajos para seguimiento documental.',
        ),
      ),
    );
  }

  String _codigoLegajo(TramiteSecretaria item) => 'SEC-${item.codigo}';

  String _tipoRegistroParaTramite(TramiteSecretaria item) {
    switch (item.tipoTramite) {
      case 'constancia':
      case 'certificacion':
      case 'emision':
      case 'salida':
        return 'documento';
      default:
        return 'expediente';
    }
  }

  String _detalleLegajo(TramiteSecretaria item) {
    final partes = <String>[
      'Origen: Secretaria',
      'Tipo de tramite: ${item.tipoTramite}',
      'Solicitante: ${item.solicitante}',
      if ((item.cursoReferencia ?? '').trim().isNotEmpty)
        'Referencia: ${item.cursoReferencia!.trim()}',
      'Estado administrativo: ${item.estado}',
      if (item.observaciones.trim().isNotEmpty)
        'Observaciones: ${item.observaciones.trim()}',
    ];
    return partes.join('\n');
  }

  int? _horasHastaFechaLimite(DateTime? fechaLimite) {
    if (fechaLimite == null) return null;
    final horas = fechaLimite.difference(DateTime.now()).inHours;
    return horas <= 0 ? 0 : horas;
  }
}

class _EstadoSecretaria extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _EstadoSecretaria({
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

class _SelloSecretaria extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloSecretaria({required this.icono, required this.etiqueta});

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

class _MetricaSecretaria extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const _MetricaSecretaria({
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

class _TarjetaTramiteSecretaria extends StatelessWidget {
  final TramiteSecretaria item;
  final String codigoLegajo;
  final VoidCallback onEditar;
  final VoidCallback onDerivar;
  final VoidCallback onArchivar;

  const _TarjetaTramiteSecretaria({
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
                  item.asunto,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ChipTramiteSecretaria(
                icono: Icons.flag_outlined,
                texto: item.prioridad,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipTramiteSecretaria(
                icono: Icons.badge_outlined,
                texto: item.codigo,
              ),
              _ChipTramiteSecretaria(
                icono: Icons.category_outlined,
                texto: item.tipoTramite,
              ),
              _ChipTramiteSecretaria(
                icono: Icons.schedule_outlined,
                texto: item.estado,
              ),
              if (item.actualizadoDesdeLegajos)
                const _ChipTramiteSecretaria(
                  icono: Icons.reply_outlined,
                  texto: 'Devuelto desde legajos',
                ),
              if ((item.cursoReferencia ?? '').trim().isNotEmpty)
                _ChipTramiteSecretaria(
                  icono: Icons.groups_outlined,
                  texto: item.cursoReferencia!,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Solicitante: ${item.solicitante}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Responsable: ${item.responsable}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          if (item.fechaLimite != null) ...[
            const SizedBox(height: 6),
            Text(
              _textoFecha(item),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: item.vencido ? const Color(0xFFB42318) : cs.primary,
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
              return _ResumenCruceLegajo(
                titulo:
                    vinculo == null
                        ? 'Sin derivacion documental todavia'
                        : vinculo.activo
                        ? 'Derivado a Legajos'
                        : 'Legajo archivado',
                descripcion:
                    vinculo == null
                        ? 'Todavia no hay un legajo vinculado para este tramite.'
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

  String _textoFecha(TramiteSecretaria item) {
    final fecha = item.fechaLimite!;
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    if (item.vencido) return 'Vencido $dd/$mm/$yyyy';
    if (item.porVencer) return 'Por vencer $dd/$mm/$yyyy';
    return 'Fecha limite $dd/$mm/$yyyy';
  }
}

class _ResumenCruceLegajo extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final bool resaltado;

  const _ResumenCruceLegajo({
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
                ? cs.primaryContainer.withValues(alpha: 0.48)
                : cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color:
              resaltado
                  ? cs.primary.withValues(alpha: 0.24)
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
              color: resaltado ? cs.primary : cs.onSurfaceVariant,
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

class _ChipTramiteSecretaria extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ChipTramiteSecretaria({required this.icono, required this.texto});

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

class _DialogoTramiteSecretaria extends StatefulWidget {
  final TramiteSecretariaBorrador borrador;

  const _DialogoTramiteSecretaria({required this.borrador});

  @override
  State<_DialogoTramiteSecretaria> createState() =>
      _DialogoTramiteSecretariaState();
}

class _DialogoTramiteSecretariaState extends State<_DialogoTramiteSecretaria> {
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _asuntoCtrl;
  late final TextEditingController _solicitanteCtrl;
  late final TextEditingController _cursoCtrl;
  late final TextEditingController _responsableCtrl;
  late final TextEditingController _obsCtrl;
  late String _tipoTramite;
  late String _categoria;
  late String _estado;
  late String _prioridad;
  DateTime? _fechaLimite;

  @override
  void initState() {
    super.initState();
    final item = widget.borrador;
    _codigoCtrl = TextEditingController(text: item.codigo);
    _asuntoCtrl = TextEditingController(text: item.asunto);
    _solicitanteCtrl = TextEditingController(text: item.solicitante);
    _cursoCtrl = TextEditingController(text: item.cursoReferencia ?? '');
    _responsableCtrl = TextEditingController(text: item.responsable);
    _obsCtrl = TextEditingController(text: item.observaciones);
    _tipoTramite = item.tipoTramite;
    _categoria = item.categoria;
    _estado = item.estado;
    _prioridad = item.prioridad;
    _fechaLimite = item.fechaLimite;
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _asuntoCtrl.dispose();
    _solicitanteCtrl.dispose();
    _cursoCtrl.dispose();
    _responsableCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.borrador.id == null ? 'Nuevo tramite' : 'Editar tramite'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(labelText: 'Codigo interno'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _asuntoCtrl,
                decoration: const InputDecoration(labelText: 'Asunto'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _solicitanteCtrl,
                decoration: const InputDecoration(labelText: 'Solicitante'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cursoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Curso o referencia',
                ),
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
                      initialValue: _tipoTramite,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        'tramite',
                        'constancia',
                        'pase',
                        'equivalencia',
                        'certificacion',
                        'emision',
                        'salida',
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
                        setState(() => _tipoTramite = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: const ['alumnos', 'personal', 'institucional']
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: const [
                        'En preparacion',
                        'En verificacion',
                        'Pendiente de firma',
                        'Listo para firma',
                        'Listo para emitir',
                        'Urgente',
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
                      _fechaLimite == null
                          ? 'Sin fecha limite'
                          : 'Fecha limite: ${_fechaTexto(_fechaLimite!)}',
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
      initialDate: _fechaLimite ?? hoy.add(const Duration(days: 3)),
      firstDate: hoy.subtract(const Duration(days: 30)),
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Fecha limite del tramite',
    );
    if (fecha == null || !mounted) return;
    setState(() => _fechaLimite = fecha);
  }

  void _confirmar() {
    if (_codigoCtrl.text.trim().isEmpty ||
        _asuntoCtrl.text.trim().isEmpty ||
        _solicitanteCtrl.text.trim().isEmpty ||
        _responsableCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa codigo, asunto, solicitante y responsable.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      TramiteSecretariaBorrador(
        id: widget.borrador.id,
        tipoTramite: _tipoTramite,
        categoria: _categoria,
        codigo: _codigoCtrl.text.trim(),
        asunto: _asuntoCtrl.text.trim(),
        solicitante: _solicitanteCtrl.text.trim(),
        cursoReferencia: _cursoCtrl.text.trim().isEmpty ? null : _cursoCtrl.text.trim(),
        estado: _estado,
        prioridad: _prioridad,
        responsable: _responsableCtrl.text.trim(),
        observaciones: _obsCtrl.text.trim(),
        fechaLimite: _fechaLimite,
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
