import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/aplicacion/animaciones/transiciones_correlativas.dart';
import 'package:gestion_de_asistencias/aplicacion/tema/estilos_aplicacion.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/agenda/modelos/agenda_docente_item.dart';
import 'package:gestion_de_asistencias/modulos/alumnos/pantallas/alumnos_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/agenda/pantallas/agenda_docente_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/asistencias/pantallas/asistencia_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/biblioteca/pantallas/biblioteca_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/cursos/modelos/curso.dart';
import 'package:gestion_de_asistencias/modulos/cursos/pantallas/cursos_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/incidencias/pantallas/incidencias_transversales_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/instituciones/pantallas/carreras_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/instituciones/pantallas/instituciones_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/legajos/pantallas/legajos_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';
import 'package:gestion_de_asistencias/modulos/panel_institucional/pantallas/panel_institucional_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/preceptoria/pantallas/preceptoria_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/reportes_asistencia/pantallas/reportes_asistencia_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/secretaria/pantallas/secretaria_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/tablero_gestion/pantallas/tablero_gestion_pantalla.dart';

class PantallasPrincipales extends StatefulWidget {
  const PantallasPrincipales({super.key});

  @override
  State<PantallasPrincipales> createState() => _PantallasPrincipalesState();
}

class _PantallasPrincipalesState extends State<PantallasPrincipales>
    with SingleTickerProviderStateMixin {
  static const int _menuPanel = 0;
  static const int _menuAcademico = 1;
  static const int _menuLegajos = 2;
  static const int _menuSecretaria = 3;
  static const int _menuBiblioteca = 4;
  static const int _menuPreceptoria = 5;
  static const int _menuGestion = 6;
  static const int _menuIncidencias = 7;
  static const int _menuAsistencias = 8;
  static const int _menuReportes = 9;

  static const int _subNuevoInstituciones = 0;
  static const int _subNuevoCarreras = 1;
  static const int _subNuevoCursos = 2;
  static const int _subNuevoAlumnos = 3;

  int _menuPrincipal = _menuPanel;
  int _submenuNuevo = _subNuevoInstituciones;
  final LayerLink _menuAcademicoLink = LayerLink();
  final LayerLink _menuCursosAcademicoLink = LayerLink();
  final LayerLink _menuGrupoCursoAcademicoLink = LayerLink();
  bool _menuAcademicoAbierto = false;
  bool _submenuCursosAcademicoAbierto = false;
  String? _grupoCursoAcademicoAbierto;
  late final VoidCallback _syncMsgListener;
  late final VoidCallback _contextoInstitucionalListener;
  late final Timer _clockTimer;
  late final AnimationController _transicionController;
  DateTime _ahora = DateTime.now();
  int _direccionTransicion = 1;

  final List<Widget> _pantallas = const [
    PanelInstitucionalPantalla(),
    InstitucionesPantalla(),
    CarrerasPantalla(),
    CursosPantalla(),
    AlumnosPantalla(),
    LegajosPantalla(),
    SecretariaPantalla(),
    BibliotecaPantalla(),
    PreceptoriaPantalla(),
    TableroGestionPantalla(),
    IncidenciasTransversalesPantalla(),
    AsistenciaPantalla(),
    ReportesAsistenciaPantalla(),
  ];

  @override
  void initState() {
    super.initState();
    _transicionController = AnimationController(
      vsync: this,
      duration: TransicionesCorrelativas.duracionCambioPantalla,
    )..value = 1;
    _syncMsgListener = () {
      final msg = Proveedores.estadoSincronizacion.value;
      if (!mounted || msg == null || msg.trim().isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        Proveedores.limpiarEstadoSincronizacion();
      });
    };
    Proveedores.estadoSincronizacion.addListener(_syncMsgListener);
    _contextoInstitucionalListener = () {
      if (!mounted) return;
      final contexto = Proveedores.contextoInstitucional.value;
      if (_menuPrincipal != _menuPanel &&
          !_menuPrincipalHabilitado(contexto, _menuPrincipal)) {
        setState(() {
          _menuPrincipal = _menuPanel;
          _menuAcademicoAbierto = false;
          _submenuCursosAcademicoAbierto = false;
          _grupoCursoAcademicoAbierto = null;
        });
      } else {
        setState(() {});
      }
    };
    Proveedores.contextoInstitucional.addListener(_contextoInstitucionalListener);

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _transicionController.dispose();
    _clockTimer.cancel();
    Proveedores.estadoSincronizacion.removeListener(_syncMsgListener);
    Proveedores.contextoInstitucional.removeListener(
      _contextoInstitucionalListener,
    );
    super.dispose();
  }

  int _indicePantallaPara({
    required int menuPrincipal,
    required int submenuNuevo,
  }) {
    if (menuPrincipal == _menuPanel) return 0;
    if (menuPrincipal == _menuLegajos) return 5;
    if (menuPrincipal == _menuSecretaria) return 6;
    if (menuPrincipal == _menuBiblioteca) return 7;
    if (menuPrincipal == _menuPreceptoria) return 8;
    if (menuPrincipal == _menuGestion) return 9;
    if (menuPrincipal == _menuIncidencias) return 10;
    if (menuPrincipal == _menuAsistencias) return 11;
    if (menuPrincipal == _menuReportes) return 12;
    switch (submenuNuevo) {
      case _subNuevoCarreras:
        return 2;
      case _subNuevoCursos:
        return 3;
      case _subNuevoAlumnos:
        return 4;
      case _subNuevoInstituciones:
      default:
        return 1;
    }
  }

  int _indicePantallaActual() {
    return _indicePantallaPara(
      menuPrincipal: _menuPrincipal,
      submenuNuevo: _submenuNuevo,
    );
  }

  String _tituloActual() {
    if (_menuPrincipal == _menuPanel) return 'Panel institucional';
    if (_menuPrincipal == _menuLegajos) return 'Legajos';
    if (_menuPrincipal == _menuSecretaria) return 'Secretaria';
    if (_menuPrincipal == _menuBiblioteca) return 'Biblioteca';
    if (_menuPrincipal == _menuPreceptoria) return 'Preceptoria';
    if (_menuPrincipal == _menuGestion) return 'Gestion';
    if (_menuPrincipal == _menuIncidencias) return 'Incidencias';
    if (_menuPrincipal == _menuAsistencias) return 'Asistencia';
    if (_menuPrincipal == _menuReportes) return 'Reportes';
    switch (_submenuNuevo) {
      case _subNuevoCarreras:
        return 'Carreras';
      case _subNuevoCursos:
        return 'Cursos';
      case _subNuevoAlumnos:
        return 'Alumnos';
      case _subNuevoInstituciones:
      default:
        return 'Instituciones';
    }
  }

  void _animarNavegacion({
    required int menuPrincipal,
    required int submenuNuevo,
  }) {
    final indiceAnterior = _indicePantallaActual();
    final indiceSiguiente = _indicePantallaPara(
      menuPrincipal: menuPrincipal,
      submenuNuevo: submenuNuevo,
    );

    if (_menuPrincipal == menuPrincipal && _submenuNuevo == submenuNuevo) {
      return;
    }

    _direccionTransicion = indiceSiguiente >= indiceAnterior ? 1 : -1;
    setState(() {
      _menuPrincipal = menuPrincipal;
      _submenuNuevo = submenuNuevo;
      if (menuPrincipal != _menuAcademico) {
        _menuAcademicoAbierto = false;
        _submenuCursosAcademicoAbierto = false;
        _grupoCursoAcademicoAbierto = null;
      }
    });
    Proveedores.notificarDatosActualizados();
    _transicionController.forward(from: 0);
  }

  void _seleccionarMenuPrincipal(int menu) {
    if (!_menuPrincipalHabilitado(
      Proveedores.contextoInstitucional.value,
      menu,
    )) {
      _mostrarModuloNoDisponible();
      return;
    }
    if (menu == _menuPrincipal) return;
    _animarNavegacion(menuPrincipal: menu, submenuNuevo: _submenuNuevo);
  }

  void _toggleMenuAcademico() {
    if (!_menuPrincipalHabilitado(
      Proveedores.contextoInstitucional.value,
      _menuAcademico,
    )) {
      _mostrarModuloNoDisponible();
      return;
    }
    if (_menuPrincipal != _menuAcademico) {
      _animarNavegacion(
        menuPrincipal: _menuAcademico,
        submenuNuevo: _submenuNuevo,
      );
    }
    setState(() {
      final abierto = !_menuAcademicoAbierto;
      _menuAcademicoAbierto = abierto;
      if (!abierto) {
        _submenuCursosAcademicoAbierto = false;
        _grupoCursoAcademicoAbierto = null;
      }
    });
  }

  void _cerrarMenuAcademico() {
    if (!_menuAcademicoAbierto) return;
    setState(() {
      _menuAcademicoAbierto = false;
      _submenuCursosAcademicoAbierto = false;
      _grupoCursoAcademicoAbierto = null;
    });
  }

  Widget _itemMenuAcademico({
    required int value,
    required IconData icono,
    required String titulo,
    VoidCallback? onTap,
    IconData? iconoSecundario,
  }) {
    final seleccionado = _submenuNuevo == value;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ?? () => _seleccionarSubmenuNuevo(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              icono,
              size: 17,
              color: seleccionado ? cs.primary : cs.onSurface,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: seleccionado ? cs.primary : cs.onSurface,
                  fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (iconoSecundario != null)
              Icon(iconoSecundario, size: 16, color: cs.onSurfaceVariant)
            else if (seleccionado)
              Icon(Icons.check_rounded, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }

  void _seleccionarSubmenuNuevo(int sub) {
    if (sub != _subNuevoCursos && _submenuCursosAcademicoAbierto) {
      setState(() {
        _submenuCursosAcademicoAbierto = false;
        _grupoCursoAcademicoAbierto = null;
      });
    }
    if (_menuPrincipal == _menuAcademico && _submenuNuevo == sub) return;
    _animarNavegacion(menuPrincipal: _menuAcademico, submenuNuevo: sub);
  }

  Future<void> _toggleSubmenuCursosAcademico() async {
    if (_menuPrincipal != _menuAcademico ||
        _submenuNuevo != _subNuevoCursos) {
      _animarNavegacion(
        menuPrincipal: _menuAcademico,
        submenuNuevo: _subNuevoCursos,
      );
    }
    setState(() {
      final abierto = !_submenuCursosAcademicoAbierto;
      _submenuCursosAcademicoAbierto = abierto;
      if (!abierto) {
        _grupoCursoAcademicoAbierto = null;
      }
    });
  }

  AgendaDocenteItem? _itemAgendaCursoAcademicoSeleccionado() {
    final curso = Proveedores.cursoAcademicoSeleccionado.value;
    if (curso == null) return null;
    return AgendaDocenteItem(
      cursoId: curso.id,
      institucion: curso.institucion,
      carrera: curso.carrera,
      materia: curso.materia,
      etiquetaCurso: '${curso.anioCursada}° ${curso.curso}',
      bloquesHorarios: const [],
      horaReferenciaOrden: null,
      tieneClaseHoy: false,
      claseHoyId: null,
      registrosHoy: 0,
      ultimaClaseFecha: null,
      temaClasePasada: null,
      continuarHoy: '',
      alumnosPendientes: 0,
      actividadesSinEntregar: 0,
      trabajosSinCorregir: 0,
      proximaEvaluacionFecha: null,
      proximaEvaluacion: null,
    );
  }

  Future<void> _ejecutarAccionCursoAcademico(
    Future<bool> Function(AgendaDocenteItem item) accion,
  ) async {
    final item = _itemAgendaCursoAcademicoSeleccionado();
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un curso primero')),
      );
      return;
    }
    _cerrarMenuAcademico();
    await accion(item);
  }

  Widget _itemAccionCursoAcademico({
    required IconData icono,
    required String titulo,
    required Future<bool> Function(AgendaDocenteItem item) onTap,
    bool destacado = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _ejecutarAccionCursoAcademico(onTap),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: destacado ? cs.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              size: 16,
              color: destacado ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: destacado ? cs.primary : cs.onSurface,
                  fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: destacado ? cs.primary : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ejecutarAccionGeneralAcademico(
    Future<bool> Function() accion,
  ) async {
    _cerrarMenuAcademico();
    await accion();
  }

  Widget _itemAccionGeneralAcademico({
    required IconData icono,
    required String titulo,
    required Future<bool> Function() onTap,
    bool destacado = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _ejecutarAccionGeneralAcademico(onTap),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: destacado ? cs.primary.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icono,
              size: 16,
              color: destacado ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                titulo,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: destacado ? cs.primary : cs.onSurface,
                  fontWeight: destacado ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: destacado ? cs.primary : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleGrupoCursoAcademico(String clave) {
    setState(() {
      _grupoCursoAcademicoAbierto = _grupoCursoAcademicoAbierto == clave
          ? null
          : clave;
    });
  }

  List<_GrupoCursoAcademico> _gruposCursosAcademico() {
    return const [
      _GrupoCursoAcademico(
        clave: 'aula',
        titulo: 'Aula',
        icono: Icons.school_outlined,
      ),
      _GrupoCursoAcademico(
        clave: 'seguimiento',
        titulo: 'Seguimiento',
        icono: Icons.visibility_outlined,
      ),
      _GrupoCursoAcademico(
        clave: 'evaluacion',
        titulo: 'Evaluacion',
        icono: Icons.rule_folder_outlined,
      ),
      _GrupoCursoAcademico(
        clave: 'gestion',
        titulo: 'Gestion',
        icono: Icons.analytics_outlined,
      ),
    ];
  }

  Widget _itemGrupoCursoAcademico({
    required _GrupoCursoAcademico grupo,
    required bool abierto,
  }) {
    final cs = Theme.of(context).colorScheme;
    final contenido = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _toggleGrupoCursoAcademico(grupo.clave),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              grupo.icono,
              size: 17,
              color: abierto ? cs.primary : cs.onSurface,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                grupo.titulo,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: abierto ? cs.primary : cs.onSurface,
                  fontWeight: abierto ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: abierto ? cs.primary : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
    if (!abierto) return contenido;
    return CompositedTransformTarget(
      link: _menuGrupoCursoAcademicoLink,
      child: contenido,
    );
  }

  Widget _panelCursoSeleccionadoHeader(Curso? cursoSeleccionado) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Herramientas de curso',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (cursoSeleccionado == null)
            Text(
              'Selecciona un curso en la pantalla de Cursos para usar las acciones ligadas al detalle.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            )
          else ...[
            Text(
              cursoSeleccionado.materia,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '${cursoSeleccionado.institucion} | ${cursoSeleccionado.carrera}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              '${cursoSeleccionado.anioCursada}° ${cursoSeleccionado.curso}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.primary),
            ),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _submenuCursosAcademico() {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Curso?>(
      valueListenable: Proveedores.cursoAcademicoSeleccionado,
      builder: (context, cursoSeleccionado, _) {
        return Container(
          width: 292,
          padding: const EdgeInsets.all(10),
          decoration: EstilosAplicacion.decoracionPanel(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Herramientas de curso',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        if (cursoSeleccionado == null)
                          Text(
                            'Selecciona un curso en la pantalla de Cursos para usar este panel.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          )
                        else ...[
                          Text(
                            cursoSeleccionado.materia,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cursoSeleccionado.institucion} | ${cursoSeleccionado.carrera}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cursoSeleccionado.anioCursada}° ${cursoSeleccionado.curso}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: cs.primary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  _itemAccionCursoAcademico(
                    icono: Icons.schedule_outlined,
                    titulo: 'Horarios',
                    onTap: (item) => agendaAbrirHorariosCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.record_voice_over_outlined,
                    titulo: 'Intervenciones',
                    onTap: (item) =>
                        agendaAbrirIntervencionesCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.person_search_outlined,
                    titulo: 'Historial',
                    onTap: (item) => agendaAbrirHistorialCurso(
                      context,
                      item,
                      fechaReferencia: DateTime.now(),
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.rule_folder_outlined,
                    titulo: 'Evaluaciones',
                    onTap: (item) =>
                        agendaAbrirEvaluacionesCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.attach_file_outlined,
                    titulo: 'Evidencias',
                    onTap: (item) => agendaAbrirEvidenciasCurso(
                      context,
                      item,
                      fechaReferencia: DateTime.now(),
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.menu_book_outlined,
                    titulo: 'Ficha',
                    onTap: (item) => agendaAbrirFichaCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.handshake_outlined,
                    titulo: 'Acuerdos',
                    onTap: (item) => agendaAbrirAcuerdosCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.apartment_outlined,
                    titulo: 'Reglas',
                    onTap: (item) =>
                        agendaAbrirReglasInstitucion(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.groups_outlined,
                    titulo: 'Agrupamiento',
                    onTap: (item) =>
                        agendaAbrirAgrupamientoCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.text_snippet_outlined,
                    titulo: 'Plantillas',
                    onTap: (item) => agendaAbrirPlantillasCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.fact_check_outlined,
                    titulo: 'Rubricas',
                    onTap: (item) => agendaAbrirRubricasCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.bolt_outlined,
                    titulo: 'Clase actual',
                    onTap: (item) => agendaAbrirClaseActualCurso(
                      context,
                      item,
                      fechaReferencia: DateTime.now(),
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.psychology_alt_outlined,
                    titulo: 'Perfil',
                    onTap: (item) =>
                        agendaAbrirPerfilEstableCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.assignment_outlined,
                    titulo: 'Cierre',
                    onTap: (item) => agendaAbrirCierreCurso(
                      context,
                      item,
                      fechaReferencia: DateTime.now(),
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.summarize_outlined,
                    titulo: 'Sintesis',
                    onTap: (item) => agendaAbrirSintesisPeriodoCurso(
                      context,
                      item,
                      fechaReferencia: DateTime.now(),
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.pending_actions_outlined,
                    titulo: 'Pendientes',
                    destacado: true,
                    onTap: (_) => agendaAbrirPendientesAccionables(
                      context,
                      fechaReferencia: DateTime.now(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    /*

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Herramientas de curso',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_cargandoCursosAcademico)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (_cursosAcademico.isEmpty)
            Text(
              'No hay cursos cargados.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            )
          else ...[
            DropdownButtonFormField<int>(
              initialValue: _cursoAcademicoId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Curso',
                prefixIcon: Icon(Icons.class_outlined),
              ),
              items: _cursosAcademico
                  .map(
                    (curso) => DropdownMenuItem<int>(
                      value: curso.id,
                      child: Text(
                        '${curso.materia} (${curso.anioCursada}° ${curso.curso})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _cursoAcademicoId = value);
              },
            ),
            if (cursoSeleccionado != null) ...[
              const SizedBox(height: 8),
              Text(
                '${cursoSeleccionado.institucion} | ${cursoSeleccionado.carrera}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _botonAccionCursoAcademico(
                  icono: Icons.schedule_outlined,
                  titulo: 'Horarios',
                  onTap: (item) => agendaAbrirHorariosCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.record_voice_over_outlined,
                  titulo: 'Intervenciones',
                  onTap: (item) =>
                      agendaAbrirIntervencionesCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.person_search_outlined,
                  titulo: 'Historial',
                  onTap: (item) => agendaAbrirHistorialCurso(
                    context,
                    item,
                    fechaReferencia: DateTime.now(),
                  ),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.rule_folder_outlined,
                  titulo: 'Evaluaciones',
                  onTap: (item) => agendaAbrirEvaluacionesCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.attach_file_outlined,
                  titulo: 'Evidencias',
                  onTap: (item) => agendaAbrirEvidenciasCurso(
                    context,
                    item,
                    fechaReferencia: DateTime.now(),
                  ),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.menu_book_outlined,
                  titulo: 'Ficha',
                  onTap: (item) => agendaAbrirFichaCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.handshake_outlined,
                  titulo: 'Acuerdos',
                  onTap: (item) => agendaAbrirAcuerdosCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.apartment_outlined,
                  titulo: 'Reglas',
                  onTap: (item) => agendaAbrirReglasInstitucion(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.groups_outlined,
                  titulo: 'Agrupamiento',
                  onTap: (item) => agendaAbrirAgrupamientoCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.text_snippet_outlined,
                  titulo: 'Plantillas',
                  onTap: (item) => agendaAbrirPlantillasCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.fact_check_outlined,
                  titulo: 'Rubricas',
                  onTap: (item) => agendaAbrirRubricasCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.bolt_outlined,
                  titulo: 'Clase actual',
                  onTap: (item) => agendaAbrirClaseActualCurso(
                    context,
                    item,
                    fechaReferencia: DateTime.now(),
                  ),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.psychology_alt_outlined,
                  titulo: 'Perfil',
                  onTap: (item) => agendaAbrirPerfilEstableCurso(context, item),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.assignment_outlined,
                  titulo: 'Cierre',
                  onTap: (item) => agendaAbrirCierreCurso(
                    context,
                    item,
                    fechaReferencia: DateTime.now(),
                  ),
                ),
                _botonAccionCursoAcademico(
                  icono: Icons.summarize_outlined,
                  titulo: 'Sintesis',
                  onTap: (item) => agendaAbrirSintesisPeriodoCurso(
                    context,
                    item,
                    fechaReferencia: DateTime.now(),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    _cerrarMenuAcademico();
                    await agendaAbrirPendientesAccionables(
                      context,
                      fechaReferencia: DateTime.now(),
                    );
                  },
                  icon: const Icon(Icons.pending_actions_outlined, size: 16),
                  label: const Text('Pendientes'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
    */
  }

  Widget _submenuCursosAcademicoJerarquico() {
    return ValueListenableBuilder<Curso?>(
      valueListenable: Proveedores.cursoAcademicoSeleccionado,
      builder: (context, cursoSeleccionado, _) {
        final grupos = _gruposCursosAcademico();
        return Container(
          width: 248,
          padding: const EdgeInsets.all(10),
          decoration: EstilosAplicacion.decoracionPanel(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 520),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _panelCursoSeleccionadoHeader(cursoSeleccionado),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  ...grupos.map(
                    (grupo) => _itemGrupoCursoAcademico(
                      grupo: grupo,
                      abierto: _grupoCursoAcademicoAbierto == grupo.clave,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _submenuGrupoCursoAcademico() {
    final grupo = _gruposCursosAcademico().firstWhere(
      (item) => item.clave == _grupoCursoAcademicoAbierto,
    );
    final cursoSeleccionado = Proveedores.cursoAcademicoSeleccionado.value;
    final fechaReferencia = DateTime.now();
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 292,
      padding: const EdgeInsets.all(10),
      decoration: EstilosAplicacion.decoracionPanel(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grupo.titulo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (cursoSeleccionado != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${cursoSeleccionado.materia} · ${cursoSeleccionado.anioCursada}° ${cursoSeleccionado.curso}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: cs.primary),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 6),
              ...switch (grupo.clave) {
                'aula' => [
                  _itemAccionGeneralAcademico(
                    icono: Icons.near_me_outlined,
                    titulo: 'Curso actual / proximo',
                    onTap: () => agendaAbrirCursoActualOProximo(
                      context,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.bolt_outlined,
                    titulo: 'Clase actual',
                    onTap: (item) => agendaAbrirClaseActualCurso(
                      context,
                      item,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.schedule_outlined,
                    titulo: 'Horarios',
                    onTap: (item) => agendaAbrirHorariosCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.record_voice_over_outlined,
                    titulo: 'Intervenciones',
                    onTap: (item) =>
                        agendaAbrirIntervencionesCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.attach_file_outlined,
                    titulo: 'Evidencias',
                    onTap: (item) => agendaAbrirEvidenciasCurso(
                      context,
                      item,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                ],
                'seguimiento' => [
                  _itemAccionCursoAcademico(
                    icono: Icons.person_search_outlined,
                    titulo: 'Historial',
                    onTap: (item) => agendaAbrirHistorialCurso(
                      context,
                      item,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.menu_book_outlined,
                    titulo: 'Ficha',
                    onTap: (item) => agendaAbrirFichaCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.psychology_alt_outlined,
                    titulo: 'Perfil',
                    onTap: (item) =>
                        agendaAbrirPerfilEstableCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.handshake_outlined,
                    titulo: 'Acuerdos',
                    onTap: (item) => agendaAbrirAcuerdosCurso(context, item),
                  ),
                  _itemAccionGeneralAcademico(
                    icono: Icons.warning_amber_outlined,
                    titulo: 'Alertas',
                    onTap: () => agendaAbrirAlertasAutomaticas(
                      context,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionGeneralAcademico(
                    icono: Icons.pending_actions_outlined,
                    titulo: 'Pendientes',
                    destacado: true,
                    onTap: () => agendaAbrirPendientesAccionables(
                      context,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionGeneralAcademico(
                    icono: Icons.auto_awesome_outlined,
                    titulo: 'Automatizaciones',
                    onTap: () => agendaAbrirAutomatizacionesDocentes(
                      context,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                ],
                'evaluacion' => [
                  _itemAccionCursoAcademico(
                    icono: Icons.rule_folder_outlined,
                    titulo: 'Evaluaciones y resultados',
                    onTap: (item) =>
                        agendaAbrirEvaluacionesCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.fact_check_outlined,
                    titulo: 'Rubricas',
                    onTap: (item) => agendaAbrirRubricasCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.text_snippet_outlined,
                    titulo: 'Plantillas',
                    onTap: (item) => agendaAbrirPlantillasCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.apartment_outlined,
                    titulo: 'Reglas',
                    onTap: (item) =>
                        agendaAbrirReglasInstitucion(context, item),
                  ),
                ],
                _ => [
                  _itemAccionCursoAcademico(
                    icono: Icons.groups_outlined,
                    titulo: 'Agrupamiento',
                    onTap: (item) =>
                        agendaAbrirAgrupamientoCurso(context, item),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.summarize_outlined,
                    titulo: 'Sintesis de curso',
                    onTap: (item) => agendaAbrirSintesisPeriodoCurso(
                      context,
                      item,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionCursoAcademico(
                    icono: Icons.assignment_outlined,
                    titulo: 'Cierre de curso',
                    onTap: (item) => agendaAbrirCierreCurso(
                      context,
                      item,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionGeneralAcademico(
                    icono: Icons.business_center_outlined,
                    titulo: 'Cierre institucional',
                    onTap: () => agendaAbrirCierreInstitucional(
                      context,
                      fechaReferencia: fechaReferencia,
                      institucionSugerida: cursoSeleccionado?.institucion,
                    ),
                  ),
                  _itemAccionGeneralAcademico(
                    icono: Icons.dashboard_outlined,
                    titulo: 'Dashboard',
                    onTap: () => agendaAbrirDashboardEjecutivo(
                      context,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                  _itemAccionGeneralAcademico(
                    icono: Icons.history_outlined,
                    titulo: 'Auditoria',
                    onTap: () => agendaAbrirAuditoriaDocente(
                      context,
                      fechaReferencia: fechaReferencia,
                    ),
                  ),
                ],
              },
            ],
          ),
        ),
      ),
    );
  }

  String _fechaHora(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  Widget _seccionSincronizada({
    required Widget child,
    required double inicio,
    required double fin,
    required double desplazamientoHorizontal,
    required double desplazamientoVertical,
  }) {
    return _SeccionSincronizada(
      controller: _transicionController,
      curve: TransicionesCorrelativas.curvaPrincipal,
      intervalo: Interval(
        inicio,
        fin,
        curve: TransicionesCorrelativas.curvaPrincipal,
      ),
      desplazamientoInicial: Offset(
        desplazamientoHorizontal * _direccionTransicion,
        desplazamientoVertical,
      ),
      child: child,
    );
  }

  Widget _panelesFuncionesSuperiores() {
    return _PanelNavegacionPrincipal(
      menuPrincipal: _menuPrincipal,
      contexto: Proveedores.contextoInstitucional.value,
      menuAcademicoLink: _menuAcademicoLink,
      onSeleccionarMenuPrincipal: _seleccionarMenuPrincipal,
      onAbrirMenuAcademico: _toggleMenuAcademico,
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _indicePantallaActual(),
      children: _pantallas,
    );
    final maxWidthPrincipal = _menuPrincipal == _menuAsistencias
        ? double.infinity
        : LayoutApp.kMaxPageWidth + 180;

    return Scaffold(
      body: Stack(
        children: [
          ...EstilosAplicacion.fondosDecorativos(context),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidthPrincipal),
                child: Padding(
                  padding: LayoutApp.kPagePadding,
                  child: Column(
                    children: [
                      _seccionSincronizada(
                        inicio: 0,
                        fin: 0.72,
                        desplazamientoHorizontal: 0.018,
                        desplazamientoVertical: 0.012,
                        child: _BarraSuperiorDesktop(
                          titulo: _tituloActual(),
                          hora: _fechaHora(_ahora),
                          menuPrincipal: _menuPrincipal,
                          contexto: Proveedores.contextoInstitucional.value,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _seccionSincronizada(
                        inicio: 0.08,
                        fin: 0.84,
                        desplazamientoHorizontal: 0.022,
                        desplazamientoVertical: 0.018,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _panelesFuncionesSuperiores(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: _seccionSincronizada(
                          inicio: 0.14,
                          fin: 1,
                          desplazamientoHorizontal: 0.026,
                          desplazamientoVertical: 0.03,
                          child: body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_menuAcademicoAbierto) ...[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _cerrarMenuAcademico,
              ),
            ),
            CompositedTransformFollower(
              link: _menuAcademicoLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 12),
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: TransicionesCorrelativas.duracionCambioPantalla,
                curve: TransicionesCorrelativas.curvaPrincipal,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 10),
                      child: child,
                    ),
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(8),
                    decoration: EstilosAplicacion.decoracionPanel(context),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 540),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _itemMenuAcademico(
                              value: _subNuevoInstituciones,
                              icono: Icons.account_balance_outlined,
                              titulo: 'Instituciones',
                            ),
                            _itemMenuAcademico(
                              value: _subNuevoCarreras,
                              icono: Icons.route_outlined,
                              titulo: 'Carreras',
                            ),
                            CompositedTransformTarget(
                              link: _menuCursosAcademicoLink,
                              child: _itemMenuAcademico(
                                value: _subNuevoCursos,
                                icono: Icons.class_outlined,
                                titulo: 'Cursos',
                                onTap: () {
                                  _toggleSubmenuCursosAcademico();
                                },
                                iconoSecundario: Icons.chevron_right_rounded,
                              ),
                            ),
                            _itemMenuAcademico(
                              value: _subNuevoAlumnos,
                              icono: Icons.school_outlined,
                              titulo: 'Alumnos',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_submenuCursosAcademicoAbierto)
              CompositedTransformFollower(
                link: _menuCursosAcademicoLink,
                showWhenUnlinked: false,
                offset: const Offset(12, -6),
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.topLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: TransicionesCorrelativas.duracionCambioPantalla,
                  curve: TransicionesCorrelativas.curvaPrincipal,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset((1 - value) * -10, 0),
                        child: child,
                      ),
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: _submenuCursosAcademicoJerarquico(),
                  ),
                ),
              ),
            if (_grupoCursoAcademicoAbierto != null)
              CompositedTransformFollower(
                link: _menuGrupoCursoAcademicoLink,
                showWhenUnlinked: false,
                offset: const Offset(12, -6),
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.topLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: TransicionesCorrelativas.duracionCambioPantalla,
                  curve: TransicionesCorrelativas.curvaPrincipal,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset((1 - value) * -10, 0),
                        child: child,
                      ),
                    );
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: _submenuGrupoCursoAcademico(),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  bool _menuPrincipalHabilitado(ContextoInstitucional contexto, int menu) {
    final permiso = switch (menu) {
      _menuPanel => PermisoModulo.panelInstitucional,
      _menuAcademico => PermisoModulo.academicoCatalogos,
      _menuLegajos => PermisoModulo.legajos,
      _menuSecretaria => PermisoModulo.secretaria,
      _menuBiblioteca => PermisoModulo.biblioteca,
      _menuPreceptoria => PermisoModulo.preceptoria,
      _menuGestion => PermisoModulo.tableroGestion,
      _menuIncidencias => PermisoModulo.incidencias,
      _menuAsistencias => PermisoModulo.asistencias,
      _menuReportes => PermisoModulo.reportes,
      _ => PermisoModulo.panelInstitucional,
    };
    return contexto.tienePermiso(permiso);
  }

  void _mostrarModuloNoDisponible() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El perfil activo no tiene permiso para ese modulo.'),
      ),
    );
  }
}

class _GrupoCursoAcademico {
  final String clave;
  final String titulo;
  final IconData icono;

  const _GrupoCursoAcademico({
    required this.clave,
    required this.titulo,
    required this.icono,
  });
}

class _SeccionSincronizada extends StatelessWidget {
  final AnimationController controller;
  final Curve curve;
  final Interval intervalo;
  final Offset desplazamientoInicial;
  final Widget child;

  const _SeccionSincronizada({
    required this.controller,
    required this.curve,
    required this.intervalo,
    required this.desplazamientoInicial,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animacion = CurvedAnimation(parent: controller, curve: intervalo);
    return FadeTransition(
      opacity: animacion,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: desplazamientoInicial,
          end: Offset.zero,
        ).animate(animacion),
        child: child,
      ),
    );
  }
}

class _PanelNavegacionPrincipal extends StatelessWidget {
  final int menuPrincipal;
  final ContextoInstitucional contexto;
  final LayerLink menuAcademicoLink;
  final ValueChanged<int> onSeleccionarMenuPrincipal;
  final VoidCallback onAbrirMenuAcademico;

  const _PanelNavegacionPrincipal({
    required this.menuPrincipal,
    required this.contexto,
    required this.menuAcademicoLink,
    required this.onSeleccionarMenuPrincipal,
    required this.onAbrirMenuAcademico,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionPanel(context, destacado: true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: EstilosAplicacion.gradienteHero(context),
                  borderRadius: EstilosAplicacion.radioChip,
                  border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fact_check_outlined,
                        size: 16,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Gestion Institucional',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _BotonModuloDesktop(
                titulo: 'Panel',
                icono: Icons.space_dashboard_outlined,
                seleccionado:
                    menuPrincipal == _PantallasPrincipalesState._menuPanel,
                habilitado: contexto.tienePermiso(
                  PermisoModulo.panelInstitucional,
                ),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuPanel,
                ),
              ),
              const SizedBox(width: 8),
              CompositedTransformTarget(
                link: menuAcademicoLink,
                child: _BotonModuloDesktop(
                  titulo: 'Academico',
                  icono: Icons.account_balance_outlined,
                  seleccionado:
                      menuPrincipal ==
                      _PantallasPrincipalesState._menuAcademico,
                  habilitado: contexto.tienePermiso(
                    PermisoModulo.academicoCatalogos,
                  ),
                  iconoSecundario: Icons.keyboard_arrow_down_rounded,
                  onTap: onAbrirMenuAcademico,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Legajos',
                icono: Icons.folder_open_outlined,
                seleccionado:
                    menuPrincipal == _PantallasPrincipalesState._menuLegajos,
                habilitado: contexto.tienePermiso(PermisoModulo.legajos),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuLegajos,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Secretaria',
                icono: Icons.work_history_outlined,
                seleccionado:
                    menuPrincipal ==
                    _PantallasPrincipalesState._menuSecretaria,
                habilitado: contexto.tienePermiso(PermisoModulo.secretaria),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuSecretaria,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Biblioteca',
                icono: Icons.menu_book_outlined,
                seleccionado:
                    menuPrincipal ==
                    _PantallasPrincipalesState._menuBiblioteca,
                habilitado: contexto.tienePermiso(PermisoModulo.biblioteca),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuBiblioteca,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Preceptoria',
                icono: Icons.fact_check_outlined,
                seleccionado:
                    menuPrincipal ==
                    _PantallasPrincipalesState._menuPreceptoria,
                habilitado: contexto.tienePermiso(PermisoModulo.preceptoria),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuPreceptoria,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Gestion',
                icono: Icons.insights_outlined,
                seleccionado:
                    menuPrincipal == _PantallasPrincipalesState._menuGestion,
                habilitado: contexto.tienePermiso(
                  PermisoModulo.tableroGestion,
                ),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuGestion,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Incidencias',
                icono: Icons.hub_outlined,
                seleccionado:
                    menuPrincipal ==
                    _PantallasPrincipalesState._menuIncidencias,
                habilitado: contexto.tienePermiso(PermisoModulo.incidencias),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuIncidencias,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Asistencias',
                icono: Icons.fact_check_outlined,
                seleccionado:
                    menuPrincipal ==
                    _PantallasPrincipalesState._menuAsistencias,
                habilitado: contexto.tienePermiso(PermisoModulo.asistencias),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuAsistencias,
                ),
              ),
              const SizedBox(width: 8),
              _BotonModuloDesktop(
                titulo: 'Reportes',
                icono: Icons.bar_chart_outlined,
                seleccionado:
                    menuPrincipal == _PantallasPrincipalesState._menuReportes,
                habilitado: contexto.tienePermiso(PermisoModulo.reportes),
                onTap: () => onSeleccionarMenuPrincipal(
                  _PantallasPrincipalesState._menuReportes,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarraSuperiorDesktop extends StatelessWidget {
  final String titulo;
  final String hora;
  final int menuPrincipal;
  final ContextoInstitucional contexto;

  const _BarraSuperiorDesktop({
    required this.titulo,
    required this.hora,
    required this.menuPrincipal,
    required this.contexto,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final subtitulo = switch (menuPrincipal) {
      _PantallasPrincipalesState._menuPanel =>
        'Entrada por perfil institucional para escuelas, institutos y universidades.',
      _PantallasPrincipalesState._menuLegajos =>
        'Mesa documental, expedientes, firmas pendientes y control administrativo.',
      _PantallasPrincipalesState._menuSecretaria =>
        'Constancias, pases, equivalencias, certificaciones y salidas administrativas.',
      _PantallasPrincipalesState._menuBiblioteca =>
        'Prestamos, reservas y catalogo basico de recursos bibliotecarios.',
      _PantallasPrincipalesState._menuPreceptoria =>
        'Justificaciones, novedades diarias, convivencia y seguimiento estudiantil.',
      _PantallasPrincipalesState._menuGestion =>
        'Tablero ejecutivo con metricas, alertas y pulso institucional.',
      _PantallasPrincipalesState._menuIncidencias =>
        'Mesa transversal de casos cruzados entre modulos y seguimiento documental.',
      _PantallasPrincipalesState._menuAsistencias =>
        'Carga operativa, detalle por clase y control rapido del aula.',
      _PantallasPrincipalesState._menuReportes =>
        'Lectura transversal, exportaciones y resumen de asistencia.',
      _ => 'Catalogos, cursos, alumnos y estructura academica base.',
    };

    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionHeroPanel(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: EstilosAplicacion.radioChip,
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Text(
                      'Panel activo',
                      style: t.labelLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    titulo,
                    style: t.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      subtitulo,
                      style: t.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                _IndicadorSuperior(
                  icono: Icons.schedule_outlined,
                  etiqueta: 'Actualizado',
                  valor: hora,
                ),
                _IndicadorSuperior(
                  icono: contexto.rol.icono,
                  etiqueta: 'Perfil activo',
                  valor: contexto.rol.etiqueta,
                ),
                const _IndicadorSuperior(
                  icono: Icons.desktop_windows_outlined,
                  etiqueta: 'Entorno',
                  valor: 'Windows',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonModuloDesktop extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final bool seleccionado;
  final bool habilitado;
  final VoidCallback onTap;
  final IconData? iconoSecundario;

  const _BotonModuloDesktop({
    required this.titulo,
    required this.icono,
    required this.seleccionado,
    this.habilitado = true,
    required this.onTap,
    this.iconoSecundario,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: EstilosAplicacion.decoracionChip(
        context,
        seleccionado: seleccionado,
      ),
      child: InkWell(
        borderRadius: EstilosAplicacion.radioChip,
        onTap: habilitado ? onTap : null,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 16,
                color: !habilitado
                    ? cs.onSurfaceVariant.withValues(alpha: 0.45)
                    : seleccionado
                    ? cs.primary
                    : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: t.labelLarge?.copyWith(
                  color: !habilitado
                      ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                      : seleccionado
                      ? cs.primary
                      : cs.onSurface,
                ),
              ),
              if (iconoSecundario != null) ...[
                const SizedBox(width: 4),
                Icon(
                  iconoSecundario,
                  size: 16,
                  color: !habilitado
                      ? cs.onSurfaceVariant.withValues(alpha: 0.45)
                      : seleccionado
                      ? cs.primary
                      : cs.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicadorSuperior extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _IndicadorSuperior({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest.withValues(alpha: 0.78),
        borderRadius: EstilosAplicacion.radioSuave,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.82)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
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
                etiqueta,
                style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                valor,
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
