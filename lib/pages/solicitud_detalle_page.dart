import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gestion_bloc.dart';
import '../bloc/gestion_event.dart';
import '../bloc/gestion_state.dart';
import '../models/solicitud_adopcion.dart';
import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/formato.dart';
import '../widgets/boton_certificado.dart';
import '../widgets/campo_texto.dart';
import '../widgets/confirmar.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/fila_dato.dart';
import '../widgets/mostrar_aviso.dart';

String _siNo(bool? v) => v == null ? '—' : (v ? 'Sí' : 'No');

/// El encargado revisa el formulario completo y aprueba o rechaza (con un mensaje para el adoptante).
class SolicitudDetallePage extends StatelessWidget {
  final SolicitudAdopcion solicitud;
  const SolicitudDetallePage({super.key, required this.solicitud});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => GestionBloc(
        admin: ctx.read<AdminRepository>(),
        solicitudes: ctx.read<SolicitudRepository>(),
        mascotas: ctx.read<MascotaRepository>(),
        productos: ctx.read<ProductoRepository>(),
        refugios: ctx.read<RefugioRepository>(),
      ),
      child: _Contenido(solicitud: solicitud),
    );
  }
}

class _Contenido extends StatefulWidget {
  final SolicitudAdopcion solicitud;
  const _Contenido({required this.solicitud});

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  final _comentario = TextEditingController();

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _resolver(String estado) async {
    final bloc = context.read<GestionBloc>();
    final ok = await confirmar(
      context,
      titulo: estado == 'Aprobada' ? 'Aprobar solicitud' : 'Rechazar solicitud',
      mensaje: estado == 'Aprobada'
          ? 'La mascota quedará como "Adoptada" y las otras solicitudes pendientes de esa mascota se rechazarán.'
          : 'La solicitud quedará rechazada y el adoptante verá tu mensaje.',
      textoConfirmar: estado == 'Aprobada' ? 'Aprobar' : 'Rechazar',
      peligroso: estado == 'Rechazada',
    );
    if (ok) bloc.add(SolicitudResuelta(widget.solicitud.id, estado, _comentario.text));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.solicitud;
    final nacimiento = s.fechaNacimiento;
    return BlocConsumer<GestionBloc, GestionState>(
      listener: (context, estado) {
        if (estado is GestionExitosa) {
          mostrarTexto(context, estado.mensaje);
          Navigator.of(context).pop();
        } else if (estado is GestionError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      builder: (context, estado) {
        final ocupado = estado is GestionEnCurso;
        return Scaffold(
          appBar: AppBar(title: Text('Solicitud de ${s.mascotaNombre ?? 'mascota'}')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(s.adoptanteNombre ?? 'Adoptante',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                    EtiquetaEstado(estado: s.estado),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Datos personales', style: Theme.of(context).textTheme.titleMedium),
                FilaDato(etiqueta: 'Nombre', valor: s.nombreContacto),
                FilaDato(etiqueta: 'Nacimiento', valor: nacimiento == null ? null : fechaLegible(nacimiento)),
                FilaDato(etiqueta: 'Teléfono', valor: s.telefono),
                FilaDato(etiqueta: 'Correo', valor: s.emailContacto),
                FilaDato(etiqueta: 'Dirección', valor: s.direccion),
                const SizedBox(height: 12),
                Text('Vivienda y entorno', style: Theme.of(context).textTheme.titleMedium),
                FilaDato(etiqueta: 'Vivienda', valor: s.tipoVivienda),
                FilaDato(etiqueta: 'Permite mascotas', valor: _siNo(s.viviendaPermiteMascotas)),
                FilaDato(etiqueta: 'Patio o jardín', valor: _siNo(s.tienePatio)),
                FilaDato(etiqueta: 'Cercas', valor: _siNo(s.tieneCercas)),
                FilaDato(etiqueta: 'Personas en casa', valor: s.personasHogar?.toString()),
                const SizedBox(height: 12),
                Text('Experiencia', style: Theme.of(context).textTheme.titleMedium),
                FilaDato(etiqueta: 'Tuvo mascotas', valor: _siNo(s.tuvoMascotas)),
                if (s.tuvoMascotas == true) ...[
                  FilaDato(etiqueta: 'Vacunadas', valor: _siNo(s.mascotasVacunadas)),
                  FilaDato(etiqueta: 'Esterilizadas', valor: _siNo(s.mascotasEsterilizadas)),
                ],
                const SizedBox(height: 12),
                Text('Disponibilidad', style: Theme.of(context).textTheme.titleMedium),
                FilaDato(etiqueta: 'Horas solo', valor: s.horasSolo?.toString()),
                FilaDato(etiqueta: 'Cuidado en viajes', valor: s.responsableViajes),
                FilaDato(etiqueta: 'Motivo', valor: s.motivo),
                if ((s.comentarioEncargado ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  FilaDato(etiqueta: 'Tu mensaje', valor: s.comentarioEncargado),
                ],
                if (s.estado == 'Aprobada') ...[
                  const SizedBox(height: 20),
                  BotonCertificado(solicitudId: s.id),
                ],
                if (s.enRevision) ...[
                  const Divider(height: 32),
                  CampoTexto(
                    etiqueta: 'Mensaje para el adoptante (opcional)',
                    controlador: _comentario,
                    obligatorio: false,
                    maxLineas: 3,
                    maxLongitud: 500,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: ocupado ? null : () => _resolver('Rechazada'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB71C1C)),
                          child: const Text('Rechazar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: ocupado ? null : () => _resolver('Aprobada'),
                          child: const Text('Aprobar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
