import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gestion_de_asistencias/aplicacion/utiles/formatos.dart';
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
    final colorEstado = !producto.activo
        ? theme.colorScheme.onSurfaceVariant
        : (enFalta ? theme.colorScheme.error : theme.colorScheme.primary);
    final textoEstado = !producto.activo
        ? 'Inactivo'
        : (enFalta ? 'Bajo minimo' : 'OK');

    final ruta = (producto.imagen ?? '').trim();
    final tieneImagen = ruta.isNotEmpty && File(ruta).existsSync();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: alTocar,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: tieneImagen
                            ? Image.file(File(ruta), fit: BoxFit.cover)
                            : Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 42,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: colorEstado.withValues(alpha: 0.14),
                          border: Border.all(
                            color: colorEstado.withValues(alpha: 0.26),
                          ),
                        ),
                        child: Text(
                          textoEstado,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorEstado,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombreConVariante,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${Formatos.cantidad(stock, unidad: producto.unidad)} ${producto.unidad}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorEstado,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
