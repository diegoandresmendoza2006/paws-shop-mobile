import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/catalogos_bloc.dart';
import '../bloc/catalogos_event.dart';
import '../bloc/catalogos_state.dart';
import '../bloc/favoritos_bloc.dart';
import '../bloc/favoritos_event.dart';
import '../bloc/gestion_bloc.dart';
import '../bloc/gestion_event.dart';
import '../bloc/gestion_state.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/lista_event.dart';
import '../models/mascota.dart';
import '../repositories/admin_repository.dart';
import '../repositories/mascota_repository.dart';
import '../repositories/producto_repository.dart';
import '../repositories/refugio_repository.dart';
import '../repositories/solicitud_repository.dart';
import '../widgets/barra_busqueda.dart';
import '../widgets/boton_nuevo.dart';
import '../widgets/botones_gestion.dart';
import '../widgets/etiqueta_estado.dart';
import '../widgets/foto_mascota.dart';
import '../widgets/confirmar.dart';
import '../widgets/filtro_chips.dart';
import '../widgets/lista_paginada.dart';
import '../widgets/mostrar_aviso.dart';
import '../widgets/tarjeta_mascota.dart';
import 'detalle_mascota_page.dart';
import 'mascota_form_page.dart';

/// catalogo = lo que ve el cliente (todas las mascotas, con corazón de favorito).
/// gestion  = lo que ve el personal (su inventario, con menú para cambiar el estado o eliminar).
enum ModoMascotas { catalogo, gestion }

class MascotasPage extends StatelessWidget {
  final ModoMascotas modo;
  const MascotasPage({super.key, required this.modo});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ListaBloc<Mascota>>(
          create: (ctx) {
            final repo = ctx.read<MascotaRepository>();
            return ListaBloc<Mascota>((pagina, busqueda, filtros) {
              if (modo == ModoMascotas.catalogo) {
                return repo.buscar(
                  pagina: pagina,
                  busqueda: busqueda,
                  estado: filtros['estado'],
                  especie: filtros['especie'],
                );
              }
              return repo.inventario(
                  pagina: pagina,
                  busqueda: busqueda,
                  estado: filtros['estado'],
                  refugioId: filtros['refugio_id']);
            })
              ..add(const ListaIniciada());
          },
        ),
        if (modo == ModoMascotas.gestion)
          BlocProvider<CatalogosBloc>(
            create: (ctx) => CatalogosBloc(ctx.read<RefugioRepository>(), ctx.read<ProductoRepository>())
              ..add(const CatalogosSolicitados()),
          ),
        BlocProvider<GestionBloc>(
          create: (ctx) => GestionBloc(
            admin: ctx.read<AdminRepository>(),
            solicitudes: ctx.read<SolicitudRepository>(),
            mascotas: ctx.read<MascotaRepository>(),
        productos: ctx.read<ProductoRepository>(),
        refugios: ctx.read<RefugioRepository>(),
          ),
        ),
      ],
      child: _Contenido(modo: modo),
    );
  }
}

class _Contenido extends StatefulWidget {
  final ModoMascotas modo;
  const _Contenido({required this.modo});

  @override
  State<_Contenido> createState() => _ContenidoState();
}

class _ContenidoState extends State<_Contenido> {
  String _estado = '';
  String _especie = '';
  String _refugio = '';

  void _aplicarFiltros() {
    final filtros = <String, String>{};
    if (_estado.isNotEmpty) filtros['estado'] = _estado;
    if (_especie.isNotEmpty) filtros['especie'] = _especie;
    if (_refugio.isNotEmpty) filtros['refugio_id'] = _refugio;
    context.read<ListaBloc<Mascota>>().add(ListaFiltrada(filtros: filtros));
  }

