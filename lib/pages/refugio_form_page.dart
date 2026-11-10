import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../bloc/formulario_bloc.dart';
import '../bloc/formulario_event.dart';
import '../models/refugio.dart';
import '../utils/validadores.dart';
import 'ubicacion_page.dart';
import '../widgets/campo_texto.dart';
import '../widgets/formulario_comun.dart';
import '../utils/colores.dart';

/// Crear o editar un refugio (solo el administrador).
class RefugioFormPage extends StatelessWidget {
  final Refugio? refugio; // null = crear uno nuevo
  const RefugioFormPage({super.key, this.refugio});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: FormularioBloc.desdeContexto,
      child: Scaffold(
        appBar: AppBar(title: Text(refugio == null ? 'Nuevo refugio' : 'Editar refugio')),
        body: EscuchaFormulario(child: _Formulario(refugio: refugio)),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  final Refugio? refugio;
  const _Formulario({required this.refugio});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _clave = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _direccion;
  late final TextEditingController _telefono;
  LatLng? _ubicacion; // punto elegido en el mapa (null = sin ubicación)

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.refugio?.nombre ?? '');
    _direccion = TextEditingController(text: widget.refugio?.direccion ?? '');
    _telefono = TextEditingController(text: widget.refugio?.telefono ?? '');
    final r = widget.refugio;
    if (r != null && r.tieneUbicacion) _ubicacion = LatLng(r.latitud!, r.longitud!);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _elegirUbicacion() async {
    final punto = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => UbicacionPage(inicial: _ubicacion)),
    );
    if (punto != null) setState(() => _ubicacion = punto);
  }

  void _guardar() {
    if (!_clave.currentState!.validate()) return;
    context.read<FormularioBloc>().add(RefugioGuardado(
          id: widget.refugio?.id,
          datos: {
            'nombre': _nombre.text.trim(),
            'direccion': vacioANulo(_direccion.text),
            'telefono': vacioANulo(_telefono.text),
            'latitud': _ubicacion?.latitude,
            'longitud': _ubicacion?.longitude,
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _clave,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CampoTexto(
            etiqueta: 'Nombre',
            controlador: _nombre,
            maxLongitud: 100,
            accion: TextInputAction.next,
            validador: (v) => validarObligatorio(v, min: 3, nombre: 'El nombre'),
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Dirección',
            controlador: _direccion,
            obligatorio: false,
            maxLongitud: 255,
            pista: 'Calle, número y ciudad',
            accion: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Teléfono',
            controlador: _telefono,
            obligatorio: false,
            maxLongitud: 20,
            teclado: TextInputType.phone,
            pista: 'Ej: 310...',
            validador: (v) => (v ?? '').trim().isEmpty ? null : validarTelefono(v),
          ),
          const SizedBox(height: 14),
          const Text('Ubicación en el mapa', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _elegirUbicacion,
            icon: Icon(_ubicacion == null ? Icons.add_location_alt_outlined : Icons.edit_location_alt_outlined),
            label: Text(_ubicacion == null
                ? 'Elegir en el mapa'
                : 'Ubicación elegida (${_ubicacion!.latitude.toStringAsFixed(4)}, ${_ubicacion!.longitude.toStringAsFixed(4)}) · cambiar'),
          ),
          if (_ubicacion != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _ubicacion = null),
                child: const Text('Quitar ubicación'),
              ),
            ),
          const SizedBox(height: 20),
          BotonGuardar(
            texto: widget.refugio == null ? 'Crear refugio' : 'Guardar cambios',
            alPulsar: _guardar,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('Los campos con * son obligatorios',
                style: TextStyle(fontSize: 12, color: context.textoSecundario)),
          ),
        ],
      ),
    );
  }
}
