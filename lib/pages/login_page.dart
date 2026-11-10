import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/validadores.dart';
import '../widgets/campo_texto.dart';
import '../widgets/logo_paws.dart';
import '../widgets/mensaje_error.dart';
import 'registro_page.dart';

/// Pantalla de inicio de sesión.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _intentoIniciar = false; // para no mostrar errores viejos de otras pantallas

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _iniciar() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _intentoIniciar = true);
    context.read<AuthBloc>().add(
          SesionIniciada(email: _email.text.trim(), password: _password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Foto de fondo: la persona queda a la derecha, así que se alinea hacia ese lado
          Image.asset(
            'assets/images/fondo_login.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.55, -0.2),
            errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF4A4B78)),
          ),
          // Degradado oscuro para que el formulario siempre se lea bien
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66101030), Color(0xCC101030)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: LogoPaws()),
                      const SizedBox(height: 12),
                      const Text('Paws&Shop',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
                      const SizedBox(height: 4),
                      const Text('Adopta una mascota y apoya a los refugios',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 6, color: Colors.black54)])),
                      const SizedBox(height: 24),
                      // Tarjeta casi opaca con el formulario encima de la foto
                      Card(
                        elevation: 6,
                        color: Theme.of(context).colorScheme.surface.withAlpha(238),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                                  accion: TextInputAction.done,
                                  alEnviar: (_) => _iniciar(),
                                  validador: (v) =>
                                      (v ?? '').isEmpty ? 'La contraseña es obligatoria' : null,
                                ),
                                const SizedBox(height: 16),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, estado) {
                                    final cargando = estado is AuthCargando;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        if (_intentoIniciar && estado is AuthError) ...[
                                          MensajeError(mensaje: estado.mensaje),
                                          const SizedBox(height: 12),
                                        ],
                                        FilledButton(
                                          onPressed: cargando ? null : _iniciar,
                                          child: cargando
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(strokeWidth: 2))
                                              : const Text('Iniciar sesión'),
                                        ),
                                        if (cargando)
                                          const Padding(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              'Conectando… la primera vez puede tardar hasta 30 segundos.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const RegistroPage())),
                                  child: const Text('¿No tienes cuenta? Regístrate'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
