import 'asset.dart';

/// Cara aset diidentifikasi saat opname.
enum OpnameMethod {
  scan('Scan QR', 'SCAN QR'),
  manual('Manual', 'MANUAL');

  const OpnameMethod(this.label, this.badge);
  final String label;
  final String badge;
}

/// Hasil pemeriksaan aset.
enum OpnameStatus {
  sesuai('Sesuai'),
  kondisiBerubah('Kondisi berubah'),
  bedaLokasi('Beda lokasi'),
  tidakDitemukan('Tidak ditemukan');

  const OpnameStatus(this.label);
  final String label;

  /// Selain "Sesuai" dihitung sebagai bermasalah.
  bool get isProblem => this != OpnameStatus.sesuai;
}

/// Periode opname, mis. Semester II 2026. Hasil dihitung per periode.
class OpnamePeriod {
  const OpnamePeriod({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
  });

  /// Dari JSON API `GET /periods/active`. [end] = hari terakhir periode.
  factory OpnamePeriod.fromJson(Map<String, dynamic> json) => OpnamePeriod(
        id: json['id'] as String,
        name: json['name'] as String,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
      );

  final String id;
  final String name;
  final DateTime start;
  final DateTime end;

  /// Sisa hari sampai periode berakhir (0 kalau sudah lewat).
  int daysLeft(DateTime now) {
    final days = end.difference(now).inDays;
    return days < 0 ? 0 : days;
  }
}

/// Alasan input manual (tanpa scan).
const manualReasons = [
  'Label belum terpasang',
  'Label rusak',
  'Label hilang',
  'Kamera/scan gagal',
  'Lainnya',
];

/// Alasan yang otomatis membuat permintaan cetak label baru.
const labelReprintReasons = {
  'Label belum terpasang',
  'Label rusak',
  'Label hilang',
};

/// Satu kali pencatatan opname untuk satu aset. Satu aset bisa punya
/// beberapa (riwayat); yang terbaru dianggap hasil aset itu.
class OpnameResult {
  const OpnameResult({
    this.id,
    required this.periodId,
    required this.assetId,
    required this.method,
    required this.status,
    required this.condition,
    required this.recordedAt,
    this.note = '',
    this.manualReason = '',
    this.photoCount = 0,
    this.gpsDistanceM = 0,
    this.synced = false,
  });

  /// ID baris di database lokal (null sebelum disimpan).
  final int? id;

  /// Periode tempat hasil ini dicatat ([OpnamePeriod.id]).
  final String periodId;
  final String assetId;
  final OpnameMethod method;
  final OpnameStatus status;
  final AssetCondition condition;
  final DateTime recordedAt;
  final String note;

  /// Wajib diisi kalau [method] = manual (kenapa tidak scan).
  final String manualReason;
  final int photoCount;

  /// Jarak posisi petugas ke titik aset saat simpan (meter).
  final double gpsDistanceM;

  /// Sudah terkirim ke server atau belum.
  final bool synced;

  /// Payload `POST /opname-results`. Pasangan (asset_id, recorded_at)
  /// unik, jadi kirim ulang hasil yang sama tidak membuat data ganda.
  Map<String, dynamic> toJson() => {
        'period_id': periodId,
        'asset_id': assetId,
        'method': method.name,
        'status': status.name,
        'condition': condition.code,
        'recorded_at': recordedAt.toUtc().toIso8601String(),
        'note': note,
        'manual_reason': manualReason,
        'photo_count': photoCount,
        'gps_distance_m': gpsDistanceM,
      };

  OpnameResult copyWith({int? id, bool? synced}) => OpnameResult(
        id: id ?? this.id,
        periodId: periodId,
        assetId: assetId,
        method: method,
        status: status,
        condition: condition,
        recordedAt: recordedAt,
        note: note,
        manualReason: manualReason,
        photoCount: photoCount,
        gpsDistanceM: gpsDistanceM,
        synced: synced ?? this.synced,
      );
}

/// Usulan koreksi data master aset (stock adjustment).
/// Baru berlaku setelah disetujui admin di website.
class AdjustmentRequest {
  const AdjustmentRequest({
    this.id,
    required this.assetId,
    required this.changes,
    required this.reason,
    required this.createdAt,
    this.synced = false,
  });

  /// ID baris di database lokal (null sebelum disimpan).
  final int? id;
  final String assetId;

  /// Nama field → nilai baru, mis. {'Lokasi / Pad': 'Pad B · Area Barat'}.
  final Map<String, String> changes;
  final String reason;
  final DateTime createdAt;

  /// Sudah terkirim ke server (lalu menunggu approval admin) atau belum.
  final bool synced;

  /// Payload `POST /adjustments`.
  Map<String, dynamic> toJson() => {
        'asset_id': assetId,
        'changes': changes,
        'reason': reason,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  AdjustmentRequest copyWith({int? id, bool? synced}) => AdjustmentRequest(
        id: id ?? this.id,
        assetId: assetId,
        changes: changes,
        reason: reason,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}
