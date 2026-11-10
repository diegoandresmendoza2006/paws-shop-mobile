import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/catalogos_bloc.dart';
import '../bloc/catalogos_event.dart';
import '../bloc/catalogos_state.dart';
import '../models/refugio.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import 'mostrar_aviso.dart';

/// Muestra a qué refugio pertenece la mascota: nombre, dirección y teléfono,
/// con un botón para ver la dirección en el mapa.
class TarjetaRefugio extends StatelessWidget {
  final int refugioId;
  const TarjetaRefugio({super.key, required this.refugioId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CatalogosBloc(ctx.read<RefugioRepository>(), ctx.read<ProductoRepository>())
        ..add(const CatalogosSolicitados()),
      child: BlocBuilder<CatalogosBloc, CatalogosState>(
        builder: (context, estado) {
          if (estado is CatalogosCargando) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          if (estado is CatalogosError) {
            return Text('No se pudo cargar la información del refugio.',
                style: TextStyle(color: Theme.of(context).colorScheme.error));
          }
          final refugios = (estado as CatalogosCargados).refugios;
          Refugio? refugio;
          for (final r in refugios) {
            if (r.id == refugioId) refugio = r;
          }
          if (refugio == null) return const SizedBox.shrink();
          return _Contenido(refugio: refugio);
        },
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final Refugio refugio;
  const _Contenido({required this.refugio});

  Future<void> _abrirMapa(BuildContext context) async {
    // Con ubicación elegida en el mapa se abre ese punto exacto; si no, se busca por la dirección
    final consulta = refugio.tieneUbicacion
        ? '${refugio.latitud},${refugio.longitud}'
        : '${refugio.nombre} ${refugio.direccion ?? ''}'.trim();
    final uri = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': consulta});
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && context.mounted) {
      mostrarTexto(context, 'No se pudo abrir el mapa.', esError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final direccion = (refugio.direccion ?? '').trim();
    final telefono = (refugio.telefono ?? '').trim();
    return Card(
      margin: EdgeInsets.zero,
      color: tema.colorScheme.secondaryContainer.withAlpha(110),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_work_outlined, color: Color(0xFF28A745)),
                const SizedBox(width: 8),
                Text('Refugio', style: tema.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(refugio.nombre, style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            _Linea(icono: Icons.place_outlined, texto: direccion.isEmpty ? 'Dirección no registrada' : direccion),
            if (telefono.isNotEmpty) _Linea(icono: Icons.phone_outlined, texto: telefono),
            if (direccion.isNotEmpty || refugio.tieneUbicacion)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _abrirMapa(context),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver en el mapa'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Linea({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
      ),
    );
  }
}
