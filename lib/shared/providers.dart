import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/database/app_database.dart';
import '../core/network/fake_api.dart';
import 'data/dummy_assets.dart';
import 'models/asset.dart';
import 'models/opname_result.dart';
import 'utils/geo.dart';

// ---------------------------------------------------------------------------
// Database lokal
// ---------------------------------------------------------------------------

/// Database SQLite di HP. Dibuka di [loadLocalData], lalu di-override.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Panggil loadLocalData() di main()'),
);

/// Buka isi database sebelum app tampil, lalu pasang ke provider.
///
/// Semua hasil dimuat ke memori sekali di awal, supaya layar tetap
/// membaca data secara langsung (tanpa loading). Setiap perubahan ditulis
/// ke database dulu, baru ke memori.
// ponytail: load semua ke memori, cukup untuk ratusan aset; ganti ke query
// per halaman (drift watch) kalau data sudah ribuan.
Future<List<Override>> loadLocalData(AppDatabase db) async {
  final results = await db.allResults();
  final adjustments = await db.allAdjustments();
  return [
    databaseProvider.overrideWithValue(db),
    opnameHistoryProvider.overrideWith(() => OpnameHistoryNotifier(results)),
    adjustmentsProvider.overrideWith(() => AdjustmentsNotifier(adjustments)),
  ];
}

/// Toggle di menu Akun untuk mencoba alur gagal kirim.
final simulateOfflineProvider = StateProvider<bool>((ref) => false);

/// Koneksi ke server. Sekarang palsu; nanti HTTP client sungguhan.
final apiProvider = Provider<FakeApi>(
  (ref) => FakeApi(isOffline: () => ref.read(simulateOfflineProvider)),
);

// ---------------------------------------------------------------------------
// Login (dummy). Nanti: API login + token di flutter_secure_storage.
// ---------------------------------------------------------------------------

class AuthNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;

  void login(String email) {
    state = UserProfile(
      name: 'Nama Petugas',
      email: email.trim().isEmpty ? 'petugas@perusahaan.co.id' : email.trim(),
      role: 'Petugas Aset · BA-1001',
    );
  }

  /// Keluar + hapus data yang sudah terkirim (beserta file fotonya) dari HP.
  Future<void> logout() async {
    for (final r in ref.read(opnameHistoryProvider).where((r) => r.synced)) {
      for (final path in r.photoPaths) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
    await ref.read(databaseProvider).deleteSynced();
    ref.read(opnameHistoryProvider.notifier).removeSynced();
    ref.read(adjustmentsProvider.notifier).removeSynced();
    state = null;
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);

// ---------------------------------------------------------------------------
// Aset & posisi
// ---------------------------------------------------------------------------

/// Daftar aset. Sekarang dari data dummy; nanti dari database lokal (drift)
/// yang diisi lewat API.
final assetsProvider = Provider<List<Asset>>((ref) => dummyAssets);

/// Cari aset berdasarkan ID (isi QR/barcode). null kalau tidak ada.
final assetByIdProvider = Provider.family<Asset?, String>((ref, id) {
  final key = id.trim().toUpperCase();
  for (final a in ref.watch(assetsProvider)) {
    if (a.id.toUpperCase() == key) return a;
  }
  return null;
});

/// Titik GPS + akurasi (meter).
typedef GeoPoint = ({double lat, double lng, double accuracy});

/// Toggle di menu Akun: pakai posisi dummy di dekat aset dummy, supaya alur
/// bisa dites tanpa berada di lokasi aset.
final useDummyPositionProvider = StateProvider<bool>((ref) => false);

/// Posisi GPS HP, diperbarui tiap bergeser 5 m. Error berisi pesan untuk
/// petugas kalau GPS mati atau izin lokasi ditolak.
final gpsProvider = StreamProvider<GeoPoint>((ref) async* {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw 'GPS HP mati — nyalakan Lokasi';
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw 'Izin lokasi ditolak';
  }
  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).map((p) => (lat: p.latitude, lng: p.longitude, accuracy: p.accuracy));
});

/// Posisi petugas. null = GPS belum tersedia (mencari sinyal / ditolak).
final userPositionProvider = Provider<GeoPoint?>((ref) {
  if (ref.watch(useDummyPositionProvider)) return dummyUserPosition;
  return ref.watch(gpsProvider).valueOrNull;
});

/// Jarak petugas ke titik aset yang masih dianggap "di lokasi". Lebih dari
/// ini → peringatan, hasil tetap boleh disimpan.
// ponytail: angka tetap, tunggu keputusan mentor (Pertanyaan untuk Mentor §10).
const gpsToleranceM = 100.0;

/// Jarak petugas ke aset (meter). null kalau posisi belum ada.
final distanceProvider = Provider.family<double?, String>((ref, assetId) {
  final asset = ref.watch(assetByIdProvider(assetId));
  final pos = ref.watch(userPositionProvider);
  if (asset == null || pos == null) return null;
  return distanceMeters(pos.lat, pos.lng, asset.lat, asset.lng);
});

