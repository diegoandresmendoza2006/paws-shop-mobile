import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/validadores.dart';
import '../widgets/campo_documento.dart';
import '../widgets/campo_fecha.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensaje_error.dart';
import '../widgets/requisitos_clave.dart';

/// Crear cuenta: nombre, documento, fecha de nacimiento, teléfono, dirección, correo y contraseña.
/// Esos datos se guardan en el perfil y luego se precargan en el formulario de adopción.
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _documento = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  String _tipoDocumento = 'CC';
  DateTime? _fechaNacimiento;
  bool _intentoRegistrar = false;

  @override
  void dispose() {
    _nombre.dispose();
    _documento.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _email.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _registrar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _intentoRegistrar = true);
    context.read<AuthBloc>().add(
          RegistroEnviado(
            nombreCompleto: _nombre.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            tipoDocumento: _tipoDocumento,
            numeroDocumento: _documento.text.trim(),
            fechaNacimiento: _fechaNacimiento!,
            telefono: _telefono.text.replaceAll(' ', ''),
            direccion: _direccion.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Si el registro salió bien, cerramos esta pantalla: debajo ya está la pantalla principal
      listener: (context, estado) {
        if (estado is AuthAutenticado || estado is AuthElegirRol) {
          Navigator.of(context).popUntil((ruta) => ruta.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear cuenta')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Estos datos se guardan en tu perfil y se usan solos cuando pidas adoptar una mascota.',
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Nombre completo',
                    controlador: _nombre,
                    accion: TextInputAction.next,
                    maxLongitud: 100,
                    validador: (v) => validarObligatorio(v, min: 2, nombre: 'El nombre'),
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
                    ayuda: 'Debes ser mayor de 18 años',
                    alCambiar: (f) => _fechaNacimiento = f,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Teléfono celular',
                    controlador: _telefono,
                    teclado: TextInputType.phone,
                    accion: TextInputAction.next,
                    pista: 'Ej: 310...',
                    maxLongitud: 10,
                    formateadores: [FilteringTextInputFormatter.digitsOnly],
                    validador: validarTelefono,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Dirección',
                    controlador: _direccion,
                    accion: TextInputAction.next,
                    pista: 'Ej: Calle 10 # 5-20, Bogotá',
                    maxLongitud: 255,
                    validador: (v) => validarObligatorio(v, min: 5, nombre: 'La dirección'),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Correo electrónico',
                    controlador: _email,
                    teclado: TextInputType.emailAddress,
                    accion: TextInputAction.next,
                    pista: 'nombre@correo.com',
                    validador: validarEmail,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Contraseña',
                    controlador: _password,
                    oculto: true,
                    accion: TextInputAction.next,
                    validador: validarPassword,
                  ),
                  const SizedBox(height: 8),
                  RequisitosClave(controlador: _password),
                  const SizedBox(height: 16),
                  CampoTexto(
                    etiqueta: 'Confirmar contraseña',
                    controlador: _confirmar,
                    oculto: true,
                    accion: TextInputAction.done,
                    alEnviar: (_) => _registrar(),
                    validador: (v) =>
                        v != _password.text ? 'Las contraseñas no coinciden' : null,
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, estado) {
                      final cargando = estado is AuthCargando;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_intentoRegistrar && estado is AuthError) ...[
                            MensajeError(mensaje: estado.mensaje),
                            const SizedBox(height: 12),
                          ],
                          FilledButton(
                            onPressed: cargando ? null : _registrar,
                            child: cargando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Crear cuenta'),
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
