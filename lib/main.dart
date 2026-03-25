import 'package:flutter/material.dart';

import 'aplicacion/rutas/rutas.dart';
import 'aplicacion/tema/tema.dart';
import 'infraestructura/dep_inyeccion/proveedores.dart';
import 'infraestructura/servicios/contexto_institucional_persistencia.dart';
import 'infraestructura/servicios/respaldo_local.dart';
import 'infraestructura/servicios/restart_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RespaldoLocal.restaurarSiHaceFalta();
  final contexto = await ContextoInstitucionalPersistencia.cargar();
  Proveedores.restaurarContextoInstitucional(contexto);
  runApp(const RestartWidget(child: Aplicacion()));
}

class Aplicacion extends StatelessWidget {
  const Aplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Asistencias',
      debugShowCheckedModeBanner: false,
      theme: temaSuiteClaro(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: true,
        physics: ClampingScrollPhysics(),
      ),
      initialRoute: Rutas.inicio,
      routes: rutasAplicacion(),
    );
  }
}
