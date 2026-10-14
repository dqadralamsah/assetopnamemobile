# Notes — Roadmap Pengembangan

Tahapan setelah MVP. Data masih dummy (belum ada API), tapi fitur HP dibuat sungguhan.
Catatan belajar & dokumen proyek ada di vault Obsidian:
`D:\Dicky\DYWORK\Asset Opname Mobile\` (lihat `01 Docs/06. Code Structure Guide` dan `02 Brainstorm/Learning Notes — Flutter`).

## Fase 1 — Bisa dipakai di HP sungguhan (tanpa server)

- [x] **1. Penyimpanan lokal** — SQLite via `drift`. Hasil opname & usulan adjustment tidak hilang saat app ditutup. (13 Okt 2026)
- [ ] ~~**2. Scan QR sungguhan** — `mobile_scanner`, sambungkan ke `_onCode` di `scan_screen.dart`. Siapkan label QR `AST-0001`–`AST-0054` untuk tes.~~ ⏸ ditunda (butuh HP Android)
- [ ] ~~**3. Foto aset** — `image_picker` + `flutter_image_compress`, simpan path foto di hasil opname.~~ ⏸ ditunda (butuh HP Android)
- [ ] ~~**4. GPS sungguhan** — `geolocator` + izin lokasi. Masalah: aset dummy ada di -7.205, 109.905 → sebar dummy di sekitar posisi pertama, atau toggle "posisi dummy".~~ ⏸ ditunda (butuh HP Android)
- [ ] **5. Peta sungguhan** — `flutter_map` + OpenStreetMap (tunggu cek web app pakai peta apa).

## Fase 2 — Siap disambung ke API (masih dummy)

- [x] ~~**6. Repository**~~ — dilewati: `assetsProvider` di `providers.dart` sudah satu-satunya pintu data aset, cukup ganti isinya saat API siap.
- [x] **7. `fromJson` / `toJson` di model** — `Asset.fromJson`, `OpnameResult.toJson`, `AdjustmentRequest.toJson`. Kontrak: vault `01 Docs/07. API Contract`. (13 Okt 2026)
- [x] **8. Antrean sync** — `FakeApi` (`lib/core/network/`), kirim satu per satu, gagal → tetap di antrean, toggle "Simulasi offline" di Akun. Adjustment ikut antrean. (13 Okt 2026)
- [ ] **Tabel `assets` di database** — saat master aset diunduh dari API (sekarang masih list dummy di memori).

## Fase 3 — Logika bisnis

- [x] **9. Periode opname** — `OpnamePeriod` + `activePeriodProvider` (dummy `2026-S2`). Hasil menyimpan `periodId`; Beranda/Peta/Aset hanya hitung periode aktif, riwayat tampilkan semua periode. `features/tasks/` belum dibuat (belum ada layar periode). Periode belum disimpan di DB — nanti bareng tabel `assets` saat API. (13 Okt 2026)
- [x] **10. Riwayat & edit hasil** — setiap pencatatan/koreksi = entri baru (jejak audit). `opnameHistoryProvider` (semua) → `opnameResultsProvider` (terbaru per aset). Tombol "Koreksi hasil" + "Riwayat pencatatan" di detail aset. (13 Okt 2026)
- [ ] **11. Status pemakaian + approval adjustment** — tunggu keputusan mentor.
- [x] **12a. Logout hapus data lokal** — hapus yang sudah terkirim; yang belum terkirim tetap disimpan + peringatan "Kirim dulu" (sesuai teks mockup). (13 Okt 2026)
- [ ] ~~**12b. Kunci aplikasi (PIN / sidik jari)**~~ ⏸ ditunda (butuh `flutter_secure_storage` / `local_auth` di HP Android)

## Fase 4 — Siap dicoba orang lain

- [ ] **13. Test** — alur scan → simpan → sync (`integration_test/`).
- [ ] **14. Build APK release** — signing key sesuai dokumen 04.
  - [x] `build.gradle.kts` membaca `android/key.properties` (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`). Tinggal buat keystore + file itu. Belum ada → kunci debug. (14 Okt 2026)
  - [x] Data dummy awal hanya diisi di build debug (`kDebugMode`). (14 Okt 2026)
  - [ ] Nama app (`android:label`) — tunggu mentor.

## Tanya mentor

- **ID unik per data** (`client_id` UUID) di `OpnameResult.toJson` / `AdjustmentRequest.toJson`, supaya server bisa tolak duplikat. Kasus: data sudah sampai server tapi app mati sebelum tandai `synced` → terkirim ulang.
- **Format `changes` adjustment** — sekarang kuncinya teks tampilan (`'Lokasi / Pad'`) dan titik peta berupa teks, bukan lat/lng. Server mau format apa?
- **Nama app** yang tampil di HP.
- Login tetap tersimpan saat app dibuka ulang → dikerjakan bareng login API + token.

## Catatan teknis

- Setelah mengubah tabel di `lib/core/database/app_database.dart`, jalankan:
  `dart run build_runner build` (membuat ulang `app_database.g.dart`).
- Ubah struktur tabel setelah app terpasang di HP → naikkan `schemaVersion` + tulis migrasi. Selama masih dev: uninstall app saja.
- Ganti `FakeApi` ke API asli: buat class dengan method yang sama (`postOpnameResult`, `postAdjustment`) pakai `dio`, lalu ganti isi `apiProvider`.
- Preview di Chrome (`flutter run -d chrome`) belum bisa karena drift di web butuh file `sqlite3.wasm` + worker. Target MVP Android, jadi dilewati.
