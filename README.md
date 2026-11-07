# Paws&Shop (app móvil)

Aplicación **Flutter** de **adopción de mascotas y tienda solidaria**. Los usuarios adoptan y compran;
los encargados gestionan su refugio; el administrador supervisa todo el sistema.

Consume el backend propio (FastAPI + PostgreSQL) desplegado en la nube:
**https://paws-shop-api.onrender.com** · documentación interactiva: `/docs`

> Corre en planes gratuitos (Render, Neon y Cloudinary). Si nadie la usó en los últimos 15 minutos,
> la primera petición puede tardar cerca de 1 minuto mientras la API despierta.

## Roles

| Rol | Qué puede hacer |
|---|---|
| **Usuario** | Ver catálogo, solicitar adopciones, comprar en la tienda, favoritos y carrito, ver sus trámites, enviar seguimientos y descargar el certificado de adopción |
| **Encargado** | CRUD de mascotas y productos de su refugio, aprobar o rechazar solicitudes, ver seguimientos |
| **Administrador** | Dashboard por meses, exportar el reporte en Excel, gestionar refugios, encargados y usuarios |

Una misma persona puede tener dos cuentas (por ejemplo Encargado y Usuario) y cambiar de rol sin volver a escribir la contraseña.

## Características

- Sesión que se recuerda al cerrar y abrir la app (token guardado en el dispositivo; dura 7 días).
- Modo claro, oscuro o automático, recordado **por persona**; sin sesión siempre se ve en claro.
- Paginación por páginas (botones Anterior / Siguiente).
- Fotos de perfil, mascotas y productos en Cloudinary (al reemplazar o eliminar, la foto vieja se borra).
- Contraseña fuerte con lista de requisitos en vivo.
- Certificado de adopción en PDF y reporte Excel descargables mediante enlaces temporales de 5 minutos.

## Arquitectura

Patrón **BLoC** (`flutter_bloc`): las pantallas solo muestran estado y envían eventos; la lógica vive en los blocs.

```
lib/
├── bloc/          # eventos, estados y blocs (auth, listas, panel, formularios, tema...)
├── models/        # clases modelo con fromJson
├── pages/         # pantallas
├── repositories/  # acceso a datos por tema (auth, mascotas, productos...)
├── services/      # ApiService: HTTP, token, errores y tiempo de espera
├── utils/         # configuración de la API, validadores, formato, colores
├── widgets/       # componentes reutilizables
└── main.dart
test/              # pruebas de blocs, modelos, validadores y servicio HTTP
```

Flujo: **Página → Bloc → Repositorio → ApiService → API REST**.

## Cómo ejecutarla

Requisitos: Flutter SDK 3.x. En Windows, activar el **Modo de desarrollador** (necesario para compilar plugins).

```bash
flutter pub get
flutter run -d chrome --web-port=4300
```

Usa siempre el mismo puerto: en web la sesión guardada depende de él.

Por defecto apunta al backend en Render. Para usar un backend local:

```bash
flutter run --dart-define=API_URL=http://localhost:8000
```

(En el emulador de Android, `http://10.0.2.2:8000`).

## Pruebas

```bash
flutter analyze
flutter test
```

## Backend y mockups

El backend, la base de datos y los mockups de las pantallas están en el repositorio
[adopcion-ecommerce](https://github.com/diegoandresmendoza2006/adopcion-ecommerce).
