import 'package:shared_preferences/shared_preferences.dart';

class Formatos {
  static Future<String> leerMoneda() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('config_moneda') ?? r'$';
  }

  static String dinero(String moneda, double valor) {
    return '$moneda ${valor.toStringAsFixed(2)}';
  }
}