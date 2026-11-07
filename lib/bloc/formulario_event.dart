import '../models/foto_nueva.dart';

/// Guardar lo que se llenó en un formulario de gestión (crear o editar).
sealed class FormularioEvent {
  const FormularioEvent();
}

/// Crea una mascota (id == null) o edita la que tiene ese id.
/// [foto] = foto nueva elegida (se sube primero); si no hay, el servidor conserva [datos]['imagen_url'].
class MascotaGuardada extends FormularioEvent {
  final int? id;
  final Map<String, dynamic> datos;
  final FotoNueva? foto;
  const MascotaGuardada({this.id, required this.datos, this.foto});
}

class ProductoGuardado extends FormularioEvent {
  final int? id;
  final Map<String, dynamic> datos;
  final FotoNueva? foto;
  final String categoriaNombre; // sirve para guardar la foto en la carpeta de su categoría
  const ProductoGuardado({this.id, required this.datos, this.foto, this.categoriaNombre = ''});
}

class RefugioGuardado extends FormularioEvent {
  final int? id;
  final Map<String, dynamic> datos;
  const RefugioGuardado({this.id, required this.datos});
}

/// Crea un encargado (id == null) o edita el que tiene ese id.
class EncargadoGuardado extends FormularioEvent {
  final int? id;
  final Map<String, dynamic> datos;
  const EncargadoGuardado({this.id, required this.datos});
}

/// El adoptante reporta cómo va su mascota adoptada.
class SeguimientoEnviado extends FormularioEvent {
  final int solicitudId;
  final String estadoSalud;
  final String? observaciones;
  const SeguimientoEnviado({required this.solicitudId, required this.estadoSalud, this.observaciones});
}
