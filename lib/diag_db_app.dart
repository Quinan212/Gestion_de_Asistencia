import 'package:flutter/material.dart';

import '/infraestructura/dep_inyeccion/proveedores.dart';
import '/modulos/instituciones/modelos/institucion.dart';
import '/modulos/instituciones/modelos/carrera.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _DiagApp());
}

class _DiagApp extends StatefulWidget {
  const _DiagApp();

  @override
  State<_DiagApp> createState() => _DiagAppState();
}

class _DiagAppState extends State<_DiagApp> {
  final List<String> _logs = <String>[];
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    Future<void> step(String nombre, Future<dynamic> Function() fn) async {
      try {
        final data = await fn();
        _append('OK $nombre => ${_size(data)}');
      } catch (e, st) {
        _append('ERROR $nombre => $e');
        _append(st.toString());
      }
    }

    await step('db.user_version', () async {
      final row = await Proveedores.baseDeDatos
          .customSelect('PRAGMA user_version')
          .getSingle();
      return row.read<int>('user_version');
    });

    await step(
      'instituciones.listar',
      () => Proveedores.institucionesRepositorio.listar(),
    );
    await step(
      'instituciones.carrerasAgrupadas',
      () => Proveedores.institucionesRepositorio.listarCarrerasAgrupadas(),
    );
    await step(
      'instituciones.materiasAgrupadas',
      () => Proveedores.institucionesRepositorio.listarMateriasAgrupadas(),
    );
    await step('alumnos.listar', () => Proveedores.alumnosRepositorio.listar());
    await step(
      'alumnos.listarParaOrganizar',
      () => Proveedores.alumnosRepositorio.listarParaOrganizar(),
    );
    await step('cursos.listar', () => Proveedores.cursosRepositorio.listar());

    await _stepsPorInstitucionYCarrera();

    if (!mounted) return;
    setState(() => _running = false);
  }

  Future<void> _stepsPorInstitucionYCarrera() async {
    Future<void> step(String nombre, Future<dynamic> Function() fn) async {
      try {
        final data = await fn();
        _append('OK $nombre => ${_size(data)}');
      } catch (e, st) {
        _append('ERROR $nombre => $e');
        _append(st.toString());
      }
    }

    final instituciones = await Proveedores.institucionesRepositorio.listar(
      incluirInactivas: true,
    );
    for (final Institucion inst in instituciones) {
      List<Carrera> carreras = const [];
      await step(
        'instituciones.listarCarrerasDeInstitucion(${inst.id})',
        () async {
          carreras = await Proveedores.institucionesRepositorio
              .listarCarrerasDeInstitucion(inst.id, incluirInactivas: true);
          return carreras;
        },
      );
      for (final Carrera carrera in carreras) {
        await step(
          'instituciones.listarMateriasDeCarrera(${carrera.id})',
          () => Proveedores.institucionesRepositorio.listarMateriasDeCarrera(
            carrera.id,
            incluirInactivas: true,
          ),
        );
      }
    }
  }

  String _size(dynamic value) {
    if (value is List) return 'list(${value.length})';
    if (value is Map) return 'map(${value.length})';
    return value.runtimeType.toString();
  }

  void _append(String line) {
    debugPrint(line);
    if (!mounted) return;
    setState(() => _logs.add(line));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            _running ? 'Diagnostico en curso' : 'Diagnostico completo',
          ),
        ),
        body: ListView.builder(
          itemCount: _logs.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(_logs[i]),
          ),
        ),
      ),
    );
  }
}
