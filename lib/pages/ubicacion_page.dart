import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mapa para elegir la ubicación de un refugio: se toca el mapa para poner el pin y se confirma.
/// Devuelve el punto elegido (LatLng) con Navigator.pop, o null si se cancela.
class UbicacionPage extends StatefulWidget {
  /// Punto con el que abre el mapa (el que ya tenía el refugio, si lo tenía).
  final LatLng? inicial;
  const UbicacionPage({super.key, this.inicial});

  @override
  State<UbicacionPage> createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  // Si no hay punto previo, el mapa abre en Colombia
  static const _centroColombia = LatLng(4.5709, -74.2973);

  final _mapa = MapController();
  LatLng? _elegido;

  @override
  void initState() {
    super.initState();
    _elegido = widget.inicial;
  }

  @override
  void dispose() {
    _mapa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elegido = _elegido;
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicación del refugio')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapa,
            options: MapOptions(
              initialCenter: widget.inicial ?? _centroColombia,
              initialZoom: widget.inicial == null ? 5.5 : 15,
              onTap: (_, punto) => setState(() => _elegido = punto),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.paws_shop',
              ),
              if (elegido != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: elegido,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on, size: 48, color: Color(0xFFD32F2F)),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('© OpenStreetMap contributors')],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  elegido == null
                      ? 'Toca el mapa para marcar dónde está el refugio. Puedes acercar con dos dedos.'
                      : 'Ubicación: ${elegido.latitude.toStringAsFixed(5)}, ${elegido.longitude.toStringAsFixed(5)}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Usar esta ubicación'),
            onPressed: elegido == null ? null : () => Navigator.of(context).pop(elegido),
          ),
        ),
      ),
    );
  }
}
