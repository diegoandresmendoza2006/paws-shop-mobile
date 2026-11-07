import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/perfil_bloc.dart';
import '../bloc/perfil_event.dart';
import '../bloc/perfil_state.dart';
import '../models/usuario.dart';
import '../repositories/perfil_repository.dart';
import '../utils/formato.dart';
import '../utils/validadores.dart';
import '../widgets/campo_documento.dart';
import '../widgets/campo_fecha.dart';
import '../widgets/campo_texto.dart';
import '../widgets/confirmar.dart';
import '../widgets/fila_dato.dart';
import '../widgets/foto_perfil.dart';
import '../widgets/mostrar_aviso.dart';
import '../widgets/requisitos_clave.dart';

/// Mi perfil: cambiar la foto (poner, cambiar o quitar), los datos personales y la contraseña.
class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PerfilBloc(ctx.read<PerfilRepository>()),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatefulWidget {
  const _Contenido();

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  final _formDatos = GlobalKey<FormState>();
  final _formPassword = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _documento = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();
  String _tipoDocumento = 'CC';
  DateTime? _fechaNacimiento;
  DateTime? _fechaInicial;

  @override
  void initState() {
    super.initState();
    final estado = context.read<AuthBloc>().state;
    if (estado is AuthAutenticado) {
      final u = estado.sesion.usuario;
      _nombre.text = u.nombreCompleto;
      _documento.text = u.numeroDocumento ?? '';
      _telefono.text = u.telefono ?? '';
      _direccion.text = u.direccion ?? '';
      _tipoDocumento = u.tipoDocumento ?? 'CC';
      _fechaNacimiento = u.fechaNacimiento;
      _fechaInicial = u.fechaNacimiento;
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _documento.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final bloc = context.read<PerfilBloc>();
    final archivo = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (archivo == null) return;
    final bytes = await archivo.readAsBytes();
    bloc.add(FotoElegida(bytes, archivo.name));
  }

  Future<void> _quitarFoto() async {
    final bloc = context.read<PerfilBloc>();
    final ok = await confirmar(context,
        titulo: 'Quitar foto',
        mensaje: '¿Quieres eliminar tu foto de perfil?',
        textoConfirmar: 'Quitar',
        peligroso: true);
    if (ok) bloc.add(const FotoQuitada());
  }

  /// Tras el registro, el documento y la fecha de nacimiento solo los cambia el administrador.
  bool _documentoBloqueado(Usuario u) => !u.esAdmin && u.numeroDocumento != null;
  bool _fechaBloqueada(Usuario u) => !u.esAdmin && u.fechaNacimiento != null;

  void _guardarDatos(Usuario u) {
    if (!_formDatos.currentState!.validate()) return;
    context.read<PerfilBloc>().add(PerfilGuardado({
          'nombre_completo': _nombre.text.trim(),
          if (!_documentoBloqueado(u)) ...{
            'tipo_documento': _tipoDocumento,
            'numero_documento': _documento.text.trim(),
          },
          if (!_fechaBloqueada(u)) 'fecha_nacimiento': fechaParaApi(_fechaNacimiento!),
          'telefono': _telefono.text.replaceAll(' ', ''),
          'direccion': _direccion.text.trim(),
        }));
  }

  void _cambiarPassword() {
    if (!_formPassword.currentState!.validate()) return;
    context
        .read<PerfilBloc>()
        .add(PasswordCambiada(actual: _actual.text, nueva: _nueva.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PerfilBloc, PerfilState>(
      listener: (context, estado) {
        if (estado is PerfilActualizado) {
          final usuario = estado.usuario;
          if (usuario != null) {
            // Actualiza los datos de la sesión (menú lateral, formulario de adopción...)
            context.read<AuthBloc>().add(UsuarioActualizado(usuario));
          } else {
            _actual.clear();
            _nueva.clear();
            _confirmar.clear();
          }
          mostrarTexto(context, estado.mensaje);
        } else if (estado is PerfilError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, auth) {
            if (auth is! AuthAutenticado) return const SizedBox.shrink();
            final u = auth.sesion.usuario;
            return BlocBuilder<PerfilBloc, PerfilState>(
              builder: (context, estado) {
                final ocupado = estado is PerfilGuardando;
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SeccionFoto(
                          usuario: u,
                          ocupado: ocupado,
                          alElegir: _elegirFoto,
                          alQuitar: _quitarFoto,
                        ),
                        const Divider(height: 32),
                        Text('Datos personales',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        FilaDato(etiqueta: 'Correo', valor: u.email),
                        FilaDato(etiqueta: 'Rol', valor: u.rol),
                        const SizedBox(height: 12),
                        Form(
                          key: _formDatos,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CampoTexto(
                                etiqueta: 'Nombre completo',
                                controlador: _nombre,
                                maxLongitud: 100,
                                accion: TextInputAction.next,
                                validador: (v) =>
                                    validarObligatorio(v, min: 2, nombre: 'El nombre'),
                              ),
                              const SizedBox(height: 16),
                              if (_documentoBloqueado(u))
                                _DatoBloqueado(
                                  etiqueta: 'Documento',
                                  valor: '${u.tipoDocumento ?? ''} ${u.numeroDocumento ?? ''}',
                                )
                              else
                                CampoDocumento(
                                  tipo: _tipoDocumento,
                                  alCambiarTipo: (nuevo) => setState(() {
                                    _tipoDocumento = nuevo;
                                    _documento.clear();
                                  }),
                                  controlador: _documento,
                                ),
                              const SizedBox(height: 16),
                              if (_fechaBloqueada(u))
                                _DatoBloqueado(
                                  etiqueta: 'Fecha de nacimiento',
                                  valor: fechaParaApi(u.fechaNacimiento!),
                                )
                              else
                                CampoFecha(
                                  etiqueta: 'Fecha de nacimiento',
                                  fechaInicial: _fechaInicial,
                                  alCambiar: (f) => _fechaNacimiento = f,
                                ),
                              const SizedBox(height: 16),
                              CampoTexto(
                                etiqueta: 'Teléfono celular',
                                controlador: _telefono,
                                teclado: TextInputType.phone,
                                accion: TextInputAction.next,
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
                                pista: 'Ej: Calle 10 # 5-20, Bogotá',
                                validador: (v) =>
                                    validarObligatorio(v, min: 5, nombre: 'La dirección'),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: ocupado ? null : () => _guardarDatos(u),
                                child: const Text('Guardar cambios'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 40),
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: const Text('Cambiar contraseña',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          children: [
                            Form(
                              key: _formPassword,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  CampoTexto(
                                    etiqueta: 'Contraseña actual',
                                    controlador: _actual,
                                    oculto: true,
                                    validador: (v) => (v ?? '').isEmpty
                                        ? 'Escribe tu contraseña actual'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  CampoTexto(
                                    etiqueta: 'Contraseña nueva',
                                    controlador: _nueva,
                                    oculto: true,
                                    validador: validarPassword,
                                  ),
                                  const SizedBox(height: 8),
                                  RequisitosClave(controlador: _nueva),
                                  const SizedBox(height: 16),
                                  CampoTexto(
                                    etiqueta: 'Confirmar contraseña nueva',
                                    controlador: _confirmar,
                                    oculto: true,
                                    validador: (v) => v != _nueva.text
                                        ? 'Las contraseñas no coinciden'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    onPressed: ocupado ? null : _cambiarPassword,
                                    child: const Text('Cambiar contraseña'),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Foto grande + botones para poner, cambiar o quitar la foto de perfil.
class _SeccionFoto extends StatelessWidget {
  final Usuario usuario;
  final bool ocupado;
  final VoidCallback alElegir;
  final VoidCallback alQuitar;

  const _SeccionFoto({
    required this.usuario,
    required this.ocupado,
    required this.alElegir,
    required this.alQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final tieneFoto = (usuario.fotoUrl ?? '').isNotEmpty;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            FotoPerfil(url: usuario.fotoUrl, iniciales: usuario.iniciales, tamano: 120),
            if (ocupado)
              const SizedBox(
                  width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 3)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: ocupado ? null : alElegir,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(tieneFoto ? 'Cambiar foto' : 'Poner foto'),
            ),
            if (tieneFoto)
              TextButton.icon(
                onPressed: ocupado ? null : alQuitar,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Quitar'),
              ),
          ],
        ),
      ],
    );
  }
}


/// Dato de solo lectura: se muestra pero no se puede editar (solo el administrador lo cambia).
class _DatoBloqueado extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _DatoBloqueado({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: etiqueta,
        helperText: 'Solo el administrador puede cambiarlo',
        suffixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
      ),
      child: Text(valor.trim()),
    );
  }
}
