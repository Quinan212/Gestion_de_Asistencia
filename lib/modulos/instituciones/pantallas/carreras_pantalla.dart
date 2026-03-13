import 'package:flutter/material.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/utiles/validaciones.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/aplicacion/widgets/panel_controles_modulo.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '../modelos/carrera.dart';
import '../modelos/institucion.dart';
import '../modelos/materia_institucion.dart';

part 'carreras_pantalla_auxiliares.dart';

enum _VistaExplorador { carpetas, lista }

class CarrerasPantalla extends StatefulWidget {
  const CarrerasPantalla({super.key});

  @override
  State<CarrerasPantalla> createState() => _CarrerasPantallaState();
}

class _CarrerasPantallaState extends State<CarrerasPantalla> {
  static const List<int> _opcionesAnio = [1, 2, 3, 4, 5, 6];

  late final VoidCallback _datosVersionListener;

  bool _cargando = true;
  bool _sincronizando = false;
  String? _error;

  List<Institucion> _instituciones = const [];
  int? _institucionId;

  List<Carrera> _carreras = const [];
  int? _carreraId;
  String _filtroCarrera = '';

  bool _cargandoMaterias = false;
  List<MateriaInstitucion> _materias = const [];

  _VistaExplorador _vistaExplorador = _VistaExplorador.carpetas;

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
      int? carreraId = _carreraId;
      if (institucionId != null) {
        carreras = await Proveedores.institucionesRepositorio
            .listarCarrerasDeInstitucion(institucionId);
        if (carreraId != null && !carreras.any((c) => c.id == carreraId)) {
          carreraId = null;
        }
      } else {
        carreraId = null;
      }

      List<MateriaInstitucion> materias = const [];
      if (carreraId != null) {
        materias = await Proveedores.institucionesRepositorio
            .listarMateriasDeCarrera(carreraId);
      }

      if (!mounted) return;
      setState(() {
        _instituciones = instituciones;
        _institucionId = institucionId;
        _carreras = carreras;
        _carreraId = carreraId;
        _materias = materias;
        _cargandoMaterias = false;
        _cargando = false;
        _sincronizando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (!conservarVista) {
          _error = 'No se pudieron cargar carreras y materias';
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
        _materias = const [];
        _cargandoMaterias = false;
      });
      return;
    }

