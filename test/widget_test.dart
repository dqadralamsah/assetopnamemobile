import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_opname_app/app/app.dart';
import 'package:asset_opname_app/core/database/app_database.dart';
import 'package:asset_opname_app/core/network/fake_api.dart';
import 'package:asset_opname_app/shared/models/asset.dart';
import 'package:asset_opname_app/shared/models/opname_result.dart';
import 'package:asset_opname_app/shared/providers.dart';
import 'package:asset_opname_app/shared/utils/format.dart';

void main() {
  testWidgets('Login lalu masuk ke Beranda', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    // Database butuh I/O sungguhan, jadi dijalankan di luar fake-async test.
    final overrides = (await tester.runAsync(() => loadLocalData(db)))!;
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const AssetOpnameApp()),
    );
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(FilledButton, 'Masuk');
    expect(loginButton, findsOneWidget);
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    for (final label in ['Beranda', 'Peta', 'Aset', 'Akun']) {
      expect(find.text(label), findsWidgets);
    }
    expect(find.text('12 dari 54 aset'), findsOneWidget);
  });

  test('Database: isi awal, simpan, adjustment', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // Isi awal dummy: 14 entri riwayat untuk 13 aset (1 dari periode lalu),
    // 3 belum terkirim.
    var results = await db.allResults();
    expect(results.length, 14);
    expect(results.map((r) => r.assetId).toSet().length, 13);
    expect(results.where((r) => !r.synced).length, 3);

    final id = await db.saveResult(OpnameResult(
      periodId: '2026-S2',
      assetId: 'AST-0001',
      method: OpnameMethod.manual,
      status: OpnameStatus.bedaLokasi,
      condition: AssetCondition.rusakRingan,
      recordedAt: DateTime(2026, 10, 13, 9),
      manualReason: 'Label rusak',
      photoCount: 2,
    ));
    results = await db.allResults();
    expect(results.length, 15);
    final saved = results.firstWhere((r) => r.id == id);
    expect(saved.status, OpnameStatus.bedaLokasi);
    expect(saved.condition, AssetCondition.rusakRingan);
    expect(saved.manualReason, 'Label rusak');
    expect(saved.synced, isFalse);

    await db.addAdjustment(AdjustmentRequest(
      assetId: 'AST-0002',
      changes: {'Lokasi / Pad': 'Pad B · Area Barat'},
      reason: 'Aset dipindah',
      createdAt: DateTime(2026, 10, 13),
    ));
    final adjustments = await db.allAdjustments();
    expect(adjustments.single.changes, {'Lokasi / Pad': 'Pad B · Area Barat'});
  });

  test('Antrean sync: offline gagal & tetap di antrean, online terkirim',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: await loadLocalData(db));
    addTearDown(container.dispose);

    await container.read(adjustmentsProvider.notifier).submit(
          AdjustmentRequest(
            assetId: 'AST-0002',
            changes: {'Kondisi': 'RR'},
            reason: 'Retak',
            createdAt: DateTime(2026, 10, 13),
          ),
        );
    expect(container.read(unsyncedCountProvider), 4); // 3 hasil + 1 usulan

    container.read(simulateOfflineProvider.notifier).state = true;
    await expectLater(
      container.read(opnameHistoryProvider.notifier).sendPending(),
      throwsA(isA<ApiException>()),
    );
    expect(container.read(unsyncedCountProvider), 4);

    container.read(simulateOfflineProvider.notifier).state = false;
    await container.read(opnameHistoryProvider.notifier).sendPending();
    await container.read(adjustmentsProvider.notifier).sendPending();
    expect(container.read(unsyncedCountProvider), 0);

    // Status terkirim juga tersimpan di database.
    expect((await db.allResults()).every((r) => r.synced), isTrue);
    expect((await db.allAdjustments()).single.synced, isTrue);
  });

  test('Riwayat: catat ulang menambah entri, hasil terbaru yang dipakai',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: await loadLocalData(db));
    addTearDown(container.dispose);

    OpnameResult entry(OpnameStatus status, int hour) => OpnameResult(
          periodId: '2026-S2',
          assetId: 'AST-0001',
          method: OpnameMethod.scan,
          status: status,
          condition: AssetCondition.baik,
          recordedAt: DateTime(2026, 10, 13, hour),
        );
    // AST-0001 hanya punya hasil periode lalu → belum dicatat periode ini.
    expect(container.read(opnameResultsProvider)['AST-0001'], isNull);
    expect(container.read(assetHistoryProvider('AST-0001')).single.periodId,
        '2026-S1');

    final history = container.read(opnameHistoryProvider.notifier);
    await history.save(entry(OpnameStatus.sesuai, 8));
    await history.save(entry(OpnameStatus.bedaLokasi, 9));

    expect(
      container.read(opnameResultsProvider)['AST-0001']!.status,
      OpnameStatus.bedaLokasi,
    );
    expect(
      container.read(assetHistoryProvider('AST-0001')).map((r) => r.status),
      [OpnameStatus.bedaLokasi, OpnameStatus.sesuai, OpnameStatus.sesuai],
    );
    expect(container.read(opnameResultsProvider).length, 13);
    // Dua entri baru = dua data di antrean (3 dari isi awal + 2).
    expect(container.read(unsyncedCountProvider), 5);
  });

  test('Label cetak ulang: masuk saat manual label rusak, keluar saat di-scan',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: await loadLocalData(db));
    addTearDown(container.dispose);

    bool listed() => container
        .read(labelReprintProvider)
        .any((r) => r.assetId == 'AST-0001');
    OpnameResult entry(OpnameMethod method, String reason, int hour) =>
        OpnameResult(
          periodId: '2026-S2',
          assetId: 'AST-0001',
          method: method,
          status: OpnameStatus.sesuai,
          condition: AssetCondition.baik,
          recordedAt: DateTime(2026, 10, 15, hour),
          manualReason: reason,
        );
    final history = container.read(opnameHistoryProvider.notifier);

    expect(listed(), isFalse);
    await history.save(entry(OpnameMethod.manual, 'Kamera/scan gagal', 8));
    expect(listed(), isFalse); // bukan masalah label
    await history.save(entry(OpnameMethod.manual, 'Label rusak', 9));
    expect(listed(), isTrue);
    await history.save(entry(OpnameMethod.scan, '', 10)); // label baru terpasang
    expect(listed(), isFalse);
  });

  test('Logout: hapus yang sudah terkirim, simpan yang belum', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(overrides: await loadLocalData(db));
    addTearDown(container.dispose);

    container.read(authProvider.notifier).login('petugas@contoh.id');
    await container.read(authProvider.notifier).logout();

    expect(container.read(authProvider), isNull);
    // Isi awal: 14 entri, 3 belum terkirim → tinggal 3.
    final left = container.read(opnameHistoryProvider);
    expect(left.length, 3);
    expect(left.every((r) => !r.synced), isTrue);
    expect(container.read(unsyncedCountProvider), 3);
    expect((await db.allResults()).length, 3);
  });

  test('JSON sesuai kontrak API', () {
    final asset = Asset.fromJson({
      'id': 'AST-0001',
      'kind': 'power',
      'asset_class': 'Mesin & Peralatan',
      'ecc_number': '100000123',
      'fiori_number': 'FI-80000',
      'name': 'Genset 500 kVA',
      'acquisition_year': 2015,
      'acquisition_value': 15000000,
      'condition': 'RR',
      'location': 'Pad A',
      'area': 'Area Utilitas',
      'business_area': 'BA-1001',
      'lat': -7.205,
      'lng': 109,
    });
    expect(asset.condition, AssetCondition.rusakRingan);
    expect(asset.lng, 109.0);

    final json = OpnameResult(
      periodId: '2026-S2',
      assetId: 'AST-0001',
      method: OpnameMethod.manual,
      status: OpnameStatus.kondisiBerubah,
      condition: AssetCondition.rusakBerat,
      recordedAt: DateTime.utc(2026, 10, 13, 2, 30),
      manualReason: 'Label hilang',
      userId: 'petugas@perusahaan.co.id',
    ).toJson();
    expect(json['user_id'], 'petugas@perusahaan.co.id');
    expect(json['gps_distance_m'], isNull);
    expect(json['method'], 'manual');
    expect(json['status'], 'kondisiBerubah');
    expect(json['condition'], 'RB');
    expect(json['recorded_at'], '2026-10-13T02:30:00.000Z');
    expect(json['period_id'], '2026-S2');

    final period = OpnamePeriod.fromJson({
      'id': '2026-S2',
      'name': 'Opname Semester II 2026',
      'start': '2026-07-01',
      'end': '2026-12-31',
    });
    expect(period.daysLeft(DateTime(2026, 12, 1)), 30);
    expect(period.daysLeft(DateTime(2027, 1, 5)), 0);
  });

  test('formatRupiah', () {
    expect(formatRupiah(12500000), 'Rp 12.500.000');
    expect(formatRupiah(999), 'Rp 999');
  });

  test('formatDistance', () {
    expect(formatDistance(18.4), '18 m');
    expect(formatDistance(1260), '1,3 km');
    expect(formatDistance(null), '– m');
    expect(formatDate(DateTime(2026, 12, 31)), '31 Des 2026');
  });

  test('Migrasi v1 → v2: data lama di HP tetap ada', () async {
    // Skema v1 persis seperti yang sudah terpasang di HP sebelum 15 Okt.
    final db = AppDatabase(NativeDatabase.memory(setup: (raw) {
      raw.execute('''
        CREATE TABLE opname_results (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          period_id TEXT NOT NULL, asset_id TEXT NOT NULL, method TEXT NOT NULL,
          status TEXT NOT NULL, condition TEXT NOT NULL, recorded_at INTEGER NOT NULL,
          note TEXT NOT NULL, manual_reason TEXT NOT NULL, photo_count INTEGER NOT NULL,
          gps_distance_m REAL NOT NULL,
          synced INTEGER NOT NULL CHECK (synced IN (0, 1)));
        CREATE TABLE adjustment_requests (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          asset_id TEXT NOT NULL, changes TEXT NOT NULL, reason TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          synced INTEGER NOT NULL DEFAULT 0 CHECK (synced IN (0, 1)));
        INSERT INTO opname_results VALUES (1, '2026-S2', 'AST-0001', 'scan',
          'sesuai', 'baik', 1760000000, '', '', 2, 12.5, 0);
        INSERT INTO adjustment_requests VALUES (1, 'AST-0002', '{"Kondisi":"RR"}',
          'rusak', 1760000000, 0);
        PRAGMA user_version = 1;
      ''');
    }));
    addTearDown(db.close);

    final results = await db.allResults();
    expect(results.single.assetId, 'AST-0001');
    expect(results.single.photoCount, 2);
    expect(results.single.gpsDistanceM, 12.5);
    expect(results.single.userId, '');
    expect(results.single.photoPaths, isEmpty);
    expect((await db.allAdjustments()).single.userId, '');

    // Kolom baru bisa diisi, GPS boleh kosong.
    final id = await db.saveResult(OpnameResult(
      periodId: '2026-S2',
      assetId: 'AST-0003',
      method: OpnameMethod.scan,
      status: OpnameStatus.sesuai,
      condition: AssetCondition.baik,
      recordedAt: DateTime(2026, 10, 15),
      userId: 'a@b.c',
      photoPaths: const ['/x/1.jpg', '/x/2.jpg'],
    ));
    final saved = (await db.allResults()).firstWhere((r) => r.id == id);
    expect(saved.userId, 'a@b.c');
    expect(saved.photoPaths, ['/x/1.jpg', '/x/2.jpg']);
    expect(saved.gpsDistanceM, isNull);
  });
}
