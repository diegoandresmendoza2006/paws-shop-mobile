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

  // Tarjeta casi opaca con el formulario, debajo de la foto
  Widget _tarjeta(BuildContext context) {
    return Card(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final alto = MediaQuery.of(context).size.height;
    const fondo = Color(0xFF26274D);
    return Scaffold(
      backgroundColor: fondo,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // La foto ocupa la parte de arriba y se funde con el fondo hacia abajo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: alto * 0.60,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/fondo_login.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.6, -0.4),
                  errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF4A4B78)),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x55000000), Color(0x00000000), Color(0x00000000), fondo],
                      stops: [0.0, 0.25, 0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Logo y nombre arriba a la izquierda (sobre las estrellas, sin tapar la cara)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    LogoPaws(tamano: 46),
                    SizedBox(width: 10),
                    Text('Paws&Shop',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
                  ],
                ),
              ),
            ),
          ),
          // El formulario empieza debajo de la cara y se desplaza si sale el teclado
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: alto * 0.40),
                      const Text('Adopta una mascota y apoya a los refugios',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [Shadow(blurRadius: 6, color: Colors.black54)])),
                      const SizedBox(height: 12),
                      _tarjeta(context),
                      const SizedBox(height: 28),
                      // Frase de cierre al pie de la pantalla
                      const Icon(Icons.pets, color: Color(0xFF28A745), size: 20),
                      const SizedBox(height: 8),
                      const Text('Tu mejor compañía podría estar aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3)),
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