    final carreras = await Proveedores.institucionesRepositorio
        .listarCarrerasDeInstitucion(institucionId);
    int? carreraId = _carreraId;
    if (carreraId != null && !carreras.any((c) => c.id == carreraId)) {
      carreraId = null;
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
      setState(() {
        _materias = const [];
        _cargandoMaterias = false;
      });
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

  Future<void> _abrirCarrera(Carrera carrera) async {
    if (_carreraId == carrera.id) return;
    setState(() => _carreraId = carrera.id);
    await _cargarMaterias();
  }

  void _cerrarCarpetaCarrera() {
    setState(() {
      _carreraId = null;
      _materias = const [];
      _cargandoMaterias = false;
    });
  }

  Future<void> _agregarCarrera() async {
    final institucionId = _institucionId;
    if (institucionId == null) return;

    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva carrera'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nombre de carrera'),
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
    final err = AppValidaciones.validarRequerido(ctrl.text, campo: 'Carrera');
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    try {
      await Proveedores.institucionesRepositorio.crearCarrera(
        institucionId: institucionId,
        nombre: ctrl.text,
      );
      Proveedores.notificarDatosActualizados(mensaje: 'Carrera creada');
      await _cargarCarreras();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la carrera')),
      );
    }
  }

  Future<void> _agregarMateria() async {
    final carreraId = _carreraId;
    if (carreraId == null) return;

    final nombreCtrl = TextEditingController();
    int? anio = _opcionesAnio.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nueva materia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: anio,
                  decoration: const InputDecoration(labelText: 'Anio'),
                  items: _opcionesAnio
                      .map(
                        (a) =>
                            DropdownMenuItem<int>(value: a, child: Text('$a')),
                      )
                      .toList(growable: false),
                  onChanged: (v) => setStateDialog(() => anio = v),
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
        ),
      ),
    );

    if (ok != true || !mounted) return;
    final errNombre = AppValidaciones.validarRequerido(
      nombreCtrl.text,
      campo: 'Materia',
    );
    if (errNombre != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errNombre)));
      return;
    }

    final errAnio = AppValidaciones.validarSeleccion<int>(anio, campo: 'Anio');
    if (errAnio != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errAnio)));
      return;
    }

    try {
      await Proveedores.institucionesRepositorio.crearMateria(
        carreraId: carreraId,
        nombre: nombreCtrl.text,
        anioCursada: anio!,
      );
      Proveedores.notificarDatosActualizados(mensaje: 'Materia creada');
      await _cargarMaterias();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la materia')),
      );
    }
  }

  Future<_ConfirmacionBorrado?> _confirmarBorrado({
    required String titulo,
    required String detalle,
    bool mostrarOpcionAlumnos = true,
  }) {
    var eliminarAlumnos = false;
    return showDialog<_ConfirmacionBorrado>(
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
                _ConfirmacionBorrado(eliminarAlumnosAsociados: eliminarAlumnos),
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarCarreraSeleccionada() async {
    final carreraId = _carreraId;
    if (carreraId == null) return;
    final carrera = _carreras.where((c) => c.id == carreraId);
    final nombre = carrera.isEmpty ? 'seleccionada' : carrera.first.nombre;

    final confirmacion = await _confirmarBorrado(
      titulo: 'Eliminar carrera',
      detalle:
          'Se eliminara la carrera "$nombre" con sus materias, cursos, clases y asistencias.',
    );

    if (confirmacion == null || !mounted) return;

    try {
      final msg = await Proveedores.borradoJerarquicoServicio.eliminarCarrera(
        carreraId: carreraId,
        eliminarAlumnosAsociados: confirmacion.eliminarAlumnosAsociados,
      );
      if (!mounted) return;
      Proveedores.notificarDatosActualizados(mensaje: msg);
      _cerrarCarpetaCarrera();
      await _cargarCarreras();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la carrera')),
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

  Widget _buildPanelControles() {
    final idsInstituciones = _instituciones.map((i) => i.id).toSet();
    final institucionSeleccionada = idsInstituciones.contains(_institucionId)
        ? _institucionId
        : null;

    return PanelControlesModulo(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_outlined, size: 18),
              SizedBox(width: 8),
              Text('Institucion'),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: institucionSeleccionada,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Institucion base'),
            items: _instituciones
                .map(
                  (i) => DropdownMenuItem<int>(
                    value: i.id,
                    child: Text(i.nombre, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(growable: false),
            onChanged: (v) async {
              if (v == null || v == _institucionId) return;
              setState(() => _institucionId = v);
              _cerrarCarpetaCarrera();
              await _cargarCarreras();
            },
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar carrera',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _filtroCarrera = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _institucionId == null ? null : _agregarCarrera,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('Crear carrera'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _carreraId == null ? null : _agregarMateria,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Nueva materia'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _carreraId == null
                  ? null
                  : _eliminarCarreraSeleccionada,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar carrera abierta'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorador() {
    if (_instituciones.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'Crea una institucion para empezar',
        icono: Icons.account_balance_outlined,
      );
    }

    final carrerasVisibles = _carreras
        .where(
          (c) => c.nombre.toLowerCase().contains(
            _filtroCarrera.trim().toLowerCase(),
          ),
        )
        .toList(growable: false);
    final carreraAbierta = _carreras
        .where((c) => c.id == _carreraId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerExplorador(carreraAbierta),
        const SizedBox(height: 10),
        Expanded(
          child: carreraAbierta == null
              ? _contenidoRaizCarreras(carrerasVisibles)
              : _contenidoCarpetaMaterias(),
        ),
      ],
    );
  }

  Widget _headerExplorador(Carrera? carreraAbierta) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final enRaiz = carreraAbierta == null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.75)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.school_outlined, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          InkWell(
            onTap: enRaiz ? null : _cerrarCarpetaCarrera,
            child: Text(
              'Carreras',
              style: t.titleSmall?.copyWith(
                color: enRaiz ? cs.onSurface : cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!enRaiz) ...[
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                carreraAbierta.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.titleSmall,
              ),
            ),
          ] else
            const Spacer(),
          if (!enRaiz)
            IconButton(
              onPressed: _cerrarCarpetaCarrera,
              tooltip: 'Cerrar carpeta',
              icon: const Icon(Icons.close_rounded),
            ),
          const SizedBox(width: 4),
          ToggleButtons(
            isSelected: [
              _vistaExplorador == _VistaExplorador.carpetas,
              _vistaExplorador == _VistaExplorador.lista,
            ],
            onPressed: (index) {
              setState(() {
                _vistaExplorador = index == 0
                    ? _VistaExplorador.carpetas
                    : _VistaExplorador.lista;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.grid_view_rounded, size: 18),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.view_list_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contenidoRaizCarreras(List<Carrera> carrerasVisibles) {
    if (_carreras.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay carreras cargadas en esta institucion',
        icono: Icons.folder_open_outlined,
      );
    }
    if (carrerasVisibles.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'No hay carreras para ese filtro',
        icono: Icons.search_off_outlined,
      );
    }

    if (_vistaExplorador == _VistaExplorador.lista) {
      return Card(
        margin: EdgeInsets.zero,
        child: ListView.separated(
          itemCount: carrerasVisibles.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final carrera = carrerasVisibles[index];
            return ListTile(
              leading: const Icon(Icons.school_outlined, size: 30),
              title: Text(
                carrera.nombre,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _abrirCarrera(carrera),
            );
          },
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, c) {
          final ancho = c.maxWidth;
          final columnas = (ancho / 220).floor().clamp(1, 6);
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemCount: carrerasVisibles.length,
            itemBuilder: (context, index) {
              final carrera = carrerasVisibles[index];
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _abrirCarrera(carrera),
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.school_outlined, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        carrera.nombre,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        'Abrir',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _contenidoCarpetaMaterias() {
    final cs = Theme.of(context).colorScheme;
    if (_cargandoMaterias) {
      return const EstadoListaCargando(mensaje: 'Cargando materias...');
    }
    if (_materias.isEmpty) {
      return const EstadoListaVacia(
        titulo: 'Sin materias cargadas.\nCrea materias para esta carrera.',
        icono: Icons.insert_drive_file_outlined,
      );
    }

    if (_vistaExplorador == _VistaExplorador.lista) {
      return Card(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        margin: EdgeInsets.zero,
        child: ListView.separated(
          itemCount: _materias.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: cs.outlineVariant),
          itemBuilder: (context, index) {
            final materia = _materias[index];
            return _filaListaMateria(materia);
          },
        ),
      );
    }

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      margin: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, c) {
          final ancho = c.maxWidth;
          final columnas = (ancho / 220).floor().clamp(1, 6);
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.45,
            ),
            itemCount: _materias.length,
            itemBuilder: (context, index) {
              final materia = _materias[index];
              return _tarjetaArchivoMateriaCompacta(materia);
            },
          );
        },
      ),
    );
  }

  Widget _tarjetaArchivoMateriaCompacta(MateriaInstitucion materia) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? cs.surface : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: cs.primary,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _eliminarMateria(materia),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _NombreMateriaConScroll(
                texto: materia.nombre,
                maxLineas: 3,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaListaMateria(MateriaInstitucion materia) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.menu_book_rounded, size: 15, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${materia.nombre} (${materia.anioCursada}\u00b0)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () => _eliminarMateria(materia),
            tooltip: 'Eliminar archivo',
            icon: const Icon(Icons.close, size: 18),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const EstadoListaCargando(mensaje: 'Cargando carreras...');
    }
    if (_error != null) {
      return EstadoListaError(mensaje: _error!, alReintentar: _cargar);
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
                final panelControles = _buildPanelControles();
                final explorador = _buildExplorador();

                if (!esDesktop) {
                  return Column(
                    children: [
                      panelControles,
                      const SizedBox(height: 12),
                      Expanded(child: explorador),
                    ],
                  );
                }

                final anchoControles = c.maxWidth >= 1500 ? 360.0 : 320.0;
                return Row(
                  children: [
                    SizedBox(width: anchoControles, child: panelControles),
                    const SizedBox(width: 14),
                    Expanded(child: explorador),
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
