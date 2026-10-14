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
    ).toJson();
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
  });
}
