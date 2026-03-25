import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/legajos/modelos/legajo_documental.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class LegajosPantalla extends StatefulWidget {
  const LegajosPantalla({super.key});

  @override
  State<LegajosPantalla> createState() => _LegajosPantallaState();
}

class _LegajosPantallaState extends State<LegajosPantalla> {
  _FiltroLegajo _filtro = _FiltroLegajo.alumnos;
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ContextoInstitucional>(
      valueListenable: Proveedores.contextoInstitucional,
      builder: (context, contexto, _) {
        return FutureBuilder<DashboardLegajos>(
          future: Proveedores.legajosRepositorio.cargarDashboard(
            contexto: contexto,
            categoria: _filtro.categoria,
          ).then((value) => value),
          key: ValueKey('${contexto.rol.name}-${_filtro.categoria}-$_refreshToken'),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _EstadoLegajos(
                icono: Icons.error_outline,
                titulo: 'No se pudo cargar la mesa documental',
                descripcion: '${snapshot.error}',
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const _EstadoLegajos(
                icono: Icons.folder_off_outlined,
                titulo: 'Sin datos de legajos',
                descripcion: 'Todavia no hay informacion documental disponible.',
              );
            }

            return _contenidoPrincipal(
              context: context,
              contexto: contexto,
              data: data,
            );
          },
        );
      },
    );
  }

  Widget _contenidoPrincipal({
    required BuildContext context,
    required ContextoInstitucional contexto,
    required DashboardLegajos data,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final metricas = _metricasPara(data.resumen);

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
                      _SelloLegajo(
                        icono: contexto.rol.icono,
                        etiqueta: contexto.rol.etiqueta,
                      ),
                      const _SelloLegajo(
                        icono: Icons.folder_open_outlined,
                        etiqueta: 'Legajos persistentes',
                      ),
                      _SelloLegajo(
                        icono: Icons.approval_outlined,
                        etiqueta: contexto.nivel.etiqueta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Mesa documental y legajos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Text(
                      _descripcionPara(contexto),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: metricas
                        .map(
                          (metrica) => _TarjetaMetricaLegajo(
                            icono: metrica.icono,
                            titulo: metrica.titulo,
                            valor: metrica.valor,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: EstilosAplicacion.decoracionPanel(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flujo de trabajo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esta bandeja organiza expedientes, documentos por vencer y tareas administrativas prioritarias.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.42,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _FiltroLegajo.values.map((filtro) {
                      return ChoiceChip(
                        label: Text(filtro.etiqueta),
                        selected: _filtro == filtro,
                        onSelected: (_) => setState(() => _filtro = filtro),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _abrirDialogoNuevo(
                          contexto: contexto,
                          tipoRegistro: 'expediente',
                        ),
                        icon: const Icon(Icons.add_task_outlined),
                        label: const Text('Nuevo expediente'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _abrirDialogoNuevo(
                          contexto: contexto,
                          tipoRegistro: 'documento',
                        ),
                        icon: const Icon(Icons.note_add_outlined),
                        label: const Text('Nuevo documento'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final esDobleColumna = constraints.maxWidth >= 1120;
              if (!esDobleColumna) {
                return Column(
                  children: [
                    _bloqueExpedientes(context, contexto, data.expedientes),
                    const SizedBox(height: 18),
                    _bloqueVencimientos(
                      context,
                      contexto,
                      data.documentosPendientes,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _bloqueExpedientes(
                      context,
                      contexto,
                      data.expedientes,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _bloqueVencimientos(
                      context,
                      contexto,
                      data.documentosPendientes,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _bloqueExpedientes(
    BuildContext context,
    ContextoInstitucional contexto,
    List<LegajoDocumental> expedientes,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expedientes recientes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            if (expedientes.isEmpty)
              const _EstadoLegajos(
                icono: Icons.inbox_outlined,
                titulo: 'Sin expedientes para este filtro',
                descripcion:
                    'Cambia la categoria o el perfil institucional para ver otros movimientos.',
              )
            else
              ...expedientes.map(
                (expediente) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaExpediente(
                    expediente: expediente,
                    onEditar: () => _abrirDialogoEditar(
                      contexto: contexto,
                      item: expediente,
                    ),
                    onDevolver:
                        expediente.origen != null
                            ? () => _devolverAModuloOrigen(expediente)
                            : null,
                    onArchivar: () => _archivarRegistro(expediente.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueVencimientos(
    BuildContext context,
    ContextoInstitucional contexto,
    List<LegajoDocumental> vencimientos,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documentos por revisar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Control preventivo de vencimientos, firmas y faltantes de documentacion.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            if (vencimientos.isEmpty)
              const _EstadoLegajos(
                icono: Icons.verified_outlined,
                titulo: 'Sin documentos pendientes',
                descripcion:
                    'No hay vencimientos documentales para el perfil activo.',
              )
            else
              ...vencimientos.map(
                (documento) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaDocumento(
                    documento: documento,
                    onEditar: () => _abrirDialogoEditar(
                      contexto: contexto,
                      item: documento,
                    ),
                    onDevolver:
                        documento.origen != null
                            ? () => _devolverAModuloOrigen(documento)
                            : null,
                    onArchivar: () => _archivarRegistro(documento.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _descripcionPara(ContextoInstitucional contexto) {
    switch (contexto.rol) {
      case RolInstitucional.secretario:
        return 'La secretaria necesita centralizar legajos, constancias, pases, regularidades y cierres administrativos sin perder trazabilidad.';
      case RolInstitucional.director:
      case RolInstitucional.rector:
        return 'Direccion y rectorado requieren una vista de control documental para detectar riesgos, pendientes y cuellos de botella administrativos.';
      default:
        return 'Este modulo ordena la capa documental institucional y prepara el sistema para legajos completos de alumnos, personal y expedientes internos.';
    }
  }

  List<_MetricaLegajo> _metricasPara(ResumenLegajos resumen) {
    return [
      _MetricaLegajo(
        icono: Icons.inventory_2_outlined,
        titulo: 'Legajos activos',
        valor: '${resumen.legajosActivos}',
      ),
      _MetricaLegajo(
        icono: Icons.pending_actions_outlined,
        titulo: 'Pendientes',
        valor: '${resumen.pendientes}',
      ),
      _MetricaLegajo(
        icono: Icons.warning_amber_outlined,
        titulo: 'Criticos',
        valor: '${resumen.criticos}',
      ),
    ];
  }

  Future<void> _abrirDialogoNuevo({
    required ContextoInstitucional contexto,
    required String tipoRegistro,
  }) async {
    final borrador = await showDialog<LegajoDocumentalBorrador>(
      context: context,
      builder: (context) => _DialogoLegajo(
        contextoBase: contexto,
        borradorInicial: LegajoDocumentalBorrador(
          tipoRegistro: tipoRegistro,
          categoria: _filtro.categoria,
          codigo: '',
          titulo: '',
          detalle: '',
          responsable: contexto.rol.etiqueta,
          estado: tipoRegistro == 'documento' ? 'Pendiente' : 'En seguimiento',
          severidad: 'Media',
          rolDestino: contexto.rol.name,
          nivelDestino: contexto.nivel.name,
          dependenciaDestino: contexto.dependencia.name,
          horasHastaVencimiento: tipoRegistro == 'documento' ? 72 : null,
        ),
      ),
    );
    if (borrador == null) return;
    await _guardarBorrador(borrador, creado: true);
  }

  Future<void> _abrirDialogoEditar({
    required ContextoInstitucional contexto,
    required LegajoDocumental item,
  }) async {
    final borrador = await showDialog<LegajoDocumentalBorrador>(
      context: context,
      builder: (context) => _DialogoLegajo(
        contextoBase: contexto,
        borradorInicial: LegajoDocumentalBorrador.desdeRegistro(item),
      ),
    );
    if (borrador == null) return;
    await _guardarBorrador(borrador, creado: false);
  }

  Future<void> _guardarBorrador(
    LegajoDocumentalBorrador borrador, {
    required bool creado,
  }) async {
    await Proveedores.legajosRepositorio.guardarRegistro(borrador);
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          creado
              ? 'Registro documental creado correctamente.'
              : 'Registro documental actualizado correctamente.',
        ),
      ),
    );
  }

  Future<void> _archivarRegistro(int id) async {
    await Proveedores.legajosRepositorio.archivarRegistro(id);
    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro archivado.')),
    );
  }

  Future<void> _devolverAModuloOrigen(LegajoDocumental item) async {
    final origen = item.origen;
    if (origen == null) return;

    final resumen = _mensajeDevolucion(item);
    var actualizado = false;

    if (origen.modulo == 'Secretaria') {
      final codigoTramite = item.codigoSecretariaOrigen;
      if (codigoTramite != null) {
        actualizado = await Proveedores.tramitesSecretariaRepositorio
            .recibirDeLegajos(
              codigoTramite: codigoTramite,
              estadoLegajo: item.estado,
              detalleLegajo: resumen,
              urgente: item.severidad == 'Alta',
            );
      }
    } else if (origen.modulo == 'Preceptoria') {
      final novedadId = item.idPreceptoriaOrigen;
      if (novedadId != null) {
        actualizado = await Proveedores.preceptoriaRepositorio.recibirDeLegajos(
          novedadId: novedadId,
          estadoLegajo: item.estado,
          detalleLegajo: resumen,
            urgente: item.severidad == 'Alta',
          );
      }
    } else if (origen.modulo == 'Biblioteca') {
      final codigoRecurso = item.codigoBibliotecaOrigen;
      if (codigoRecurso != null) {
        actualizado = await Proveedores.recursosBibliotecaRepositorio
            .recibirDeLegajos(
              codigoRecurso: codigoRecurso,
              estadoLegajo: item.estado,
              detalleLegajo: resumen,
              urgente: item.severidad == 'Alta',
            );
      }
    }

    if (!actualizado) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar la mesa de origen para este legajo.',
          ),
        ),
      );
      return;
    }

    final borrador = LegajoDocumentalBorrador.desdeRegistro(item).copyWith(
      detalle: _detalleConDevolucion(item.detalle, origen.modulo, resumen),
    );
    await Proveedores.legajosRepositorio.guardarRegistro(borrador);

    if (!mounted) return;
    setState(() => _refreshToken++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se devolvio el caso a ${origen.modulo} con actualizacion operativa.',
        ),
      ),
    );
  }

  String _mensajeDevolucion(LegajoDocumental item) {
    final partes = <String>[
      'Codigo legajo: ${item.codigo}',
      'Estado documental: ${item.estado}',
      'Severidad: ${item.severidad}',
    ];
    if (item.horasHastaVencimiento != null) {
      partes.add('Vencimiento: ${item.horasHastaVencimiento} hs');
    }
    return partes.join(' | ');
  }

  String _detalleConDevolucion(
    String detalleActual,
    String moduloOrigen,
    String resumen,
  ) {
    final nota =
        'Derivado nuevamente a $moduloOrigen para accion operativa: $resumen';
    if (detalleActual.contains(nota)) return detalleActual;
    return '$detalleActual\n$nota'.trim();
  }
}

enum _FiltroLegajo { alumnos, personal, institucional }

extension on _FiltroLegajo {
  String get etiqueta => switch (this) {
    _FiltroLegajo.alumnos => 'Alumnos',
    _FiltroLegajo.personal => 'Personal',
    _FiltroLegajo.institucional => 'Institucional',
  };

  String get categoria => switch (this) {
    _FiltroLegajo.alumnos => 'alumnos',
    _FiltroLegajo.personal => 'personal',
    _FiltroLegajo.institucional => 'institucional',
  };
}

class _MetricaLegajo {
  final IconData icono;
  final String titulo;
  final String valor;

  const _MetricaLegajo({
    required this.icono,
    required this.titulo,
    required this.valor,
  });
}

class _SelloLegajo extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloLegajo({required this.icono, required this.etiqueta});

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

class _TarjetaMetricaLegajo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _TarjetaMetricaLegajo({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 170),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.75),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.82)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                valor,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarjetaExpediente extends StatelessWidget {
  final LegajoDocumental expediente;
  final VoidCallback onEditar;
  final VoidCallback? onDevolver;
  final VoidCallback onArchivar;

  const _TarjetaExpediente({
    required this.expediente,
    required this.onEditar,
    required this.onDevolver,
    required this.onArchivar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final origen = expediente.origen;
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
                  expediente.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                expediente.codigo,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expediente.detalle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.42,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (origen != null)
                _PildoraLegajo(
                  icono: Icons.link_outlined,
                  texto: '${origen.modulo}: ${origen.referencia}',
                ),
              _PildoraLegajo(
                icono: Icons.person_outline,
                texto: expediente.responsable,
              ),
              _PildoraLegajo(
                icono: Icons.flag_outlined,
                texto: expediente.estado,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              if (onDevolver != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDevolver,
                  icon: const Icon(Icons.reply_outlined),
                  label: Text('Devolver a ${origen!.modulo}'),
                ),
              ],
              const SizedBox(width: 8),
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
}

class _TarjetaDocumento extends StatelessWidget {
  final LegajoDocumental documento;
  final VoidCallback onEditar;
  final VoidCallback? onDevolver;
  final VoidCallback onArchivar;

  const _TarjetaDocumento({
    required this.documento,
    required this.onEditar,
    required this.onDevolver,
    required this.onArchivar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = documento.severidad == 'Alta'
        ? const Color(0xFFB42318)
        : const Color(0xFFB45309);
    final vencimiento = _textoVencimiento(documento.horasHastaVencimiento);
    final origen = documento.origen;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.description_outlined, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documento.titulo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vence en $vencimiento',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                documento.severidad,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (origen != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _PildoraLegajo(
                icono: Icons.link_outlined,
                texto: '${origen.modulo}: ${origen.referencia}',
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              TextButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              if (onDevolver != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDevolver,
                  icon: const Icon(Icons.reply_outlined),
                  label: Text('Devolver a ${origen!.modulo}'),
                ),
              ],
              const SizedBox(width: 8),
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

  String _textoVencimiento(int? horas) {
    if (horas == null) return 'sin fecha';
    if (horas < 24) return '$horas hs';
    final dias = (horas / 24).round();
    return dias == 1 ? '1 dia' : '$dias dias';
  }
}

class _EstadoLegajos extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _EstadoLegajos({
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
          Icon(icono, color: cs.primary, size: 22),
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

class _PildoraLegajo extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _PildoraLegajo({required this.icono, required this.texto});

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

class _DialogoLegajo extends StatefulWidget {
  final ContextoInstitucional contextoBase;
  final LegajoDocumentalBorrador borradorInicial;

  const _DialogoLegajo({
    required this.contextoBase,
    required this.borradorInicial,
  });

  @override
  State<_DialogoLegajo> createState() => _DialogoLegajoState();
}

class _DialogoLegajoState extends State<_DialogoLegajo> {
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _detalleCtrl;
  late final TextEditingController _responsableCtrl;
  late final TextEditingController _horasCtrl;
  late String _tipoRegistro;
  late String _categoria;
  late String _estado;
  late String _severidad;
  late RolInstitucional _rolDestino;
  late NivelInstitucional _nivelDestino;
  late DependenciaInstitucional _dependenciaDestino;

  @override
  void initState() {
    super.initState();
    final item = widget.borradorInicial;
    _codigoCtrl = TextEditingController(text: item.codigo);
    _tituloCtrl = TextEditingController(text: item.titulo);
    _detalleCtrl = TextEditingController(text: item.detalle);
    _responsableCtrl = TextEditingController(text: item.responsable);
    _horasCtrl = TextEditingController(
      text: item.horasHastaVencimiento?.toString() ?? '',
    );
    _tipoRegistro = item.tipoRegistro;
    _categoria = item.categoria;
    _estado = item.estado;
    _severidad = item.severidad;
    _rolDestino = RolInstitucional.values.firstWhere(
      (value) => value.name == item.rolDestino,
      orElse: () => widget.contextoBase.rol,
    );
    _nivelDestino = NivelInstitucional.values.firstWhere(
      (value) => value.name == item.nivelDestino,
      orElse: () => widget.contextoBase.nivel,
    );
    _dependenciaDestino = DependenciaInstitucional.values.firstWhere(
      (value) => value.name == item.dependenciaDestino,
      orElse: () => widget.contextoBase.dependencia,
    );
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _tituloCtrl.dispose();
    _detalleCtrl.dispose();
    _responsableCtrl.dispose();
    _horasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esDocumento = _tipoRegistro == 'documento';

    return AlertDialog(
      title: Text(
        widget.borradorInicial.id == null
            ? 'Nuevo registro documental'
            : 'Editar registro documental',
      ),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipoRegistro,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const [
                        DropdownMenuItem(
                          value: 'expediente',
                          child: Text('Expediente'),
                        ),
                        DropdownMenuItem(
                          value: 'documento',
                          child: Text('Documento'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _tipoRegistro = value;
                          final estados = _estadosDisponibles(value);
                          if (!estados.contains(_estado)) {
                            _estado = estados.first;
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: const [
                        DropdownMenuItem(
                          value: 'alumnos',
                          child: Text('Alumnos'),
                        ),
                        DropdownMenuItem(
                          value: 'personal',
                          child: Text('Personal'),
                        ),
                        DropdownMenuItem(
                          value: 'institucional',
                          child: Text('Institucional'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _categoria = value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      initialValue: _severidad,
                      decoration: const InputDecoration(labelText: 'Severidad'),
                      items: const [
                        DropdownMenuItem(value: 'Media', child: Text('Media')),
                        DropdownMenuItem(value: 'Alta', child: Text('Alta')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _severidad = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(labelText: 'Codigo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Titulo'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detalleCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Detalle'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _responsableCtrl,
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      initialValue: _estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _estadosDisponibles(_tipoRegistro)
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _estado = value);
                      },
                    ),
                  ),
                  if (esDocumento)
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _horasCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Horas hasta vencimiento',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<RolInstitucional>(
                      initialValue: _rolDestino,
                      decoration: const InputDecoration(labelText: 'Rol destino'),
                      items: RolInstitucional.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.etiqueta),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _rolDestino = value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<NivelInstitucional>(
                      initialValue: _nivelDestino,
                      decoration: const InputDecoration(labelText: 'Nivel'),
                      items: NivelInstitucional.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.etiqueta),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _nivelDestino = value);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<DependenciaInstitucional>(
                      initialValue: _dependenciaDestino,
                      decoration: const InputDecoration(labelText: 'Gestion'),
                      items: DependenciaInstitucional.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value.etiqueta),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _dependenciaDestino = value);
                      },
                    ),
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
          onPressed: _guardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  List<String> _estadosDisponibles(String tipoRegistro) {
    if (tipoRegistro == 'documento') {
      return const ['Pendiente', 'En revision', 'Listo para emitir'];
    }
    return const [
      'En seguimiento',
      'Requiere revision',
      'En revision',
      'Critico',
      'Listo para emitir',
      'En curso',
    ];
  }

  void _guardar() {
    final codigo = _codigoCtrl.text.trim();
    final titulo = _tituloCtrl.text.trim();
    final responsable = _responsableCtrl.text.trim();

    if (codigo.isEmpty || titulo.isEmpty || responsable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Codigo, titulo y responsable son obligatorios.'),
        ),
      );
      return;
    }

    final horas = _tipoRegistro == 'documento'
        ? int.tryParse(_horasCtrl.text.trim())
        : null;

    Navigator.of(context).pop(
      LegajoDocumentalBorrador(
        id: widget.borradorInicial.id,
        tipoRegistro: _tipoRegistro,
        categoria: _categoria,
        codigo: codigo,
        titulo: titulo,
        detalle: _detalleCtrl.text.trim(),
        responsable: responsable,
        estado: _estado,
        severidad: _severidad,
        rolDestino: _rolDestino.name,
        nivelDestino: _nivelDestino.name,
        dependenciaDestino: _dependenciaDestino.name,
        horasHastaVencimiento: horas,
      ),
    );
  }
}
