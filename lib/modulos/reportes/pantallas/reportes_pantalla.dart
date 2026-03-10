// lib/modulos/reportes/pantallas/reportes_pantalla.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';
import 'package:gestion_de_asistencias/aplicacion/widgets/tablet_master_detail_layout.dart';
import 'package:gestion_de_asistencias/infraestructura/dep_inyeccion/proveedores.dart';
import 'package:gestion_de_asistencias/infraestructura/servicios/copia_seguridad.dart';
import 'package:gestion_de_asistencias/infraestructura/servicios/respaldo_local.dart';
import 'package:gestion_de_asistencias/infraestructura/servicios/restart_widget.dart';

import 'reporte_ventas_pantalla.dart';
import 'reporte_reposicion_pantalla.dart';
import 'reporte_margen_pantalla.dart';

class ReportesPantalla extends StatefulWidget {
  const ReportesPantalla({super.key});

  @override
  State<ReportesPantalla> createState() => _ReportesPantallaState();
}

class _ReportesPantallaState extends State<ReportesPantalla> {
  static const double _kTablet = LayoutApp.kTablet;
  static const int _kSelVentas = 0;
  static const int _kSelReposicion = 1;
  static const int _kSelMargen = 2;
  static const int _kSelRespaldo = 3;

  // sheets prolijos (no gigantones)
  static const double _kMaxSheetWidth = 620;

  String _nombreNegocio = 'Mi negocio';
  String _moneda = r'$';
  String _notaVenta = '';
  Uri? _treeUri;

  int? _sel;
  bool _respaldoGuardadoReciente = false;
  bool _sincronizandoRestauracion = false;
  bool _chequeandoRespaldo = false;
  RespaldoInspeccion? _ultimoChequeoRespaldo;
  String? _ultimoResumenReparaciones;

  // Mantener opciones legacy disponibles en codigo, pero ocultas al usuario.
  bool get _mostrarOpcionesAvanzadasRespaldo => false;

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
    final messenger = ScaffoldMessenger.of(context);
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

