import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/catalogos_bloc.dart';
import '../bloc/catalogos_event.dart';
import '../bloc/catalogos_state.dart';
import '../bloc/formulario_bloc.dart';
import '../bloc/formulario_event.dart';
import '../models/foto_nueva.dart';
import '../models/producto.dart';
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

/// Crear o editar un producto de la tienda solidaria.
class ProductoFormPage extends StatelessWidget {
  final Producto? producto; // null = crear uno nuevo
  const ProductoFormPage({super.key, this.producto});

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
        appBar: AppBar(title: Text(producto == null ? 'Nuevo producto' : 'Editar producto')),
        body: EscuchaFormulario(child: _Formulario(producto: producto)),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  final Producto? producto;
  const _Formulario({required this.producto});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _clave = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  late final TextEditingController _stock;
  late final TextEditingController _descripcion;
  int? _categoriaId;
  FotoNueva? _foto;
  bool _quitarFoto = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _precio = TextEditingController(text: p == null ? '' : _sinCeros(p.precio));
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _categoriaId = p?.categoriaId;
  }

  /// 45900.0 -> "45900"; 4.5 -> "4.5"
  static String _sinCeros(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar(CatalogosCargados catalogos) {
    if (!_clave.currentState!.validate()) return;
    final datos = <String, dynamic>{
      'nombre': _nombre.text.trim(),
      'categoria_id': _categoriaId,
      'precio': double.parse(_precio.text.trim().replaceAll(',', '.')),
      'stock': int.parse(_stock.text.trim()),
      'descripcion': vacioANulo(_descripcion.text),
      'imagen_url': _quitarFoto ? null : widget.producto?.imagenUrl,
    };
    context.read<FormularioBloc>().add(ProductoGuardado(
          id: widget.producto?.id,
          datos: datos,
          foto: _foto,
          categoriaNombre: catalogos.nombreDeCategoria(_categoriaId ?? 0),
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
        if (_categoriaId == null && catalogos.categorias.isNotEmpty) {
          _categoriaId = catalogos.categorias.first.id;
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
              CampoLista<int>(
                etiqueta: 'Categoría',
                valor: _categoriaId,
                opciones: [
                  for (final c in catalogos.categorias) DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                ],
                alCambiar: (v) => setState(() => _categoriaId = v),
                validador: (v) => v == null ? 'Elige una categoría' : null,
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Precio (\$)',
                      controlador: _precio,
                      teclado: const TextInputType.numberWithOptions(decimal: true),
                      validador: validarPrecio,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CampoTexto(
                      etiqueta: 'Stock',
                      controlador: _stock,
                      teclado: TextInputType.number,
                      validador: (v) => validarEntero(v, min: 0, max: 100000, nombre: 'El stock'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CampoTexto(
                etiqueta: 'Descripción',
                controlador: _descripcion,
                obligatorio: false,
                maxLineas: 4,
              ),
              const SizedBox(height: 14),
              SelectorFoto(
                urlActual: widget.producto?.imagenUrl,
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
                texto: widget.producto == null ? 'Crear producto' : 'Guardar cambios',
                alPulsar: () => _guardar(catalogos),
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
