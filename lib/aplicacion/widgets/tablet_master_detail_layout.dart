import 'package:flutter/material.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/layout_app.dart';

class TabletMasterDetailLayout extends StatelessWidget {
  static const double kListRatio = 0.52;
  static const double kMinListWidth = 400;
  static const double kMinDetailWidth = 560;
  static const double kDividerWidth = 1;
  static const EdgeInsets kPagePadding = LayoutApp.kPagePadding;
  static const EdgeInsets kMasterPanelPadding = EdgeInsets.only(right: 10);
  static const EdgeInsets kDetailPanelPadding = EdgeInsets.only(left: 10);

  final Widget master;
  final Widget detail;
  final EdgeInsets masterPadding;
  final EdgeInsets detailPadding;
  final double listRatio;
  final double minListWidth;
  final double minDetailWidth;

  const TabletMasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterPadding = kMasterPanelPadding,
    this.detailPadding = kDetailPanelPadding,
    this.listRatio = kListRatio,
    this.minListWidth = kMinListWidth,
    this.minDetailWidth = kMinDetailWidth,
  });

  static double calcularAnchoLista({
    required double totalWidth,
    double listRatio = kListRatio,
    double minListWidth = kMinListWidth,
    double minDetailWidth = kMinDetailWidth,
  }) {
    final usable = totalWidth - kDividerWidth;
    if (usable <= 0) return 0;

    final preferido = usable * listRatio;
    final maxLista = usable - minDetailWidth;

    if (maxLista <= minListWidth) {
      return maxLista > 0 ? maxLista : preferido;
    }

    return preferido.clamp(minListWidth, maxLista);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final anchoLista = calcularAnchoLista(
          totalWidth: c.maxWidth,
          listRatio: listRatio,
          minListWidth: minListWidth,
          minDetailWidth: minDetailWidth,
        );

        return Row(
          children: [
            SizedBox(
              width: anchoLista,
              child: Padding(padding: masterPadding, child: master),
            ),
            const VerticalDivider(width: kDividerWidth),
            Expanded(
              child: Padding(padding: detailPadding, child: detail),
            ),
          ],
        );
      },
    );
  }
}