    messenger.showSnackBar(
      const SnackBar(content: Text('Configuracion guardada')),
    );
  }

  bool _esTabletUI(BuildContext context) =>
      MediaQuery.of(context).size.width >= _kTablet;

  bool _esTabletCompactUI(BuildContext context) =>
      _esTabletUI(context) && MediaQuery.of(context).size.width < 1080;

  Widget _sheetWrap(BuildContext context, Widget child) {
    final esTablet = _esTabletUI(context);
    if (!esTablet) return child;

    final media = MediaQuery.of(context);
    final maxH = (media.size.height * 0.48).clamp(240.0, 440.0);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          widthFactor: 1,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _kMaxSheetWidth,
              maxHeight: maxH,
            ),
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
    final esTablet = _esTabletUI(context);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      showDragHandle: !esTablet,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _sheetWrap(
          context,
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Configuracion',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del negocio',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: monedaCtrl,
                    decoration: const InputDecoration(
                      labelText: r'Simbolo de moneda (ej: $, ARS, EUR)',
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
          ),
        );
      },
    );

    if (ok != true) return;

    final nombre = nombreCtrl.text.trim().isEmpty
        ? 'Mi negocio'
        : nombreCtrl.text.trim();
    final moneda = monedaCtrl.text.trim().isEmpty
        ? r'$'
        : monedaCtrl.text.trim();
    final nota = notaCtrl.text.trim();

    await _guardarConfig(
      nombreNegocio: nombre,
      moneda: moneda,
      notaVenta: nota,
    );
  }

  String _resumenConfig() {
    final nota = _notaVenta.trim();
    final notaTxt = nota.isEmpty ? 'sin nota' : 'con nota';
    return '$_nombreNegocio - moneda $_moneda - $notaTxt';
  }

  String _resumenRespaldo() {
    final s = _treeUri?.toString() ?? '';
    return s.trim().isEmpty ? 'No elegida' : 'Elegida';
  }

  Future<void> _elegirCarpetaRespaldo() async {
    final uri = await RespaldoLocal.elegirDirectorio();
    if (!mounted) return;

    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se eligio carpeta')));
      return;
    }

    setState(() {
      _treeUri = uri;
      _respaldoGuardadoReciente = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carpeta de respaldo guardada')),
    );
  }

  Future<void> _guardarRespaldoAhora() async {
    final ok = await RespaldoLocal.guardarRespaldoAhora();
    if (!mounted) return;
    setState(() => _respaldoGuardadoReciente = ok);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Respaldo guardado en la carpeta elegida'
              : 'No se pudo guardar (primero elegi carpeta)',
        ),
      ),
    );

    await _cargarConfig();
  }

  Future<void> _verificarRespaldo() async {
    final tree = _treeUri ?? await RespaldoLocal.elegirDirectorio();
    if (tree == null) return;

    if (mounted) {
      setState(() {
        _treeUri = tree;
        _chequeandoRespaldo = true;
      });
    }

    try {
      final info = await RespaldoLocal.inspeccionarRespaldoDesdeTreeUri(tree);
      if (!mounted) return;

      setState(() {
        _ultimoChequeoRespaldo = info;
      });

      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            info.valido
                ? (info.tieneAdvertencias
                      ? 'Chequeo completado con advertencias'
                      : 'Chequeo correcto: respaldo valido')
                : 'Chequeo fallido: respaldo invalido',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _chequeandoRespaldo = false);
      }
    }
  }

  Future<bool> _confirmarAdvertenciasRespaldo(RespaldoInspeccion info) async {
    if (!info.tieneAdvertencias) return true;

    final seguir = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Advertencias en el respaldo'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.resumenCorto),
              const SizedBox(height: 8),
              for (final w in info.advertencias) ...[
                Text('- $w'),
                const SizedBox(height: 4),
              ],
              const SizedBox(height: 6),
              const Text(
                'Podes continuar, pero algunos datos (por ejemplo fotos o prefs) podrian no restaurarse.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );

    return seguir == true;
  }

  Future<void> _mostrarErroresChequeo(RespaldoInspeccion info) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Respaldo invalido'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.resumenCorto),
              const SizedBox(height: 8),
              for (final e in info.errores) ...[
                Text('- $e'),
                const SizedBox(height: 4),
              ],
              if (info.advertencias.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text('Advertencias:'),
                const SizedBox(height: 4),
                for (final w in info.advertencias) ...[
                  Text('- $w'),
                  const SizedBox(height: 4),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<_ResultadoReparacionesRestauracion>
  _aplicarReparacionesPostRestore() async {
    try {
      final stockReparado = await Proveedores.pedidosRepositorio
          .repararStockDeCanceladosRetroactivo();
      final ventasMarcadas = await Proveedores.pedidosRepositorio
          .marcarVentasDePedidosCanceladosRetroactivo();

      return _ResultadoReparacionesRestauracion(
        stockReparado: stockReparado,
        ventasMarcadas: ventasMarcadas,
      );
    } catch (_) {
      return const _ResultadoReparacionesRestauracion(
        stockReparado: 0,
        ventasMarcadas: 0,
        error: 'No se pudo completar la reparacion retroactiva.',
      );
    }
  }

  Future<void> _restaurarYReiniciar() async {
    var dependenciasCerradas = false;
    if (mounted) {
      setState(() {
        _sincronizandoRestauracion = true;
        _ultimoResumenReparaciones = null;
      });
    }
    try {
      final tree = await RespaldoLocal.elegirDirectorio();
      if (tree == null) return;
      if (mounted) setState(() => _treeUri = tree);

      final chequeo = await RespaldoLocal.inspeccionarRespaldoDesdeTreeUri(
        tree,
      );
      if (!mounted) return;
      setState(() => _ultimoChequeoRespaldo = chequeo);

      if (!chequeo.valido) {
        await _mostrarErroresChequeo(chequeo);
        return;
      }

      final continuar = await _confirmarAdvertenciasRespaldo(chequeo);
      if (!continuar) return;

      // Cerramos la DB antes de sobreescribir el archivo sqlite restaurado.
      await Proveedores.cerrarDependencias();
      dependenciasCerradas = true;

      final ok = await RespaldoLocal.restaurarAhoraDesdeTreeUri(tree);
      await Proveedores.recrearDependencias();
      dependenciasCerradas = false;

      final reparaciones = await _aplicarReparacionesPostRestore();
      if (!mounted) return;
      setState(() => _ultimoResumenReparaciones = reparaciones.resumen);

      if (reparaciones.huboCambios) {
        Proveedores.notificarDatosActualizados(mensaje: reparaciones.resumen);
      }

      await _cargarConfig();
      if (!mounted) return;

      if (!ok) {
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('No encontro el respaldo'),
            content: const Text('En esa carpeta no hay un respaldo valido.'),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reparaciones.error == null
                ? 'Restauracion completa. ${reparaciones.resumen}'
                : 'Restauracion completa. ${reparaciones.error}',
          ),
        ),
      );

      final reiniciar = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Restauracion lista'),
          content: const Text(
            'Los datos ya se sincronizaron. Si queres, reinicia para limpieza total de memoria.',
          ),
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
      if (dependenciasCerradas) {
        try {
          await Proveedores.recrearDependencias();
        } catch (_) {}
      }
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
    } finally {
      if (mounted) {
        setState(() => _sincronizandoRestauracion = false);
      }
    }
  }

  // -------- estilo lista "ventas" (sin bordes fuertes) --------

  Widget _menuHeader() {
    final cs = Theme.of(context).colorScheme;
    final compact = _esTabletCompactUI(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withValues(alpha: 0.08), Colors.transparent],
        ),
      ),
      child: Card(
        color: cs.surfaceContainerLow,
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 20 : 22,
                backgroundColor: cs.surfaceContainerHighest,
                child: Icon(
                  Icons.bar_chart_outlined,
                  color: cs.onSurfaceVariant,
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportes',
                      style: compact
                          ? Theme.of(context).textTheme.titleMedium
                          : Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _resumenConfig(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _abrirConfiguracion,
                icon: const Icon(Icons.tune),
                tooltip: 'Configuracion',
                visualDensity: compact ? VisualDensity.compact : null,
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
    final compact = _esTabletCompactUI(context);
    final bgSel = cs.primary.withValues(alpha: 0.10);
    final fg = warn ? cs.error : cs.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 3,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 10,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: selected ? bgSel : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.28)
                : cs.outlineVariant.withValues(alpha: 0.34),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: compact ? 18 : 20,
              backgroundColor: selected
                  ? cs.primary.withValues(alpha: 0.14)
                  : cs.surfaceContainerHighest,
              child: Icon(icon, color: selected ? cs.primary : fg),
            ),
            SizedBox(width: compact ? 8 : 10),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 6 : 8),
            Icon(
              selected ? Icons.arrow_forward_ios_rounded : Icons.chevron_right,
              size: selected ? (compact ? 14 : 16) : (compact ? 18 : 20),
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuSectionLabel({
    required String title,
    required String subtitle,
    IconData icon = Icons.label_outline,
  }) {
    final cs = Theme.of(context).colorScheme;
    final compact = _esTabletCompactUI(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(12, compact ? 4 : 6, 12, compact ? 6 : 8),
      child: Row(
        children: [
          Container(
            width: compact ? 24 : 28,
            height: compact ? 24 : 28,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: compact ? 14 : 16, color: cs.primary),
          ),
          SizedBox(width: compact ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoChip({
    required String text,
    required bool activo,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final compact = _esTabletCompactUI(context);
    final fg = activo ? cs.primary : cs.onSurfaceVariant;
    final bg = activo
        ? cs.primary.withValues(alpha: 0.14)
        : cs.surfaceContainerHighest;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 9,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: fg),
          SizedBox(width: compact ? 4 : 5),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accionRapida({
    required String tooltip,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool primario = false,
  }) {
    final btn = primario
        ? FilledButton.tonalIcon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
          );

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(message: tooltip, child: btn),
    );
  }

  Widget _botonesGrid({
    required List<Widget> botones,
    int maxColumnas = 3,
    double minAnchoBoton = 172,
    double spacing = 8,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < botones.length; i++) ...[
                botones[i],
                if (i != botones.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        final colsEstimadas = (constraints.maxWidth / minAnchoBoton).floor();
        final columnas = colsEstimadas.clamp(1, maxColumnas);
        final totalSpacing = spacing * (columnas - 1);
        final anchoCelda = ((constraints.maxWidth - totalSpacing) / columnas)
            .clamp(0.0, constraints.maxWidth);
        final resto = botones.length % columnas;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < botones.length; i++)
              SizedBox(
                width: (resto == 1 && columnas > 1 && i == botones.length - 1)
                    ? constraints.maxWidth
                    : anchoCelda,
                child: botones[i],
              ),
          ],
        );
      },
    );
  }

  Widget _accionesRapidasCard({required bool enMobile}) {
    final compact = !enMobile && _esTabletCompactUI(context);
    void abrirVentas() {
      if (enMobile) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReporteVentasPantalla()),
        );
        return;
      }
      setState(() => _sel = _kSelVentas);
    }

    void abrirReposicion() {
      if (enMobile) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReporteReposicionPantalla()),
        );
        return;
      }
      setState(() => _sel = _kSelReposicion);
    }

    void abrirMargen() {
      if (enMobile) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReporteMargenPantalla()),
        );
        return;
      }
      setState(() => _sel = _kSelMargen);
    }

    void abrirRespaldo() {
      if (enMobile) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La seccion de respaldo esta mas abajo en esta vista',
            ),
          ),
        );
        return;
      }
      setState(() => _sel = _kSelRespaldo);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones rapidas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _botonesGrid(
              maxColumnas: enMobile ? 1 : 2,
              minAnchoBoton: compact ? 150 : 170,
              spacing: compact ? 6 : 8,
              botones: [
                _accionRapida(
                  tooltip: 'Abrir reporte de ventas por dia',
                  icon: Icons.calendar_month_outlined,
                  label: 'Ventas',
                  onTap: abrirVentas,
                  primario: true,
                ),
                _accionRapida(
                  tooltip: 'Abrir reporte de reposicion',
                  icon: Icons.inventory_outlined,
                  label: 'Reposicion',
                  onTap: abrirReposicion,
                  primario: true,
                ),
                _accionRapida(
                  tooltip: 'Abrir reporte de margen',
                  icon: Icons.percent_outlined,
                  label: 'Margen',
                  onTap: abrirMargen,
                ),
                _accionRapida(
                  tooltip: 'Abrir panel de respaldo y restauracion',
                  icon: Icons.restore_page_outlined,
                  label: 'Respaldo',
                  onTap: abrirRespaldo,
                ),
                _accionRapida(
                  tooltip: 'Abrir configuracion del negocio',
                  icon: Icons.tune,
                  label: 'Configuracion',
                  onTap: _abrirConfiguracion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _respaldoAccionesCard({required bool enMobile}) {
    final cs = Theme.of(context).colorScheme;
    final compact = !enMobile && _esTabletCompactUI(context);
    final elegida = (_treeUri?.toString() ?? '').trim().isNotEmpty;
    final paso1Ok = elegida;
    final paso2Ok = _respaldoGuardadoReciente;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: cs.surface,
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_chequeandoRespaldo) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                'Chequeando respaldo...',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
            ],
            if (_sincronizandoRestauracion) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              Text(
                'Sincronizando datos restaurados...',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                CircleAvatar(
                  radius: compact ? 16 : 18,
                  backgroundColor: elegida
                      ? cs.primary.withValues(alpha: 0.14)
                      : cs.surfaceContainerHighest,
                  child: Icon(
                    Icons.shield_outlined,
                    size: compact ? 16 : 18,
                    color: elegida ? cs.primary : cs.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: compact ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Respaldo y restauracion',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        elegida
                            ? 'Ubicacion configurada'
                            : 'Falta elegir ubicacion de respaldo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Estado: ${_resumenRespaldo()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: compact ? 6 : 8,
              runSpacing: compact ? 6 : 8,
              children: [
                _estadoChip(
                  text: compact ? '1 listo' : 'Paso 1 listo',
                  activo: paso1Ok,
                  icon: paso1Ok ? Icons.check_circle : Icons.looks_one_rounded,
                ),
                _estadoChip(
                  text: compact ? '2 listo' : 'Paso 2 listo',
                  activo: paso2Ok,
                  icon: paso2Ok ? Icons.check_circle : Icons.looks_two_rounded,
                ),
                _estadoChip(
                  text: 'Restaurar directo',
                  activo: false,
                  icon: Icons.restore,
                ),
              ],
            ),
            if (_ultimoChequeoRespaldo != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _ultimoChequeoRespaldo!.valido
                      ? cs.primary.withValues(alpha: 0.08)
                      : cs.error.withValues(alpha: 0.08),
                  border: Border.all(
                    color: _ultimoChequeoRespaldo!.valido
                        ? cs.primary.withValues(alpha: 0.22)
                        : cs.error.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ultimoChequeoRespaldo!.valido
                          ? 'Chequeo de respaldo: OK'
                          : 'Chequeo de respaldo: con errores',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _ultimoChequeoRespaldo!.resumenCorto,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (_ultimoChequeoRespaldo!.advertencias.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Advertencias: ${_ultimoChequeoRespaldo!.advertencias.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_ultimoChequeoRespaldo!.errores.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Errores: ${_ultimoChequeoRespaldo!.errores.length}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: cs.error),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if ((_ultimoResumenReparaciones ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cs.surfaceContainerHighest,
                ),
                child: Text(
                  _ultimoResumenReparaciones!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Flujo A: elegir ubicacion y crear respaldo. Flujo B: restaurar directo desde carpeta.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            _botonesGrid(
              maxColumnas: enMobile ? 1 : 2,
              minAnchoBoton: compact ? 150 : 170,
              spacing: compact ? 6 : 8,
              botones: [
                OutlinedButton.icon(
                  onPressed: (_sincronizandoRestauracion || _chequeandoRespaldo)
                      ? null
                      : () async {
                          await _elegirCarpetaRespaldo();
                          if (!mounted) return;
                          setState(() {});
                        },
                  icon: const Icon(Icons.folder_open),
                  label: Text(
                    (enMobile || compact)
                        ? 'Paso 1: Ubicacion'
                        : 'Paso 1: Elegir ubicacion',
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: (_sincronizandoRestauracion || _chequeandoRespaldo)
                      ? null
                      : () async {
                          await _guardarRespaldoAhora();
                          if (!mounted) return;
                          setState(() {});
                        },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Paso 2: Crear respaldo'),
                ),
                OutlinedButton.icon(
                  onPressed: (_sincronizandoRestauracion || _chequeandoRespaldo)
                      ? null
                      : () async {
                          await _verificarRespaldo();
                          if (!mounted) return;
                          setState(() {});
                        },
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verificar respaldo'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.errorContainer,
                    foregroundColor: cs.onErrorContainer,
                  ),
                  onPressed: (_sincronizandoRestauracion || _chequeandoRespaldo)
                      ? null
                      : () async {
                          await _restaurarYReiniciar();
                          if (!mounted) return;
                          setState(() {});
                        },
                  icon: const Icon(Icons.restore),
                  label: const Text('Restaurar directo'),
                ),
              ],
            ),
            if (_mostrarOpcionesAvanzadasRespaldo) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final path = await CopiaSeguridad.crearCopiaCompleta();
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Copia creada: $path')),
                      );
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Copia CSV'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final zipPath =
                          await CopiaSeguridad.crearZipDeCopiaCompleta();
                      await Share.shareXFiles([
                        XFile(zipPath),
                      ], text: 'Copia de seguridad (ZIP)');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir ZIP'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuList() {
    final compact = _esTabletCompactUI(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _menuHeader(),
        SizedBox(height: compact ? 10 : 12),
        _accionesRapidasCard(enMobile: false),
        SizedBox(height: compact ? 10 : 12),
        _menuSectionLabel(
          title: 'Analitica',
          subtitle: 'Elegi un reporte para ver en detalle',
          icon: Icons.analytics_outlined,
        ),

        _menuItem(
          selected: _sel == _kSelVentas,
          icon: Icons.calendar_month_outlined,
          title: 'Ventas por dia',
          subtitle: 'Ultimos 14 dias + consumo 30 dias',
          onTap: () => setState(() => _sel = _kSelVentas),
        ),
        _menuItem(
          selected: _sel == _kSelReposicion,
          icon: Icons.inventory_outlined,
          title: 'Reposicion',
          subtitle: 'Por minimo o por combo objetivo',
          onTap: () => setState(() => _sel = _kSelReposicion),
        ),
        _menuItem(
          selected: _sel == _kSelMargen,
          icon: Icons.percent_outlined,
          title: 'Margen por combo',
          subtitle: 'Ganancia y % sobre costo',
          onTap: () => setState(() => _sel = _kSelMargen),
        ),
        SizedBox(height: compact ? 10 : 12),
        _menuSectionLabel(
          title: 'Respaldo',
          subtitle: 'Guardado y restauracion de datos',
          icon: Icons.shield_outlined,
        ),
        _menuItem(
          selected: _sel == _kSelRespaldo,
          icon: Icons.restore_page_outlined,
          title: 'Respaldo y restauracion',
          subtitle: 'Elegir carpeta, guardar y restaurar',
          onTap: () => setState(() => _sel = _kSelRespaldo),
        ),
      ],
    );
  }

  Widget _panelDerecho({required int datosVersion}) {
    final compact = _esTabletCompactUI(context);
    return switch (_sel) {
      _kSelVentas => ReporteVentasPantalla(
        key: ValueKey('reporte_ventas_v$datosVersion'),
        embebido: true,
      ),
      _kSelReposicion => ReporteReposicionPantalla(
        key: ValueKey('reporte_reposicion_v$datosVersion'),
        embebido: true,
      ),
      _kSelMargen => ReporteMargenPantalla(
        key: ValueKey('reporte_margen_v$datosVersion'),
        embebido: true,
      ),
      _kSelRespaldo => SingleChildScrollView(
        padding: EdgeInsets.all(compact ? 10 : 12),
        child: _respaldoAccionesCard(enMobile: false),
      ),
      _ => Center(
        child: Text(
          'Elegi una opcion',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    };
  }

  // movil: cards como las demas pantallas (pero con menos "saltos" visuales)
  Widget _mobileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    IconData? trailingIcon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: cs.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                trailingIcon ?? Icons.chevron_right,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
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
                  _accionesRapidasCard(enMobile: true),
                  const SizedBox(height: 12),
                  _menuSectionLabel(
                    title: 'Analitica',
                    subtitle: 'Reportes principales del negocio',
                    icon: Icons.analytics_outlined,
                  ),
                  _mobileTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Ventas por dia',
                    subtitle: 'Ultimos 14 dias + consumo 30 dias',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReporteVentasPantalla(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.inventory_outlined,
                    title: 'Reposicion',
                    subtitle: 'Por minimo o por combo objetivo',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReporteReposicionPantalla(),
                        ),
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
                        MaterialPageRoute(
                          builder: (_) => const ReporteMargenPantalla(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _menuSectionLabel(
                    title: 'Respaldo',
                    subtitle: 'Segui estos pasos para guardar o restaurar',
                    icon: Icons.shield_outlined,
                  ),
                  _respaldoAccionesCard(enMobile: true),
                  const SizedBox(height: 8),
                  _mobileTile(
                    icon: Icons.tune,
                    title: 'Configuracion',
                    subtitle: _resumenConfig(),
                    trailingIcon: Icons.tune,
                    onTap: _abrirConfiguracion,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: TabletMasterDetailLayout.kPagePadding,
          child: TabletMasterDetailLayout(
            master: Material(
              color: Theme.of(context).colorScheme.surface,
              child: _menuList(),
            ),
            detail: Card(
              clipBehavior: Clip.antiAlias,
              child: ValueListenableBuilder<int>(
                valueListenable: Proveedores.datosVersion,
                builder: (context, version, _) {
                  return _panelDerecho(datosVersion: version);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultadoReparacionesRestauracion {
  final int stockReparado;
  final int ventasMarcadas;
  final String? error;

  const _ResultadoReparacionesRestauracion({
    required this.stockReparado,
    required this.ventasMarcadas,
    this.error,
  });

  bool get huboCambios => stockReparado > 0 || ventasMarcadas > 0;

  String get resumen {
    if ((error ?? '').trim().isNotEmpty) return error!.trim();
    if (!huboCambios) {
      return 'Chequeo retroactivo: no hizo falta reparar pedidos/ventas.';
    }
    return 'Reparaciones aplicadas: stock revertido en $stockReparado pedido(s) y ventas marcadas en $ventasMarcadas pedido(s).';
  }
}
