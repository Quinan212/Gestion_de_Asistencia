import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FotosProducto {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> elegirYGuardar({
    required int productoId,
    bool usarCamara = false,
  }) async {
    final XFile? x = await _picker.pickImage(
      source: usarCamara ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(dir.path, 'productos'));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final ext = p.extension(x.path).isEmpty ? '.jpg' : p.extension(x.path);
    final nombre = 'producto_${productoId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destino = p.join(carpeta.path, nombre);

    await File(x.path).copy(destino);
    return destino;
  }

  static Future<void> borrarSiExiste(String? ruta) async {
    if (ruta == null || ruta.trim().isEmpty) return;
    final f = File(ruta);
    if (await f.exists()) {
      await f.delete();
    }
  }
}