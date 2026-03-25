import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'estilos_aplicacion.dart';

ThemeData temaSuiteClaro() {
  final esWindows = defaultTargetPlatform == TargetPlatform.windows;
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: EstilosAplicacion.marca,
        brightness: Brightness.light,
      ).copyWith(
        primary: EstilosAplicacion.marca,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFDCECF5),
        onPrimaryContainer: const Color(0xFF04253A),
        secondary: EstilosAplicacion.acento,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFDCE4FF),
        onSecondaryContainer: const Color(0xFF152A64),
        surface: EstilosAplicacion.fondoClaro,
        surfaceContainerLowest: EstilosAplicacion.superficieClaro,
        surfaceContainerLow: const Color(0xFFFFFFFF),
        surfaceContainer: const Color(0xFFF8FAFC),
        surfaceContainerHigh: const Color(0xFFF1F5F9),
        surfaceContainerHighest: const Color(0xFFE7EEF5),
        outline: const Color(0xFF6B7280),
        outlineVariant: EstilosAplicacion.bordeClaro,
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    fontFamily: 'Inter',
  );
  final cs = base.colorScheme;
  final densidad = esWindows ? VisualDensity.compact : VisualDensity.standard;

  var texto = base.textTheme.copyWith(
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.05,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.05,
    ),
    titleSmall: base.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    labelMedium: base.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
    ),
  );

  return base.copyWith(
    visualDensity: densidad,
    materialTapTargetSize: esWindows
        ? MaterialTapTargetSize.shrinkWrap
        : MaterialTapTargetSize.padded,
    textTheme: texto,
    primaryTextTheme: texto,
    scaffoldBackgroundColor: cs.surface,
    canvasColor: cs.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: texto.titleLarge?.copyWith(color: cs.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: EstilosAplicacion.radioPanel,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.92)),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(
      color: cs.outlineVariant.withValues(alpha: 0.75),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: EstilosAplicacion.radioSuave,
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: EstilosAplicacion.radioSuave,
        borderSide: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.95),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: EstilosAplicacion.radioSuave,
        borderSide: BorderSide(color: cs.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
      isDense: esWindows,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 44),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: EstilosAplicacion.radioSuave,
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: cs.surfaceContainerLowest.withValues(alpha: 0.72),
        foregroundColor: cs.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(
          borderRadius: EstilosAplicacion.radioSuave,
        ),
        backgroundColor: cs.surfaceContainerLowest.withValues(alpha: 0.78),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.95)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      selectedColor: cs.primary.withValues(alpha: 0.12),
      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.9)),
      labelStyle: TextStyle(color: cs.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      indicatorColor: cs.secondaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      selectedIconTheme: IconThemeData(color: cs.primary),
      selectedLabelTextStyle: TextStyle(
        color: cs.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: cs.onSurfaceVariant),
      groupAlignment: -0.9,
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(cs.surfaceContainerHighest),
      headingTextStyle: texto.titleSmall?.copyWith(color: cs.onSurface),
      dataTextStyle: texto.bodyMedium,
      horizontalMargin: 10,
      columnSpacing: 14,
      dividerThickness: 1,
    ),
    listTileTheme: ListTileThemeData(
      dense: esWindows,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: cs.onSurfaceVariant,
      selectedTileColor: cs.primary.withValues(alpha: 0.09),
      selectedColor: cs.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: EstilosAplicacion.radioPanel,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.75)),
      ),
      titleTextStyle: texto.titleLarge?.copyWith(color: cs.onSurface),
      contentTextStyle: texto.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: EstilosAplicacion.radioSuave,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      textStyle: texto.bodyMedium,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLowest),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: EstilosAplicacion.radioSuave,
            side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
          ),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF22262D),
      contentTextStyle: texto.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      actionTextColor: const Color(0xFF9DC4FF),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: const WidgetStatePropertyAll(true),
      trackVisibility: const WidgetStatePropertyAll(false),
      thickness: const WidgetStatePropertyAll(10),
      radius: const Radius.circular(8),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.dragged)) {
          return cs.primary.withValues(alpha: 0.85);
        }
        return cs.outline.withValues(alpha: 0.55);
      }),
      interactive: true,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      iconColor: cs.onSurfaceVariant,
      collapsedIconColor: cs.onSurfaceVariant,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(color: cs.onInverseSurface),
      waitDuration: const Duration(milliseconds: 350),
      preferBelow: false,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