// ---------------------------------------------------------------------------
// Hasil opname
// ---------------------------------------------------------------------------

/// Semua riwayat hasil opname, urut dari yang terlama. Tersimpan di
/// database lokal. Menyimpan ulang / koreksi = entri baru, yang lama tetap ada.
class OpnameHistoryNotifier extends Notifier<List<OpnameResult>> {
  OpnameHistoryNotifier([this._initial = const []]);

  final List<OpnameResult> _initial;

  @override
  List<OpnameResult> build() => _initial;

  /// Samakan memori setelah [AppDatabase.deleteSynced].
  void removeSynced() => state = [...state.where((r) => !r.synced)];

  Future<void> save(OpnameResult result) async {
    final id = await ref.read(databaseProvider).saveResult(result);
    state = [...state, result.copyWith(id: id)];
  }

  /// Kirim hasil yang belum terkirim, satu per satu. Berhenti di kegagalan
  /// pertama (biasanya tidak ada sinyal) dengan melempar [ApiException];
  /// sisanya tetap di antrean untuk dicoba lagi.
  Future<void> sendPending() async {
    final api = ref.read(apiProvider);
    final db = ref.read(databaseProvider);
    for (final r in state.where((r) => !r.synced).toList()) {
      await api.postOpnameResult(r.toJson());
      await db.markResultSynced(r.id!);
      state = [
        for (final x in state) x.id == r.id ? x.copyWith(synced: true) : x
      ];
    }
  }
}

final opnameHistoryProvider =
    NotifierProvider<OpnameHistoryNotifier, List<OpnameResult>>(
  OpnameHistoryNotifier.new,
);

/// Periode opname aktif. Sekarang dummy; nanti dari API (disimpan di
/// database supaya tetap ada saat offline).
final activePeriodProvider = Provider<OpnamePeriod>((ref) => dummyActivePeriod);

/// Hasil terbaru per aset **di periode aktif**, key = assetId.
/// Ini yang dipakai sebagian besar layar.
final opnameResultsProvider = Provider<Map<String, OpnameResult>>((ref) {
  final periodId = ref.watch(activePeriodProvider).id;
  // Riwayat urut dari terlama, jadi entri terakhir yang menang.
  return {
    for (final r in ref.watch(opnameHistoryProvider))
      if (r.periodId == periodId) r.assetId: r,
  };
});

/// Riwayat satu aset (semua periode), terbaru di atas.
final assetHistoryProvider =
    Provider.family<List<OpnameResult>, String>((ref, assetId) {
  return ref
      .watch(opnameHistoryProvider)
      .where((r) => r.assetId == assetId)
      .toList()
      .reversed
      .toList();
});

/// Jumlah data di antrean (hasil opname + usulan adjustment) yang belum
/// terkirim.
final unsyncedCountProvider = Provider<int>((ref) {
  final results =
      ref.watch(opnameHistoryProvider).where((r) => !r.synced).length;
  final adjustments =
      ref.watch(adjustmentsProvider).where((a) => !a.synced).length;
  return results + adjustments;
});

/// Aset terdekat yang belum dicatat (untuk kartu "Lanjutkan").
final nearestPendingAssetProvider = Provider<Asset?>((ref) {
  final results = ref.watch(opnameResultsProvider);
  Asset? best;
  var bestDistance = double.infinity;
  for (final a in ref.watch(assetsProvider)) {
    if (results.containsKey(a.id)) continue;
    // Tanpa GPS: ambil aset belum dicatat yang pertama.
    final d = ref.watch(distanceProvider(a.id)) ?? double.infinity;
    if (best == null || d < bestDistance) {
      bestDistance = d;
      best = a;
    }
  }
  return best;
});

// ---------------------------------------------------------------------------
// Stock adjustment
// ---------------------------------------------------------------------------

class AdjustmentsNotifier extends Notifier<List<AdjustmentRequest>> {
  AdjustmentsNotifier([this._initial = const []]);

  final List<AdjustmentRequest> _initial;

  @override
  List<AdjustmentRequest> build() => _initial;

  /// Samakan memori setelah [AppDatabase.deleteSynced].
  void removeSynced() => state = [...state.where((a) => !a.synced)];

  Future<void> submit(AdjustmentRequest request) async {
    final id = await ref.read(databaseProvider).addAdjustment(request);
    state = [...state, request.copyWith(id: id)];
  }

  /// Sama seperti [OpnameHistoryNotifier.sendPending].
  Future<void> sendPending() async {
    final api = ref.read(apiProvider);
    final db = ref.read(databaseProvider);
    for (final a in state.where((a) => !a.synced).toList()) {
      await api.postAdjustment(a.toJson());
      await db.markAdjustmentSynced(a.id!);
      state = [
        for (final x in state) x.id == a.id ? x.copyWith(synced: true) : x
      ];
    }
  }
}

final adjustmentsProvider =
    NotifierProvider<AdjustmentsNotifier, List<AdjustmentRequest>>(
  AdjustmentsNotifier.new,
);
