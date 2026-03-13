import 'package:flutter/material.dart';

class LayoutApp {
  LayoutApp._();

  static const double kTablet = 900;
  static const double kDesktop = 1180;
  static const double kNavigationTablet = 700;
  static const double kRailExtendida = 1320;
  static const double kMaxPageWidth = 1180;

  static const EdgeInsets kPagePadding = EdgeInsets.fromLTRB(14, 14, 14, 14);

  static bool esTablet(double width) => width >= kTablet;
  static bool esDesktop(double width) => width >= kDesktop;
}
