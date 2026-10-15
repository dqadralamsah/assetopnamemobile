/// Kondisi aset sesuai data di web app: B (Baik), RR (Rusak Ringan), RB (Rusak Berat).
enum AssetCondition {
  baik('B', 'Baik'),
  rusakRingan('RR', 'Rusak ringan'),
  rusakBerat('RB', 'Rusak berat');

  const AssetCondition(this.code, this.label);

  final String code;
  final String label;

  /// Dari kode di API/web ('B', 'RR', 'RB').
  static AssetCondition fromCode(String code) =>
      values.firstWhere((c) => c.code == code);
}

/// Jenis aset, dipakai untuk memilih ikon.
enum AssetKind { power, water, electrical, tank, container, vehicle, it }

/// Data master aset. Nanti diambil dari API web app (GET /assets).
class Asset {
  const Asset({
    required this.id,
    required this.kind,
    required this.assetClass,
    required this.eccNumber,
    required this.fioriNumber,
    required this.name,
    required this.acquisitionYear,
    required this.acquisitionValue,
    required this.condition,
    required this.location,
    required this.area,
    required this.businessArea,
    required this.lat,
    required this.lng,
  });

  /// ID aset = isi QR code / barcode di label.
  final String id;
  final AssetKind kind;
  final String assetClass;
  final String eccNumber;
  final String fioriNumber;
  final String name;
  final int acquisitionYear;
  final int acquisitionValue;
  final AssetCondition condition;

  /// Lokasi / pad, mis. "Pad A".
  final String location;

  /// Nama area, mis. "Area Utilitas".
  final String area;
  final String businessArea;

  /// Koordinat derajat desimal WGS84.
  final double lat;
  final double lng;

  /// Dari JSON API `GET /assets` (lihat dokumen 04a. API Contract di vault).
  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
        id: json['id'] as String,
        kind: AssetKind.values.byName(json['kind'] as String),
        assetClass: json['asset_class'] as String,
        eccNumber: json['ecc_number'] as String,
        fioriNumber: json['fiori_number'] as String,
        name: json['name'] as String,
        acquisitionYear: json['acquisition_year'] as int,
        acquisitionValue: json['acquisition_value'] as int,
        condition: AssetCondition.fromCode(json['condition'] as String),
        location: json['location'] as String,
        area: json['area'] as String,
        businessArea: json['business_area'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  /// Label grup di daftar aset, mis. "Pad A · Area Utilitas".
  String get group => '$location · $area';
}
