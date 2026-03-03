import 'package:flutter/material.dart';

class ComboTarjeta extends StatelessWidget {
  const ComboTarjeta({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Nombre del Combo'),
        subtitle: Text('Precio: \$0.00'),
      ),
    );
  }
}
