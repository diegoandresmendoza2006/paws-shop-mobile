import 'package:flutter/material.dart';

/// Botón grande «+ Nueva mascota», «+ Nuevo producto»... que va arriba de las listas de gestión.
class BotonNuevo extends StatelessWidget {
  final String texto;
  final VoidCallback alPulsar;

  const BotonNuevo({super.key, required this.texto, required this.alPulsar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: alPulsar,
          icon: const Icon(Icons.add),
          label: Text(texto),
        ),
      ),
    );
  }
}
