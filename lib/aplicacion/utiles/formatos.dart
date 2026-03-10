import 'package:shared_preferences/shared_preferences.dart';

class Formatos {
  static Future<String> leerMoneda() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('config_moneda') ?? r'$';
  }

  static String dinero(String moneda, double valor) {
    return '$moneda ${valor.toStringAsFixed(2)}';
  }

  static String cantidad(double valor, {String? unidad, int decimales = 2}) {
    if (_esUnidadEntera(unidad)) {
      return valor.toStringAsFixed(0);
    }
    return valor.toStringAsFixed(decimales);
  }

  static bool _esUnidadEntera(String? unidad) {
    if (unidad == null) return false;
    final u = _normalizarTexto(unidad);
    return u == 'unidad' || u == 'unidades';
  }

  static String _normalizarTexto(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }
}
