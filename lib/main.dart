import 'package:flutter/material.dart';

import 'aplicacion/rutas/rutas.dart';
import 'aplicacion/tema/tema.dart';
import 'infraestructura/servicios/respaldo_local.dart';
import 'infraestructura/servicios/restart_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RespaldoLocal.restaurarSiHaceFalta();

  runApp(const RestartWidget(child: Aplicacion()));
}

class Aplicacion extends StatelessWidget {
  const Aplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de mercadería',
      debugShowCheckedModeBanner: false,
      theme: temaAplicacion(),
      initialRoute: Rutas.inicio,
      routes: rutasAplicacion(),
    );
  }
}