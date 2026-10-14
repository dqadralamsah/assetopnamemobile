# Asset Opname App (MVP Android)

Aplikasi mobile stock opname aset, dibuat dengan Flutter. Master aset masih **data dummy** (54 aset) dan server masih palsu (`FakeApi`), tapi hasil opname sudah tersimpan di **SQLite lokal** (`drift`). Target: Android.

## Cara Menjalankan

```
flutter pub get
flutter run            # pilih emulator / HP Android
```

- Cek kualitas kode: `flutter analyze` dan `flutter test`.
- Setelah mengubah tabel di `lib/core/database/app_database.dart`: `dart run build_runner build`.
- `flutter run -d chrome` belum bisa: drift di web butuh `sqlite3.wasm` + worker (lihat `Notes.md`).

## Struktur Folder

```
lib/
├── main.dart
├── app/            # app, routing (go_router), tema & warna (AppColors)
├── core/
│   ├── database/   # SQLite lokal (drift): riwayat opname + usulan adjustment
│   └── network/    # FakeApi (pengganti server) — diganti dio saat API siap
├── shared/
│   ├── models/     # Asset, OpnameResult, AdjustmentRequest + enum status
│   ├── data/       # data dummy 54 aset + posisi petugas (diganti API nanti)
│   ├── widgets/    # komponen UI bersama (kartu, chip status, pilihan kondisi)
│   ├── utils/      # format Rupiah/jarak/jam, hitung jarak GPS
│   └── providers.dart   # state (Riverpod)
└── features/
    ├── auth/           # Login (email + password, SSO menyusul)
    ├── home/           # Beranda: progres, aset terdekat, terakhir dicatat
    ├── map/            # Peta skematik (flutter_map menyusul)
    ├── assets/         # Daftar Aset per lokasi + detail aset
    ├── scan/           # Scan QR/Barcode (simulasi: tap area kamera)
    ├── manual_input/   # Input Manual 1/2: pilih aset + alasan
    ├── opname_form/    # Form Hasil (Scan) & Form Manual 2/2
    ├── adjustment/     # Stock Adjustment (usulan koreksi data)
    ├── sync_status/    # Status Sync (antrean belum terkirim)
    └── account/        # Akun
```

## Alur yang Sudah Jalan (data dummy)

- **Login** → Beranda (email/password apa saja).
- **Scan:** tombol tengah menu bawah → tap area kamera (simulasi) → Lanjut isi hasil → Form Hasil.
- **Manual:** Scan → "Label rusak / tidak ada?" atau dari Peta/Detail → pilih aset + alasan → Form Manual (foto wajib).
- **Stock Adjustment:** dari Form Hasil atau Detail Aset → centang data → alasan → Ajukan.
- **Status Sync:** ikon sync di Beranda / Akun → Kirim sekarang (simulasi; toggle "Simulasi offline" di Akun untuk mencoba gagal kirim).
- Data awal: 12 dari 54 aset sudah dicatat, 3 belum terkirim. Tersimpan di database HP, jadi tetap ada setelah app ditutup. Logout menghapus yang sudah terkirim saja.

## Menyusul (lihat `Notes.md` untuk roadmap)

| Fitur | Package |
|---|---|
| Kamera scan QR + Code 128 | `mobile_scanner` |
| Enkripsi database lokal | SQLCipher |
| Foto bukti | `image_picker` + `flutter_image_compress` |
| GPS | `geolocator` |
| Peta asli | `flutter_map` (OSM) / `google_maps_flutter` |
| API & login | `dio` + `flutter_secure_storage` |
