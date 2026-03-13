import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/aplicacion/utiles/layout_app.dart';
import '/aplicacion/widgets/estado_lista.dart';
import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/agenda/datos/agenda_docente_repositorio.dart';
import '/modulos/agenda/modelos/agenda_docente_item.dart';
import '/modulos/agenda/modelos/alerta_automatica_docente.dart';
import '/modulos/cursos/modelos/curso.dart';

import '../modelos/clase_asistencia.dart';
import '../modelos/estado_asistencia.dart';
import '../modelos/registro_asistencia_alumno.dart';

part 'asistencia_pantalla_carga.dart';
part 'asistencia_pantalla_detalles.dart';
part 'asistencia_pantalla_clases_acciones.dart';
part 'asistencia_pantalla_widgets_detalle.dart';
part 'asistencia_pantalla_lista_layout.dart';
part 'asistencia_pantalla_agenda.dart';

class AsistenciaPantalla extends StatefulWidget {
  const AsistenciaPantalla({super.key});

  @override
  State<AsistenciaPantalla> createState() => _AsistenciaPantallaState();
}

class _AsistenciaPantallaState extends State<AsistenciaPantalla> {
  static const String _prefCursoKey = 'asistencias_ultimo_curso_v1';
  late final VoidCallback _datosVersionListener;

  bool _cargandoInicial = true;
  bool _sincronizando = false;
  String? _error;

  List<Curso> _cursos = const [];
  int? _cursoId;
  DateTime _fechaAgenda = DateTime.now();
  bool _cargandoAgenda = false;
  List<AgendaDocenteItem> _agendaDia = const [];
  List<AlertaAutomaticaDocente> _alertasAgenda = const [];
  final Set<String> _alertasAgendaPosponiendo = <String>{};

  bool _cargandoClases = false;
  List<ClaseAsistencia> _clases = const [];
  int? _claseId;

  bool _cargandoPlanilla = false;
  List<RegistroAsistenciaAlumno> _planilla = const [];

  bool _guardando = false;
  String _filtroClase = '';
  String _filtroAlumno = '';
  int _selectorMasivoVersion = 0;
  int? _claseDetalleId;
  int? _alumnoDetalleId;
  int? _claseFormularioId;
  final TextEditingController _temaClaseCtrl = TextEditingController();
  final TextEditingController _descripcionClaseCtrl = TextEditingController();
  final TextEditingController _actividadClaseCtrl = TextEditingController();
  String _estadoContenidoClase = 'parcial';
  String _resultadoActividadClase = 'regular';
  bool _guardandoDetalleClase = false;
  bool _editandoDetalleClase = false;
  int? _alumnoFormularioId;
  bool _justificadaFormulario = false;
  bool _actividadEntregadaFormulario = false;
  final TextEditingController _detalleJustificacionCtrl =
      TextEditingController();
  final TextEditingController _notaActividadCtrl = TextEditingController();
  final TextEditingController _detalleActividadCtrl = TextEditingController();
  bool _guardandoDetalleAlumno = false;
  bool _editandoDetalleAlumno = false;

  @override
  void initState() {
    super.initState();
    _datosVersionListener = _onDatosVersionChanged;
    Proveedores.datosVersion.addListener(_datosVersionListener);
    _cargarInicial();
  }

  @override
  void dispose() {
    _temaClaseCtrl.dispose();
    _descripcionClaseCtrl.dispose();
    _actividadClaseCtrl.dispose();
    _detalleJustificacionCtrl.dispose();
    _notaActividadCtrl.dispose();
    _detalleActividadCtrl.dispose();
    Proveedores.datosVersion.removeListener(_datosVersionListener);
    super.dispose();
  }

  void _onDatosVersionChanged() {
    if (!mounted) return;
    _cargarInicial(silencioso: true);
  }

  void _actualizarEstado(VoidCallback callback) => setState(callback);

  @override
  Widget build(BuildContext context) => _buildPantalla(context);
}
