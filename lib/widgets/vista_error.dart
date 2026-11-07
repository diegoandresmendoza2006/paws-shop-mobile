import 'package:flutter/material.dart';

/// Mensaje de error con botón "Reintentar".
class VistaError extends StatelessWidget {
  final String mensaje;
  final VoidCallback alReintentar;
  const VistaError({super.key, required this.mensaje, required this.alReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: alReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
