import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/tema_repository.dart';
import 'tema_event.dart';

/// Modo claro / oscuro de toda la app. El estado ES el [ThemeMode] que usa el MaterialApp.
///
/// El modo es de cada PERSONA: se aplica mientras tiene la sesión abierta y se recuerda para
/// la próxima vez que entre. Sin sesión (pantalla de login) siempre se ve en modo claro.
class TemaBloc extends Bloc<TemaEvent, ThemeMode> {
  final TemaRepository _repositorio;
  String? _email; // la persona con sesión abierta

  TemaBloc(this._repositorio) : super(ThemeMode.light) {
    on<TemaDePersonaCargado>((e, emit) async {
      if (e.email == _email) return; // misma persona (p. ej. cambió de cuenta): no se toca
      _email = e.email;
      final modo = await _repositorio.leer(e.email);
      if (_email == e.email) emit(modo);
    });
    on<TemaDePersonaCerrado>((e, emit) {
      _email = null;
      emit(ThemeMode.light);
    });
    on<TemaElegido>((e, emit) async {
      final email = _email;
      if (email == null) return; // sin sesión no hay a quién guardarle el modo
      emit(e.modo);
      await _repositorio.guardar(email, e.modo);
    });
  }
}
