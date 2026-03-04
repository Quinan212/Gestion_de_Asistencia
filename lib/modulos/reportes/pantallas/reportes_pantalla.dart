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

  // mismo “ancho cómodo” que venimos usando
  static const double _kMaxPageWidth = 1120;
  static const double _kMenuWidth = 360;

  // sheets prolijos (no gigantones)
  static const double _kMaxSheetWidth = 620;

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

  bool _esTabletUI(BuildContext context) => MediaQuery.of(context).size.width >= _kTablet;

  Widget _sheetWrap(BuildContext context, Widget child) {
    final esTablet = _esTabletUI(context);
    if (!esTablet) return child;

    final media = MediaQuery.of(context);
    final maxH = (media.size.height * 0.70).clamp(320.0, 640.0);

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _kMaxSheetWidth, maxHeight: maxH),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirConfiguracion() async {
    final nombreCtrl = TextEditingController(text: _nombreNegocio);
    final monedaCtrl = TextEditingController(text: _moneda);
    final notaCtrl = TextEditingController(text: _notaVenta);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _sheetWrap(
          context,
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Text('Configuración', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      tooltip: 'Cerrar',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(labelText: 'Nombre del negocio'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: monedaCtrl,
                          decoration: const InputDecoration(
                            labelText: r'Símbolo de moneda (ej: $, ARS, €)',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notaCtrl,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Nota corta por defecto en ventas (opcional)',
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
          ok
              ? 'Respaldo guardado en la carpeta elegida'
              : 'No se pudo guardar (primero elegí carpeta)',
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

  // -------- estilo lista “ventas” (sin bordes fuertes) --------

  Widget _menuHeader() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Card(
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: cs.surfaceContainerHighest,
                child: Icon(Icons.bar_chart_outlined, color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reportes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      _resumenConfig(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _abrirConfiguracion,
                icon: const Icon(Icons.tune),
                tooltip: 'Configuración',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool warn = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final bgSel = cs.primary.withValues(alpha: 0.08);
    final fg = warn ? cs.error : cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: selected ? bgSel : null,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.surfaceContainerHighest,
              child: Icon(icon, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _menuList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _menuHeader(),
        const SizedBox(height: 12),

        _menuItem(
          selected: _sel == 0,
          icon: Icons.calendar_month_outlined,
          title: 'Ventas por día',
          subtitle: 'Últimos 14 días + consumo 30 días',
          onTap: () => setState(() => _sel = 0),
        ),
        const Divider(height: 1),
        _menuItem(
          selected: _sel == 1,
          icon: Icons.inventory_outlined,
          title: 'Reposición',
          subtitle: 'Por mínimo o por combo objetivo',
          onTap: () => setState(() => _sel = 1),
        ),
        const Divider(height: 1),
        _menuItem(
          selected: _sel == 2,
          icon: Icons.percent_outlined,
          title: 'Margen por combo',
          subtitle: 'Ganancia y % sobre costo',
          onTap: () => setState(() => _sel = 2),
        ),

        const SizedBox(height: 12),

        _menuItem(
          selected: false,
          icon: Icons.restore,
          title: 'Restaurar desde respaldo',
          subtitle: 'Elegís carpeta, restaura y reinicia',
          warn: true,
          onTap: () async {
            await _restaurarYReiniciar();
            if (!mounted) return;
            setState(() => _sel = 0);
          },
        ),
        const Divider(height: 1),
        _menuItem(
          selected: false,
          icon: Icons.folder_open,
          title: 'Carpeta de respaldo',
          subtitle: 'Estado: ${_resumenRespaldo()}',
          onTap: () async {
            await _elegirCarpetaRespaldo();
            if (!mounted) return;
            setState(() {});
          },
        ),
        const Divider(height: 1),
        _menuItem(
          selected: false,
          icon: Icons.save,
          title: 'Guardar respaldo ahora',
          subtitle: 'DB + fotos (en la carpeta elegida)',
          onTap: () async {
            await _guardarRespaldoAhora();
            if (!mounted) return;
            setState(() {});
          },
        ),

        const SizedBox(height: 12),

        _menuItem(
          selected: false,
          icon: Icons.download_outlined,
          title: 'Copia de seguridad',
          subtitle: 'Exporta todo a CSV',
          onTap: () async {
            final path = await CopiaSeguridad.crearCopiaCompleta();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copia creada: $path')),
            );
          },
        ),
        const Divider(height: 1),
        _menuItem(
          selected: false,
          icon: Icons.share,
          title: 'Compartir copia',
          subtitle: 'Crea un ZIP y lo comparte',
          onTap: () async {
            final zipPath = await CopiaSeguridad.crearZipDeCopiaCompleta();
            await Share.shareXFiles([XFile(zipPath)], text: 'Copia de seguridad (ZIP)');
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
          child: Text('Elegí una opción', style: Theme.of(context).textTheme.titleMedium),
        );
    }
  }

  // móvil: cards como las demás pantallas (pero con menos “saltos” visuales)
  Widget _mobileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    IconData? trailingIcon,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(trailingIcon ?? Icons.chevron_right),
        onTap: onTap,
      ),
    );
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
                  _mobileTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Ventas por día',
                    subtitle: 'Últimos 14 días + consumo 30 días',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReporteVentasPantalla()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.inventory_outlined,
                    title: 'Reposición',
                    subtitle: 'Por mínimo o por combo objetivo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReporteReposicionPantalla()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.percent_outlined,
                    title: 'Margen por combo',
                    subtitle: 'Ganancia y % sobre costo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReporteMargenPantalla()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.restore,
                    title: 'Restaurar desde respaldo',
                    subtitle: 'Elegís carpeta, restaura y reinicia',
                    trailingIcon: Icons.restore,
                    onTap: _restaurarYReiniciar,
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.tune,
                    title: 'Configuración',
                    subtitle: _resumenConfig(),
                    trailingIcon: Icons.tune,
                    onTap: _abrirConfiguracion,
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.folder_open,
                    title: 'Carpeta de respaldo',
                    subtitle: _resumenRespaldo(),
                    trailingIcon: Icons.folder_open,
                    onTap: _elegirCarpetaRespaldo,
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.save,
                    title: 'Guardar respaldo ahora',
                    subtitle: 'DB + fotos (en la carpeta elegida)',
                    trailingIcon: Icons.save,
                    onTap: _guardarRespaldoAhora,
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.download_outlined,
                    title: 'Copia de seguridad',
                    subtitle: 'Exporta todo a CSV',
                    onTap: () async {
                      final path = await CopiaSeguridad.crearCopiaCompleta();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copia creada: $path')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.share,
                    title: 'Compartir copia',
                    subtitle: 'Crea un ZIP y lo comparte',
                    trailingIcon: Icons.share,
                    onTap: () async {
                      final zipPath = await CopiaSeguridad.crearZipDeCopiaCompleta();
                      await Share.shareXFiles([XFile(zipPath)], text: 'Copia de seguridad (ZIP)');
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxPageWidth),
            child: Row(
              children: [
                SizedBox(
                  width: _kMenuWidth,
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: _menuList(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: _panelDerecho(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}