import 'package:flutter/material.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/utiles/validaciones.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/aplicacion/widgets/panel_controles_modulo.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/alumnos/modelos/alumno_organizado.dart';
import '/modulos/instituciones/modelos/carrera.dart';
import '/modulos/instituciones/modelos/institucion.dart';
import '/modulos/instituciones/modelos/materia_institucion.dart';
import '../modelos/curso.dart';

class CursosPantalla extends StatefulWidget {
  const CursosPantalla({super.key});

  @override
  State<CursosPantalla> createState() => _CursosPantallaState();
}

class _CursosPantallaState extends State<CursosPantalla> {
  static final List<int> _opcionesAnioLectivo = List<int>.generate(
    16,
    (i) => 2025 + i,
  );
  static const List<String> _opcionesDivision = ['A', 'B', 'C', 'D', 'E'];

  late final VoidCallback _datosVersionListener;
  late Future<_CursosVistaData> _future;
  String _filtro = '';
  _CursosVistaData? _vistaCache;
  bool _sincronizando = false;
  int? _cursoDetalleId;
  Curso? _cursoDetalle;
  bool _cargandoDetalleCurso = false;
  String? _errorDetalleCurso;
  List<AlumnoOrganizado> _alumnosDetalleCurso = const [];

  @override
  void initState() {
    super.initState();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _future = _lanzarCargaVista();
  }

  @override
  void dispose() {
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    super.dispose();
  }

  void _onDatosVersionChanged() {
    if (!mounted) return;
    _recargar(silencioso: true);
  }

