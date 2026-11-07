/// Lo que la pantalla le PIDE al DescargaBloc.
sealed class DescargaEvent {
  const DescargaEvent();
}

class CertificadoPedido extends DescargaEvent {
  final int solicitudId;
  const CertificadoPedido(this.solicitudId);
}

class ReportePedido extends DescargaEvent {
  final String? mes; // '2026-11'
  final bool historico;
  const ReportePedido({this.mes, this.historico = false});
}
