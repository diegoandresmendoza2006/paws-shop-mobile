import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/catalogos_bloc.dart';
import '../bloc/catalogos_event.dart';
import '../bloc/catalogos_state.dart';
import '../bloc/formulario_bloc.dart';
import '../bloc/formulario_event.dart';
import '../models/encargado.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../utils/validadores.dart';
import '../widgets/campo_lista.dart';
import '../widgets/campo_texto.dart';
import '../widgets/formulario_comun.dart';
import '../widgets/pantalla_carga.dart';
import '../widgets/vista_error.dart';
import '../utils/colores.dart';
import '../widgets/requisitos_clave.dart';

/// El administrador crea una cuenta de encargado (o edita una) y le asigna su refugio.
class EncargadoFormPage extends StatelessWidget {
  final Encargado? encargado; // null = nuevo
  const EncargadoFormPage({super.key, this.encargado});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => CatalogosBloc(ctx.read<RefugioRepository>(), ctx.read<ProductoRepository>())
            ..add(const CatalogosSolicitados()),
        ),
        BlocProvider(create: FormularioBloc.desdeContexto),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(encargado == null ? 'Nuevo encargado' : 'Editar encargado')),
        body: EscuchaFormulario(child: _Formulario(encargado: encargado)),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  final Encargado? encargado;
  const _Formulario({this.encargado});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _clave = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.encargado?.nombreCompleto ?? '');
  late final _email = TextEditingController(text: widget.encargado?.email ?? '');
  final _password = TextEditingController();
  late int? _refugioId = widget.encargado?.refugioId;

  bool get _edita => widget.encargado != null;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_clave.currentState!.validate()) return;
    context.read<FormularioBloc>().add(EncargadoGuardado(
          id: widget.encargado?.id,
          datos: {
            'nombre_completo': _nombre.text.trim(),
            'email': _email.text.trim(),
            // al editar, la contraseña solo se manda si escribió una nueva
            if (!_edita || _password.text.isNotEmpty) 'password': _password.text,
            'refugio_id': _refugioId,
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogosBloc, CatalogosState>(
      builder: (context, catalogos) {
        if (catalogos is CatalogosError) {
          return VistaError(
            mensaje: catalogos.mensaje,
            alReintentar: () => context.read<CatalogosBloc>().add(const CatalogosSolicitados()),
          );
        }
        if (catalogos is! CatalogosCargados) return const PantallaCarga(compacta: true);
        if (_refugioId == null && catalogos.refugios.isNotEmpty) {
          _refugioId = catalogos.refugios.first.id;
        }
        return Form(
          key: _clave,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CampoTexto(
                etiqueta: 'Nombre completo',
                controlador: _nombre,
                maxLongitud: 150,
                accion: TextInputAction.next,
                validador: (v) => validarObligatorio(v, min: 3, nombre: 'El nombre'),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Correo electrónico',
                controlador: _email,
                teclado: TextInputType.emailAddress,
                accion: TextInputAction.next,
                validador: validarEmail,
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: _edita ? 'Contraseña nueva (opcional)' : 'Contraseña',
                controlador: _password,
                oculto: true, // con el "ojito" para verla
                pista: _edita ? 'Déjala vacía para no cambiarla' : null,
                obligatorio: !_edita,
                validador: (v) => _edita && (v ?? '').isEmpty ? null : validarPassword(v),
              ),
              const SizedBox(height: 8),
              RequisitosClave(controlador: _password),
              const SizedBox(height: 6),
              Text(
                _edita
                    ? 'Si la dejas vacía, conserva su contraseña actual.'
                    : 'Si esa persona ya tiene una cuenta de usuario con este correo, la cuenta de encargado '
                        'usará su misma contraseña y al iniciar sesión podrá elegir cómo entrar.',
                style: TextStyle(fontSize: 12, color: context.textoSecundario),
              ),
              const SizedBox(height: 14),
              CampoLista<int>(
                etiqueta: 'Refugio asignado',
                valor: _refugioId,
                opciones: [
                  for (final r in catalogos.refugios) DropdownMenuItem(value: r.id, child: Text(r.nombre)),
                ],
                alCambiar: (v) => setState(() => _refugioId = v),
                validador: (v) => v == null ? 'Elige un refugio' : null,
              ),
              const SizedBox(height: 20),
              BotonGuardar(texto: _edita ? 'Guardar cambios' : 'Crear encargado', alPulsar: _guardar),
              const SizedBox(height: 8),
              Center(
                child: Text('Los campos con * son obligatorios',
                    style: TextStyle(fontSize: 12, color: context.textoSecundario)),
              ),
            ],
          ),
        );
      },
    );
  }
}
