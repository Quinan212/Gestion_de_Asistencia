import 'dart:io';

import 'package:flutter/material.dart';
import '../modelos/producto.dart';

class ProductoCuadro extends StatelessWidget {
  final Producto producto;
  final double stock;
  final VoidCallback alTocar;

  const ProductoCuadro({
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

    return InkWell(
      onTap: alTocar,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: tieneImagen
                      ? Image.file(
                    File(ruta),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                      : Container(
                    alignment: Alignment.center,
                    child: Icon(
                      enFalta ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                      color: color,
                      size: 46,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                producto.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${stock.toStringAsFixed(2)} ${producto.unidad}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}