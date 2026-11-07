import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/catalogos_bloc.dart';
import '../bloc/catalogos_event.dart';
import '../bloc/catalogos_state.dart';
import '../bloc/formulario_bloc.dart';
import '../bloc/formulario_event.dart';
import '../models/foto_nueva.dart';
import '../models/mascota.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../utils/validadores.dart';
import '../widgets/campo_lista.dart';
import '../widgets/campo_texto.dart';
import '../widgets/formulario_comun.dart';
import '../widgets/pantalla_carga.dart';
import '../widgets/selector_foto.dart';
import '../widgets/vista_error.dart';
import '../utils/colores.dart';

/// Crear o editar una mascota (encargado: en su refugio; administrador: elige el refugio).
class MascotaFormPage extends StatelessWidget {
  final Mascota? mascota; // null = crear una nueva
  const MascotaFormPage({super.key, this.mascota});

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
        appBar: AppBar(title: Text(mascota == null ? 'Nueva mascota' : 'Editar mascota')),
        body: EscuchaFormulario(child: _Formulario(mascota: mascota)),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  final Mascota? mascota;
  const _Formulario({required this.mascota});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  static const _especies = ['Perro', 'Gato', 'Otro'];
  static const _estados = ['Disponible', 'En Proceso', 'Adoptada'];

  final _clave = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _raza;
  late final TextEditingController _edad;
  late final TextEditingController _descripcion;
  late String _especie;
  late String _estado;
  int? _refugioId;
  FotoNueva? _foto;
  bool _quitarFoto = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mascota;
    _nombre = TextEditingController(text: m?.nombre ?? '');
    _raza = TextEditingController(text: m?.raza ?? '');
    _edad = TextEditingController(text: m?.edadMeses?.toString() ?? '');
    _descripcion = TextEditingController(text: m?.descripcion ?? '');
    _especie = _especies.contains(m?.especie) ? m!.especie : 'Perro';
    _estado = _estados.contains(m?.estadoAdopcion) ? m!.estadoAdopcion : 'Disponible';
    _refugioId = m?.refugioId;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _raza.dispose();
    _edad.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar(bool esAdmin, int? refugioDelEncargado) {
    if (!_clave.currentState!.validate()) return;
    final datos = <String, dynamic>{
      'nombre': _nombre.text.trim(),
      'especie': _especie,
      'raza': vacioANulo(_raza.text),
      'edad_meses': int.parse(_edad.text.trim()),
      'descripcion': vacioANulo(_descripcion.text),
      'estado_adopcion': _estado,
      'imagen_url': _quitarFoto ? null : widget.mascota?.imagenUrl,
    };
    if (esAdmin) {
      datos['refugio_id'] = _refugioId;
    } else if (widget.mascota == null) {
      // El servidor siempre usa el refugio del encargado; este valor solo cumple el formato
      datos['refugio_id'] = refugioDelEncargado ?? 1;
    }
    context.read<FormularioBloc>().add(MascotaGuardada(id: widget.mascota?.id, datos: datos, foto: _foto));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final usuario = auth is AuthAutenticado ? auth.sesion.usuario : null;
    final esAdmin = usuario?.esAdmin ?? false;

    return BlocBuilder<CatalogosBloc, CatalogosState>(
      builder: (context, catalogos) {
        if (catalogos is CatalogosError) {
          return VistaError(
            mensaje: catalogos.mensaje,
            alReintentar: () => context.read<CatalogosBloc>().add(const CatalogosSolicitados()),
          );
        }
        if (catalogos is! CatalogosCargados) return const PantallaCarga(compacta: true);
        if (esAdmin && _refugioId == null && catalogos.refugios.isNotEmpty) {
          _refugioId = catalogos.refugios.first.id;
        }
        return Form(
          key: _clave,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CampoTexto(
                etiqueta: 'Nombre',
                controlador: _nombre,
                maxLongitud: 100,
                accion: TextInputAction.next,
                validador: (v) => validarObligatorio(v, min: 2, nombre: 'El nombre'),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoLista<String>(
                      etiqueta: 'Especie',
                      valor: _especie,
                      opciones: [for (final e in _especies) DropdownMenuItem(value: e, child: Text(e))],
                      alCambiar: (v) => setState(() => _especie = v ?? _especie),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Edad (meses)',
                      controlador: _edad,
                      teclado: TextInputType.number,
                      validador: (v) => validarEntero(v, min: 0, max: 240, nombre: 'La edad'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Raza',
                controlador: _raza,
                obligatorio: false,
                maxLongitud: 50,
                pista: 'Ej: Labrador',
                validador: (v) => validarMaximo(v, 50, nombre: 'La raza'),
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Descripción',
                controlador: _descripcion,
                obligatorio: false,
                maxLineas: 4,
                pista: 'Historia y carácter de la mascota',
              ),
              const SizedBox(height: 14),
              CampoLista<String>(
                etiqueta: 'Estado',
                valor: _estado,
                opciones: [for (final e in _estados) DropdownMenuItem(value: e, child: Text(e))],
                alCambiar: (v) => setState(() => _estado = v ?? _estado),
              ),
              if (esAdmin) ...[
                const SizedBox(height: 14),
                CampoLista<int>(
                  etiqueta: 'Refugio',
                  valor: _refugioId,
                  opciones: [
                    for (final r in catalogos.refugios) DropdownMenuItem(value: r.id, child: Text(r.nombre)),
                  ],
                  alCambiar: (v) => setState(() => _refugioId = v),
                  validador: (v) => v == null ? 'Elige un refugio' : null,
                ),
              ],
              const SizedBox(height: 14),
              SelectorFoto(
                urlActual: widget.mascota?.imagenUrl,
                nueva: _foto,
                quitada: _quitarFoto,
                alElegir: (f) => setState(() {
                  _foto = f;
                  _quitarFoto = false;
                }),
                alQuitar: () => setState(() {
                  _foto = null;
                  _quitarFoto = true;
                }),
              ),
              const SizedBox(height: 20),
              BotonGuardar(
                texto: widget.mascota == null ? 'Crear mascota' : 'Guardar cambios',
                alPulsar: () => _guardar(esAdmin, usuario?.refugioId),
              ),
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
