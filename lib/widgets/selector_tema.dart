import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/tema_bloc.dart';
import '../bloc/tema_event.dart';

/// Elegir entre modo del sistema, claro u oscuro (cada persona tiene el suyo y se recuerda al volver a entrar).
class SelectorTema extends StatelessWidget {
  const SelectorTema({super.key});

  @override
  Widget build(BuildContext context) {
    final modo = context.watch<TemaBloc>().state;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apariencia', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto), label: Text('Auto')),
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Claro')),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Oscuro')),
              ],
              selected: {modo},
              onSelectionChanged: (s) => context.read<TemaBloc>().add(TemaElegido(s.first)),
            ),
          ),
        ],
      ),
    );
  }
}
