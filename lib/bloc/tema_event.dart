import 'package:flutter/material.dart';

/// Lo que se le PIDE al TemaBloc.
sealed class TemaEvent {
  const TemaEvent();
}

/// Entró una persona: se carga el modo que ELLA eligió (si nunca eligió, claro).
class TemaDePersonaCargado extends TemaEvent {
  final String email;
  const TemaDePersonaCargado(this.email);
}

/// Se cerró la sesión: la app vuelve al modo claro por defecto (lo guardado de cada persona no se borra).
class TemaDePersonaCerrado extends TemaEvent {
  const TemaDePersonaCerrado();
}

/// La persona eligió modo claro, oscuro o el del sistema (solo se puede con sesión iniciada).
class TemaElegido extends TemaEvent {
  final ThemeMode modo;
  const TemaElegido(this.modo);
}
