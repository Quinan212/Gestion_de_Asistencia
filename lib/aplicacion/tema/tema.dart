import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ThemeData temaSuiteClaro() {
  final esWindows = defaultTargetPlatform == TargetPlatform.windows;
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF005FB8),
        brightness: Brightness.light,
      ).copyWith(
        primary: const Color(0xFF005FB8),
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD6E7FF),
        onPrimaryContainer: const Color(0xFF001B3D),
        secondary: const Color(0xFF365E8D),
        onSecondary: Colors.white,
        surface: const Color(0xFFF2F4F8),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFFCFCFD),
        surfaceContainer: const Color(0xFFF7F8FB),
        surfaceContainerHigh: const Color(0xFFEFF2F7),
        surfaceContainerHighest: const Color(0xFFE7EBF2),
        outline: const Color(0xFF737F8B),
        outlineVariant: const Color(0xFFC4CBD5),
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    fontFamily: esWindows ? 'Segoe UI' : null,
  );
  final cs = base.colorScheme;
  final densidad = esWindows ? VisualDensity.compact : VisualDensity.standard;
  final r8 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
  final r10 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  final r12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

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
    scaffoldBackgroundColor: cs.surface,
    canvasColor: cs.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: cs.surfaceContainerLowest,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: texto.titleLarge?.copyWith(color: cs.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      shape: r12.copyWith(
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.72)),
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
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.95),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
      isDense: esWindows,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 40),
        shape: r10,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        shape: r8,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.95)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: r8,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      selectedColor: cs.primary.withValues(alpha: 0.12),
      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.9)),
      labelStyle: TextStyle(color: cs.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      iconColor: cs.onSurfaceVariant,
      selectedTileColor: cs.primary.withValues(alpha: 0.09),
      selectedColor: cs.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cs.surfaceContainerLowest,
      shape: r12.copyWith(
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.75)),
      ),
      titleTextStyle: texto.titleLarge?.copyWith(color: cs.onSurface),
      contentTextStyle: texto.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: cs.surfaceContainerLowest,
      shape: r10.copyWith(
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
      ),
      textStyle: texto.bodyMedium,
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(cs.surfaceContainerLowest),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          r10.copyWith(
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
        borderRadius: BorderRadius.circular(8),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
