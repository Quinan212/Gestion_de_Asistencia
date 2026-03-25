import 'package:shared_preferences/shared_preferences.dart';

import 'package:gestion_de_asistencias/modulos/panel_institucional/modelos/perfil_institucional.dart';

class ContextoInstitucionalPersistencia {
  ContextoInstitucionalPersistencia._();

  static const String _keyRol = 'contexto_institucional_rol';
  static const String _keyNivel = 'contexto_institucional_nivel';
  static const String _keyDependencia = 'contexto_institucional_dependencia';

  static Future<ContextoInstitucional> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = _enumDesdeTexto(
      RolInstitucional.values,
      prefs.getString(_keyRol),
      RolInstitucional.director,
    );
    final nivel = _enumDesdeTexto(
      NivelInstitucional.values,
      prefs.getString(_keyNivel),
      NivelInstitucional.secundario,
    );
    final dependencia = _enumDesdeTexto(
      DependenciaInstitucional.values,
      prefs.getString(_keyDependencia),
      DependenciaInstitucional.publica,
    );

    return ContextoInstitucional(
      rol: rol,
      nivel: nivel,
      dependencia: dependencia,
    );
  }

  static Future<void> guardar(ContextoInstitucional contexto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRol, contexto.rol.name);
    await prefs.setString(_keyNivel, contexto.nivel.name);
    await prefs.setString(_keyDependencia, contexto.dependencia.name);
  }

  static T _enumDesdeTexto<T extends Enum>(
    List<T> values,
    String? raw,
    T fallback,
  ) {
    if (raw == null || raw.trim().isEmpty) return fallback;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }
}
