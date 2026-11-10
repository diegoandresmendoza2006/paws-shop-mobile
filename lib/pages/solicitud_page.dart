import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/solicitud_bloc.dart';
import '../bloc/solicitud_event.dart';
import '../bloc/solicitud_state.dart';
import '../models/mascota.dart';
import '../models/solicitud_adopcion.dart';
import '../models/usuario.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/fila_dato.dart';
import '../widgets/foto_mascota.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/mostrar_aviso.dart';
import '../widgets/pregunta_si_no.dart';
import 'perfil_page.dart';

/// Formulario de adopción. Empieza en "Vivienda": los datos personales ya vienen del registro
/// y se muestran arriba, junto a la foto de la mascota que se quiere adoptar.
class SolicitudPage extends StatelessWidget {
  final Mascota mascota;
  const SolicitudPage({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => SolicitudBloc(ctx.read<SolicitudRepository>()),
      child: _Formulario(mascota: mascota),
    );
  }
}

class _Formulario extends StatefulWidget {
  final Mascota mascota;
  const _Formulario({required this.mascota});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _formKey = GlobalKey<FormState>();
  final _personas = TextEditingController();
  final _horas = TextEditingController();
  final _viajes = TextEditingController();
  final _motivo = TextEditingController();

  String? _tipoVivienda;
  bool? _permiteMascotas;
  bool? _tienePatio;
  bool? _tieneCercas;
  bool? _tuvoMascotas;
  bool? _vacunadas;
  bool? _esterilizadas;

  @override
  void dispose() {
    _personas.dispose();
    _horas.dispose();
    _viajes.dispose();
    _motivo.dispose();
    super.dispose();
  }

  void _enviar(Usuario u) {
    if (!_formKey.currentState!.validate()) return;
    final solicitud = SolicitudAdopcionNueva(
      mascotaId: widget.mascota.id,
      nombreContacto: u.nombreCompleto,
      fechaNacimiento: u.fechaNacimiento!,
      telefono: u.telefono!,
      emailContacto: u.email,
      direccion: u.direccion!,
      tipoVivienda: _tipoVivienda!,
      viviendaPermiteMascotas: _permiteMascotas!,
      tienePatio: _tienePatio!,
      tieneCercas: _tieneCercas!,
      personasHogar: int.parse(_personas.text.trim()),
      tuvoMascotas: _tuvoMascotas!,
      mascotasVacunadas: _tuvoMascotas! ? _vacunadas : null,
      mascotasEsterilizadas: _tuvoMascotas! ? _esterilizadas : null,
      horasSolo: int.parse(_horas.text.trim()),
      responsableViajes: _viajes.text.trim(),
      motivo: _motivo.text,
    );
    context.read<SolicitudBloc>().add(SolicitudEnviada(solicitud));
  }

