import 'package:flutter/material.dart';

class LayoutApp {
  LayoutApp._();

  static const double kTablet = 900;
  static const double kNavigationTablet = 700;
  static const double kRailExtendida = 1280;
  static const double kMaxPageWidth = 1120;

  static const EdgeInsets kPagePadding = EdgeInsets.fromLTRB(8, 12, 8, 12);

  static bool esTablet(double width) => width >= kTablet;
}
