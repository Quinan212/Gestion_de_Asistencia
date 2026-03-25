import 'package:flutter/material.dart';

class CampoComboOpcion<T> {
  final T value;
  final String etiqueta;

  const CampoComboOpcion({required this.value, required this.etiqueta});
}

class CampoCombo<T> extends StatelessWidget {
  final T? value;
  final List<CampoComboOpcion<T>> opciones;
  final ValueChanged<T?>? onChanged;
  final InputDecoration? decoration;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final double menuMaxHeight;

  const CampoCombo({
    super.key,
    required this.value,
    required this.opciones,
    required this.onChanged,
    this.decoration,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.menuMaxHeight = 360,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseDecoration = decoration ?? const InputDecoration();
    final campoDecoration = baseDecoration.copyWith(
      labelText: labelText ?? baseDecoration.labelText,
      hintText: hintText ?? baseDecoration.hintText,
      prefixIcon: prefixIcon ?? baseDecoration.prefixIcon,
    );

    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: menuMaxHeight,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.expand_more_rounded),
      dropdownColor: cs.surfaceContainerLowest,
      decoration: campoDecoration,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
      items: opciones
          .map(
            (opcion) => DropdownMenuItem<T>(
              value: opcion.value,
              child: Text(
                opcion.etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(growable: false),
      selectedItemBuilder: (context) {
        return opciones
            .map(
              (opcion) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  opcion.etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false);
      },
      onChanged: onChanged,
    );
  }
}
