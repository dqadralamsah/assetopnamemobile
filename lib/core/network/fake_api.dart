/// Gagal mengirim ke server (tidak ada sinyal, server error, dll.).
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Pengganti API server selama backend belum ada.
///
/// Nanti diganti HTTP client sungguhan (dio) dengan method & payload yang
/// sama — lihat dokumen 07. API Contract di vault.
class FakeApi {
  FakeApi({required this.isOffline});

  /// Dibaca setiap request, supaya toggle "Simulasi offline" langsung berlaku.
  final bool Function() isOffline;

  /// `POST /opname-results`
  Future<void> postOpnameResult(Map<String, dynamic> json) => _send();

  /// `POST /adjustments`
  Future<void> postAdjustment(Map<String, dynamic> json) => _send();

  Future<void> _send() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (isOffline()) throw const ApiException('Tidak ada koneksi');
  }
}
