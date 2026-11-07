import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paws_shop/bloc/tema_bloc.dart';
import 'package:paws_shop/bloc/tema_event.dart';
import 'package:paws_shop/repositories/tema_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _esperar() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sin sesión empieza en modo claro', () {
    expect(TemaBloc(TemaRepository()).state, ThemeMode.light);
  });

  test('sin sesión no se puede cambiar el modo', () async {
    final bloc = TemaBloc(TemaRepository())..add(const TemaElegido(ThemeMode.dark));
    await _esperar();
    expect(bloc.state, ThemeMode.light);
    await bloc.close();
  });

  test('el modo que eligió una persona se recuerda al volver a entrar', () async {
    final bloc = TemaBloc(TemaRepository());
    bloc.add(const TemaDePersonaCargado('ana@correo.com'));
    await _esperar();
    bloc.add(const TemaElegido(ThemeMode.dark));
    await _esperar();
    expect(bloc.state, ThemeMode.dark);

    bloc.add(const TemaDePersonaCerrado());
    await _esperar();
    expect(bloc.state, ThemeMode.light); // al cerrar sesión, claro

    bloc.add(const TemaDePersonaCargado('ANA@correo.com'));
    await _esperar();
    expect(bloc.state, ThemeMode.dark); // vuelve el suyo (el correo no distingue mayúsculas)
    await bloc.close();
  });

  test('otra persona no hereda el modo y empieza en claro', () async {
    final bloc = TemaBloc(TemaRepository());
    bloc.add(const TemaDePersonaCargado('ana@correo.com'));
    await _esperar();
    bloc.add(const TemaElegido(ThemeMode.dark));
    await _esperar();
    bloc.add(const TemaDePersonaCerrado());
    bloc.add(const TemaDePersonaCargado('admin@correo.com'));
    await _esperar();
    expect(bloc.state, ThemeMode.light);
    await bloc.close();
  });

  test('si lo guardado no es válido usa el modo claro', () async {
    SharedPreferences.setMockInitialValues({'modo_tema_ana@correo.com': 'raro'});
    expect(await TemaRepository().leer('ana@correo.com'), ThemeMode.light);
  });
}