  Future<_CursosVistaData> _lanzarCargaVista() {
    final future = _cargarVista();
    future.then(
      (data) {
        if (!mounted) return;
        setState(() {
          _vistaCache = data;
          _sincronizando = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _sincronizando = false);
      },
    );
    return future;
  }

  Future<_CursosVistaData> _cargarVista() async {
    final cursos = await Proveedores.cursosRepositorio.listar();
    final registros = await Proveedores.alumnosRepositorio
        .listarParaOrganizar();
    final porCurso = <int, List<AlumnoOrganizado>>{};
    for (final r in registros) {
      final cursoId = r.cursoId;
      if (cursoId == null) continue;
      porCurso.putIfAbsent(cursoId, () => <AlumnoOrganizado>[]).add(r);
    }
    for (final entry in porCurso.entries) {
      entry.value.sort((a, b) {
        final ap = a.apellido.toLowerCase().compareTo(b.apellido.toLowerCase());
        if (ap != 0) return ap;
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });
    }
    return _CursosVistaData(cursos: cursos, alumnosPorCurso: porCurso);
  }

  Future<void> _recargar({bool silencioso = false}) async {
    setState(() {
      if (silencioso && _vistaCache != null) {
        _sincronizando = true;
      }
      _future = _lanzarCargaVista();
    });
    final cursoId = _cursoDetalleId;
    if (cursoId != null) {
      await _cargarDetalleCurso(cursoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LayoutApp.kPagePadding,
      child: LayoutBuilder(
        builder: (context, c) {
          final esDesktop = LayoutApp.esDesktop(c.maxWidth);
          final panelControles = PanelControlesModulo(
            child: _buildControles(compacto: !esDesktop),
          );
          final listado = _buildListaCursos();
          final mostrarDetalle = esDesktop && _cursoDetalleId != null;

          if (!esDesktop) {
            return Column(
              children: [
                Flexible(fit: FlexFit.loose, child: panelControles),
                const SizedBox(height: 12),
                Expanded(child: listado),
              ],
            );
          }

          final anchoControles = c.maxWidth >= 1500 ? 360.0 : 320.0;
          return Row(
            children: [
              SizedBox(
                width: anchoControles,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(child: panelControles),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: listado),
              if (mostrarDetalle) ...[
                const SizedBox(width: 14),
                SizedBox(
                  width: c.maxWidth >= 1650 ? 480 : 420,
                  child: _buildPanelDetalleCurso(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildControles({required bool compacto}) {
    final boton = SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _nuevoCurso,
        icon: const Icon(Icons.class_outlined),
        label: const Text('Agregar curso'),
      ),
    );
    final buscador = TextField(
      decoration: const InputDecoration(
        hintText: 'Buscar curso o alumno',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (v) => setState(() => _filtro = v),
    );

    if (compacto) {
      return Column(children: [boton, const SizedBox(height: 10), buscador]);
    }

    return Column(children: [boton, const SizedBox(height: 10), buscador]);
  }

  Widget _buildListaCursos() {
    return FutureBuilder<_CursosVistaData>(
      future: _future,
      builder: (context, snap) {
        final dataDisponible = snap.data ?? _vistaCache;
        if (snap.connectionState != ConnectionState.done &&
            dataDisponible == null) {
          return const EstadoListaCargando(mensaje: 'Cargando cursos...');
        }
        if (snap.hasError && dataDisponible == null) {
          return EstadoListaError(
            mensaje: 'No se pudieron cargar cursos',
            alReintentar: _recargar,
          );
        }

        final data = dataDisponible!;
        if (_cursoDetalleId != null &&
            !data.cursos.any((c) => c.id == _cursoDetalleId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _cerrarDetalleCurso();
          });
        }
        if (data.cursos.isEmpty) {
          return const EstadoListaVacia(
            titulo: 'Todavia no hay cursos cargados',
            icono: Icons.class_outlined,
          );
        }

        final cursosFiltrados = _filtrarCursos(data);
        if (cursosFiltrados.isEmpty) {
          return const EstadoListaVacia(
            titulo: 'No hay cursos/alumnos para ese filtro',
            icono: Icons.search_off_outlined,
          );
        }

        return Column(
          children: [
            if (_sincronizando) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: ListView.separated(
                itemCount: cursosFiltrados.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final curso = cursosFiltrados[index];
                  final alumnos = data.alumnosPorCurso[curso.id] ?? const [];
                  return _TarjetaCursoResumen(
                    curso: curso,
                    alumnosCount: alumnos.length,
                    seleccionado: _cursoDetalleId == curso.id,
                    onSeleccionar: () => _seleccionarCurso(curso),
                    onInscripciones: () => _gestionarInscripciones(curso),
                    onEliminar: () => _eliminarCurso(curso),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Curso> _filtrarCursos(_CursosVistaData data) {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return data.cursos;

    return data.cursos
        .where((c) {
          final meta =
              '${c.institucion} ${c.carrera} ${c.materia} ${c.anioCursada} ${c.curso} ${c.anio}'
                  .toLowerCase();
          if (meta.contains(q)) return true;

          final alumnos = data.alumnosPorCurso[c.id] ?? const [];
          for (final a in alumnos) {
            final texto = '${a.nombreCompleto} ${a.edad ?? ''} ${a.notaManual}'
                .toLowerCase();
            if (texto.contains(q)) return true;
          }
          return false;
        })
        .toList(growable: false);
  }

  Future<void> _seleccionarCurso(Curso curso) async {
    setState(() {
      _cursoDetalleId = curso.id;
      _cursoDetalle = curso;
      _cargandoDetalleCurso = true;
      _errorDetalleCurso = null;
      _alumnosDetalleCurso = const [];
    });
    Proveedores.cursoAcademicoSeleccionado.value = curso;
    await _cargarDetalleCurso(curso.id);
  }

  Future<void> _cargarDetalleCurso(int cursoId) async {
    try {
      final rows = await Proveedores.alumnosRepositorio.listarParaOrganizar();
      final alumnos =
          rows.where((r) => r.cursoId == cursoId).toList(growable: false)
            ..sort((a, b) {
              final ap = a.apellido.toLowerCase().compareTo(
                b.apellido.toLowerCase(),
              );
              if (ap != 0) return ap;
              return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
            });

      if (!mounted || _cursoDetalleId != cursoId) return;
      setState(() {
        _alumnosDetalleCurso = alumnos;
        _errorDetalleCurso = null;
        _cargandoDetalleCurso = false;
      });
    } catch (_) {
      if (!mounted || _cursoDetalleId != cursoId) return;
      setState(() {
        _errorDetalleCurso = 'No se pudo cargar la lista de alumnos';
        _cargandoDetalleCurso = false;
      });
    }
  }

  void _cerrarDetalleCurso() {
    setState(() {
      _cursoDetalleId = null;
      _cursoDetalle = null;
      _cargandoDetalleCurso = false;
      _errorDetalleCurso = null;
      _alumnosDetalleCurso = const [];
    });
    Proveedores.cursoAcademicoSeleccionado.value = null;
  }

  Widget _buildPanelDetalleCurso() {
    final curso = _cursoDetalle;
    if (_cursoDetalleId == null || curso == null) {
      return const SizedBox.shrink();
    }

    return PanelControlesModulo(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alumnos del curso',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: _cerrarDetalleCurso,
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          Text(
            curso.etiqueta,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          Expanded(child: _contenidoPanelDetalleCurso()),
        ],
      ),
    );
  }

  Widget _contenidoPanelDetalleCurso() {
    if (_cargandoDetalleCurso) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorDetalleCurso != null) {
      return EstadoListaError(
        mensaje: _errorDetalleCurso!,
        alReintentar: () {
          final cursoId = _cursoDetalleId;
          if (cursoId != null) {
            _cargarDetalleCurso(cursoId);
          }
        },
      );
    }
    if (_alumnosDetalleCurso.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay alumnos inscriptos en este curso',
        icono: Icons.groups_2_outlined,
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: _grillaAlumnosCurso(
        alumnos: _alumnosDetalleCurso,
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _grillaAlumnosCurso({
    required List<AlumnoOrganizado> alumnos,
    Set<int> seleccionados = const <int>{},
    ValueChanged<AlumnoOrganizado>? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return LayoutBuilder(
      builder: (context, c) {
        final columnas = c.maxWidth >= 760
            ? 4
            : c.maxWidth >= 560
            ? 3
            : c.maxWidth >= 320
            ? 2
            : 1;
        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 126,
          ),
          itemCount: alumnos.length,
          itemBuilder: (context, index) {
            final alumno = alumnos[index];
            return _tarjetaAlumnoCurso(
              alumno: alumno,
              indice: index + 1,
              seleccionado: seleccionados.contains(alumno.alumnoId),
              onTap: onTap == null ? null : () => onTap(alumno),
            );
          },
        );
      },
    );
  }

  Widget _tarjetaAlumnoCurso({
    required AlumnoOrganizado alumno,
    required int indice,
    required bool seleccionado,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final detalles = <String>[
      if (alumno.edad != null) '${alumno.edad} años',
      if (alumno.notaManual.trim().isNotEmpty)
        'Nota ${alumno.notaManual.trim()}',
    ];
    final secundaria = detalles.isEmpty
        ? 'Sin datos complementarios'
        : detalles.join(' · ');
    final colorBorde = seleccionado ? cs.primary : cs.outlineVariant;
    final colorIcono = seleccionado ? cs.primary : cs.secondary;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorBorde,
              width: seleccionado ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colorIcono.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: colorIcono,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? cs.primary.withValues(alpha: 0.12)
                          : cs.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      seleccionado ? 'Inscripto' : '#$indice',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: seleccionado ? cs.primary : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                alumno.nombreCompleto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                secundaria,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
              const Spacer(),
              Text(
                '${alumno.anioLectivo} · ${alumno.etiquetaCurso}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: seleccionado ? cs.primary : cs.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _nuevoCurso() async {
    final instituciones = await Proveedores.institucionesRepositorio.listar();
    if (!mounted) return;

    if (instituciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero crea una institucion, carrera y materias en la pestana Instituciones',
          ),
        ),
      );
      return;
    }

    final carrerasPorInstitucion = await Proveedores.institucionesRepositorio
        .listarCarrerasAgrupadas();
    final materiasPorCarrera = await Proveedores.institucionesRepositorio
        .listarMateriasAgrupadas();
    if (!mounted) return;

    int? institucionId = instituciones.first.id;
    final carrerasIniciales =
        carrerasPorInstitucion[institucionId] ?? const <Carrera>[];
    int? carreraId = carrerasIniciales.isEmpty
        ? null
        : carrerasIniciales.first.id;
    final materiasIniciales =
        materiasPorCarrera[carreraId] ?? const <MateriaInstitucion>[];
    int? materiaId = materiasIniciales.isEmpty
        ? null
        : materiasIniciales.first.id;
    String? division = _opcionesDivision.first;
    int? anioLectivo = _opcionesAnioLectivo.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final carreras =
              carrerasPorInstitucion[institucionId] ?? const <Carrera>[];
          final materias =
              materiasPorCarrera[carreraId] ?? const <MateriaInstitucion>[];

          return AlertDialog(
            title: const Text('Nuevo curso'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: institucionId,
                    decoration: const InputDecoration(labelText: 'Institucion'),
                    items: instituciones
                        .map(
                          (Institucion i) => DropdownMenuItem<int>(
                            value: i.id,
                            child: Text(i.nombre),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      final cs = carrerasPorInstitucion[v] ?? const <Carrera>[];
                      final cid = cs.isEmpty ? null : cs.first.id;
                      final ms =
                          materiasPorCarrera[cid] ??
                          const <MateriaInstitucion>[];
                      setStateDialog(() {
                        institucionId = v;
                        carreraId = cid;
                        materiaId = ms.isEmpty ? null : ms.first.id;
                        division = _opcionesDivision.first;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: carreraId,
                    decoration: const InputDecoration(labelText: 'Carrera'),
                    items: carreras
                        .map(
                          (Carrera c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.nombre),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      final ms =
                          materiasPorCarrera[v] ?? const <MateriaInstitucion>[];
                      setStateDialog(() {
                        carreraId = v;
                        materiaId = ms.isEmpty ? null : ms.first.id;
                        division = _opcionesDivision.first;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: materiaId,
                    decoration: const InputDecoration(labelText: 'Materia'),
                    items: materias
                        .map(
                          (m) => DropdownMenuItem<int>(
                            value: m.id,
                            child: Text('${m.nombre} (${m.anioCursada}°)'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) {
                      if (v == null) return;
                      setStateDialog(() {
                        materiaId = v;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: division,
                    decoration: const InputDecoration(labelText: 'Division'),
                    items: _opcionesDivision
                        .map(
                          (d) => DropdownMenuItem<String>(
                            value: d,
                            child: Text(d),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) => setStateDialog(() => division = v),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    initialValue: anioLectivo,
                    decoration: const InputDecoration(
                      labelText: 'Ciclo lectivo',
                    ),
                    items: _opcionesAnioLectivo
                        .map(
                          (a) => DropdownMenuItem<int>(
                            value: a,
                            child: Text(a.toString()),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (v) => setStateDialog(() => anioLectivo = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (ok != true || !mounted) return;

    final errInstitucion = AppValidaciones.validarSeleccion<int>(
      institucionId,
      campo: 'Institucion',
    );
    if (errInstitucion != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errInstitucion)));
      return;
    }
    final errCarrera = AppValidaciones.validarSeleccion<int>(
      carreraId,
      campo: 'Carrera',
    );
    if (errCarrera != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errCarrera)));
      return;
    }
    final errMateria = AppValidaciones.validarSeleccion<int>(
      materiaId,
      campo: 'Materia',
    );
    if (errMateria != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errMateria)));
      return;
    }
    final errDivision = AppValidaciones.validarSeleccion<String>(
      division,
      campo: 'Division',
    );
    if (errDivision != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errDivision)));
      return;
    }
    final errAnioLectivo = AppValidaciones.validarSeleccion<int>(
      anioLectivo,
      campo: 'Ciclo lectivo',
    );
    if (errAnioLectivo != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errAnioLectivo)));
      return;
    }

    await Proveedores.cursosRepositorio.crear(
      institucionId: institucionId!,
      carreraId: carreraId!,
      materiaId: materiaId!,
      division: division!,
      anioLectivo: anioLectivo!,
    );
    Proveedores.notificarDatosActualizados(mensaje: 'Curso creado');
    await _recargar();
  }

  Future<void> _gestionarInscripciones(Curso curso) async {
    final institucionId = curso.institucionId;
    final carreraId = curso.carreraId;
    if (institucionId == null || carreraId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este curso no tiene institucion o carrera validas para gestionar inscripciones',
          ),
        ),
      );
      return;
    }

    final alumnos = await Proveedores.alumnosRepositorio
        .listarDisponiblesParaCurso(
          institucionId: institucionId,
          carreraId: carreraId,
        );
    if (!mounted) return;

    if (alumnos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay alumnos disponibles para inscribir en este curso',
          ),
        ),
      );
      return;
    }

    final seleccionInicial = await Proveedores.cursosRepositorio
        .listarIdsAlumnosInscritosActivos(curso.id);
    if (!mounted) return;

    final seleccionActual = Set<int>.from(seleccionInicial);
    var filtro = '';

    final guardar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final visibles = alumnos
                .where((a) {
                  final q = filtro.trim().toLowerCase();
                  if (q.isEmpty) return true;
                  return a.nombreCompleto.toLowerCase().contains(q);
                })
                .toList(growable: false);

            return AlertDialog(
              title: Text('Inscriptos en ${curso.etiqueta}'),
              content: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar alumno',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => setStateDialog(() => filtro = v),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: _grillaAlumnosCurso(
                        alumnos: visibles
                            .map(
                              (a) => AlumnoOrganizado(
                                alumnoId: a.id,
                                cursoId: curso.id,
                                apellido: a.apellido,
                                nombre: a.nombre,
                                edad: a.edad,
                                notaManual: '',
                                institucion: curso.institucion,
                                carrera: curso.carrera,
                                materia: curso.materia,
                                anioCursada: curso.anioCursada,
                                curso: curso.curso,
                                anioLectivo: curso.anio,
                                ordenIngreso: 0,
                              ),
                            )
                            .toList(growable: false),
                        seleccionados: seleccionActual,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 2, right: 2),
                        onTap: (alumno) {
                          setStateDialog(() {
                            if (seleccionActual.contains(alumno.alumnoId)) {
                              seleccionActual.remove(alumno.alumnoId);
                            } else {
                              seleccionActual.add(alumno.alumnoId);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (guardar != true || !mounted) return;

    await Proveedores.cursosRepositorio.sincronizarInscripciones(
      cursoId: curso.id,
      alumnoIdsActivos: seleccionActual,
    );
    Proveedores.notificarDatosActualizados(
      mensaje: 'Inscripciones actualizadas para ${curso.etiqueta}',
    );
    await _recargar();
  }

  Future<_ConfirmacionEliminarCurso?> _confirmarEliminarCurso(Curso curso) {
    var eliminarAlumnos = false;
    return showDialog<_ConfirmacionEliminarCurso>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Eliminar curso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Se eliminara el curso "${curso.etiqueta}" con clases y asistencias.',
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: eliminarAlumnos,
                  title: const Text('Eliminar alumnos asociados'),
                  subtitle: const Text(
                    'Si se desactiva, se conservan y solo se quita el curso.',
                  ),
                  onChanged: (v) => setStateDialog(() => eliminarAlumnos = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _ConfirmacionEliminarCurso(
                  eliminarAlumnosAsociados: eliminarAlumnos,
                ),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarCurso(Curso curso) async {
    final confirmar = await _confirmarEliminarCurso(curso);
    if (confirmar == null || !mounted) return;
    try {
      final msg = await Proveedores.borradoJerarquicoServicio.eliminarCurso(
        cursoId: curso.id,
        eliminarAlumnosAsociados: confirmar.eliminarAlumnosAsociados,
      );
      if (!mounted) return;
      if (_cursoDetalleId == curso.id) {
        _cerrarDetalleCurso();
      } else if (Proveedores.cursoAcademicoSeleccionado.value?.id == curso.id) {
        Proveedores.cursoAcademicoSeleccionado.value = null;
      }
      Proveedores.notificarDatosActualizados(mensaje: msg);
      await _recargar();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el curso')),
      );
    }
  }
}

class _CursosVistaData {
  final List<Curso> cursos;
  final Map<int, List<AlumnoOrganizado>> alumnosPorCurso;

  const _CursosVistaData({required this.cursos, required this.alumnosPorCurso});
}

class _ConfirmacionEliminarCurso {
  final bool eliminarAlumnosAsociados;

  const _ConfirmacionEliminarCurso({required this.eliminarAlumnosAsociados});
}

class _TarjetaCursoResumen extends StatelessWidget {
  final Curso curso;
  final int alumnosCount;
  final bool seleccionado;
  final VoidCallback onSeleccionar;
  final VoidCallback onInscripciones;
  final VoidCallback onEliminar;

  const _TarjetaCursoResumen({
    required this.curso,
    required this.alumnosCount,
    required this.seleccionado,
    required this.onSeleccionar,
    required this.onInscripciones,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: seleccionado ? cs.primary : cs.outlineVariant,
          width: seleccionado ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSeleccionar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      curso.institucion.toUpperCase(),
                      style: t.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSeleccionar,
                    icon: const Icon(Icons.people_outline, size: 18),
                    tooltip: 'Ver alumnos',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onInscripciones,
                    icon: const Icon(Icons.how_to_reg_outlined, size: 18),
                    tooltip: 'Inscribir',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onEliminar,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Eliminar curso',
                    visualDensity: VisualDensity.compact,
                  ),
                  Icon(
                    seleccionado
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_right_outlined,
                    color: seleccionado ? cs.primary : cs.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chipMeta(context, curso.carrera),
                  _chipMeta(context, '${curso.anioCursada}° ${curso.curso}'),
                  _chipMeta(context, curso.anio.toString()),
                  _chipMeta(context, '$alumnosCount alumnos'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                curso.materia,
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipMeta(BuildContext context, String texto) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
