import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/favoritos_bloc.dart';
import '../bloc/favoritos_event.dart';
import '../models/mascota.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/fila_dato.dart';
import '../widgets/foto_mascota.dart';
import '../widgets/tarjeta_refugio.dart';
import 'solicitud_page.dart';

/// Detalle de una mascota. El botón "Quiero adoptar" solo lo ve un usuario y solo si está disponible.
class DetalleMascotaPage extends StatelessWidget {
  final Mascota mascota;
  const DetalleMascotaPage({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    final estadoSesion = context.watch<AuthBloc>().state;
    final esUsuario = estadoSesion is AuthAutenticado && estadoSesion.sesion.usuario.esUsuario;
    final disponible = mascota.estadoAdopcion == 'Disponible';
    final tieneRaza = mascota.raza != null && mascota.raza!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(mascota.nombre),
        actions: [
          if (esUsuario)
            Builder(builder: (context) {
              final favorita = context.select<FavoritosBloc, bool>(
                  (b) => b.state.esMascotaFavorita(mascota.id));
              return IconButton(
                tooltip: favorita ? 'Quitar de favoritos' : 'Agregar a favoritos',
                icon: Icon(favorita ? Icons.favorite : Icons.favorite_border,
                    color: favorita ? const Color(0xFFD32F2F) : null),
                onPressed: () =>
                    context.read<FavoritosBloc>().add(MascotaAlternada(mascota.id)),
              );
            }),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(aspectRatio: 4 / 3, child: FotoMascota(url: mascota.imagenUrl)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(mascota.nombre,
                          style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    EtiquetaEstado(estado: mascota.estadoAdopcion),
                  ],
                ),
                const SizedBox(height: 12),
                FilaDato(etiqueta: 'Especie', valor: mascota.especie),
                FilaDato(etiqueta: 'Raza', valor: tieneRaza ? mascota.raza : 'Sin raza definida'),
                FilaDato(etiqueta: 'Edad', valor: mascota.edadTexto),
                const SizedBox(height: 12),
                Text('Sobre ${mascota.nombre}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text((mascota.descripcion ?? '').trim().isEmpty
                    ? 'Todavía no tiene una descripción.'
                    : mascota.descripcion!),
                const SizedBox(height: 16),
                TarjetaRefugio(refugioId: mascota.refugioId),
                const SizedBox(height: 24),
                if (esUsuario && disponible)
                  FilledButton.icon(
                    icon: const Icon(Icons.favorite),
                    label: const Text('Quiero adoptar'),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => SolicitudPage(mascota: mascota))),
                  ),
                if (esUsuario && !disponible)
                  Text(
                    mascota.estadoAdopcion == 'Adoptada'
                        ? '${mascota.nombre} ya encontró un hogar.'
                        : '${mascota.nombre} tiene un proceso de adopción en curso.',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
