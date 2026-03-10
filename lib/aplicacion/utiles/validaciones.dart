class AppValidaciones {
  AppValidaciones._();

  static String? validarRequerido(String? valor, {required String campo}) {
    final t = (valor ?? '').trim();
    if (t.isEmpty) return '$campo: completa este campo';
    return null;
  }

  static double? parseNumero(String? texto) {
    var s = (texto ?? '').trim();
    if (s.isEmpty) return null;

    s = s.replaceAll(' ', '');
    if (s.contains('.') && s.contains(',')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains(',') && !s.contains('.')) {
      s = s.replaceAll(',', '.');
    }

    s = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    if (s.isEmpty || s == '-' || s == '.') return null;
    return double.tryParse(s);
  }

  static String? validarNumeroMayorQueCero(
    String? texto, {
    required String campo,
  }) {
    final n = parseNumero(texto);
    if (n == null) return '$campo: ingresa un numero valido';
    if (n <= 0) return '$campo: debe ser mayor a 0';
    return null;
  }

  static String? validarNumeroNoNegativo(
    String? texto, {
    required String campo,
  }) {
    final n = parseNumero(texto);
    if (n == null) return '$campo: ingresa un numero valido';
    if (n < 0) return '$campo: no puede ser negativo';
    return null;
  }

  static String? validarSeleccion<T>(T? valor, {required String campo}) {
    if (valor == null) return '$campo: selecciona una opcion';
    return null;
  }
}
