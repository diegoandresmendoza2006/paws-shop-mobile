import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/descarga_repository.dart';
import '../services/api_service.dart';
import 'descarga_event.dart';
import 'descarga_state.dart';

/// Prepara las descargas (certificado y Excel): pide el enlace temporal al servidor.
class DescargaBloc extends Bloc<DescargaEvent, DescargaState> {
  final DescargaRepository _repositorio;

  DescargaBloc(this._repositorio) : super(const DescargaInicial()) {
    on<CertificadoPedido>((e, emit) => _preparar(emit, () => _repositorio.enlaceCertificado(e.solicitudId)));
    on<ReportePedido>((e, emit) =>
        _preparar(emit, () => _repositorio.enlaceReporte(mes: e.mes, historico: e.historico)));
  }

  Future<void> _preparar(Emitter<DescargaState> emit, Future<String> Function() pedirEnlace) async {
    if (state is DescargaPreparando) return; // ya hay una en camino: evita dobles toques
    emit(const DescargaPreparando());
    try {
      emit(DescargaLista(await pedirEnlace()));
    } on ApiException catch (e) {
      emit(DescargaError(e.mensaje));
    } catch (_) {
      emit(const DescargaError('No se pudo preparar la descarga.'));
    }
  }
}
