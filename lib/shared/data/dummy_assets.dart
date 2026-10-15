import '../models/asset.dart';
import '../models/opname_result.dart';

/// Data dummy. Ganti dengan data dari API setelah kontrak API
/// disepakati dengan tim web.

const _baseLat = -7.20500;
const _baseLng = 109.90500;

/// (lokasi, area, offset lat, offset lng)
const _sites = [
  ('Pad A', 'Area Utilitas', 0.0000, 0.0000),
  ('Pad B', 'Area Barat', 0.0012, -0.0016),
  ('Pad C', 'Area Sumur', -0.0014, 0.0011),
  ('Kantor', 'Kantor Lapangan', 0.0011, 0.0014),
  ('Gudang', 'Gudang Material', -0.0012, -0.0014),
];

/// (nama, jenis, kelas aset)
const _catalog = [
  ('Genset 500 kVA', AssetKind.power, 'Mesin & Peralatan'),
  ('Pompa Air Sirkulasi', AssetKind.water, 'Mesin & Peralatan'),
  ('Panel Listrik LV-02', AssetKind.electrical, 'Instalasi Listrik'),
  ('Tangki Air 20 m³', AssetKind.tank, 'Bangunan Pendukung'),
  ('Kontainer Gudang 20 ft', AssetKind.container, 'Bangunan Pendukung'),
  ('Mobil Double Cabin', AssetKind.vehicle, 'Kendaraan'),
  ('Laptop Operasional', AssetKind.it, 'Peralatan IT'),
  ('Trafo Distribusi 250 kVA', AssetKind.electrical, 'Instalasi Listrik'),
  ('Pompa Transfer Solar', AssetKind.water, 'Mesin & Peralatan'),
];

const _conditions = [
  AssetCondition.baik,
  AssetCondition.baik,
  AssetCondition.baik,
  AssetCondition.rusakRingan,
  AssetCondition.baik,
  AssetCondition.rusakBerat,
];

/// 54 aset dummy (jumlah sama dengan data di web app).
final List<Asset> dummyAssets = List.generate(54, (i) {
  final site = _sites[i % _sites.length];
  final item = _catalog[i % _catalog.length];
  final no = (i + 1).toString().padLeft(4, '0');
  final unit = i ~/ _catalog.length + 1;

  // Sebar titik di sekitar pusat tiap lokasi (± 70 m).
  final jitterLat = ((i * 37) % 13 - 6) * 0.00011;
  final jitterLng = ((i * 53) % 11 - 5) * 0.00012;

  return Asset(
    id: 'AST-$no',
    kind: item.$2,
    assetClass: item.$3,
    eccNumber: '${100000123 + i * 12}',
    fioriNumber: 'FI-${80000 + i * 13}',
    name: unit == 1 ? item.$1 : '${item.$1} #$unit',
    acquisitionYear: 2015 + (i % 10),
    acquisitionValue: 15000000 + (i * 7350000) % 480000000,
    condition: _conditions[i % _conditions.length],
    location: site.$1,
    area: site.$2,
    businessArea: i.isEven ? 'BA-1001' : 'BA-1002',
    lat: _baseLat + site.$3 + jitterLat,
    lng: _baseLng + site.$4 + jitterLng,
  );
});

/// Periode opname aktif (dummy). Nanti dari API `GET /periods/active`.
final dummyActivePeriod = OpnamePeriod(
  id: '2026-S2',
  name: 'Opname Semester II 2026',
  start: DateTime(2026, 7, 1),
  end: DateTime(2026, 12, 31),
);

/// Posisi petugas dummy di dekat aset — dipakai kalau toggle "Posisi dummy"
/// di menu Akun aktif.
const dummyUserPosition =
    (lat: _baseLat + 0.00012, lng: _baseLng + 0.00010, accuracy: 8.0);

/// Profil petugas (dummy). Nanti dari API login.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Data awal dummy: 12 aset sudah dicatat, 3 di antaranya belum terkirim.
// Satu aset punya riwayat 2 entri (contoh koreksi), dan satu aset hanya
// punya hasil periode lalu (jadi "belum dicatat" di periode ini).
// ---------------------------------------------------------------------------

List<OpnameResult> seedOpnameResults() {
  const statuses = [
    OpnameStatus.sesuai,
    OpnameStatus.sesuai,
    OpnameStatus.kondisiBerubah,
    OpnameStatus.sesuai,
    OpnameStatus.sesuai,
    OpnameStatus.bedaLokasi,
    OpnameStatus.sesuai,
    OpnameStatus.sesuai,
    OpnameStatus.kondisiBerubah,
    OpnameStatus.sesuai,
    OpnameStatus.sesuai,
    OpnameStatus.sesuai,
  ];
  const indexes = [6, 8, 11, 13, 16, 19, 22, 27, 31, 36, 41, 47];
  final start = DateTime.now().subtract(const Duration(hours: 3));
  final list = <OpnameResult>[
    OpnameResult(
      periodId: '2026-S1',
      assetId: dummyAssets[0].id,
      method: OpnameMethod.scan,
      status: OpnameStatus.sesuai,
      condition: dummyAssets[0].condition,
      recordedAt: DateTime(2026, 5, 20, 10, 15),
      photoCount: 1,
      gpsDistanceM: 9,
      synced: true,
    ),
  ];

  // Contoh riwayat: aset ini awalnya tercatat "Sesuai", lalu dicatat ulang.
  final rechecked = dummyAssets[indexes[2]];
  list.add(OpnameResult(
    periodId: dummyActivePeriod.id,
    assetId: rechecked.id,
    method: OpnameMethod.scan,
    status: OpnameStatus.sesuai,
    condition: rechecked.condition,
    recordedAt: start.subtract(const Duration(hours: 2)),
    photoCount: 1,
    gpsDistanceM: 11,
    synced: true,
  ));
  for (var i = 0; i < indexes.length; i++) {
    final asset = dummyAssets[indexes[i]];
    final manual = i % 4 == 3;
    list.add(OpnameResult(
      periodId: dummyActivePeriod.id,
      assetId: asset.id,
      method: manual ? OpnameMethod.manual : OpnameMethod.scan,
      status: statuses[i],
      condition: statuses[i] == OpnameStatus.kondisiBerubah
          ? AssetCondition.rusakRingan
          : asset.condition,
      recordedAt: start.add(Duration(minutes: i * 14)),
      manualReason: manual ? 'Label rusak' : '',
      photoCount: manual ? 2 : 1,
      gpsDistanceM: 8.0 + i * 3,
      synced: i < indexes.length - 3,
    ));
  }
  return list;
}
