class TextoNormalizado {
  TextoNormalizado._();

  static String sinAcentos(String texto) {
    final sb = StringBuffer();
    for (final rune in texto.runes) {
      switch (rune) {
        case 0x00E1:
          sb.write('a');
          break;
        case 0x00E9:
          sb.write('e');
          break;
        case 0x00ED:
          sb.write('i');
          break;
        case 0x00F3:
          sb.write('o');
          break;
        case 0x00FA:
          sb.write('u');
          break;
        case 0x00C1:
          sb.write('A');
          break;
        case 0x00C9:
          sb.write('E');
          break;
        case 0x00CD:
          sb.write('I');
          break;
        case 0x00D3:
          sb.write('O');
          break;
        case 0x00DA:
          sb.write('U');
          break;
        case 0x00F1:
          sb.write('n');
          break;
        case 0x00D1:
          sb.write('N');
          break;
        default:
          sb.writeCharCode(rune);
      }
    }
    return sb.toString();
  }

  static String normalizarMojibake(String texto) {
    var t = texto.replaceAll('\r\n', '\n');
    t = t.replaceAll(RegExp(r'[\u2022\u00B7]'), '|');
    t = t.replaceAll('\u00E2\u20AC\u00A2', '|');
    t = t.replaceAll('\u00C2\u00B7', '|');
    t = t.replaceAll('\u00C2', '').replaceAll('\u00A0', ' ');
    return t;
  }

  static String normalizarNota(String? nota, {bool quitarAcentos = false}) {
    var t = normalizarMojibake((nota ?? ''));
    if (quitarAcentos) {
      t = sinAcentos(t);
    }
    return t;
  }

  static String limpiarTextoSimple(String valor) {
    var out = normalizarMojibake(valor);
    out = out.replaceAll('\r\n', ' ').replaceAll('\n', ' ').trim();
    out = out.replaceAll(RegExp(r'\s+'), ' ');
    out = out.replaceAll(RegExp(r'^[\s\-\.,:;|]+'), '');
    out = out.replaceAll(RegExp(r'[\s\-\.,:;|]+$'), '');
    if (RegExp(r'^[\s\-\.,:;|]+$').hasMatch(out)) return '';
    return out.trim();
  }
}
