import 'package:flutter/material.dart';

ThemeData temaSuiteClaro() {
  const seed = Color(0xFF1A73E8); // acento tipo Google (sin volverse chillón)

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
  );

  final cs = base.colorScheme;

  final r12 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  final r16 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

  TextTheme t = base.textTheme.copyWith(
    titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    labelMedium: base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    labelSmall: base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
  );

  return base.copyWith(
    textTheme: t,

    scaffoldBackgroundColor: cs.surface,

    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: r16,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
    ),

    dividerTheme: DividerThemeData(
      color: cs.outlineVariant.withValues(alpha: 0.6),
      thickness: 1,
      space: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.9)),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        shape: r12,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
        shape: r12,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: r12,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: cs.surfaceContainerLow,
      selectedColor: cs.primary.withValues(alpha: 0.14),
      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.55)),
      labelStyle: TextStyle(color: cs.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: const StadiumBorder(),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cs.surface,
      indicatorColor: cs.secondaryContainer,
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}