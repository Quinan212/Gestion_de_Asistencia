import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
import '../modelos/producto.dart';

class ProductoTarjeta extends StatelessWidget {
  final Producto producto;
  final double stock;
  final VoidCallback alTocar;

  const ProductoTarjeta({
    super.key,
    required this.producto,
    required this.stock,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final enFalta = stock < producto.stockMinimo;
    final color = enFalta ? theme.colorScheme.error : theme.colorScheme.primary;

    final ruta = (producto.imagen ?? '').trim();
    final tieneImagen = ruta.isNotEmpty && File(ruta).existsSync();

    Widget miniatura() {
      if (tieneImagen) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(ruta),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        );
      }

      return Icon(
        enFalta ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: color,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: ListTile(
        onTap: alTocar,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minLeadingWidth: 52,
        leading: miniatura(),
        title: Text(
          producto.nombreConVariante,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${Formatos.cantidad(stock, unidad: producto.unidad)} ${producto.unidad}',
        ),
        trailing: Icon(Icons.chevron_right, color: color),
      ),
    );
  }
}
