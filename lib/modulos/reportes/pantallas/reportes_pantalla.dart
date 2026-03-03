// lib/modulos/reportes/pantallas/reportes_pantalla.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gestion_de_stock/infraestructura/servicios/copia_seguridad.dart';
import 'package:gestion_de_stock/infraestructura/servicios/respaldo_local.dart';
import 'package:gestion_de_stock/infraestructura/servicios/restart_widget.dart';

import 'reporte_ventas_pantalla.dart';
import 'reporte_reposicion_pantalla.dart';
import 'reporte_margen_pantalla.dart';

class ReportesPantalla extends StatefulWidget {
  const ReportesPantalla({super.key});

  @override
  State<ReportesPantalla> createState() => _ReportesPantallaState();
}

class _ReportesPantallaState extends State<ReportesPantalla> {
  static const double _kTablet = 900;

  String _nombreNegocio = 'Mi negocio';
  String _moneda = r'$';
  String _notaVenta = '';
  Uri? _treeUri;

  int _sel = 0;

  @override
  void initState() {
    super.initState();
    _cargarConfig();
  }

  Future<void> _cargarConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final tree = await RespaldoLocal.leerDirectorioGuardado();
    if (!mounted) return;

    setState(() {
      _nombreNegocio = prefs.getString('config_nombre_negocio') ?? 'Mi negocio';
      _moneda = prefs.getString('config_moneda') ?? r'$';
      _notaVenta = prefs.getString('config_nota_venta') ?? '';
      _treeUri = tree;
    });
  }

  Future<void> _guardarConfig({
    required String nombreNegocio,
    required String moneda,
    required String notaVenta,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('config_nombre_negocio', nombreNegocio);
    await prefs.setString('config_moneda', moneda);
    await prefs.setString('config_nota_venta', notaVenta);

    if (!mounted) return;
    setState(() {
      _nombreNegocio = nombreNegocio;
      _moneda = moneda;
      _notaVenta = notaVenta;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
  }

  Future<void> _abrirConfiguracion() async {
    final nombreCtrl = TextEditingController(text: _nombreNegocio);
    final monedaCtrl = TextEditingController(text: _moneda);
    final notaCtrl = TextEditingController(text: _notaVenta);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Configuración',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: monedaCtrl,
                  decoration: const InputDecoration(
                    labelText: r'Símbolo de moneda (ej: $, ARS, €)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notaCtrl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Nota corta por defecto en ventas (opcional)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    final nombre = nombreCtrl.text.trim().isEmpty ? 'Mi negocio' : nombreCtrl.text.trim();
    final moneda = monedaCtrl.text.trim().isEmpty ? r'$' : monedaCtrl.text.trim();
    final nota = notaCtrl.text.trim();

    await _guardarConfig(nombreNegocio: nombre, moneda: moneda, notaVenta: nota);
  }

  String _resumenConfig() {
    final nota = _notaVenta.trim();
    final notaTxt = nota.isEmpty ? 'sin nota' : 'con nota';
    return '$_nombreNegocio • moneda $_moneda • $notaTxt';
  }

  String _resumenRespaldo() {
    final s = _treeUri?.toString() ?? '';
    return s.trim().isEmpty ? 'No elegida' : 'Elegida';
  }

  Future<void> _elegirCarpetaRespaldo() async {
    final uri = await RespaldoLocal.elegirDirectorio();
    if (!mounted) return;

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se eligió carpeta')),
      );
      return;
    }

    setState(() => _treeUri = uri);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carpeta de respaldo guardada')),
    );
  }

  Future<void> _guardarRespaldoAhora() async {
    final ok = await RespaldoLocal.guardarRespaldoAhora();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Respaldo guardado en la carpeta elegida' : 'No se pudo guardar (primero elegí carpeta)',
        ),
      ),
    );

    await _cargarConfig();
  }

  Future<void> _restaurarYReiniciar() async {
    try {
      final tree = await RespaldoLocal.elegirDirectorio();
      if (tree == null) return;

      final ok = await RespaldoLocal.restaurarAhoraDesdeTreeUri(tree);
      if (!mounted) return;

      if (!ok) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('No encontré el respaldo'),
            content: const Text('En esa carpeta no hay un respaldo válido.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
        return;
      }

      final reiniciar = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Restauración lista'),
          content: const Text('Hace falta reiniciar la app para aplicar los cambios.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reiniciar'),
            ),
          ],
        ),
      );

      if (reiniciar == true) {
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        RestartWidget.restartApp(context);
      }
    } catch (_) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No se pudo restaurar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  Widget _menuList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _MenuItem(
          selected: _sel == 0,
          icon: Icons.calendar_month_outlined,
          title: 'Ventas por día',
          subtitle: 'Últimos 14 días + consumo 30 días',
          onTap: () => setState(() => _sel = 0),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          selected: _sel == 1,
          icon: Icons.inventory_outlined,
          title: 'Reposición',
          subtitle: 'Por mínimo o por combo objetivo',
          onTap: () => setState(() => _sel = 1),
        ),
        const SizedBox(height: 8),
        _MenuItem(
          selected: _sel == 2,
          icon: Icons.percent_outlined,
          title: 'Margen por combo',
          subtitle: 'Ganancia y % sobre costo',
          onTap: () => setState(() => _sel = 2),
        ),
        const SizedBox(height: 12),

        _MenuItem(
          selected: _sel == 3,
          icon: Icons.restore,
          title: 'Restaurar desde respaldo',
          subtitle: 'Elige la carpeta, restaura y reinicia',
          onTap: () async {
            await _restaurarYReiniciar();
            if (!mounted) return;
            setState(() => _sel = 0);
          },
        ),
        const SizedBox(height: 8),
        _MenuItem(
          selected: _sel == 4,
          icon: Icons.tune,
          title: 'Configuración',
          subtitle: _resumenConfig(),
          onTap: () async {
            await _abrirConfiguracion();
            if (!mounted) return;
            setState(() => _sel = 0);
          },
        ),
        const SizedBox(height: 8),
        _MenuItem(
          selected: _sel == 5,
          icon: Icons.folder_open,
          title: 'Carpeta de respaldo',
          subtitle: _resumenRespaldo(),
          onTap: () async {
            await _elegirCarpetaRespaldo();
            if (!mounted) return;
            setState(() => _sel = 0);
          },
        ),
        const SizedBox(height: 8),
        _MenuItem(
          selected: _sel == 6,
          icon: Icons.save,
          title: 'Guardar respaldo ahora',
          subtitle: 'DB + fotos (en la carpeta elegida)',
          onTap: () async {
            await _guardarRespaldoAhora();
            if (!mounted) return;
            setState(() => _sel = 0);
          },
        ),
        const SizedBox(height: 12),

        _MenuItem(
          selected: _sel == 7,
          icon: Icons.download_outlined,
          title: 'Copia de seguridad',
          subtitle: 'Exporta todo a CSV',
          onTap: () async {
            final path = await CopiaSeguridad.crearCopiaCompleta();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copia creada: $path')),
            );
            setState(() => _sel = 0);
          },
        ),
        const SizedBox(height: 8),
        _MenuItem(
          selected: _sel == 8,
          icon: Icons.share,
          title: 'Compartir copia',
          subtitle: 'Crea un ZIP y lo comparte',
          onTap: () async {
            final zipPath = await CopiaSeguridad.crearZipDeCopiaCompleta();
            await Share.shareXFiles([XFile(zipPath)], text: 'Copia de seguridad (ZIP)');
            if (!mounted) return;
            setState(() => _sel = 0);
          },
        ),
      ],
    );
  }

  Widget _panelDerecho() {
    switch (_sel) {
      case 0:
        return const ReporteVentasPantalla(embebido: true);
      case 1:
        return const ReporteReposicionPantalla(embebido: true);
      case 2:
        return const ReporteMargenPantalla(embebido: true);
      default:
        return Center(
          child: Text(
            'Elegí una opción',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final esTablet = c.maxWidth >= _kTablet;

        if (!esTablet) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Ventas por día'),
                      subtitle: const Text('Últimos 14 días + consumo 30 días'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReporteVentasPantalla()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Reposición'),
                      subtitle: const Text('Por mínimo o por combo objetivo'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReporteReposicionPantalla()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Margen por combo'),
                      subtitle: const Text('Ganancia y % sobre costo'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReporteMargenPantalla()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Restaurar desde respaldo'),
                      subtitle: const Text('Elige la carpeta, restaura y reinicia'),
                      trailing: const Icon(Icons.restore),
                      onTap: _restaurarYReiniciar,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Configuración'),
                      subtitle: Text(_resumenConfig()),
                      trailing: const Icon(Icons.tune),
                      onTap: _abrirConfiguracion,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Carpeta de respaldo'),
                      subtitle: Text(_resumenRespaldo()),
                      trailing: const Icon(Icons.folder_open),
                      onTap: _elegirCarpetaRespaldo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Guardar respaldo ahora'),
                      subtitle: const Text('DB + fotos (en la carpeta elegida)'),
                      trailing: const Icon(Icons.save),
                      onTap: _guardarRespaldoAhora,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Copia de seguridad'),
                      subtitle: const Text('Exporta todo a CSV'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final path = await CopiaSeguridad.crearCopiaCompleta();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copia creada: $path')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      title: const Text('Compartir copia'),
                      subtitle: const Text('Crea un ZIP y lo comparte'),
                      trailing: const Icon(Icons.share),
                      onTap: () async {
                        final zipPath = await CopiaSeguridad.crearZipDeCopiaCompleta();
                        await Share.shareXFiles([XFile(zipPath)], text: 'Copia de seguridad (ZIP)');
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Row(
          children: [
            SizedBox(
              width: 360,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: _menuList(context),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _panelDerecho(),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected ? theme.colorScheme.primaryContainer : null;
    final fg = selected ? theme.colorScheme.onPrimaryContainer : null;

    return Card(
      color: bg,
      child: ListTile(
        leading: Icon(icon, color: fg),
        title: Text(title, style: fg == null ? null : TextStyle(color: fg)),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: fg == null ? null : TextStyle(color: fg),
        ),
        trailing: Icon(Icons.chevron_right, color: fg),
        onTap: onTap,
      ),
    );
  }
}