import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/formulario_bloc.dart';
import '../bloc/formulario_event.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../bloc/lista_state.dart';
import '../models/solicitud_adopcion.dart';
import '../repositories/solicitud_repository.dart';
import '../widgets/campo_lista.dart';
import '../widgets/campo_texto.dart';
import '../widgets/formulario_comun.dart';
import '../widgets/pantalla_carga.dart';
import '../widgets/vista_error.dart';

/// El adoptante cuenta cómo va su mascota; el encargado del refugio verá el reporte.
class SeguimientoFormPage extends StatelessWidget {
  const SeguimientoFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Las adopciones aprobadas del usuario (se cargan todas de una vez)
        BlocProvider<ListaBloc<SolicitudAdopcion>>(
          create: (ctx) {
            final repo = ctx.read<SolicitudRepository>();
            return ListaBloc<SolicitudAdopcion>((pagina, busqueda, filtros) => repo.aprobadas(),
                porPagina: 100)
              ..add(const ListaIniciada());
          },
        ),
        BlocProvider(create: FormularioBloc.desdeContexto),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Reportar seguimiento')),
        body: const EscuchaFormulario(child: _Contenido()),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListaBloc<SolicitudAdopcion>, ListaState<SolicitudAdopcion>>(
      builder: (context, estado) {
        if (estado is ListaError<SolicitudAdopcion>) {
          return VistaError(
            mensaje: estado.mensaje,
            alReintentar: () => context.read<ListaBloc<SolicitudAdopcion>>().add(const ListaIniciada()),
          );
        }
        if (estado is! ListaCargada<SolicitudAdopcion>) return const PantallaCarga(compacta: true);
        if (estado.items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Cuando te aprueben una adopción podrás contarnos aquí cómo está tu mascota.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _Formulario(adopciones: estado.items);
      },
    );
  }
}

class _Formulario extends StatefulWidget {
  final List<SolicitudAdopcion> adopciones;
  const _Formulario({required this.adopciones});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  static const _estados = ['Excelente', 'Bueno', 'Regular', 'Requiere atención'];

  final _clave = GlobalKey<FormState>();
  final _observaciones = TextEditingController();
  late int? _solicitudId = widget.adopciones.length == 1 ? widget.adopciones.first.id : null;
  String? _estado;

  @override
  void dispose() {
    _observaciones.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!_clave.currentState!.validate()) return;
    final texto = _observaciones.text.trim();
    context.read<FormularioBloc>().add(SeguimientoEnviado(
          solicitudId: _solicitudId!,
          estadoSalud: _estado!,
          observaciones: texto.isEmpty ? null : texto,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _clave,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Cuéntale al refugio cómo se está adaptando tu compañero.'),
          const SizedBox(height: 16),
          CampoLista<int>(
            etiqueta: 'Mascota adoptada',
            valor: _solicitudId,
            opciones: [
              for (final s in widget.adopciones)
                DropdownMenuItem(value: s.id, child: Text(s.mascotaNombre ?? 'Mascota #${s.mascotaId}')),
            ],
            alCambiar: (v) => setState(() => _solicitudId = v),
            validador: (v) => v == null ? 'Elige la mascota' : null,
          ),
          const SizedBox(height: 14),
          CampoLista<String>(
            etiqueta: '¿Cómo está de salud?',
            valor: _estado,
            opciones: [for (final e in _estados) DropdownMenuItem(value: e, child: Text(e))],
            alCambiar: (v) => setState(() => _estado = v),
            validador: (v) => v == null ? 'Elige cómo está' : null,
          ),
          const SizedBox(height: 14),
          CampoTexto(
            etiqueta: 'Observaciones',
            controlador: _observaciones,
            obligatorio: false,
            maxLongitud: 500,
            maxLineas: 4,
            pista: 'Alimentación, ánimo, visitas al veterinario…',
          ),
          const SizedBox(height: 20),
          BotonGuardar(texto: 'Enviar reporte', alPulsar: _enviar),
        ],
      ),
    );
  }
}