  /// «+ Nueva mascota»: al volver, la lista empieza de nuevo (la nueva sale primero).
  Future<void> _nueva() async {
    final lista = context.read<ListaBloc<Mascota>>();
    final guardada = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const MascotaFormPage()));
    if (guardada == true) lista.add(const ListaIniciada());
  }

  bool _esAdmin(BuildContext context) {
    final estado = context.read<AuthBloc>().state;
    return estado is AuthAutenticado && estado.sesion.usuario.esAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final esCatalogo = widget.modo == ModoMascotas.catalogo;
    return BlocListener<GestionBloc, GestionState>(
      listener: (context, estado) {
        if (estado is GestionExitosa) {
          mostrarTexto(context, estado.mensaje);
          context.read<ListaBloc<Mascota>>().add(const ListaIniciada(silenciosa: true));
        } else if (estado is GestionError) {
          mostrarTexto(context, estado.mensaje, esError: true);
        }
      },
      child: Column(
        children: [
          if (!esCatalogo) BotonNuevo(texto: 'Nueva mascota', alPulsar: _nueva),
          BarraBusqueda(
            pista: esCatalogo ? 'Buscar por raza…' : 'Buscar por nombre…',
            alBuscar: (texto) =>
                context.read<ListaBloc<Mascota>>().add(ListaFiltrada(busqueda: texto)),
          ),
          FiltroChips(
            opciones: const {
              'Todas': '',
              'Disponible': 'Disponible',
              'En Proceso': 'En Proceso',
              'Adoptada': 'Adoptada',
            },
            seleccion: _estado,
            alElegir: (v) {
              setState(() => _estado = v);
              _aplicarFiltros();
            },
          ),
          if (!esCatalogo && _esAdmin(context))
            BlocBuilder<CatalogosBloc, CatalogosState>(
              builder: (context, catalogos) {
                if (catalogos is! CatalogosCargados || catalogos.refugios.length < 2) {
                  return const SizedBox.shrink();
                }
                return FiltroChips(
                  opciones: {
                    'Todos los refugios': '',
                    for (final r in catalogos.refugios) r.nombre: '${r.id}',
                  },
                  seleccion: _refugio,
                  alElegir: (v) {
                    setState(() => _refugio = v);
                    _aplicarFiltros();
                  },
                );
              },
            ),
          if (esCatalogo)
            FiltroChips(
              opciones: const {'Todas': '', 'Perros': 'Perro', 'Gatos': 'Gato'},
              seleccion: _especie,
              alElegir: (v) {
                setState(() => _especie = v);
                _aplicarFiltros();
              },
            ),
          Expanded(
            child: ListaPaginada<Mascota>(
              textoVacio: 'No encontramos mascotas con esa búsqueda',
              construirItem: (context, m) => esCatalogo
                  ? _TarjetaCatalogo(mascota: m)
                  : _TarjetaGestion(mascota: m),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta del catálogo: toca para ver el detalle; el corazón marca favorita.
class _TarjetaCatalogo extends StatelessWidget {
  final Mascota mascota;
  const _TarjetaCatalogo({required this.mascota});

  @override
  Widget build(BuildContext context) {
    final favorita = context
        .select<FavoritosBloc, bool>((b) => b.state.esMascotaFavorita(mascota.id));
    return TarjetaMascota(
      mascota: mascota,
      esFavorita: favorita,
      alAlternarFavorito: () =>
          context.read<FavoritosBloc>().add(MascotaAlternada(mascota.id)),
      alTocar: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DetalleMascotaPage(mascota: mascota))),
    );
  }
}

/// Tarjeta del personal: foto, datos, estado con color y los botones «Editar» y «Eliminar».
class _TarjetaGestion extends StatelessWidget {
  final Mascota mascota;
  const _TarjetaGestion({required this.mascota});

  Future<void> _editar(BuildContext context) async {
    final lista = context.read<ListaBloc<Mascota>>();
    final guardada = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => MascotaFormPage(mascota: mascota)));
    // Se queda en la misma página para ver el cambio
    if (guardada == true) lista.add(const ListaIniciada(silenciosa: true));
  }

  Future<void> _eliminar(BuildContext context) async {
    final gestion = context.read<GestionBloc>();
    final estado = context.read<AuthBloc>().state;
    final esAdmin = estado is AuthAutenticado && estado.sesion.usuario.esAdmin;
    final ok = await confirmar(
      context,
      titulo: '¿Eliminar mascota?',
      mensaje: esAdmin
          ? 'Vas a eliminar a «${mascota.nombre}». Si tiene solicitudes de adopción, también se borrarán '
              'esas solicitudes y sus seguimientos. Esta acción no se puede deshacer.'
          : 'Vas a eliminar a «${mascota.nombre}». Esta acción no se puede deshacer. '
              'Si ya tiene solicitudes de adopción, márcala como "Adoptada" para conservar el historial.',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok) gestion.add(MascotaEliminada(mascota.id, forzar: esAdmin));
  }

  @override
  Widget build(BuildContext context) {
    final tieneRaza = mascota.raza != null && mascota.raza!.isNotEmpty;
    final catalogos = context.watch<CatalogosBloc>().state;
    final refugio = catalogos is CatalogosCargados ? catalogos.nombreDeRefugio(mascota.refugioId) : '';
    final auth = context.watch<AuthBloc>().state;
    final esAdmin = auth is AuthAutenticado && auth.sesion.usuario.esAdmin;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DetalleMascotaPage(mascota: mascota))),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(width: 64, height: 64, child: FotoMascota(url: mascota.imagenUrl)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mascota.nombre,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('${tieneRaza ? mascota.raza! : mascota.especie} · ${mascota.edadTexto}',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        if (esAdmin && refugio.isNotEmpty)
                          Text(refugio,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        EtiquetaEstado(estado: mascota.estadoAdopcion),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            BotonesGestion(
              alEditar: () => _editar(context),
              alEliminar: () => _eliminar(context),
            ),
          ],
        ),
      ),
    );
  }
}
