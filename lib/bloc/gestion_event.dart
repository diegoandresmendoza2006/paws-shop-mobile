/// Acciones del personal y del administrador (editar, eliminar, aprobar...).
sealed class GestionEvent {
  const GestionEvent();
}

class ClienteEditado extends GestionEvent {
  final int id;
  final Map<String, dynamic> datos;
  const ClienteEditado(this.id, this.datos);
}

/// [forzar] = true borra también su historial (solo después de que el admin lo confirme).
class ClienteEliminado extends GestionEvent {
  final int id;
  final bool forzar;
  const ClienteEliminado(this.id, {this.forzar = false});
}

/// Aprobar o rechazar una solicitud de adopción (estado: 'Aprobada' | 'Rechazada').
class SolicitudResuelta extends GestionEvent {
  final int id;
  final String estado;
  final String comentario;
  const SolicitudResuelta(this.id, this.estado, this.comentario);
}

class MascotaEstadoCambiado extends GestionEvent {
  final int id;
  final String estado;
  const MascotaEstadoCambiado(this.id, this.estado);
}

class MascotaEliminada extends GestionEvent {
  final int id;
  final bool forzar;
  const MascotaEliminada(this.id, {this.forzar = false});
}

class ProductoEliminado extends GestionEvent {
  final int id;
  const ProductoEliminado(this.id);
}

class RefugioEliminado extends GestionEvent {
  final int id;
  const RefugioEliminado(this.id);
}

class EncargadoEliminado extends GestionEvent {
  final int id;
  final bool forzar;
  const EncargadoEliminado(this.id, {this.forzar = false});
}
