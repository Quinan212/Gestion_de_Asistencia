import 'package:flutter/material.dart';

class ComponenteFila extends StatelessWidget {
  const ComponenteFila({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text('Producto del combo'),
        Spacer(),
        Text('x1'),
      ],
    );
  }
}
