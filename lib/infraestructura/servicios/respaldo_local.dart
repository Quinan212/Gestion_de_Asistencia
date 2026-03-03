// lib/infraestructura/servicios/respaldo_local.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_storage/shared_storage.dart';

class RespaldoLocal {
  static const String _kTreeUri = 'respaldo_tree_uri_v1';
  static const String _kRestoreDone = 'respaldo_restore_done_v1';

  static const String _carpetaRaiz = 'respaldo_app';
  static const String _archivoDb = 'control_de_mercaderia.sqlite';

  static const String _carpetaFotos = 'productos';
  static const String _indiceFotos = 'productos_index.json';

  static const String _archivoPrefs = 'prefs.json';

  // -------------------------
  // SAF: elegir / recordar
  // -------------------------

  static Future<Uri?> elegirDirectorio() async {
    final uri = await openDocumentTree(
      grantWritePermission: true,
      persistablePermission: true,
    );
    if (uri == null) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTreeUri, uri.toString());
    return uri;
  }

  // compat con tu UI vieja
  static Future<String?> elegirCarpeta() async {
    final uri = await elegirDirectorio();
    return uri?.toString();
  }

  static Future<Uri?> leerDirectorioGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kTreeUri);
    if (s == null || s.trim().isEmpty) return null;
    return Uri.tryParse(s);
  }

  static Future<void> persistUriPermission(Uri uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTreeUri, uri.toString());
  }

  // -------------------------
  // Helpers SAF
  // -------------------------

  static Future<DocumentFile?> _rootFromTree(Uri treeUri) async {
    return DocumentFile.fromTreeUri(treeUri);
  }

  static Future<DocumentFile?> _getOrCreateDirUnder(
      DocumentFile parent,
      String nombre, {
        required bool createIfMissing,
      }) async {
    final existente = await parent.child(nombre, requiresWriteAccess: true);
    if (existente != null && (existente.isDirectory ?? false)) return existente;

    if (!createIfMissing) return null;
    return await parent.createDirectory(nombre);
  }

  static Future<Uri?> _writeFileInDir(
      DocumentFile dir,
      String displayName,
      Uint8List bytes, {
        String mimeType = 'application/octet-stream',
      }) async {
    // si ya existe, borrar y recrear
    final viejo = await dir.findFile(displayName);
    if (viejo != null) {
      try {
        await viejo.delete();
      } catch (_) {}
    }

    final creado = await dir.createFileAsBytes(
      mimeType: mimeType,
      displayName: displayName,
      bytes: bytes,
    );

    return creado?.uri;
  }

  // -------------------------
  // Paths locales (app)
  // -------------------------

  static Future<File> _archivoDbLocal() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _archivoDb));
  }

  static Future<Directory> _dirFotosLocal() async {
    final dir = await getApplicationDocumentsDirectory();
    return Directory(p.join(dir.path, _carpetaFotos));
  }

  // -------------------------
  // PREFS: export / import
  // -------------------------

  // guardá acá TODO lo que quieras “que vuelva igual”
  static const List<String> _prefsKeys = [
    'config_nombre_negocio',
    'config_moneda',
    'config_nota_venta',

    // si después guardás la vista lista/cuadricula del inventario, poné tu key acá:
    'inventario_vista', // ejemplo

    // si agregás más configs, sumalas acá
  ];

  static Future<Map<String, dynamic>> _exportarPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <String, dynamic>{};

    for (final k in _prefsKeys) {
      if (!prefs.containsKey(k)) continue;

      // SharedPreferences soporta: bool/int/double/string/list<string>
      final v = prefs.get(k);
      if (v is bool || v is int || v is double || v is String) {
        out[k] = v;
      } else if (v is List<String>) {
        out[k] = v;
      }
    }

    return out;
  }

  static Future<void> _importarPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    for (final k in _prefsKeys) {
      if (!data.containsKey(k)) continue;
      final v = data[k];

      if (v is bool) {
        await prefs.setBool(k, v);
      } else if (v is int) {
        await prefs.setInt(k, v);
      } else if (v is double) {
        await prefs.setDouble(k, v);
      } else if (v is String) {
        await prefs.setString(k, v);
      } else if (v is List) {
        final xs = v.whereType<String>().toList();
        await prefs.setStringList(k, xs);
      }
    }
  }

  // -------------------------
  // GUARDAR (DB + fotos + índice + prefs.json)
  // -------------------------

  static Future<bool> guardarRespaldoAhora() async {
    final treeUri = await leerDirectorioGuardado();
    if (treeUri == null) return false;

    final root = await _rootFromTree(treeUri);
    if (root == null) return false;

    final backupDir = await _getOrCreateDirUnder(
      root,
      _carpetaRaiz,
      createIfMissing: true,
    );
    if (backupDir == null) return false;

    // 1) guardar DB
    final dbFile = await _archivoDbLocal();
    if (!await dbFile.exists()) return false;

    final dbBytes = await dbFile.readAsBytes();
    final okDb = await _writeFileInDir(
      backupDir,
      _archivoDb,
      Uint8List.fromList(dbBytes),
      mimeType: 'application/octet-stream',
    );
    if (okDb == null) return false;

    // 2) guardar prefs.json
    try {
      final prefsMap = await _exportarPrefs();
      final prefsJson = jsonEncode({
        'version': 1,
        'data': prefsMap,
      });

      await _writeFileInDir(
        backupDir,
        _archivoPrefs,
        Uint8List.fromList(utf8.encode(prefsJson)),
        mimeType: 'application/json',
      );
    } catch (_) {
      // si falla prefs, igual dejamos DB+fotos guardadas
    }

    // 3) guardar fotos + índice
    final fotosLocal = await _dirFotosLocal();
    final nombres = <String>[];

    if (await fotosLocal.exists()) {
      final fotosDirSaf = await _getOrCreateDirUnder(
        backupDir,
        _carpetaFotos,
        createIfMissing: true,
      );

      if (fotosDirSaf != null) {
        final archivos = fotosLocal
            .listSync(recursive: false)
            .whereType<File>()
            .toList();

        for (final f in archivos) {
          final nombre = p.basename(f.path);
          try {
            final bytes = await f.readAsBytes();
            final ok = await _writeFileInDir(
              fotosDirSaf,
              nombre,
              Uint8List.fromList(bytes),
              mimeType: _mimePorExtension(nombre),
            );
            if (ok != null) nombres.add(nombre);
          } catch (_) {
            // seguimos
          }
        }

        final indexJson = jsonEncode({
          'version': 1,
          'files': nombres,
        });

        await _writeFileInDir(
          fotosDirSaf,
          _indiceFotos,
          Uint8List.fromList(utf8.encode(indexJson)),
          mimeType: 'application/json',
        );
      }
    }

    return true;
  }

  // -------------------------
  // RESTAURAR (DB + fotos usando índice + prefs.json)
  // -------------------------

  static Future<bool> restaurarAhoraDesdeTreeUri(Uri treeUri) async {
    final root = await _rootFromTree(treeUri);
    if (root == null) return false;

    final backupDir = await _getOrCreateDirUnder(
      root,
      _carpetaRaiz,
      createIfMissing: false,
    );
    if (backupDir == null) return false;

    // 1) restaurar DB
    final archivoDb = await backupDir.findFile(_archivoDb);
    if (archivoDb == null) return false;

    final dbBytes = await archivoDb.getContent();
    if (dbBytes == null || dbBytes.isEmpty) return false;

    final dbLocal = await _archivoDbLocal();
    await dbLocal.parent.create(recursive: true);
    await dbLocal.writeAsBytes(dbBytes, flush: true);

    // 2) restaurar prefs.json (si existe)
    try {
      final prefsFile = await backupDir.findFile(_archivoPrefs);
      if (prefsFile != null) {
        final prefsBytes = await prefsFile.getContent();
        if (prefsBytes != null && prefsBytes.isNotEmpty) {
          final txt = utf8.decode(prefsBytes);
          final obj = jsonDecode(txt);
          if (obj is Map && obj['data'] is Map) {
            final data = Map<String, dynamic>.from(obj['data'] as Map);
            await _importarPrefs(data);
          }
        }
      }
    } catch (_) {
      // si falla prefs, igual restauramos DB+fotos
    }

    // 3) restaurar fotos desde índice
    final fotosSaf = await _getOrCreateDirUnder(
      backupDir,
      _carpetaFotos,
      createIfMissing: false,
    );

    if (fotosSaf != null) {
      final indexFile = await fotosSaf.findFile(_indiceFotos);
      if (indexFile != null) {
        final indexBytes = await indexFile.getContent();
        if (indexBytes != null && indexBytes.isNotEmpty) {
          final indexTxt = utf8.decode(indexBytes);
          final obj = jsonDecode(indexTxt);

          final List<dynamic> filesDyn =
          (obj is Map && obj['files'] is List) ? (obj['files'] as List) : const [];

          final files = filesDyn
              .whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty && s != _indiceFotos)
              .toList();

          final dirLocal = await _dirFotosLocal();
          if (!await dirLocal.exists()) {
            await dirLocal.create(recursive: true);
          }

          for (final nombre in files) {
            try {
              final f = await fotosSaf.child(nombre, requiresWriteAccess: false);
              if (f == null) continue;

              final bytes = await f.getContent();
              if (bytes == null || bytes.isEmpty) continue;

              final out = File(p.join(dirLocal.path, nombre));
              await out.writeAsBytes(bytes, flush: true);
            } catch (_) {
              // seguimos
            }
          }
        }
      }
    }

    // marca restore hecho para el arranque automático
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kRestoreDone, true);

    return true;
  }

  // restauración automática (solo si falta DB local)
  static Future<void> restaurarSiHaceFalta() async {
    final prefs = await SharedPreferences.getInstance();
    final ya = prefs.getBool(_kRestoreDone) ?? false;
    if (ya) return;

    final treeUri = await leerDirectorioGuardado();
    if (treeUri == null) return;

    final dbLocal = await _archivoDbLocal();
    if (await dbLocal.exists()) {
      await prefs.setBool(_kRestoreDone, true);
      return;
    }

    final ok = await restaurarAhoraDesdeTreeUri(treeUri);
    if (ok) {
      await prefs.setBool(_kRestoreDone, true);
    }
  }

  static String _mimePorExtension(String nombre) {
    final ext = p.extension(nombre).toLowerCase();
    if (ext == '.png') return 'image/png';
    if (ext == '.webp') return 'image/webp';
    if (ext == '.gif') return 'image/gif';
    return 'image/jpeg';
  }
}