import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/logo_paws.dart';
import '../widgets/mensaje_error.dart';
import '../utils/colores.dart';

/// Si la misma persona tiene dos cuentas (por ejemplo Encargado y Usuario), después de iniciar
/// sesión se le pregunta con cuál quiere entrar.
class SeleccionRolPage extends StatelessWidget {
  final AuthElegirRol estado;
  const SeleccionRolPage({super.key, required this.estado});

  static const _descripciones = {
    1: 'Panel, mascotas, productos, clientes y auditoría',
    2: 'Mascotas y solicitudes de tu refugio',
    3: 'Adopta, compra y haz seguimiento',
  };

  static const _iconos = {
    1: Icons.admin_panel_settings,
    2: Icons.home_work,
    3: Icons.pets,
  };

  @override
  Widget build(BuildContext context) {
    final sesion = estado.sesion;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: LogoPaws(tamano: 72)),
                  const SizedBox(height: 16),
                  Text('Hola, ${sesion.usuario.nombreCompleto.split(' ').first}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  const Text(
                    'Tienes más de una cuenta con este correo.\n¿Cómo quieres entrar?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (estado.mensaje != null) ...[
                    MensajeError(mensaje: estado.mensaje!),
                    const SizedBox(height: 12),
                  ],
                  for (final cuenta in sesion.cuentas)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: context.verdeSuave,
                          child: Icon(_iconos[cuenta.rolId] ?? Icons.person,
                              color: context.verdeFuerte),
                        ),
                        title: Text('Entrar como ${cuenta.rol}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(_descripciones[cuenta.rolId] ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.read<AuthBloc>().add(RolElegido(cuenta.usuarioId)),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<AuthBloc>().add(const SesionCerrada()),
                    child: const Text('Cerrar sesión'),
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
