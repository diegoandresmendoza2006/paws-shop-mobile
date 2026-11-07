import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/carrito_bloc.dart';
import '../bloc/carrito_state.dart';
import '../bloc/favoritos_bloc.dart';
import '../bloc/favoritos_event.dart';
import '../bloc/favoritos_state.dart';
import '../models/sesion.dart';
import '../widgets/confirmar.dart';
import '../widgets/foto_perfil.dart';
import '../widgets/mostrar_aviso.dart';
import '../widgets/pantalla_carga.dart';
import '../widgets/selector_tema.dart';
import 'auditoria_page.dart';
import 'carrito_page.dart';
import 'clientes_page.dart';
import 'encargados_page.dart';
import 'favoritos_page.dart';
import 'mascotas_page.dart';
import 'panel_page.dart';
import 'productos_gestion_page.dart';
import 'refugios_page.dart';
import 'perfil_page.dart';
import 'seguimientos_page.dart';
import 'solicitudes_page.dart';
import 'tienda_page.dart';
import 'tramites_page.dart';
import '../utils/colores.dart';

/// Una pestaña de la barra de abajo.
class _Destino {
  final String titulo;
  final IconData icono;
  final Widget Function() pantalla;
  final bool esCarrito; // muestra la cantidad de productos
  final bool refrescar; // vuelve a cargar los datos cada vez que se entra a la pestaña

  const _Destino(this.titulo, this.icono, this.pantalla,
      {this.esCarrito = false, this.refrescar = false});
}

/// Pantalla principal: las pestañas cambian según el rol (Usuario, Encargado o Administrador).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _clave = GlobalKey<ScaffoldState>();
  int _indice = 0;
  final Set<int> _visitadas = {0}; // las pestañas se crean solo cuando se visitan
  final Map<int, int> _versiones = {}; // sube cada vez que una pestaña "refrescable" se abre

  @override
  void initState() {
    super.initState();
    final estado = context.read<AuthBloc>().state;
    if (estado is AuthAutenticado && estado.sesion.usuario.esUsuario) {
      context.read<FavoritosBloc>().add(const FavoritosCargados());
    }
  }

  List<_Destino> _destinosDe(Sesion sesion) {
    final u = sesion.usuario;
    if (u.esAdmin) {
      return [
        _Destino('Panel', Icons.dashboard_outlined, () => const PanelPage(), refrescar: true),
        _Destino('Mascotas', Icons.pets, () => const MascotasPage(modo: ModoMascotas.gestion)),
        _Destino('Productos', Icons.storefront_outlined, () => const ProductosGestionPage()),
        _Destino('Auditoría', Icons.fact_check_outlined, () => const AuditoriaPage(), refrescar: true),
      ];
    }
    if (u.esEncargado) {
      return [
        _Destino('Mascotas', Icons.pets, () => const MascotasPage(modo: ModoMascotas.gestion)),
        _Destino('Productos', Icons.storefront_outlined, () => const ProductosGestionPage()),
        _Destino('Solicitudes', Icons.assignment_outlined, () => const SolicitudesPage(), refrescar: true),
        _Destino('Seguim.', Icons.monitor_heart_outlined,
            () => const SeguimientosPage(delPersonal: true), refrescar: true),
      ];
    }
    return [
      _Destino('Catálogo', Icons.pets, () => const MascotasPage(modo: ModoMascotas.catalogo)),
      _Destino('Tienda', Icons.storefront_outlined, () => const TiendaPage(conCompra: true)),
      _Destino('Carrito', Icons.shopping_cart_outlined, () => const CarritoPage(), esCarrito: true),
      _Destino('Trámites', Icons.assignment_outlined, () => const TramitesPage(), refrescar: true),
    ];
  }

  void _elegir(int i, List<_Destino> destinos) {
    setState(() {
      _indice = i;
      _visitadas.add(i);
      if (destinos[i].refrescar) _versiones[i] = (_versiones[i] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<AuthBloc>().state;
    if (estado is! AuthAutenticado) return const Scaffold(body: PantallaCarga());
    final sesion = estado.sesion;
    final destinos = _destinosDe(sesion);
    if (_indice >= destinos.length) _indice = 0;

    final usuario = sesion.usuario;
    return Scaffold(
      key: _clave,
      appBar: AppBar(
        // Arriba a la izquierda va la foto de perfil (abre «Mi perfil»); el menú está abajo a la derecha
        automaticallyImplyLeading: false,
        automaticallyImplyActions: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Tooltip(
              message: 'Mi perfil',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PerfilPage())),
                child: FotoPerfil(url: usuario.fotoUrl, iniciales: usuario.iniciales, tamano: 38),
              ),
            ),
          ),
        ),
        title: Text(destinos[_indice].titulo),
        actions: [
          if (sesion.usuario.esUsuario)
            IconButton(
              tooltip: 'Mis favoritos',
              icon: const Icon(Icons.favorite_border),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const FavoritosPage())),
            ),
        ],
      ),
      endDrawer: _MenuLateral(sesion: sesion),
      body: MultiBlocListener(
        listeners: [
          BlocListener<CarritoBloc, CarritoState>(
            listenWhen: (a, b) => b.aviso != null && a.aviso != b.aviso,
            listener: (context, s) => mostrarAviso(context, s.aviso!),
          ),
          BlocListener<FavoritosBloc, FavoritosState>(
            listenWhen: (a, b) => b.aviso != null && a.aviso != b.aviso,
            listener: (context, s) => mostrarAviso(context, s.aviso!),
          ),
        ],
        child: IndexedStack(
          index: _indice,
          children: [
            for (var i = 0; i < destinos.length; i++)
              _visitadas.contains(i)
                  ? KeyedSubtree(
                      key: ValueKey('destino-$i-${_versiones[i] ?? 0}'),
                      child: destinos[i].pantalla(),
                    )
                  : const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        // El último botón («Menú», abajo a la derecha) abre el menú lateral sin cambiar de pestaña
        onDestinationSelected: (i) =>
            i == destinos.length ? _clave.currentState?.openEndDrawer() : _elegir(i, destinos),
        destinations: [
          for (final d in destinos)
            NavigationDestination(
              icon: d.esCarrito
                  ? BlocBuilder<CarritoBloc, CarritoState>(
                      builder: (context, c) => Badge(
                        isLabelVisible: c.cantidadTotal > 0,
                        label: Text('${c.cantidadTotal}'),
                        child: Icon(d.icono),
                      ),
                    )
                  : Icon(d.icono),
              label: d.titulo,
            ),
          const NavigationDestination(icon: Icon(Icons.menu), label: 'Menú'),
        ],
      ),
    );
  }
}

