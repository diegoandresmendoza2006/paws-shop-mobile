import 'package:flutter/material.dart';

/// Los dos botones de cada tarjeta de gestión: «Editar» y «Eliminar» (en rojo).
class BotonesGestion extends StatelessWidget {
  final VoidCallback alEditar;
  final VoidCallback? alEliminar;

  const BotonesGestion({super.key, required this.alEditar, this.alEliminar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: alEditar,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Editar'),
          ),
        ),
        if (alEliminar != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: alEliminar,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB71C1C),
                side: const BorderSide(color: Color(0xFFB71C1C)),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar'),
            ),
          ),
        ],
      ],
    );
  }
}
