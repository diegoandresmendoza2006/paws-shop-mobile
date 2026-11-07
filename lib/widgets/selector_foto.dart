import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/foto_nueva.dart';
import '../utils/colores.dart';

/// Zona para elegir la foto de una mascota o un producto: muestra la actual (o la nueva elegida)
/// y los botones «Elegir / Cambiar foto» y «Quitar». Valida el formato (JPG, PNG o WEBP) y los 5 MB.
/// La pantalla que lo usa guarda la foto elegida y qué hacer con la que ya existía.
class SelectorFoto extends StatefulWidget {
  /// Foto que ya tiene guardada (URL), si existe.
  final String? urlActual;

  /// Foto nueva elegida y todavía sin subir.
  final FotoNueva? nueva;

  /// ¿La persona decidió quitar la foto que tenía?
  final bool quitada;

  final ValueChanged<FotoNueva> alElegir;
  final VoidCallback alQuitar;

  const SelectorFoto({
    super.key,
    required this.urlActual,
    required this.nueva,
    required this.quitada,
    required this.alElegir,
    required this.alQuitar,
  });

  static const int maxBytes = 5 * 1024 * 1024;
  static const extensionesPermitidas = ['jpg', 'jpeg', 'png', 'webp'];

  @override
  State<SelectorFoto> createState() => _SelectorFotoState();
}

class _SelectorFotoState extends State<SelectorFoto> {
  String? _error;

  Future<void> _elegir() async {
    final archivo = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    if (archivo == null) return;
    final extension = archivo.name.contains('.') ? archivo.name.split('.').last.toLowerCase() : '';
    if (!SelectorFoto.extensionesPermitidas.contains(extension)) {
      setState(() => _error = 'Formato no permitido. Usa JPG, PNG o WEBP.');
      return;
    }
    final bytes = await archivo.readAsBytes();
    if (bytes.length > SelectorFoto.maxBytes) {
      setState(() => _error = 'La imagen supera los 5 MB.');
      return;
    }
    setState(() => _error = null);
    widget.alElegir(FotoNueva(bytes, archivo.name));
  }

  @override
  Widget build(BuildContext context) {
    final tieneUrl = !widget.quitada && widget.urlActual != null && widget.urlActual!.isNotEmpty;
    final hayFoto = widget.nueva != null || tieneUrl;

    Widget vista;
    if (widget.nueva != null) {
      vista = Image.memory(widget.nueva!.bytes, fit: BoxFit.cover);
    } else if (tieneUrl) {
      vista = Image.network(widget.urlActual!, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined, size: 36));
    } else {
      vista = const Icon(Icons.add_a_photo_outlined, size: 36, color: Color(0xFF28A745));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            InkWell(
              onTap: _elegir,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 110,
                height: 110,
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.verdeSuave,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF28A745).withAlpha(120)),
                ),
                child: vista,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _elegir,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(hayFoto ? 'Cambiar foto' : 'Elegir foto'),
                  ),
                  if (hayFoto)
                    TextButton.icon(
                      onPressed: widget.alQuitar,
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFB71C1C)),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Quitar'),
                    ),
                  Text('JPG, PNG o WEBP · máximo 5 MB',
                      style: TextStyle(fontSize: 12, color: context.textoSecundario)),
                ],
              ),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_error!, style: const TextStyle(color: Color(0xFFB71C1C))),
          ),
      ],
    );
  }
}