  Widget _seccion(String titulo) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
      );

  @override
  Widget build(BuildContext context) {
    // watch: si el usuario edita su perfil y vuelve, el recuadro de datos se actualiza solo
    final sesion = context.watch<AuthBloc>().state;
    final usuario = sesion is AuthAutenticado ? sesion.sesion.usuario : null;
    if (usuario == null) return const Scaffold();

    return BlocListener<SolicitudBloc, SolicitudState>(
      listener: (context, estado) {
        if (estado is SolicitudExitosa) {
          mostrarTexto(context,
              'Solicitud enviada. Puedes seguirla en la pestaña "Trámites".');
          Navigator.of(context).popUntil((ruta) => ruta.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Adoptar a ${widget.mascota.nombre}')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TusDatos(usuario: usuario, mascota: widget.mascota),
                  if (!usuario.perfilCompleto) ...[
                    const SizedBox(height: 12),
                    const MensajeError(
                        mensaje:
                            'Tu perfil no tiene fecha de nacimiento, teléfono o dirección. Complétalos para poder enviar la solicitud.'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PerfilPage())),
                      child: const Text('Completar mi perfil'),
                    ),
                  ],
                  _seccion('Vivienda'),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _tipoVivienda,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de vivienda *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Propia', child: Text('Propia')),
                      DropdownMenuItem(value: 'Arrendada', child: Text('Arrendada')),
                    ],
                    onChanged: (v) => setState(() => _tipoVivienda = v),
                    validator: (v) => v == null ? 'Elige una opción' : null,
                  ),
                  const SizedBox(height: 16),
                  PreguntaSiNo(
                    pregunta: '¿En tu vivienda se permiten mascotas?',
                    alCambiar: (v) => _permiteMascotas = v,
                  ),
                  _seccion('Entorno y espacio'),
                  PreguntaSiNo(
                    pregunta: '¿Tienes patio o jardín?',
                    alCambiar: (v) => _tienePatio = v,
                  ),
                  const SizedBox(height: 16),
                  PreguntaSiNo(
                    pregunta: '¿El espacio tiene cercas o es seguro?',
                    alCambiar: (v) => _tieneCercas = v,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: '¿Cuántas personas viven en tu hogar?',
                    controlador: _personas,
                    teclado: TextInputType.number,
                    maxLongitud: 2,
                    pista: 'Ej: 3',
                    formateadores: [FilteringTextInputFormatter.digitsOnly],
                    validador: (v) =>
                        validarEntero(v, min: 1, max: 30, nombre: 'El número de personas'),
                  ),
                  _seccion('Experiencia con mascotas'),
                  PreguntaSiNo(
                    pregunta: '¿Has tenido mascotas antes?',
                    alCambiar: (v) => setState(() => _tuvoMascotas = v),
                  ),
                  if (_tuvoMascotas == true) ...[
                    const SizedBox(height: 16),
                    PreguntaSiNo(
                      pregunta: '¿Estaban vacunadas?',
                      alCambiar: (v) => _vacunadas = v,
                    ),
                    const SizedBox(height: 16),
                    PreguntaSiNo(
                      pregunta: '¿Estaban esterilizadas?',
                      alCambiar: (v) => _esterilizadas = v,
                    ),
                  ],
                  _seccion('Disponibilidad y estilo de vida'),
                  CampoTexto(
                    etiqueta: '¿Cuántas horas al día estaría solo?',
                    controlador: _horas,
                    teclado: TextInputType.number,
                    maxLongitud: 2,
                    pista: 'Ej: 6',
                    formateadores: [FilteringTextInputFormatter.digitsOnly],
                    validador: (v) =>
                        validarEntero(v, min: 0, max: 24, nombre: 'Las horas'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: '¿Quién lo cuidaría cuando viajes?',
                    controlador: _viajes,
                    maxLongitud: 500,
                    maxLineas: 2,
                    validador: (v) =>
                        validarObligatorio(v, min: 3, nombre: 'Este campo'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: '¿Por qué quieres adoptarlo? (opcional)',
                    controlador: _motivo,
                    obligatorio: false,
                    maxLineas: 4,
                    maxLongitud: 1000,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<SolicitudBloc, SolicitudState>(
                    builder: (context, estado) {
                      final enviando = estado is SolicitudEnviando;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (estado is SolicitudError) ...[
                            MensajeError(mensaje: estado.mensaje),
                            const SizedBox(height: 12),
                          ],
                          FilledButton(
                            onPressed: (enviando || !usuario.perfilCompleto)
                                ? null
                                : () => _enviar(usuario),
                            child: enviando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Enviar solicitud'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Recuadro de arriba: la foto de la mascota que se quiere adoptar y los datos del usuario.
class _TusDatos extends StatelessWidget {
  final Usuario usuario;
  final Mascota mascota;
  const _TusDatos({required this.usuario, required this.mascota});

  @override
  Widget build(BuildContext context) {
    final f = usuario.fechaNacimiento;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                      width: 72, height: 72, child: FotoMascota(url: mascota.imagenUrl)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vas a adoptar a',
                          style: Theme.of(context).textTheme.bodySmall),
                      Text(mascota.nombre,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      EtiquetaEstado(estado: mascota.estadoAdopcion),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('Tus datos (los tomamos de tu perfil)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            FilaDato(etiqueta: 'Nombre', valor: usuario.nombreCompleto),
            FilaDato(
                etiqueta: 'Documento',
                valor: (usuario.numeroDocumento ?? '').isEmpty
                    ? null
                    : '${usuario.tipoDocumento ?? ''} ${usuario.numeroDocumento}'.trim()),
            FilaDato(etiqueta: 'Nacimiento', valor: f == null ? null : fechaLegible(f)),
            FilaDato(etiqueta: 'Teléfono', valor: usuario.telefono),
            FilaDato(etiqueta: 'Correo', valor: usuario.email),
            FilaDato(etiqueta: 'Dirección', valor: usuario.direccion),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PerfilPage())),
                child: const Text('Editar mis datos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
