import 'package:flutter/material.dart';

/// Colores de un estado: [fondo] suave y [texto] fuerte.
class PaletaEstado {
  final Color fondo;
  final Color texto;
  const PaletaEstado(this.fondo, this.texto);
}

/// Cada estado tiene SU color en toda la app:
///   verde  = bien / disponible / aprobada      naranja = pendiente / en proceso
///   azul   = adoptada / actualización          rojo    = rechazada / eliminación
PaletaEstado paletaDeEstado(String estado, {bool oscuro = false}) {
  final base = _paletaClara(estado);
  if (!oscuro) return base;
  // En modo oscuro: fondo translúcido del mismo color y texto más claro para que se lea
  return PaletaEstado(base.texto.withAlpha(48), Color.lerp(base.texto, Colors.white, 0.6)!);
}

PaletaEstado _paletaClara(String estado) {
  switch (estado) {
    case 'Disponible':
    case 'Aprobada':
    case 'Excelente':
    case 'Bueno':
    case 'Pagada':
    case 'INSERT':
      return const PaletaEstado(Color(0xFFE8F5E9), Color(0xFF1B5E20));
    case 'En Proceso':
    case 'En Revisión':
    case 'Regular':
      return const PaletaEstado(Color(0xFFFFF3E0), Color(0xFFE65100));
    case 'Adoptada':
    case 'UPDATE':
      return const PaletaEstado(Color(0xFFE3F2FD), Color(0xFF0D47A1));
    case 'Rechazada':
    case 'Requiere atención':
    case 'DELETE':
      return const PaletaEstado(Color(0xFFFDECEA), Color(0xFFB71C1C));
    default:
      return const PaletaEstado(Color(0xFFECEFF1), Color(0xFF455A64));
  }
}

/// Píldora de color con el estado: "Disponible" (verde), "En Proceso" (naranja), "Adoptada" (azul)...
class EtiquetaEstado extends StatelessWidget {
  final String estado;
  const EtiquetaEstado({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final paleta = paletaDeEstado(estado, oscuro: Theme.of(context).brightness == Brightness.dark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: paleta.fondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: paleta.texto.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: paleta.texto, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(estado,
              style: TextStyle(
                  color: paleta.texto, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}
