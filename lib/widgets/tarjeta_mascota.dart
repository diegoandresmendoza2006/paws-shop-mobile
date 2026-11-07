import 'package:flutter/material.dart';

import '../models/mascota.dart';
import 'etiqueta_estado.dart';
import 'foto_mascota.dart';

/// Una tarjeta de la lista: foto, nombre, raza · edad y el estado con su color.
/// Opcional: corazón de favorito ([esFavorita] + [alAlternarFavorito]) y un widget al final ([acciones]).
class TarjetaMascota extends StatelessWidget {
  final Mascota mascota;
  final VoidCallback? alTocar;
  final bool? esFavorita;
  final VoidCallback? alAlternarFavorito;
  final Widget? acciones;

  const TarjetaMascota({
    super.key,
    required this.mascota,
    this.alTocar,
    this.esFavorita,
    this.alAlternarFavorito,
    this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    final tieneRaza = mascota.raza != null && mascota.raza!.isNotEmpty;
    final subtitulo =
        '${tieneRaza ? mascota.raza! : mascota.especie} · ${mascota.edadTexto}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: Row(
          children: [
            SizedBox(width: 110, height: 110, child: FotoMascota(url: mascota.imagenUrl)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mascota.nombre,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(subtitulo,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    EtiquetaEstado(estado: mascota.estadoAdopcion),
                  ],
                ),
              ),
            ),
            if (esFavorita != null)
              IconButton(
                tooltip: esFavorita! ? 'Quitar de favoritos' : 'Agregar a favoritos',
                icon: Icon(esFavorita! ? Icons.favorite : Icons.favorite_border,
                    color: esFavorita! ? const Color(0xFFD32F2F) : null),
                onPressed: alAlternarFavorito,
              ),
            ?acciones,
          ],
        ),
      ),
    );
  }
}
