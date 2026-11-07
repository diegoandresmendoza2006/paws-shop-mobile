import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gestion_bloc.dart';
import '../bloc/gestion_event.dart';
import '../bloc/gestion_state.dart';
import '../models/usuario.dart';
import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_documento.dart';
import '../widgets/campo_fecha.dart';
import '../widgets/campo_texto.dart';
import '../widgets/confirmar.dart';
import '../widgets/confirmar_eliminar_todo.dart';
import '../widgets/foto_perfil.dart';
import '../widgets/mostrar_aviso.dart';

/// El administrador ve, edita o elimina a un cliente.
class ClientePage extends StatelessWidget {
  final Usuario cliente;
  const ClientePage({super.key, required this.cliente});

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
      child: _Formulario(cliente: cliente),
    );
  }
}

class _Formulario extends StatefulWidget {
  final Usuario cliente;
  const _Formulario({required this.cliente});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _email;
  late final TextEditingController _documento;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  late String _tipoDocumento;
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nombre = TextEditingController(text: c.nombreCompleto);
    _email = TextEditingController(text: c.email);
    _documento = TextEditingController(text: c.numeroDocumento ?? '');
    _telefono = TextEditingController(text: c.telefono ?? '');
    _direccion = TextEditingController(text: c.direccion ?? '');
    _tipoDocumento = c.tipoDocumento ?? 'CC';
    _fechaNacimiento = c.fechaNacimiento;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _documento.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    context.read<GestionBloc>().add(ClienteEditado(widget.cliente.id, {
          'nombre_completo': _nombre.text.trim(),
          'email': _email.text.trim(),
          'tipo_documento': _tipoDocumento,
          'numero_documento': _documento.text.trim(),
          'fecha_nacimiento': fechaParaApi(_fechaNacimiento!),
          'telefono': _telefono.text.replaceAll(' ', ''),
          'direccion': _direccion.text.trim(),
        }));
  }

  Future<void> _eliminar() async {
    final bloc = context.read<GestionBloc>();
    final ok = await confirmar(
      context,
      titulo: 'Eliminar cliente',
      mensaje:
          '¿Eliminar a ${widget.cliente.nombreCompleto}? Esta acción no se puede deshacer.',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok) bloc.add(ClienteEliminado(widget.cliente.id));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cliente;
    return BlocConsumer<GestionBloc, GestionState>(
      listener: (context, estado) {
        if (estado is GestionExitosa) {
          mostrarTexto(context, estado.mensaje);
          Navigator.of(context).pop();
        } else if (estado is GestionConflicto) {
          preguntarEliminarTodo(
            context,
            nombre: c.nombreCompleto,
            alConfirmar: () => context.read<GestionBloc>().add(estado.eventoForzado),
          );
        } else if (estado is GestionError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      builder: (context, estado) {
        final ocupado = estado is GestionEnCurso;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cliente'),
            actions: [
              IconButton(
                tooltip: 'Eliminar cliente',
                icon: const Icon(Icons.delete_outline),
                onPressed: ocupado ? null : _eliminar,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: FotoPerfil(url: c.fotoUrl, iniciales: c.iniciales, tamano: 88)),
                    const SizedBox(height: 4),
                    if (c.fechaRegistro != null)
                      Text('Cliente desde ${fechaLegible(c.fechaRegistro!)}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Nombre completo',
                      controlador: _nombre,
                      maxLongitud: 100,
                      validador: (v) => validarObligatorio(v, min: 2, nombre: 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Correo electrónico',
                      controlador: _email,
                      teclado: TextInputType.emailAddress,
                      validador: validarEmail,
                    ),
                    const SizedBox(height: 16),
                    CampoDocumento(
                      tipo: _tipoDocumento,
                      alCambiarTipo: (nuevo) => setState(() {
                        _tipoDocumento = nuevo;
                        _documento.clear();
                      }),
                      controlador: _documento,
                    ),
                    const SizedBox(height: 16),
                    CampoFecha(
                      etiqueta: 'Fecha de nacimiento',
                      fechaInicial: c.fechaNacimiento,
                      alCambiar: (f) => _fechaNacimiento = f,
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Teléfono celular',
                      controlador: _telefono,
                      teclado: TextInputType.phone,
                      pista: 'Ej: 3101234567',
                      maxLongitud: 10,
                      formateadores: [FilteringTextInputFormatter.digitsOnly],
                      validador: validarTelefono,
                    ),
                    const SizedBox(height: 16),
                    CampoTexto(
                      etiqueta: 'Dirección',
                      controlador: _direccion,
                      maxLongitud: 255,
                      validador: (v) => validarObligatorio(v, min: 5, nombre: 'La dirección'),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: ocupado ? null : _guardar,
                      child: ocupado
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Guardar cambios'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
