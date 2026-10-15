import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../shared/data/dummy_assets.dart';
import '../../shared/models/asset.dart';
import '../../shared/models/opname_result.dart';

part 'app_database.g.dart';

/// Riwayat hasil opname: setiap pencatatan (termasuk koreksi) = satu baris.
@DataClassName('OpnameRow')
class OpnameResultsTable extends Table {
  @override
  String get tableName => 'opname_results';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get periodId => text()();
  TextColumn get assetId => text()();
  TextColumn get method => textEnum<OpnameMethod>()();
  TextColumn get status => textEnum<OpnameStatus>()();
  TextColumn get condition => textEnum<AssetCondition>()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get note => text()();
  TextColumn get manualReason => text()();
  IntColumn get photoCount => integer()();

  /// Daftar path file foto, disimpan sebagai JSON.
  TextColumn get photoPaths => text().withDefault(const Constant('[]'))();

  /// null = GPS tidak tersedia saat simpan.
  RealColumn get gpsDistanceM => real().nullable()();
  BoolColumn get synced => boolean()();
}

/// Usulan stock adjustment.
@DataClassName('AdjustmentRow')
class AdjustmentsTable extends Table {
  @override
  String get tableName => 'adjustment_requests';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get assetId => text()();

  /// Map field → nilai baru, disimpan sebagai JSON.
  TextColumn get changes => text()();
  TextColumn get reason => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

/// Database lokal (SQLite) di HP. File: `opname.sqlite` di folder aplikasi.
///
/// Master aset belum disimpan di sini karena masih dummy statis.
/// Tambah tabel `assets` saat data aset diunduh dari API.
@DriftDatabase(tables: [OpnameResultsTable, AdjustmentsTable])
class AppDatabase extends _$AppDatabase {
  /// [executor] diisi saat test (database di memori).
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'opname'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Isi awal dummy, hanya saat database pertama kali dibuat dan
          // hanya di build debug — APK release mulai kosong.
          if (!kDebugMode) return;
          for (final r in seedOpnameResults()) {
            await saveResult(r);
          }
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: petugas (userId), file foto, GPS boleh kosong. alterTable
            // menyalin ulang tabel karena SQLite tidak bisa ubah NOT NULL.
            await m.alterTable(TableMigration(
              opnameResultsTable,
              newColumns: [
                opnameResultsTable.userId,
                opnameResultsTable.photoPaths,
              ],
            ));
            await m.addColumn(adjustmentsTable, adjustmentsTable.userId);
          }
        },
      );

  /// Semua riwayat, urut dari yang terlama.
  Future<List<OpnameResult>> allResults() async {
    final rows = await (select(opnameResultsTable)
          ..orderBy([
            (t) => OrderingTerm.asc(t.recordedAt),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
    return [
      for (final r in rows)
        OpnameResult(
          id: r.id,
          periodId: r.periodId,
          assetId: r.assetId,
          method: r.method,
          status: r.status,
          condition: r.condition,
          recordedAt: r.recordedAt,
          userId: r.userId,
          note: r.note,
          manualReason: r.manualReason,
          photoCount: r.photoCount,
          photoPaths: List<String>.from(jsonDecode(r.photoPaths) as List),
          gpsDistanceM: r.gpsDistanceM,
          synced: r.synced,
        ),
    ];
  }

  /// Tambah satu entri riwayat, mengembalikan ID barisnya.
  Future<int> saveResult(OpnameResult r) {
    return into(opnameResultsTable).insert(
      OpnameResultsTableCompanion.insert(
        periodId: r.periodId,
        assetId: r.assetId,
        method: r.method,
        status: r.status,
        condition: r.condition,
        recordedAt: r.recordedAt,
        userId: Value(r.userId),
        note: r.note,
        manualReason: r.manualReason,
        photoCount: r.photoCount,
        photoPaths: Value(jsonEncode(r.photoPaths)),
        gpsDistanceM: Value(r.gpsDistanceM),
        synced: r.synced,
      ),
    );
  }

  Future<void> markResultSynced(int id) {
    return (update(opnameResultsTable)..where((t) => t.id.equals(id)))
        .write(const OpnameResultsTableCompanion(synced: Value(true)));
  }

  Future<List<AdjustmentRequest>> allAdjustments() async {
    final rows = await (select(adjustmentsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return [
      for (final r in rows)
        AdjustmentRequest(
          id: r.id,
          assetId: r.assetId,
          changes: Map<String, String>.from(jsonDecode(r.changes) as Map),
          reason: r.reason,
          createdAt: r.createdAt,
          userId: r.userId,
          synced: r.synced,
        ),
    ];
  }

  /// Simpan usulan baru, mengembalikan ID barisnya.
  Future<int> addAdjustment(AdjustmentRequest a) {
    return into(adjustmentsTable).insert(
      AdjustmentsTableCompanion.insert(
        assetId: a.assetId,
        changes: jsonEncode(a.changes),
        reason: a.reason,
        createdAt: a.createdAt,
        userId: Value(a.userId),
      ),
    );
  }

  /// Hapus data yang sudah terkirim (dipakai saat logout). Yang belum
  /// terkirim tetap disimpan supaya hasil kerja petugas tidak hilang.
  Future<void> deleteSynced() => transaction(() async {
        await (delete(opnameResultsTable)..where((t) => t.synced)).go();
        await (delete(adjustmentsTable)..where((t) => t.synced)).go();
      });

  Future<void> markAdjustmentSynced(int id) {
    return (update(adjustmentsTable)..where((t) => t.id.equals(id)))
        .write(const AdjustmentsTableCompanion(synced: Value(true)));
  }
}
