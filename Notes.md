# Notes — Roadmap Pengembangan

Tahapan setelah MVP. Data masih dummy (belum ada API), tapi fitur HP dibuat sungguhan.
Catatan belajar & dokumen proyek ada di vault Obsidian:
`D:\Dicky\DYWORK\Asset Opname Mobile\` (lihat `docs/04b. Code Structure Guide` dan `brainstorm/Learning Notes — Flutter`).

## Fase 1 — Bisa dipakai di HP sungguhan (tanpa server)

- [x] **1. Penyimpanan lokal** — SQLite via `drift`. Hasil opname & usulan adjustment tidak hilang saat app ditutup. (13 Okt 2026)
- [x] **2. Scan QR sungguhan** — `mobile_scanner` (QR + Code 128), senter. Debug: tap bingkai = simulasi (label QR belum dicetak). (15 Okt 2026, belum dites dengan label asli)
- [x] **3. Foto aset** — `image_picker` mode kamera saja (tanpa galeri), maks 5, 1600 px / kualitas 70 (tanpa `flutter_image_compress`). Disalin ke `<documents>/photos/`, path di kolom `photo_paths`. Upload ke server menunggu endpoint. (15 Okt 2026)
- [x] **4. GPS sungguhan** — `geolocator`, toleransi 100 m (`gpsToleranceM`, tunggu mentor) → peringatan, tetap boleh simpan. Toggle "Posisi dummy" di Akun untuk tes jauh dari aset dummy. (15 Okt 2026)
- [x] **`user_id`** di hasil opname & adjustment (sementara email login dummy). DB `schemaVersion 2` + migrasi. (15 Okt 2026)
- [ ] **5. Peta sungguhan** — peta berbayar dari mentor (tanya penyedia & API key mobile dulu).

## Fase 2 — Siap disambung ke API (masih dummy)

- [x] ~~**6. Repository**~~ — dilewati: `assetsProvider` di `providers.dart` sudah satu-satunya pintu data aset, cukup ganti isinya saat API siap.
- [x] **7. `fromJson` / `toJson` di model** — `Asset.fromJson`, `OpnameResult.toJson`, `AdjustmentRequest.toJson`. Kontrak: vault `docs/04a. API Contract`. (13 Okt 2026)
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

Dipindah ke vault: `brainstorm/Pertanyaan untuk Mentor` Section 9. Status pembuatan & hubungan HP–API–web: `activity-log/Development Tracker — Asset Opname`.

## Catatan teknis

- Setelah mengubah tabel di `lib/core/database/app_database.dart`, jalankan:
  `dart run build_runner build` (membuat ulang `app_database.g.dart`).
- Ubah struktur tabel setelah app terpasang di HP → naikkan `schemaVersion` + tulis migrasi. Selama masih dev: uninstall app saja.
- Ganti `FakeApi` ke API asli: buat class dengan method yang sama (`postOpnameResult`, `postAdjustment`) pakai `dio`, lalu ganti isi `apiProvider`.
- Preview di Chrome (`flutter run -d chrome`) belum bisa karena drift di web butuh file `sqlite3.wasm` + worker. Target MVP Android, jadi dilewati.
