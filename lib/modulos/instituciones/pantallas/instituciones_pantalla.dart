import 'package:flutter/material.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/utiles/validaciones.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/aplicacion/widgets/panel_controles_modulo.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '../modelos/institucion.dart';
import '../modelos/carrera.dart';
import '../modelos/materia_institucion.dart';

class InstitucionesPantalla extends StatefulWidget {
  const InstitucionesPantalla({super.key});

  @override
  State<InstitucionesPantalla> createState() => _InstitucionesPantallaState();
}

class _InstitucionesPantallaState extends State<InstitucionesPantalla> {
  late final VoidCallback _datosVersionListener;

  bool _cargando = true;
  bool _sincronizando = false;
  String? _error;

  List<Institucion> _instituciones = const [];
  int? _institucionId;

  List<Carrera> _carreras = const [];
  int? _carreraId;

  bool _cargandoMaterias = false;
  List<MateriaInstitucion> _materias = const [];

  @override
  void initState() {
    super.initState();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _cargar();
  }

  @override
  void dispose() {
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    super.dispose();
  }

  void _onDatosVersionChanged() {
    if (!mounted) return;
    _cargar(silencioso: true);
  }

  Future<void> _cargar({bool silencioso = false}) async {
    final conservarVista =
        silencioso &&
        (_instituciones.isNotEmpty ||
            _carreras.isNotEmpty ||
            _materias.isNotEmpty);
    setState(() {
      _cargando = !conservarVista;
      _sincronizando = conservarVista;
      if (!conservarVista) {
        _error = null;
      }
    });

    try {
      final instituciones = await Proveedores.institucionesRepositorio.listar();
      int? institucionId = _institucionId;
      if (institucionId == null ||
          !instituciones.any((i) => i.id == institucionId)) {
        institucionId = instituciones.isEmpty ? null : instituciones.first.id;
      }

      List<Carrera> carreras = const [];
      int? carreraId;
      if (institucionId != null) {
        carreras = await Proveedores.institucionesRepositorio
            .listarCarrerasDeInstitucion(institucionId);
        carreraId = _carreraId;
        if (carreraId == null || !carreras.any((c) => c.id == carreraId)) {
          carreraId = carreras.isEmpty ? null : carreras.first.id;
        }
      }

      if (!mounted) return;
      setState(() {
        _instituciones = instituciones;
        _institucionId = institucionId;
        _carreras = carreras;
        _carreraId = carreraId;
        _cargando = false;
        _sincronizando = false;
      });

      await _cargarMaterias();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!conservarVista) {
          _error = 'No se pudieron cargar instituciones';
        }
        _cargando = false;
        _sincronizando = false;
      });
    }
  }

  Future<void> _cargarCarreras() async {
    final institucionId = _institucionId;
    if (institucionId == null) {
      setState(() {
        _carreras = const [];
        _carreraId = null;
      });
      await _cargarMaterias();
      return;
    }

    final carreras = await Proveedores.institucionesRepositorio
        .listarCarrerasDeInstitucion(institucionId);
    int? carreraId = _carreraId;
    if (carreraId == null || !carreras.any((c) => c.id == carreraId)) {
      carreraId = carreras.isEmpty ? null : carreras.first.id;
    }

    if (!mounted) return;
    setState(() {
      _carreras = carreras;
      _carreraId = carreraId;
    });
    await _cargarMaterias();
  }

  Future<void> _cargarMaterias() async {
    final carreraId = _carreraId;
    if (carreraId == null) {
      setState(() => _materias = const []);
      return;
    }

    setState(() => _cargandoMaterias = true);
    try {
      final materias = await Proveedores.institucionesRepositorio
          .listarMateriasDeCarrera(carreraId);
      if (!mounted) return;
      setState(() {
        _materias = materias;
        _cargandoMaterias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargandoMaterias = false;
        _error = 'No se pudieron cargar materias';
      });
    }
  }

  Future<void> _agregarInstitucion() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva instituci\u00f3n'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nombre'),
          textInputAction: TextInputAction.done,
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
      ),
    );

    if (ok != true || !mounted) return;
    final err = AppValidaciones.validarRequerido(
      ctrl.text,
      campo: 'Instituci\u00f3n',
    );
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    try {
      await Proveedores.institucionesRepositorio.crearInstitucion(ctrl.text);
      Proveedores.notificarDatosActualizados();
      await _cargar();
    } catch (e, st) {
      debugPrint('Error al guardar institucion: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la instituci\u00f3n')),
      );
    }
  }

  Future<_ConfirmacionBorradoJerarquico?> _confirmarBorrado({
    required String titulo,
    required String detalle,
    bool mostrarOpcionAlumnos = true,
  }) {
    var eliminarAlumnos = false;
    return showDialog<_ConfirmacionBorradoJerarquico>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detalle),
              if (mostrarOpcionAlumnos) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: eliminarAlumnos,
                  title: const Text('Eliminar alumnos asociados'),
                  subtitle: const Text(
                    'Si se desactiva, se conservan y quedan sin asignacion.',
                  ),
                  onChanged: (v) => setStateDialog(() => eliminarAlumnos = v),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                _ConfirmacionBorradoJerarquico(
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

  Future<void> _eliminarInstitucionSeleccionada() async {
    final institucionId = _institucionId;
    if (institucionId == null) return;
    final institucion = _instituciones.where((i) => i.id == institucionId);
    final nombre = institucion.isEmpty
        ? 'seleccionada'
        : institucion.first.nombre;

    final confirmacion = await _confirmarBorrado(
      titulo: 'Eliminar institucion',
      detalle:
          'Se eliminara la institucion "$nombre" con sus carreras, materias, cursos, clases y asistencias.',
    );

    if (confirmacion == null || !mounted) return;

    try {
      final msg = await Proveedores.borradoJerarquicoServicio
          .eliminarInstitucion(
            institucionId: institucionId,
            eliminarAlumnosAsociados: confirmacion.eliminarAlumnosAsociados,
          );
      if (!mounted) return;
      Proveedores.notificarDatosActualizados(mensaje: msg);
      await _cargar();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la institucion')),
      );
    }
  }

  Future<void> _eliminarMateria(MateriaInstitucion materia) async {
    final confirmacion = await _confirmarBorrado(
      titulo: 'Eliminar materia',
      detalle:
          'Se eliminara la materia "${materia.nombre}" con sus cursos, clases y asistencias.',
    );
    if (confirmacion == null || !mounted) return;

    try {
      final msg = await Proveedores.borradoJerarquicoServicio.eliminarMateria(
        materiaId: materia.id,
        eliminarAlumnosAsociados: confirmacion.eliminarAlumnosAsociados,
      );
      if (!mounted) return;
      Proveedores.notificarDatosActualizados(mensaje: msg);
      await _cargarMaterias();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la materia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const EstadoListaCargando(mensaje: 'Cargando cat\u00e1logos...');
    }
    if (_error != null) {
      return EstadoListaError(mensaje: _error!, alReintentar: _cargar);
    }

    final idsInstituciones = _instituciones.map((i) => i.id).toSet();
    final institucionSeleccionada = idsInstituciones.contains(_institucionId)
        ? _institucionId
        : null;
    final idsCarreras = _carreras.map((c) => c.id).toSet();
    final carreraSeleccionada = idsCarreras.contains(_carreraId)
        ? _carreraId
        : null;

    final materiasVisibles = _materias;

    Widget contenidoMaterias;
    if (_instituciones.isEmpty) {
      contenidoMaterias = const EstadoListaVacia(
        titulo: 'Todav\u00eda no hay instituciones cargadas',
        icono: Icons.account_balance_outlined,
      );
    } else if (_carreras.isEmpty) {
      contenidoMaterias = const EstadoListaVacia(
        titulo:
            'La instituci\u00f3n seleccionada no tiene carreras.\nCreala desde la pantalla Carreras.',
        icono: Icons.school_outlined,
      );
    } else if (_cargandoMaterias) {
      contenidoMaterias = const EstadoListaCargando(
        mensaje: 'Cargando materias...',
      );
    } else if (_materias.isEmpty) {
      contenidoMaterias = const EstadoListaVacia(
        titulo: 'La carrera no tiene materias.\nAgrega materias con a\u00f1o.',
        icono: Icons.menu_book_outlined,
      );
    } else if (materiasVisibles.isEmpty) {
      contenidoMaterias = const EstadoListaVacia(
        titulo: 'No hay materias que coincidan con el filtro',
        icono: Icons.search_off_outlined,
      );
    } else {
      contenidoMaterias = Card(
        child: ListView.separated(
          itemCount: materiasVisibles.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final m = materiasVisibles[index];
            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              minVerticalPadding: 2,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(m.nombre),
              subtitle: Text('${m.anioCursada}\u00b0'),
              trailing: IconButton(
                onPressed: () => _eliminarMateria(m),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar materia',
              ),
            );
          },
        ),
      );
    }

    return Padding(
      padding: LayoutApp.kPagePadding,
      child: Column(
        children: [
          if (_sincronizando) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final esDesktop = LayoutApp.esDesktop(c.maxWidth);
                final panelControles = PanelControlesModulo(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _agregarInstitucion,
                          icon: const Icon(Icons.account_balance_outlined),
                          label: const Text('Agregar institucion'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: institucionSeleccionada,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Institucion',
                        ),
                        items: _instituciones
                            .map(
                              (i) => DropdownMenuItem<int>(
                                value: i.id,
                                child: Text(
                                  i.nombre,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (v) async {
                          if (v == null || v == _institucionId) return;
                          setState(() => _institucionId = v);
                          await _cargarCarreras();
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        initialValue: carreraSeleccionada,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Carrera'),
                        items: _carreras
                            .map(
                              (carrera) => DropdownMenuItem<int>(
                                value: carrera.id,
                                child: Text(
                                  carrera.nombre,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (v) async {
                          if (v == null || v == _carreraId) return;
                          setState(() => _carreraId = v);
                          await _cargarMaterias();
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _institucionId == null
                              ? null
                              : _eliminarInstitucionSeleccionada,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Eliminar institucion'),
                        ),
                      ),
                    ],
                  ),
                );

                if (!esDesktop) {
                  return Column(
                    children: [
                      panelControles,
                      const SizedBox(height: 10),
                      Expanded(child: contenidoMaterias),
                    ],
                  );
                }

                return Row(
                  children: [
                    SizedBox(
                      width: c.maxWidth >= 1500 ? 420 : 360,
                      child: panelControles,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: contenidoMaterias),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmacionBorradoJerarquico {
  final bool eliminarAlumnosAsociados;

  const _ConfirmacionBorradoJerarquico({
    required this.eliminarAlumnosAsociados,
  });
}
