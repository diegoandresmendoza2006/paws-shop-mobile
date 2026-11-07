import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import 'bloc/carrito_bloc.dart';
import 'bloc/carrito_event.dart';
import 'bloc/favoritos_bloc.dart';
import 'bloc/favoritos_event.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/seleccion_rol_page.dart';
import 'repositories/admin_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/compra_repository.dart';
import 'repositories/descarga_repository.dart';
import 'repositories/tema_repository.dart';
import 'bloc/tema_bloc.dart';
import 'bloc/tema_event.dart';
import 'repositories/favorito_repository.dart';
import 'repositories/imagen_repository.dart';
import 'repositories/mascota_repository.dart';
import 'repositories/perfil_repository.dart';
import 'repositories/producto_repository.dart';
import 'repositories/refugio_repository.dart';
import 'repositories/seguimiento_repository.dart';
import 'repositories/solicitud_repository.dart';
import 'services/api_service.dart';
import 'widgets/pantalla_carga.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PawsShopApp());
}

class PawsShopApp extends StatefulWidget {
  /// Se puede pasar un ApiService falso en las pruebas.
  final ApiService? api;
  const PawsShopApp({super.key, this.api});

  @override
  State<PawsShopApp> createState() => _PawsShopAppState();
}

class _PawsShopAppState extends State<PawsShopApp> {
  // UN SOLO ApiService para toda la app: así todos los repositorios comparten el mismo token.
  late final ApiService _api = widget.api ?? ApiService();
  late final AuthRepository _auth = AuthRepository(api: _api);
  late final PerfilRepository _perfil = PerfilRepository(api: _api);
  late final MascotaRepository _mascotas = MascotaRepository(api: _api);
  late final ProductoRepository _productos = ProductoRepository(api: _api);
  late final FavoritoRepository _favoritos = FavoritoRepository(api: _api);
  late final CompraRepository _compras = CompraRepository(api: _api);
  late final SolicitudRepository _solicitudes = SolicitudRepository(api: _api);
  late final SeguimientoRepository _seguimientos = SeguimientoRepository(api: _api);
  late final AdminRepository _admin = AdminRepository(api: _api);
  late final RefugioRepository _refugios = RefugioRepository(api: _api);
  late final ImagenRepository _imagenes = ImagenRepository(api: _api);
  late final DescargaRepository _descargas = DescargaRepository(api: _api);
  late final AuthBloc _authBloc = AuthBloc(_auth, restaurar: true);

  @override
  void initState() {
    super.initState();
    // Si el servidor dice "sesión vencida", volvemos al login
    _api.alExpirarSesion = () => _authBloc.add(const SesionCerrada());
    _despertarServidor();
    _authBloc.add(const SesionRestaurada()); // ¿quedó una sesión guardada?
  }

  /// Render (plan gratis) duerme el servidor. Lo "llamamos" apenas se abre la app para que,
  /// cuando la persona termine de escribir su correo, ya esté despierto.
  Future<void> _despertarServidor() async {
    try {
      await _api.get('/health');
    } catch (_) {
      // Si falla no pasa nada: el login mostrará el error real
    }
  }

  @override
  void dispose() {
    _authBloc.close();
    _api.cerrar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _auth),
        RepositoryProvider<PerfilRepository>.value(value: _perfil),
        RepositoryProvider<MascotaRepository>.value(value: _mascotas),
        RepositoryProvider<ProductoRepository>.value(value: _productos),
        RepositoryProvider<FavoritoRepository>.value(value: _favoritos),
        RepositoryProvider<CompraRepository>.value(value: _compras),
        RepositoryProvider<SolicitudRepository>.value(value: _solicitudes),
        RepositoryProvider<SeguimientoRepository>.value(value: _seguimientos),
        RepositoryProvider<AdminRepository>.value(value: _admin),
        RepositoryProvider<RefugioRepository>.value(value: _refugios),
        RepositoryProvider<ImagenRepository>.value(value: _imagenes),
        RepositoryProvider<DescargaRepository>.value(value: _descargas),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<CarritoBloc>(create: (_) => CarritoBloc(_compras)),
          BlocProvider<FavoritosBloc>(create: (_) => FavoritosBloc(_favoritos)),
          BlocProvider<TemaBloc>(create: (_) => TemaBloc(TemaRepository())),
        ],
        // El modo claro/oscuro es de cada persona: se carga al entrar y se quita al cerrar la sesión
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, auth) {
            final tema = context.read<TemaBloc>();
            if (auth is AuthAutenticado) {
              tema.add(TemaDePersonaCargado(auth.sesion.usuario.email));
            } else if (auth is AuthInicial || auth is AuthError) {
              tema.add(const TemaDePersonaCerrado());
            }
          },
          child: BlocBuilder<TemaBloc, ThemeMode>(
          builder: (context, modo) => MaterialApp(
          title: 'Paws&Shop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF28A745),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF28A745),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: modo,
          // Español: el calendario y los textos del sistema salen en español
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const _Raiz(),
          ),
          ),
        ),
      ),
    );
  }
}

/// Decide qué pantalla se ve según la sesión: login, "¿cómo quieres entrar?" o la principal.
class _Raiz extends StatelessWidget {
  const _Raiz();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, estado) {
        if (estado is AuthInicial) {
          // Cerró sesión: se vacía el carrito y los favoritos de esa persona
          context.read<CarritoBloc>().add(const CarritoVaciado());
          context.read<FavoritosBloc>().add(const FavoritosReiniciados());
        }
        if (estado is AuthInicial || estado is AuthElegirRol) {
          // Cierra cualquier pantalla abierta encima (detalle, perfil, menú...)
          Navigator.of(context).popUntil((ruta) => ruta.isFirst);
        }
      },
      builder: (context, estado) {
        if (estado is AuthAutenticado) {
          return HomePage(key: ValueKey(estado.sesion.usuario.id));
        }
        if (estado is AuthRestaurando) {
          return const Scaffold(body: PantallaCarga(mensaje: 'Abriendo tu sesión…'));
        }
        if (estado is AuthElegirRol) return SeleccionRolPage(estado: estado);
        if (estado is AuthCargando && estado.conSesion) {
          return const Scaffold(body: PantallaCarga(mensaje: 'Cambiando de rol…'));
        }
        return const LoginPage();
      },
    );
  }
}
