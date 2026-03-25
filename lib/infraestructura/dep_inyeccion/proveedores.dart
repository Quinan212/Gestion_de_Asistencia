// lib/infraestructura/dep_inyeccion/proveedores.dart
import 'dart:async';

import 'package:flutter/foundation.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '/infraestructura/servicios/borrado_jerarquico_servicio.dart';
import '/infraestructura/servicios/contexto_institucional_persistencia.dart';

import '/modulos/alumnos/datos/alumnos_repositorio.dart';
import '/modulos/agenda/datos/agenda_docente_repositorio.dart';
import '/modulos/biblioteca/datos/recursos_biblioteca_repositorio.dart';
import '/modulos/cursos/datos/cursos_repositorio.dart';
import '/modulos/cursos/modelos/curso.dart';
import '/modulos/asistencias/datos/asistencias_repositorio.dart';
import '/modulos/incidencias/datos/incidencias_transversales_repositorio.dart';
import '/modulos/instituciones/datos/instituciones_repositorio.dart';
import '/modulos/legajos/datos/legajos_repositorio.dart';
import '/modulos/panel_institucional/modelos/perfil_institucional.dart';
import '/modulos/preceptoria/datos/preceptoria_repositorio.dart';
import '/modulos/secretaria/datos/tramites_secretaria_repositorio.dart';
import '/modulos/tablero_gestion/datos/responsables_gestion_repositorio.dart';
import '/modulos/tablero_gestion/datos/tablero_gestion_repositorio.dart';

class Proveedores {
  Proveedores._();

  static BaseDeDatos? _baseDeDatos;
  static AlumnosRepositorio? _alumnosRepositorio;
  static AgendaDocenteRepositorio? _agendaDocenteRepositorio;
  static CursosRepositorio? _cursosRepositorio;
  static AsistenciasRepositorio? _asistenciasRepositorio;
  static InstitucionesRepositorio? _institucionesRepositorio;
  static LegajosRepositorio? _legajosRepositorio;
  static TramitesSecretariaRepositorio? _tramitesSecretariaRepositorio;
  static RecursosBibliotecaRepositorio? _recursosBibliotecaRepositorio;
  static PreceptoriaRepositorio? _preceptoriaRepositorio;
  static IncidenciasTransversalesRepositorio? _incidenciasTransversalesRepositorio;
  static ResponsablesGestionRepositorio? _responsablesGestionRepositorio;
  static TableroGestionRepositorio? _tableroGestionRepositorio;
  static BorradoJerarquicoServicio? _borradoJerarquicoServicio;
  static final ValueNotifier<int> datosVersion = ValueNotifier<int>(0);
  static final ValueNotifier<String?> estadoSincronizacion = ValueNotifier(
    null,
  );
  static final ValueNotifier<Curso?> cursoAcademicoSeleccionado =
      ValueNotifier<Curso?>(null);
  static final ValueNotifier<ContextoInstitucional> contextoInstitucional =
      ValueNotifier<ContextoInstitucional>(
        const ContextoInstitucional.predeterminado(),
      );

  static BaseDeDatos get baseDeDatos => _baseDeDatos ??= BaseDeDatos();

  static AlumnosRepositorio get alumnosRepositorio =>
      _alumnosRepositorio ??= AlumnosRepositorio(baseDeDatos);

  static AgendaDocenteRepositorio get agendaDocenteRepositorio =>
      _agendaDocenteRepositorio ??= AgendaDocenteRepositorio(baseDeDatos);

  static CursosRepositorio get cursosRepositorio =>
      _cursosRepositorio ??= CursosRepositorio(baseDeDatos);

  static AsistenciasRepositorio get asistenciasRepositorio =>
      _asistenciasRepositorio ??= AsistenciasRepositorio(baseDeDatos);

  static InstitucionesRepositorio get institucionesRepositorio =>
      _institucionesRepositorio ??= InstitucionesRepositorio(baseDeDatos);

  static LegajosRepositorio get legajosRepositorio =>
      _legajosRepositorio ??= LegajosRepositorio(baseDeDatos);

  static TramitesSecretariaRepositorio get tramitesSecretariaRepositorio =>
      _tramitesSecretariaRepositorio ??=
          TramitesSecretariaRepositorio(baseDeDatos);

  static RecursosBibliotecaRepositorio get recursosBibliotecaRepositorio =>
      _recursosBibliotecaRepositorio ??=
          RecursosBibliotecaRepositorio(baseDeDatos);

  static PreceptoriaRepositorio get preceptoriaRepositorio =>
      _preceptoriaRepositorio ??= PreceptoriaRepositorio(baseDeDatos);

  static IncidenciasTransversalesRepositorio get incidenciasTransversalesRepositorio =>
      _incidenciasTransversalesRepositorio ??=
          IncidenciasTransversalesRepositorio(baseDeDatos);

  static ResponsablesGestionRepositorio get responsablesGestionRepositorio =>
      _responsablesGestionRepositorio ??= ResponsablesGestionRepositorio(
        baseDeDatos,
      );

  static TableroGestionRepositorio get tableroGestionRepositorio =>
      _tableroGestionRepositorio ??= TableroGestionRepositorio(baseDeDatos);

  static BorradoJerarquicoServicio get borradoJerarquicoServicio =>
      _borradoJerarquicoServicio ??= BorradoJerarquicoServicio(baseDeDatos);

  static Future<void> cerrarDependencias() async {
    final bd = _baseDeDatos;
    if (bd != null) {
      await bd.cerrar();
    }
    _limpiarCaches();
  }

  static Future<void> recrearDependencias() async {
    await cerrarDependencias();
    _baseDeDatos = BaseDeDatos();
    notificarDatosActualizados(mensaje: 'Datos restaurados y sincronizados.');
  }

  static void notificarDatosActualizados({String? mensaje}) {
    datosVersion.value = datosVersion.value + 1;
    final t = (mensaje ?? '').trim();
    if (t.isNotEmpty) {
      estadoSincronizacion.value = t;
    }
  }

  static void limpiarEstadoSincronizacion() {
    estadoSincronizacion.value = null;
  }

  static void restaurarContextoInstitucional(ContextoInstitucional contexto) {
    contextoInstitucional.value = contexto;
  }

  static void actualizarContextoInstitucional(ContextoInstitucional contexto) {
    final actual = contextoInstitucional.value;
    if (actual.rol == contexto.rol &&
        actual.nivel == contexto.nivel &&
        actual.dependencia == contexto.dependencia) {
      return;
    }
    contextoInstitucional.value = contexto;
    unawaited(ContextoInstitucionalPersistencia.guardar(contexto));
  }

  static void _limpiarCaches() {
    _baseDeDatos = null;
    _alumnosRepositorio = null;
    _agendaDocenteRepositorio = null;
    _cursosRepositorio = null;
    _asistenciasRepositorio = null;
    _institucionesRepositorio = null;
    _legajosRepositorio = null;
    _tramitesSecretariaRepositorio = null;
    _recursosBibliotecaRepositorio = null;
    _preceptoriaRepositorio = null;
    _incidenciasTransversalesRepositorio = null;
    _responsablesGestionRepositorio = null;
    _tableroGestionRepositorio = null;
    _borradoJerarquicoServicio = null;
    cursoAcademicoSeleccionado.value = null;
    contextoInstitucional.value = const ContextoInstitucional.predeterminado();
  }
}
