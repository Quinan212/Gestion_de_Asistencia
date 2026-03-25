import 'package:flutter/material.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/utiles/validaciones.dart';
import '/aplicacion/widgets/campo_combo.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/aplicacion/widgets/panel_controles_modulo.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/cursos/modelos/curso.dart';
import '/modulos/instituciones/modelos/carrera.dart';
import '/modulos/instituciones/modelos/institucion.dart';
import '../modelos/alumno.dart';

class AlumnosPantalla extends StatefulWidget {
  const AlumnosPantalla({super.key});

  @override
  State<AlumnosPantalla> createState() => _AlumnosPantallaState();
}

class _AlumnosPantallaState extends State<AlumnosPantalla> {
  late final VoidCallback _datosVersionListener;
  late Future<List<Alumno>> _future;
  String _filtro = '';
  List<Alumno> _cache = const [];
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _future = _lanzarCarga();
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

  Future<List<Alumno>> _cargar() {
    return Proveedores.alumnosRepositorio.listar();
  }

  Future<List<Alumno>> _lanzarCarga() {
    final future = _cargar();
    future.then(
      (data) {
        if (!mounted) return;
        setState(() {
          _cache = data;
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

  void _recargar({bool silencioso = false}) {
    setState(() {
      if (silencioso && _cache.isNotEmpty) {
        _sincronizando = true;
      }
      _future = _lanzarCarga();
    });
  }

  Future<void> _nuevoAlumno() async {
    final apellidoCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final edadCtrl = TextEditingController();

    final instituciones = await Proveedores.institucionesRepositorio.listar();
    if (!mounted) return;

    if (instituciones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Primero crea instituciones, carreras y materias en la pestaña Instituciones',
          ),
        ),
      );
      return;
    }

    final carrerasPorInstitucion = await Proveedores.institucionesRepositorio
        .listarCarrerasAgrupadas();
    final cursos = await Proveedores.cursosRepositorio.listar();
    if (!mounted) return;

    int? institucionId = instituciones.first.id;
    final carrerasIniciales =
        carrerasPorInstitucion[institucionId] ?? const <Carrera>[];
    int? carreraId = carrerasIniciales.isEmpty
        ? null
        : carrerasIniciales.first.id;
    int? cursoSeleccionadoId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final carreras =
                carrerasPorInstitucion[institucionId] ?? const <Carrera>[];
            final cursosFiltrados = cursos
                .where(
                  (c) =>
                      c.institucionId == institucionId &&
                      c.carreraId == carreraId,
                )
                .toList(growable: false);

            return AlertDialog(
              title: const Text('Nuevo alumno'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: apellidoCtrl,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: edadCtrl,
                      decoration: const InputDecoration(labelText: 'Edad'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    CampoCombo<int>(
                      value: institucionId,
                      labelText: 'Institución',
                      opciones: instituciones
                          .map(
                            (Institucion i) => CampoComboOpcion<int>(
                              value: i.id,
                              etiqueta: i.nombre,
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        final carrerasNuevas =
                            carrerasPorInstitucion[v] ?? const <Carrera>[];
                        setStateDialog(() {
                          institucionId = v;
                          carreraId = carrerasNuevas.isEmpty
                              ? null
                              : carrerasNuevas.first.id;
                          cursoSeleccionadoId = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: carreraId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Carrera'),
                      items: carreras
                          .map(
                            (Carrera c) => DropdownMenuItem<int>(
                              value: c.id,
                              child: Text(
                                c.nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) {
                        if (v == null) return;
                        setStateDialog(() {
                          carreraId = v;
                          cursoSeleccionadoId = null;
                        });
                      },
                    ),
                    if (carreras.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'La institución no tiene carreras. Crea una en Instituciones.',
                        ),
                      ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int?>(
                      initialValue: cursoSeleccionadoId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Inscribir en curso (opcional)',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Sin inscribir por ahora'),
                        ),
                        ...cursosFiltrados.map(
                          (Curso c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(
                              c.etiqueta,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        setStateDialog(() {
                          cursoSeleccionadoId = v;
                        });
                      },
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

    if (ok != true || !mounted) return;

    final errApellido = AppValidaciones.validarRequerido(
      apellidoCtrl.text,
      campo: 'Apellido',
    );
    if (errApellido != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errApellido)));
      return;
    }

    final errNombre = AppValidaciones.validarRequerido(
      nombreCtrl.text,
      campo: 'Nombre',
    );
    if (errNombre != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errNombre)));
      return;
    }

    final errEdad = AppValidaciones.validarNumeroMayorQueCero(
      edadCtrl.text,
      campo: 'Edad',
    );
    if (errEdad != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errEdad)));
      return;
    }
    final edad = int.tryParse(edadCtrl.text.trim());
    if (edad == null || edad < 1 || edad > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edad: ingresa un valor entre 1 y 120')),
      );
      return;
    }

    final errInstitucion = AppValidaciones.validarSeleccion<int>(
      institucionId,
      campo: 'Institución',
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

    final alumnoId = await Proveedores.alumnosRepositorio.crear(
      apellido: apellidoCtrl.text,
      nombre: nombreCtrl.text,
      institucionId: institucionId!,
      carreraId: carreraId!,
      edad: edad,
    );

    final cursoId = cursoSeleccionadoId;
    if (cursoId != null) {
      await Proveedores.cursosRepositorio.inscribirAlumno(
        cursoId: cursoId,
        alumnoId: alumnoId,
      );
    }

    Proveedores.notificarDatosActualizados(
      mensaje: cursoId == null
          ? 'Alumno creado'
          : 'Alumno creado e inscripto en curso',
    );
    _recargar();
  }

  Future<bool> _confirmarEliminarAlumno(String nombreCompleto) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Eliminar alumno'),
        content: Text('Se eliminará "$nombreCompleto" de forma permanente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _eliminarAlumno({
    required int alumnoId,
    required String nombreCompleto,
  }) async {
    final confirmar = await _confirmarEliminarAlumno(nombreCompleto);
    if (!confirmar || !mounted) return;

    try {
      await Proveedores.alumnosRepositorio.eliminar(alumnoId: alumnoId);
      Proveedores.notificarDatosActualizados(
        mensaje: 'Alumno eliminado: $nombreCompleto',
      );
      _recargar();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el alumno')),
      );
    }
  }

  List<Alumno> _aplicarFiltro(List<Alumno> alumnos) {
    final q = _filtro.trim().toLowerCase();
    if (q.isEmpty) return alumnos;
    return alumnos
        .where((a) {
          final texto =
              '${a.nombreCompleto} ${a.contextoAcademico} ${a.edad ?? ''}'
                  .toLowerCase();
          return texto.contains(q);
        })
        .toList(growable: false);
  }

  Widget _buildBotonesAccion() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _nuevoAlumno,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Agregar alumno'),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar alumno',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => _filtro = v),
        ),
      ],
    );
  }

  Widget _buildListaSimple() {
    return FutureBuilder<List<Alumno>>(
      future: _future,
      builder: (context, snap) {
        final alumnosDisponibles = snap.data ?? _cache;
        if (snap.connectionState != ConnectionState.done &&
            alumnosDisponibles.isEmpty) {
          return const EstadoListaCargando(mensaje: 'Cargando alumnos...');
        }
        if (snap.hasError && alumnosDisponibles.isEmpty) {
          return EstadoListaError(
            mensaje: 'No se pudieron cargar alumnos',
            alReintentar: _recargar,
          );
        }

        final alumnos = _aplicarFiltro(alumnosDisponibles);
        if (alumnos.isEmpty) {
          return EstadoListaVacia(
            titulo: _filtro.trim().isEmpty
                ? 'Todavía no hay alumnos cargados'
                : 'No hay alumnos que coincidan con el filtro',
            icono: Icons.search_off_outlined,
          );
        }

        return Column(
          children: [
            if (_sincronizando) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final columnas = c.maxWidth >= 980
                        ? 4
                        : c.maxWidth >= 700
                        ? 3
                        : c.maxWidth >= 360
                        ? 2
                        : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: 118,
                      ),
                      itemCount: alumnos.length,
                      itemBuilder: (context, index) {
                        final a = alumnos[index];
                        return _tarjetaAlumno(a, index + 1);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _tarjetaAlumno(Alumno alumno, int indice) {
    final cs = Theme.of(context).colorScheme;
    final contexto = alumno.contextoAcademico.trim();
    final detalles = <String>[
      if (alumno.edad != null) '${alumno.edad} años',
      if ((alumno.documento ?? '').trim().isNotEmpty)
        (alumno.documento ?? '').trim(),
    ];
    final secundaria = detalles.isEmpty
        ? 'Sin datos complementarios'
        : detalles.join(' · ');

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cs.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: cs.secondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '#$indice',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _eliminarAlumno(
                        alumnoId: alumno.id,
                        nombreCompleto: alumno.nombreCompleto,
                      ),
                      tooltip: 'Eliminar alumno',
                      icon: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: cs.onSurfaceVariant,
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
              const SizedBox(height: 2),
              Text(
                secundaria,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                contexto.isEmpty ? 'Sin contexto academico' : contexto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelDetalleVacio() {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Zona de detalle de alumnos.\nPor ahora no hay contenido.',
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LayoutApp.kPagePadding,
      child: LayoutBuilder(
        builder: (context, c) {
          final controles = PanelControlesModulo(child: _buildBotonesAccion());
          final contenidoPrincipal = _buildListaSimple();
          final esDesktop = LayoutApp.esDesktop(c.maxWidth);
          final mostrarDetalleDerecha = LayoutApp.esTablet(c.maxWidth);

          if (!mostrarDetalleDerecha) {
            return Column(
              children: [
                Flexible(fit: FlexFit.loose, child: controles),
                const SizedBox(height: 12),
                Expanded(child: contenidoPrincipal),
              ],
            );
          }

          if (!esDesktop) {
            final anchoDetalle = 390.0;
            return Column(
              children: [
                Flexible(fit: FlexFit.loose, child: controles),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: contenidoPrincipal),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: anchoDetalle,
                        child: _panelDetalleVacio(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final anchoControles = c.maxWidth >= 1550 ? 360.0 : 320.0;
          final anchoDetalle = c.maxWidth >= 1550 ? 500.0 : 440.0;
          return Row(
            children: [
              SizedBox(
                width: anchoControles,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(child: controles),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: contenidoPrincipal),
              const SizedBox(width: 14),
              SizedBox(width: anchoDetalle, child: _panelDetalleVacio()),
            ],
          );
        },
      ),
    );
  }
}
