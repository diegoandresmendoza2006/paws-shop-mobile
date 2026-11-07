import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/descarga_bloc.dart';
import '../bloc/descarga_event.dart';
import '../bloc/descarga_state.dart';
import '../bloc/panel_bloc.dart';
import '../bloc/panel_event.dart';
import '../bloc/panel_state.dart';
import '../models/mes_historial.dart';
import '../repositories/admin_repository.dart';
import '../repositories/descarga_repository.dart';
import '../utils/formato.dart';
import '../widgets/escucha_descarga.dart';
import '../widgets/filtro_chips.dart';
import '../widgets/pantalla_carga.dart';
import '../widgets/vista_error.dart';
import '../utils/colores.dart';

const _verde = Color(0xFF28A745);

/// Panel del administrador: los números de un mes, de todo el historial y mes a mes,
/// con el botón para exportarlos a Excel.
class PanelPage extends StatelessWidget {
  const PanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => PanelBloc(ctx.read<AdminRepository>())..add(const PanelSolicitado())),
        BlocProvider(create: (ctx) => DescargaBloc(ctx.read<DescargaRepository>())),
      ],
      child: EscuchaDescarga(
        child: BlocBuilder<PanelBloc, PanelState>(
          builder: (context, estado) {
            if (estado is PanelError) {
              return VistaError(
                mensaje: estado.mensaje,
                alReintentar: () => context.read<PanelBloc>().add(const PanelSolicitado()),
              );
            }
            if (estado is! PanelCargado) return const PantallaCarga(compacta: true);
            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<PanelBloc>();
                bloc.add(const PanelSolicitado(silencioso: true));
                await bloc.stream.firstWhere((s) => s is PanelCargado || s is PanelError);
              },
              child: _Contenido(estado: estado),
            );
          },
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  final PanelCargado estado;
  const _Contenido({required this.estado});

  @override
  Widget build(BuildContext context) {
    final meses = estado.historial.reversed.toList(); // del más reciente al más antiguo
    final opciones = <String, String>{
      'Todo el historial': PanelBloc.todoElHistorial,
      for (final m in meses) mesCorto(m.mes): m.mes,
    };
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        FiltroChips(
          opciones: opciones,
          seleccion: estado.periodo,
          alElegir: (v) => context.read<PanelBloc>().add(PanelPeriodoElegido(v)),
        ),
        if (estado.cambiandoPeriodo) const LinearProgressIndicator(minHeight: 3),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(estado.esHistorico ? 'Todo el historial' : 'Resumen de ${estado.titulo}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _Cuadricula(estado: estado),
              const SizedBox(height: 12),
              _BotonExcel(estado: estado),
              const SizedBox(height: 24),
              Text('Mes a mes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Toca un mes para ver su resumen.', style: TextStyle(color: context.textoSecundario)),
              const SizedBox(height: 12),
              _MesAMes(meses: meses, elegido: estado.periodo),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotonExcel extends StatelessWidget {
  final PanelCargado estado;
  const _BotonExcel({required this.estado});

  @override
  Widget build(BuildContext context) {
    final preparando = context.watch<DescargaBloc>().state is DescargaPreparando;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: preparando
            ? null
            : () => context.read<DescargaBloc>().add(estado.esHistorico
                ? const ReportePedido(historico: true)
                : ReportePedido(mes: estado.periodo)),
        icon: preparando
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.download_outlined),
        label: Text(preparando ? 'Preparando Excel…' : 'Exportar a Excel · ${estado.titulo}'),
      ),
    );
  }
}

class _Cuadricula extends StatelessWidget {
  final PanelCargado estado;
  const _Cuadricula({required this.estado});

  @override
  Widget build(BuildContext context) {
    final m = estado.metricas;
    final datos = <(IconData, String, String)>[
      (Icons.assignment_outlined, 'Solicitudes', '${estado.solicitudes}'),
      (Icons.favorite_outline, 'Adopciones', '${estado.adopciones}'),
      (Icons.shopping_bag_outlined, 'Pedidos', '${estado.pedidos}'),
      (Icons.payments_outlined, 'Ventas', moneda(estado.ventas)),
      (Icons.person_add_alt, 'Usuarios nuevos', '${estado.usuariosNuevos}'),
      (Icons.account_balance_wallet_outlined, 'Ventas totales', moneda(m.ventasTotales)),
      (Icons.people_outline, 'Usuarios registrados', '${m.usuariosRegistrados}'),
      (Icons.pets, 'Mascotas disponibles', '${m.mascotasDisponibles}'),
      (Icons.home_outlined, 'Mascotas adoptadas', '${m.mascotasAdoptadas}'),
    ];
    return LayoutBuilder(
      builder: (context, restricciones) {
        final ancho = (restricciones.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final d in datos)
              SizedBox(
                width: ancho,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(d.$1, color: _verde),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(d.$3,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        Text(d.$2, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Una fila por mes con una barra de ventas proporcional al mejor mes.
class _MesAMes extends StatelessWidget {
  final List<MesHistorial> meses;
  final String elegido;
  const _MesAMes({required this.meses, required this.elegido});

  @override
  Widget build(BuildContext context) {
    final mayor = meses.fold<double>(0, (a, m) => m.ventas > a ? m.ventas : a);
    return Column(
      children: [
        for (final m in meses)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: m.mes == elegido ? _verde : Colors.transparent, width: 2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.read<PanelBloc>().add(PanelPeriodoElegido(m.mes)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(m.nombre, style: Theme.of(context).textTheme.titleMedium)),
                        Text(moneda(m.ventas),
                            style: TextStyle(fontWeight: FontWeight.w800, color: context.verdeFuerte)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: mayor == 0 ? 0 : m.ventas / mayor,
                        minHeight: 8,
                        color: _verde,
                        backgroundColor: context.verdeSuave,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${m.solicitudes} solicitudes · ${m.adopciones} adopciones · '
                      '${m.pedidos} pedidos · ${m.usuariosNuevos} usuarios nuevos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