/// Menú lateral: perfil, favoritos, cambiar de rol y cerrar sesión.
class _MenuLateral extends StatelessWidget {
  final Sesion sesion;
  const _MenuLateral({required this.sesion});

  @override
  Widget build(BuildContext context) {
    final u = sesion.usuario;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  FotoPerfil(url: u.fotoUrl, iniciales: u.iniciales, tamano: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.nombreCompleto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(u.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(u.rol,
                            style: TextStyle(
                                color: context.verdeFuerte, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.of(context).pop(); // cierra el menú
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PerfilPage()));
              },
            ),
            if (u.esUsuario)
              const _Entrada(Icons.monitor_heart_outlined, 'Mis seguimientos',
                  SeguimientosPage(delPersonal: false)),
            if (u.esUsuario)
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text('Mis favoritos'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const FavoritosPage()));
                },
              ),
            if (u.esAdmin) ...[
              _Entrada(Icons.home_work_outlined, 'Refugios', const RefugiosPage()),
              _Entrada(Icons.badge_outlined, 'Encargados', const EncargadosPage()),
              _Entrada(Icons.people_outline, 'Clientes', const ClientesPage()),
              _Entrada(Icons.monitor_heart_outlined, 'Seguimientos', const SeguimientosPage(delPersonal: true)),
            ],
            if (sesion.tieneVariosRoles)
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Cambiar de rol'),
                subtitle: Text('Ahora: ${u.rol}'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(const CambioDeRolSolicitado());
                },
              ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SelectorTema(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                final bloc = context.read<AuthBloc>();
                final ok = await confirmar(context,
                    titulo: 'Cerrar sesión',
                    mensaje: '¿Quieres salir de tu cuenta?',
                    textoConfirmar: 'Salir');
                // Al cerrar sesión, main.dart vuelve al login y cierra también este menú
                if (ok) bloc.add(const SesionCerrada());
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Entrada del menú lateral que abre una pantalla de gestión con su propia barra superior.
class _Entrada extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Widget pantalla;
  const _Entrada(this.icono, this.titulo, this.pantalla);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      onTap: () {
        Navigator.of(context).pop(); // cierra el menú
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(appBar: AppBar(title: Text(titulo)), body: pantalla),
        ));
      },
    );
  }
}
