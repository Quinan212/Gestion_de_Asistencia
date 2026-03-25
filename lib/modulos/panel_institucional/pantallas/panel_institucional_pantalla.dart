import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class PanelInstitucionalPantalla extends StatefulWidget {
  const PanelInstitucionalPantalla({super.key});

  @override
  State<PanelInstitucionalPantalla> createState() =>
      _PanelInstitucionalPantallaState();
}

class _PanelInstitucionalPantallaState
    extends State<PanelInstitucionalPantalla> {
  late ContextoInstitucional _contexto;
  late final VoidCallback _contextoListener;

  RolInstitucional get _rol => _contexto.rol;
  NivelInstitucional get _nivel => _contexto.nivel;
  DependenciaInstitucional get _dependencia => _contexto.dependencia;

  @override
  void initState() {
    super.initState();
    _contexto = Proveedores.contextoInstitucional.value;
    _contextoListener = () {
      if (!mounted) return;
      setState(() {
        _contexto = Proveedores.contextoInstitucional.value;
      });
    };
    Proveedores.contextoInstitucional.addListener(_contextoListener);
  }

  @override
  void dispose() {
    Proveedores.contextoInstitucional.removeListener(_contextoListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resumen = CatalogoPerfilesInstitucionales.construir(
      rol: _contexto.rol,
      nivel: _contexto.nivel,
      dependencia: _contexto.dependencia,
    );
    final esDesktop = LayoutApp.esDesktop(MediaQuery.sizeOf(context).width);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hero(context, resumen),
          const SizedBox(height: 18),
          if (esDesktop)
            Wrap(
              spacing: 18,
              runSpacing: 18,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                SizedBox(width: 420, child: _bloqueSelectorContexto(context)),
                SizedBox(width: 420, child: _bloqueCobertura(context)),
              ],
            )
          else ...[
            _bloqueSelectorContexto(context),
            const SizedBox(height: 18),
            _bloqueCobertura(context),
          ],
          const SizedBox(height: 18),
          _bloquePermisos(context, resumen.permisos),
          const SizedBox(height: 18),
          if (esDesktop)
            Wrap(
              spacing: 18,
              runSpacing: 18,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                SizedBox(
                  width: 520,
                  child: _bloquePrioridades(context, resumen.prioridades),
                ),
                SizedBox(
                  width: 520,
                  child: _bloqueModulos(context, resumen.modulos),
                ),
              ],
            )
          else ...[
            _bloquePrioridades(context, resumen.prioridades),
            const SizedBox(height: 18),
            _bloqueModulos(context, resumen.modulos),
          ],
        ],
      ),
    );
  }

  Widget _hero(BuildContext context, PerfilInstitucionalResumen resumen) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
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
                _SelloContexto(icono: _rol.icono, etiqueta: _rol.etiqueta),
                _SelloContexto(
                  icono: Icons.account_balance_outlined,
                  etiqueta: _nivel.etiqueta,
                ),
                _SelloContexto(
                  icono: _dependencia == DependenciaInstitucional.publica
                      ? Icons.apartment_outlined
                      : Icons.domain_outlined,
                  etiqueta: _dependencia.etiqueta,
                ),
                const _SelloContexto(
                  icono: Icons.location_on_outlined,
                  etiqueta: 'Entre Rios, Argentina',
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              resumen.titulo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Text(
                resumen.resumen,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _IndicadorHero(
                  icono: Icons.layers_outlined,
                  titulo: 'Foco del perfil',
                  valor: resumen.foco,
                ),
                _IndicadorHero(
                  icono: Icons.widgets_outlined,
                  titulo: 'Modulos priorizados',
                  valor: '${resumen.modulos.length} frentes activos',
                ),
                _IndicadorHero(
                  icono: Icons.priority_high_outlined,
                  titulo: 'Prioridades',
                  valor: '${resumen.prioridades.length} lineas de trabajo',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueSelectorContexto(BuildContext context) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuracion institucional',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta capa inicial define para quien estamos construyendo la experiencia y cuales son sus flujos criticos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los cambios se guardan automaticamente en este dispositivo.',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            _tituloGrupo(context, 'Rol principal'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RolInstitucional.values.map((rol) {
                return Tooltip(
                  message: rol.descripcionBreve,
                  child: ChoiceChip(
                    label: Text(rol.etiqueta),
                    avatar: Icon(rol.icono, size: 16),
                    selected: _rol == rol,
                    onSelected: (_) => _actualizarContexto(_contexto.copyWith(rol: rol)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            _tituloGrupo(context, 'Nivel'),
            const SizedBox(height: 10),
            SegmentedButton<NivelInstitucional>(
              showSelectedIcon: false,
              segments: NivelInstitucional.values
                  .map(
                    (nivel) => ButtonSegment(
                      value: nivel,
                      label: Text(nivel.etiqueta),
                    ),
                  )
                  .toList(),
              selected: {_nivel},
              onSelectionChanged: (seleccion) {
                _actualizarContexto(_contexto.copyWith(nivel: seleccion.first));
              },
            ),
            const SizedBox(height: 18),
            _tituloGrupo(context, 'Gestion'),
            const SizedBox(height: 10),
            SegmentedButton<DependenciaInstitucional>(
              showSelectedIcon: false,
              segments: DependenciaInstitucional.values
                  .map(
                    (dependencia) => ButtonSegment(
                      value: dependencia,
                      label: Text(dependencia.etiqueta),
                    ),
                  )
                  .toList(),
              selected: {_dependencia},
              onSelectionChanged: (seleccion) {
                _actualizarContexto(
                  _contexto.copyWith(dependencia: seleccion.first),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueCobertura(BuildContext context) {
    final cards = [
      (
        titulo: 'Cobertura objetivo',
        descripcion:
            'Maestros, profesores, directivos, rectores, secretarios, preceptores, tecnicos, bibliotecarios y otros actores institucionales.',
        icono: Icons.groups_outlined,
      ),
      (
        titulo: 'Tipos de institucion',
        descripcion:
            'Escuelas secundarias, institutos terciarios y organizaciones universitarias, publicas o privadas.',
        icono: Icons.domain_verification_outlined,
      ),
      (
        titulo: 'Huella operativa',
        descripcion:
            'Asistencia, agenda academica, legajos, reportes, alertas tempranas y futura capa administrativa.',
        icono: Icons.grid_view_rounded,
      ),
    ];

    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cobertura que vamos a perseguir',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _nivel.descripcion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 18),
            ...cards.map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaCobertura(
                  titulo: card.titulo,
                  descripcion: card.descripcion,
                  icono: card.icono,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloquePrioridades(
    BuildContext context,
    List<PrioridadOperativa> prioridades,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prioridades operativas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Este bloque marca lo que la app deberia resolver primero para este perfil y contexto institucional.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 18),
            ...prioridades.map(
              (prioridad) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FilaPrioridad(prioridad: prioridad),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloquePermisos(
    BuildContext context,
    Set<PermisoModulo> permisos,
  ) {
    final permisosOrdenados = PermisoModulo.values
        .where(permisos.contains)
        .toList();

    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos del perfil activo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta matriz empieza a gobernar la experiencia: lo que ves aca es lo que este actor deberia poder operar dentro del sistema.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: permisosOrdenados
                  .map((permiso) => _ChipPermiso(permiso: permiso))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloqueModulos(
    BuildContext context,
    List<ModuloRecomendado> modulos,
  ) {
    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapa de modulos sugeridos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'La idea es ir creciendo por capas, sin perder la perspectiva institucional completa.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.42,
              ),
            ),
            const SizedBox(height: 18),
            ...modulos.map(
              (modulo) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaModulo(modulo: modulo),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloGrupo(BuildContext context, String texto) {
    return Text(
      texto,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  void _actualizarContexto(ContextoInstitucional contexto) {
    Proveedores.actualizarContextoInstitucional(contexto);
  }
}

class _SelloContexto extends StatelessWidget {
  final IconData icono;
  final String etiqueta;

  const _SelloContexto({required this.icono, required this.etiqueta});

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
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _IndicadorHero extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _IndicadorHero({
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.74),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.85)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCobertura extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;

  const _TarjetaCobertura({
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.85)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: cs.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          ),
        ],
      ),
    );
  }
}

class _FilaPrioridad extends StatelessWidget {
  final PrioridadOperativa prioridad;

  const _FilaPrioridad({required this.prioridad});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(prioridad.icono, size: 18, color: cs.primary),
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
                        prioridad.titulo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: EstilosAplicacion.radioChip,
                      ),
                      child: Text(
                        prioridad.impacto,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  prioridad.descripcion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaModulo extends StatelessWidget {
  final ModuloRecomendado modulo;

  const _TarjetaModulo({required this.modulo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorEstado = switch (modulo.estado) {
      'Activo' => const Color(0xFF047857),
      'En construccion' => cs.primary,
      'Proximo' => const Color(0xFFB45309),
      _ => cs.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerLowest,
            cs.surfaceContainer.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(modulo.icono, size: 20, color: cs.primary),
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
                        modulo.titulo,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      modulo.estado,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorEstado,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  modulo.descripcion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPermiso extends StatelessWidget {
  final PermisoModulo permiso;

  const _ChipPermiso({required this.permiso});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: EstilosAplicacion.radioChip,
        border: Border.all(color: cs.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(permiso.icono, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            permiso.etiqueta,
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
