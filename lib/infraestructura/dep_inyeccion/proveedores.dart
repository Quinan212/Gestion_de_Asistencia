// lib/infraestructura/dep_inyeccion/proveedores.dart
import 'package:flutter/foundation.dart';

import '/infraestructura/base_de_datos/base_de_datos.dart';
import '/infraestructura/servicios/borrado_jerarquico_servicio.dart';

import '/modulos/alumnos/datos/alumnos_repositorio.dart';
import '/modulos/agenda/datos/agenda_docente_repositorio.dart';
import '/modulos/cursos/datos/cursos_repositorio.dart';
import '/modulos/asistencias/datos/asistencias_repositorio.dart';
import '/modulos/instituciones/datos/instituciones_repositorio.dart';

class Proveedores {
  Proveedores._();

  static BaseDeDatos? _baseDeDatos;
  static AlumnosRepositorio? _alumnosRepositorio;
  static AgendaDocenteRepositorio? _agendaDocenteRepositorio;
  static CursosRepositorio? _cursosRepositorio;
  static AsistenciasRepositorio? _asistenciasRepositorio;
  static InstitucionesRepositorio? _institucionesRepositorio;
  static BorradoJerarquicoServicio? _borradoJerarquicoServicio;
  static final ValueNotifier<int> datosVersion = ValueNotifier<int>(0);
  static final ValueNotifier<String?> estadoSincronizacion = ValueNotifier(
    null,
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

  static void _limpiarCaches() {
    _baseDeDatos = null;
    _alumnosRepositorio = null;
    _agendaDocenteRepositorio = null;
    _cursosRepositorio = null;
    _asistenciasRepositorio = null;
    _institucionesRepositorio = null;
    _borradoJerarquicoServicio = null;
  }
}
