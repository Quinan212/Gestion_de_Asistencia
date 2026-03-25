import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/biblioteca/modelos/recurso_biblioteca.dart';
import 'package:gestion_de_asistencias/modulos/legajos/modelos/legajo_documental.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class BibliotecaPantalla extends StatefulWidget {
  const BibliotecaPantalla({super.key});

  @override
  State<BibliotecaPantalla> createState() => _BibliotecaPantallaState();
}

class _BibliotecaPantallaState extends State<BibliotecaPantalla> {
  String _filtro = 'academico';
  int _refreshToken = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ContextoInstitucional>(
      valueListenable: Proveedores.contextoInstitucional,
      builder: (context, contexto, _) {
        return FutureBuilder<DashboardBiblioteca>(
          key: ValueKey('${contexto.rol.name}-$_filtro-$_refreshToken'),
          future: Proveedores.recursosBibliotecaRepositorio.cargarDashboard(
            contexto: contexto,
            categoria: _filtro,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _EstadoBiblioteca(
                icono: Icons.menu_book_outlined,
                titulo: 'Cargando biblioteca',
                descripcion:
                    'Preparando catalogo, prestamos y disponibilidad de recursos.',
              );
            }
            if (snapshot.hasError) {
              return _EstadoBiblioteca(
                icono: Icons.error_outline,
                titulo: 'No se pudo abrir biblioteca',
                descripcion: '${snapshot.error}',
              );
            }
            final data = snapshot.data;
            if (data == null) {
              return const _EstadoBiblioteca(
                icono: Icons.library_books_outlined,
                titulo: 'Sin recursos cargados',
                descripcion:
                    'Todavia no hay material registrado para este contexto bibliotecario.',
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
    DashboardBiblioteca data,
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
              _SelloBiblioteca(icono: contexto.rol.icono, etiqueta: contexto.rol.etiqueta),
              _SelloBiblioteca(icono: Icons.school_outlined, etiqueta: contexto.nivel.etiqueta),
              _SelloBiblioteca(
                icono: Icons.apartment_outlined,
                etiqueta: contexto.dependencia.etiqueta,
              ),
              const _SelloBiblioteca(
                icono: Icons.library_books_outlined,
                etiqueta: 'Prestamos persistentes',
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
                      'Biblioteca institucional',
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
                    onPressed: () => _editarRecurso(
                      contexto,
                      tipoInicial: 'libro',
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nuevo recurso'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _editarRecurso(
                      contexto,
                      estadoInicial: 'Prestado',
                    ),
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('Nuevo prestamo'),
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
              _MetricaBiblioteca(
                titulo: 'Recursos activos',
                valor: '${data.resumen.recursosActivos}',
                descripcion: 'Catalogo visible para este contexto.',
                icono: Icons.library_books_outlined,
              ),
              _MetricaBiblioteca(
                titulo: 'Prestamos activos',
                valor: '${data.resumen.prestamosActivos}',
                descripcion: 'Prestamos o reservas actualmente abiertas.',
                icono: Icons.assignment_turned_in_outlined,
              ),
              _MetricaBiblioteca(
                titulo: 'Vencidos',
                valor: '${data.resumen.vencidos}',
                descripcion: 'Recursos que ya superaron su fecha de devolucion.',
                icono: Icons.event_busy_outlined,
              ),
              _MetricaBiblioteca(
                titulo: 'Disponibles',
                valor: '${data.resumen.disponibles}',
                descripcion: 'Ejemplares listos para prestar o consultar.',
                icono: Icons.check_circle_outline,
              ),
              _MetricaBiblioteca(
                titulo: 'Con legajo',
                valor: '${data.resumen.vinculadosALegajos}',
                descripcion: 'Prestamos o incidencias que tocaron el circuito documental.',
                icono: Icons.link_outlined,
              ),
              _MetricaBiblioteca(
                titulo: 'Devueltos',
                valor: '${data.resumen.devueltosDesdeLegajos}',
                descripcion: 'Casos que volvieron desde Legajos para accion bibliotecaria.',
                icono: Icons.reply_outlined,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['academico', 'literatura', 'multimedia', 'hemeroteca']
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
            'Prestamos y reservas',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.prestamos.isEmpty)
            const _EstadoBiblioteca(
              icono: Icons.assignment_turned_in_outlined,
              titulo: 'Sin prestamos activos',
              descripcion:
                  'No hay prestamos ni reservas abiertos para este contexto.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.prestamos
                  .map(
                    (item) => _TarjetaRecursoBiblioteca(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarRecurso(contexto, actual: item),
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
          if (data.recursosDerivados.isEmpty)
            const _EstadoBiblioteca(
              icono: Icons.link_off_outlined,
              titulo: 'Sin cruces documentales activos',
              descripcion:
                  'Todavia no hay prestamos o incidencias vinculados a Legajos.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.recursosDerivados
                  .map(
                    (item) => _TarjetaRecursoBiblioteca(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarRecurso(contexto, actual: item),
                      onDerivar: () => _derivarALegajos(contexto, item),
                      onArchivar: () => _archivar(item.id),
                    ),
                  )
                  .toList(growable: false),
            ),
          const SizedBox(height: 18),
          Text(
            'Catalogo e inventario',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (data.catalogo.isEmpty)
            const _EstadoBiblioteca(
              icono: Icons.search_off_outlined,
              titulo: 'Sin recursos para esta categoria',
              descripcion: 'No hay material cargado en la categoria seleccionada.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: data.catalogo
                  .map(
                    (item) => _TarjetaRecursoBiblioteca(
                      item: item,
                      codigoLegajo: _codigoLegajo(item),
                      onEditar: () => _editarRecurso(contexto, actual: item),
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
      case RolInstitucional.bibliotecario:
        return 'La biblioteca ya puede registrar recursos, prestar materiales, controlar vencimientos y sostener un inventario basico.';
      case RolInstitucional.director:
      case RolInstitucional.rector:
        return 'Direccion y rectorado pueden revisar prestamos, disponibilidad y recursos comprometidos desde una vista unificada.';
      default:
        return 'Este modulo organiza prestamos, reservas e inventario basico de la biblioteca institucional.';
    }
  }

  Future<void> _editarRecurso(
    ContextoInstitucional contexto, {
    RecursoBiblioteca? actual,
    String? tipoInicial,
    String? estadoInicial,
  }) async {
    final borrador =
        actual != null
            ? RecursoBibliotecaBorrador.desdeRecurso(actual)
            : RecursoBibliotecaBorrador(
                tipoRecurso: tipoInicial ?? 'libro',
                categoria: _filtro,
                codigo: '',
                titulo: '',
                autorReferencia: null,
                estado: estadoInicial ?? 'Disponible',
                responsable: contexto.rol.etiqueta,
                destinatario: null,
                cursoReferencia: null,
                cantidadTotal: 1,
                cantidadDisponible: estadoInicial == 'Prestado' ? 0 : 1,
                fechaVencimiento: estadoInicial == 'Prestado'
                    ? DateTime.now().add(const Duration(days: 7))
                    : null,
                observaciones: '',
                rolDestino: contexto.rol.name,
                nivelDestino: contexto.nivel.name,
                dependenciaDestino: contexto.dependencia.name,
              );

    final resultado = await showDialog<RecursoBibliotecaBorrador>(
      context: context,
      builder: (context) => _DialogoRecursoBiblioteca(borrador: borrador),
    );
    if (resultado == null) return;
    await Proveedores.recursosBibliotecaRepositorio.guardarRecurso(resultado);
    if (!mounted) return;
    setState(() => _refreshToken++);
  }

  Future<void> _archivar(int id) async {
    await Proveedores.recursosBibliotecaRepositorio.archivarRecurso(id);
    if (!mounted) return;
    setState(() => _refreshToken++);
  }

  Future<void> _derivarALegajos(
    ContextoInstitucional contexto,
    RecursoBiblioteca item,
  ) async {
    final registro = LegajoDocumentalBorrador(
      tipoRegistro: item.prestadoOReservado ? 'documento' : 'expediente',
      categoria: 'institucional',
      codigo: _codigoLegajo(item),
      titulo: item.titulo,
      detalle: _detalleLegajo(item),
      responsable: item.responsable,
      estado: item.vencido ? 'Pendiente' : 'En revision',
      severidad: _severidadLegajo(item),
      rolDestino: contexto.tienePermiso(PermisoModulo.legajos)
          ? contexto.rol.name
          : RolInstitucional.director.name,
      nivelDestino: contexto.nivel.name,
      dependenciaDestino: contexto.dependencia.name,
      horasHastaVencimiento: _horasHastaVencimiento(item.fechaVencimiento),
    );

    await Proveedores.legajosRepositorio.guardarRegistro(registro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se derivo "${item.titulo}" a Legajos para seguimiento institucional.',
        ),
      ),
    );
    setState(() => _refreshToken++);
  }

  String _codigoLegajo(RecursoBiblioteca item) => 'BIB-${item.codigo}';

  String _detalleLegajo(RecursoBiblioteca item) {
    final partes = <String>[
      'Origen: Biblioteca',
      'Recurso: ${item.titulo}',
      'Tipo de recurso: ${item.tipoRecurso}',
      if ((item.destinatario ?? '').trim().isNotEmpty)
        'Destinatario: ${item.destinatario!.trim()}',
      if ((item.cursoReferencia ?? '').trim().isNotEmpty)
        'Curso: ${item.cursoReferencia!.trim()}',
      'Estado bibliotecario: ${item.estado}',
      'Disponibilidad: ${item.cantidadDisponible}/${item.cantidadTotal}',
      if (item.observaciones.trim().isNotEmpty)
        'Observaciones: ${item.observaciones.trim()}',
    ];
    return partes.join('\n');
  }

  String _severidadLegajo(RecursoBiblioteca item) {
    if (item.vencido) return 'Alta';
    if (item.porVencer || item.estado == 'Reservado') return 'Media';
    return 'Baja';
  }

  int? _horasHastaVencimiento(DateTime? fechaVencimiento) {
    if (fechaVencimiento == null) return null;
    final horas = fechaVencimiento.difference(DateTime.now()).inHours;
    return horas <= 0 ? 0 : horas;
  }
}

class _EstadoBiblioteca extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const _EstadoBiblioteca({
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

class _SelloBiblioteca extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloBiblioteca({required this.icono, required this.etiqueta});

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

class _MetricaBiblioteca extends StatelessWidget {
  final String titulo;
  final String valor;
  final String descripcion;
  final IconData icono;

  const _MetricaBiblioteca({
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

class _TarjetaRecursoBiblioteca extends StatelessWidget {
  final RecursoBiblioteca item;
  final String codigoLegajo;
  final VoidCallback onEditar;
  final VoidCallback onDerivar;
  final VoidCallback onArchivar;

  const _TarjetaRecursoBiblioteca({
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
                  item.titulo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ChipBiblioteca(icono: Icons.inventory_2_outlined, texto: item.estado),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChipBiblioteca(icono: Icons.badge_outlined, texto: item.codigo),
              _ChipBiblioteca(icono: Icons.category_outlined, texto: item.tipoRecurso),
              _ChipBiblioteca(
                icono: Icons.numbers_outlined,
                texto: '${item.cantidadDisponible}/${item.cantidadTotal}',
              ),
              if (item.actualizadoDesdeLegajos)
                const _ChipBiblioteca(
                  icono: Icons.reply_outlined,
                  texto: 'Devuelto desde legajos',
                ),
              if ((item.destinatario ?? '').trim().isNotEmpty)
                _ChipBiblioteca(
                  icono: Icons.person_outline,
                  texto: item.destinatario!,
                ),
            ],
          ),
          if ((item.autorReferencia ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.autorReferencia!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          if (item.fechaVencimiento != null) ...[
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
              return _ResumenCruceBiblioteca(
                titulo:
                    vinculo == null
                        ? 'Sin derivacion documental todavia'
                        : vinculo.activo
                        ? 'Vinculado a Legajos'
                        : 'Legajo archivado',
                descripcion:
                    vinculo == null
                        ? 'El recurso sigue gestionado solo desde Biblioteca.'
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

  String _textoFecha(RecursoBiblioteca item) {
    final fecha = item.fechaVencimiento!;
    final dd = fecha.day.toString().padLeft(2, '0');
    final mm = fecha.month.toString().padLeft(2, '0');
    final yyyy = fecha.year.toString();
    if (item.vencido) return 'Vencido $dd/$mm/$yyyy';
    if (item.porVencer) return 'Por vencer $dd/$mm/$yyyy';
    return 'Devolver $dd/$mm/$yyyy';
  }
}

class _ResumenCruceBiblioteca extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final bool resaltado;

  const _ResumenCruceBiblioteca({
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
                ? cs.secondaryContainer.withValues(alpha: 0.52)
                : cs.surfaceContainer,
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(
          color:
              resaltado
                  ? cs.secondary.withValues(alpha: 0.26)
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
              color: resaltado ? cs.secondary : cs.onSurfaceVariant,
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

class _ChipBiblioteca extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _ChipBiblioteca({required this.icono, required this.texto});

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

class _DialogoRecursoBiblioteca extends StatefulWidget {
  final RecursoBibliotecaBorrador borrador;

  const _DialogoRecursoBiblioteca({required this.borrador});

  @override
  State<_DialogoRecursoBiblioteca> createState() =>
      _DialogoRecursoBibliotecaState();
}

class _DialogoRecursoBibliotecaState extends State<_DialogoRecursoBiblioteca> {
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _autorCtrl;
  late final TextEditingController _responsableCtrl;
  late final TextEditingController _destinatarioCtrl;
  late final TextEditingController _cursoCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _disponibleCtrl;
  late final TextEditingController _obsCtrl;
  late String _tipoRecurso;
  late String _categoria;
  late String _estado;
  DateTime? _fechaVencimiento;

  @override
  void initState() {
    super.initState();
    final item = widget.borrador;
    _codigoCtrl = TextEditingController(text: item.codigo);
    _tituloCtrl = TextEditingController(text: item.titulo);
    _autorCtrl = TextEditingController(text: item.autorReferencia ?? '');
    _responsableCtrl = TextEditingController(text: item.responsable);
    _destinatarioCtrl = TextEditingController(text: item.destinatario ?? '');
    _cursoCtrl = TextEditingController(text: item.cursoReferencia ?? '');
    _totalCtrl = TextEditingController(text: '${item.cantidadTotal}');
    _disponibleCtrl = TextEditingController(text: '${item.cantidadDisponible}');
    _obsCtrl = TextEditingController(text: item.observaciones);
    _tipoRecurso = item.tipoRecurso;
    _categoria = item.categoria;
    _estado = item.estado;
    _fechaVencimiento = item.fechaVencimiento;
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _tituloCtrl.dispose();
    _autorCtrl.dispose();
    _responsableCtrl.dispose();
    _destinatarioCtrl.dispose();
    _cursoCtrl.dispose();
    _totalCtrl.dispose();
    _disponibleCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.borrador.id == null ? 'Nuevo recurso' : 'Editar recurso'),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: _autorCtrl,
                decoration: const InputDecoration(labelText: 'Autor o referencia'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _tipoRecurso,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: const ['libro', 'manual', 'revista', 'equipo']
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _tipoRecurso = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: const [
                        'academico',
                        'literatura',
                        'multimedia',
                        'hemeroteca',
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
                controller: _responsableCtrl,
                decoration: const InputDecoration(labelText: 'Responsable'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _destinatarioCtrl,
                      decoration: const InputDecoration(labelText: 'Destinatario'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cursoCtrl,
                      decoration: const InputDecoration(labelText: 'Curso o referencia'),
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
                        'Disponible',
                        'Prestado',
                        'Reservado',
                        'En reparacion',
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
                    child: TextField(
                      controller: _totalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad total'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _disponibleCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad disponible',
                      ),
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
                      _fechaVencimiento == null
                          ? 'Sin fecha de devolucion'
                          : 'Fecha: ${_fechaTexto(_fechaVencimiento!)}',
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
      initialDate: _fechaVencimiento ?? hoy.add(const Duration(days: 7)),
      firstDate: hoy.subtract(const Duration(days: 30)),
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Fecha de devolucion',
    );
    if (fecha == null || !mounted) return;
    setState(() => _fechaVencimiento = fecha);
  }

  void _confirmar() {
    final total = int.tryParse(_totalCtrl.text.trim());
    final disponible = int.tryParse(_disponibleCtrl.text.trim());
    if (_codigoCtrl.text.trim().isEmpty ||
        _tituloCtrl.text.trim().isEmpty ||
        _responsableCtrl.text.trim().isEmpty ||
        total == null ||
        disponible == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa codigo, titulo, responsable y cantidades validas.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      RecursoBibliotecaBorrador(
        id: widget.borrador.id,
        tipoRecurso: _tipoRecurso,
        categoria: _categoria,
        codigo: _codigoCtrl.text.trim(),
        titulo: _tituloCtrl.text.trim(),
        autorReferencia: _autorCtrl.text.trim().isEmpty ? null : _autorCtrl.text.trim(),
        estado: _estado,
        responsable: _responsableCtrl.text.trim(),
        destinatario: _destinatarioCtrl.text.trim().isEmpty
            ? null
            : _destinatarioCtrl.text.trim(),
        cursoReferencia: _cursoCtrl.text.trim().isEmpty ? null : _cursoCtrl.text.trim(),
        cantidadTotal: total,
        cantidadDisponible: disponible,
        fechaVencimiento: _fechaVencimiento,
        observaciones: _obsCtrl.text.trim(),
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
