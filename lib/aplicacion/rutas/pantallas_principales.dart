import 'dart:async';

import 'package:flutter/material.dart';

import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/modulos/alumnos/pantallas/alumnos_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/agenda/pantallas/agenda_docente_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/asistencias/pantallas/asistencia_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/cursos/pantallas/cursos_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/instituciones/pantallas/carreras_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/instituciones/pantallas/instituciones_pantalla.dart';
import 'package:gestion_de_asistencias/modulos/reportes_asistencia/pantallas/reportes_asistencia_pantalla.dart';

class PantallasPrincipales extends StatefulWidget {
  const PantallasPrincipales({super.key});

  @override
  State<PantallasPrincipales> createState() => _PantallasPrincipalesState();
}

class _PantallasPrincipalesState extends State<PantallasPrincipales> {
  static const int _menuNuevo = 0;
  static const int _menuAgenda = 1;
  static const int _menuAsistencias = 2;
  static const int _menuReportes = 3;

  static const int _subNuevoInstituciones = 0;
  static const int _subNuevoCarreras = 1;
  static const int _subNuevoCursos = 2;
  static const int _subNuevoAlumnos = 3;

  int _menuPrincipal = _menuNuevo;
  int _submenuNuevo = _subNuevoInstituciones;
  late final VoidCallback _syncMsgListener;
  late final Timer _clockTimer;
  DateTime _ahora = DateTime.now();

  final List<Widget> _pantallas = const [
    InstitucionesPantalla(),
    CarrerasPantalla(),
    CursosPantalla(),
    AlumnosPantalla(),
    AgendaDocentePantalla(),
    AsistenciaPantalla(),
    ReportesAsistenciaPantalla(),
  ];

  @override
  void initState() {
    super.initState();
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

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _ahora = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    Proveedores.estadoSincronizacion.removeListener(_syncMsgListener);
    super.dispose();
  }

  int _indicePantallaActual() {
    if (_menuPrincipal == _menuAgenda) return 4;
    if (_menuPrincipal == _menuAsistencias) return 5;
    if (_menuPrincipal == _menuReportes) return 6;
    switch (_submenuNuevo) {
      case _subNuevoCarreras:
        return 1;
      case _subNuevoCursos:
        return 2;
      case _subNuevoAlumnos:
        return 3;
      case _subNuevoInstituciones:
      default:
        return 0;
    }
  }

  String _tituloActual() {
    if (_menuPrincipal == _menuAgenda) return 'Agenda Docente';
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

  void _seleccionarMenuPrincipal(int menu) {
    if (menu == _menuPrincipal) return;
    setState(() => _menuPrincipal = menu);
    Proveedores.notificarDatosActualizados();
  }

  void _seleccionarSubmenuNuevo(int sub) {
    if (_menuPrincipal == _menuNuevo && _submenuNuevo == sub) return;
    setState(() {
      _menuPrincipal = _menuNuevo;
      _submenuNuevo = sub;
    });
    Proveedores.notificarDatosActualizados();
  }

  String _fechaHora(DateTime f) {
    String d2(int n) => n.toString().padLeft(2, '0');
    return '${d2(f.day)}/${d2(f.month)}/${f.year} ${d2(f.hour)}:${d2(f.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final body = IndexedStack(
      index: _indicePantallaActual(),
      children: _pantallas,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _PanelNavegacionPrincipal(
              menuPrincipal: _menuPrincipal,
              onSeleccionarMenuPrincipal: _seleccionarMenuPrincipal,
            ),
            _BarraSuperiorDesktop(
              titulo: _tituloActual(),
              hora: _fechaHora(_ahora),
            ),
            if (_menuPrincipal == _menuNuevo)
              _SubPanelNavegacionNuevo(
                submenuNuevo: _submenuNuevo,
                onSeleccionarSubmenu: _seleccionarSubmenuNuevo,
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _PanelNavegacionPrincipal extends StatelessWidget {
  final int menuPrincipal;
  final ValueChanged<int> onSeleccionarMenuPrincipal;

  const _PanelNavegacionPrincipal({
    required this.menuPrincipal,
    required this.onSeleccionarMenuPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.72)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fact_check_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Gestion de Asistencias'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Academico',
              icono: Icons.account_balance_outlined,
              seleccionado:
                  menuPrincipal == _PantallasPrincipalesState._menuNuevo,
              onTap: () => onSeleccionarMenuPrincipal(
                _PantallasPrincipalesState._menuNuevo,
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Agenda',
              icono: Icons.event_note_outlined,
              seleccionado:
                  menuPrincipal == _PantallasPrincipalesState._menuAgenda,
              onTap: () => onSeleccionarMenuPrincipal(
                _PantallasPrincipalesState._menuAgenda,
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Asistencias',
              icono: Icons.fact_check_outlined,
              seleccionado:
                  menuPrincipal == _PantallasPrincipalesState._menuAsistencias,
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
              onTap: () => onSeleccionarMenuPrincipal(
                _PantallasPrincipalesState._menuReportes,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 1, height: 28, color: cs.outlineVariant),
          ],
        ),
      ),
    );
  }
}

class _SubPanelNavegacionNuevo extends StatelessWidget {
  final int submenuNuevo;
  final ValueChanged<int> onSeleccionarSubmenu;

  const _SubPanelNavegacionNuevo({
    required this.submenuNuevo,
    required this.onSeleccionarSubmenu,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.72)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_tree_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('Gestion academica y docente'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Instituciones',
              icono: Icons.account_balance_outlined,
              seleccionado:
                  submenuNuevo ==
                  _PantallasPrincipalesState._subNuevoInstituciones,
              onTap: () => onSeleccionarSubmenu(
                _PantallasPrincipalesState._subNuevoInstituciones,
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Carreras',
              icono: Icons.route_outlined,
              seleccionado:
                  submenuNuevo == _PantallasPrincipalesState._subNuevoCarreras,
              onTap: () => onSeleccionarSubmenu(
                _PantallasPrincipalesState._subNuevoCarreras,
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Cursos',
              icono: Icons.class_outlined,
              seleccionado:
                  submenuNuevo == _PantallasPrincipalesState._subNuevoCursos,
              onTap: () => onSeleccionarSubmenu(
                _PantallasPrincipalesState._subNuevoCursos,
              ),
            ),
            const SizedBox(width: 8),
            _BotonModuloDesktop(
              titulo: 'Alumnos',
              icono: Icons.school_outlined,
              seleccionado:
                  submenuNuevo == _PantallasPrincipalesState._subNuevoAlumnos,
              onTap: () => onSeleccionarSubmenu(
                _PantallasPrincipalesState._subNuevoAlumnos,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarraSuperiorDesktop extends StatelessWidget {
  final String titulo;
  final String hora;

  const _BarraSuperiorDesktop({required this.titulo, required this.hora});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.72)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: t.titleLarge),
              Text('Actualizado: $hora', style: t.bodySmall),
            ],
          ),
          const Spacer(),
          Icon(Icons.desktop_windows_outlined, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text('Modo Windows', style: t.labelMedium),
        ],
      ),
    );
  }
}

class _BotonModuloDesktop extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const _BotonModuloDesktop({
    required this.titulo,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Material(
      color: seleccionado
          ? cs.primary.withValues(alpha: 0.13)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: seleccionado ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 16,
                color: seleccionado ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: t.labelLarge?.copyWith(
                  color: seleccionado ? cs.primary : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
