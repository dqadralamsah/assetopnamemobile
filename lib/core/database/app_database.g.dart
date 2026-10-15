// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OpnameResultsTableTable extends OpnameResultsTable
    with TableInfo<$OpnameResultsTableTable, OpnameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpnameResultsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _periodIdMeta =
      const VerificationMeta('periodId');
  @override
  late final GeneratedColumn<String> periodId = GeneratedColumn<String>(
      'period_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<OpnameMethod, String> method =
      GeneratedColumn<String>('method', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<OpnameMethod>(
              $OpnameResultsTableTable.$convertermethod);
  @override
  late final GeneratedColumnWithTypeConverter<OpnameStatus, String> status =
      GeneratedColumn<String>('status', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<OpnameStatus>(
              $OpnameResultsTableTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<AssetCondition, String>
      condition = GeneratedColumn<String>('condition', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AssetCondition>(
              $OpnameResultsTableTable.$convertercondition);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _manualReasonMeta =
      const VerificationMeta('manualReason');
  @override
  late final GeneratedColumn<String> manualReason = GeneratedColumn<String>(
      'manual_reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoCountMeta =
      const VerificationMeta('photoCount');
  @override
  late final GeneratedColumn<int> photoCount = GeneratedColumn<int>(
      'photo_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _photoPathsMeta =
      const VerificationMeta('photoPaths');
  @override
  late final GeneratedColumn<String> photoPaths = GeneratedColumn<String>(
      'photo_paths', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _gpsDistanceMMeta =
      const VerificationMeta('gpsDistanceM');
  @override
  late final GeneratedColumn<double> gpsDistanceM = GeneratedColumn<double>(
      'gps_distance_m', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        periodId,
        assetId,
        method,
        status,
        condition,
        recordedAt,
        userId,
        note,
        manualReason,
        photoCount,
        photoPaths,
        gpsDistanceM,
        synced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opname_results';
  @override
  VerificationContext validateIntegrity(Insertable<OpnameRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(_periodIdMeta,
          periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta));
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('manual_reason')) {
      context.handle(
          _manualReasonMeta,
          manualReason.isAcceptableOrUnknown(
              data['manual_reason']!, _manualReasonMeta));
    } else if (isInserting) {
      context.missing(_manualReasonMeta);
    }
    if (data.containsKey('photo_count')) {
      context.handle(
          _photoCountMeta,
          photoCount.isAcceptableOrUnknown(
              data['photo_count']!, _photoCountMeta));
    } else if (isInserting) {
      context.missing(_photoCountMeta);
    }
    if (data.containsKey('photo_paths')) {
      context.handle(
          _photoPathsMeta,
          photoPaths.isAcceptableOrUnknown(
              data['photo_paths']!, _photoPathsMeta));
    }
    if (data.containsKey('gps_distance_m')) {
      context.handle(
          _gpsDistanceMMeta,
          gpsDistanceM.isAcceptableOrUnknown(
              data['gps_distance_m']!, _gpsDistanceMMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    } else if (isInserting) {
      context.missing(_syncedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpnameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpnameRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      periodId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}period_id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      method: $OpnameResultsTableTable.$convertermethod.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!),
      status: $OpnameResultsTableTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!),
      condition: $OpnameResultsTableTable.$convertercondition.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}condition'])!),
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      manualReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manual_reason'])!,
      photoCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}photo_count'])!,
      photoPaths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_paths'])!,
      gpsDistanceM: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}gps_distance_m']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $OpnameResultsTableTable createAlias(String alias) {
    return $OpnameResultsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OpnameMethod, String, String> $convertermethod =
      const EnumNameConverter<OpnameMethod>(OpnameMethod.values);
  static JsonTypeConverter2<OpnameStatus, String, String> $converterstatus =
      const EnumNameConverter<OpnameStatus>(OpnameStatus.values);
  static JsonTypeConverter2<AssetCondition, String, String>
      $convertercondition =
      const EnumNameConverter<AssetCondition>(AssetCondition.values);
}

class OpnameRow extends DataClass implements Insertable<OpnameRow> {
  final int id;
  final String periodId;
  final String assetId;
  final OpnameMethod method;
  final OpnameStatus status;
  final AssetCondition condition;
  final DateTime recordedAt;
  final String userId;
  final String note;
  final String manualReason;
  final int photoCount;

  /// Daftar path file foto, disimpan sebagai JSON.
  final String photoPaths;

  /// null = GPS tidak tersedia saat simpan.
  final double? gpsDistanceM;
  final bool synced;
  const OpnameRow(
      {required this.id,
      required this.periodId,
      required this.assetId,
      required this.method,
      required this.status,
      required this.condition,
      required this.recordedAt,
      required this.userId,
      required this.note,
      required this.manualReason,
      required this.photoCount,
      required this.photoPaths,
      this.gpsDistanceM,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<String>(periodId);
    map['asset_id'] = Variable<String>(assetId);
    {
      map['method'] = Variable<String>(
          $OpnameResultsTableTable.$convertermethod.toSql(method));
    }
    {
      map['status'] = Variable<String>(
          $OpnameResultsTableTable.$converterstatus.toSql(status));
    }
    {
      map['condition'] = Variable<String>(
          $OpnameResultsTableTable.$convertercondition.toSql(condition));
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['user_id'] = Variable<String>(userId);
    map['note'] = Variable<String>(note);
    map['manual_reason'] = Variable<String>(manualReason);
    map['photo_count'] = Variable<int>(photoCount);
    map['photo_paths'] = Variable<String>(photoPaths);
    if (!nullToAbsent || gpsDistanceM != null) {
      map['gps_distance_m'] = Variable<double>(gpsDistanceM);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  OpnameResultsTableCompanion toCompanion(bool nullToAbsent) {
    return OpnameResultsTableCompanion(
      id: Value(id),
      periodId: Value(periodId),
      assetId: Value(assetId),
      method: Value(method),
      status: Value(status),
      condition: Value(condition),
      recordedAt: Value(recordedAt),
      userId: Value(userId),
      note: Value(note),
      manualReason: Value(manualReason),
      photoCount: Value(photoCount),
      photoPaths: Value(photoPaths),
      gpsDistanceM: gpsDistanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(gpsDistanceM),
      synced: Value(synced),
    );
  }

  factory OpnameRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpnameRow(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<String>(json['periodId']),
      assetId: serializer.fromJson<String>(json['assetId']),
      method: $OpnameResultsTableTable.$convertermethod
          .fromJson(serializer.fromJson<String>(json['method'])),
      status: $OpnameResultsTableTable.$converterstatus
          .fromJson(serializer.fromJson<String>(json['status'])),
      condition: $OpnameResultsTableTable.$convertercondition
          .fromJson(serializer.fromJson<String>(json['condition'])),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      userId: serializer.fromJson<String>(json['userId']),
      note: serializer.fromJson<String>(json['note']),
      manualReason: serializer.fromJson<String>(json['manualReason']),
      photoCount: serializer.fromJson<int>(json['photoCount']),
      photoPaths: serializer.fromJson<String>(json['photoPaths']),
      gpsDistanceM: serializer.fromJson<double?>(json['gpsDistanceM']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<String>(periodId),
      'assetId': serializer.toJson<String>(assetId),
      'method': serializer.toJson<String>(
          $OpnameResultsTableTable.$convertermethod.toJson(method)),
      'status': serializer.toJson<String>(
          $OpnameResultsTableTable.$converterstatus.toJson(status)),
      'condition': serializer.toJson<String>(
          $OpnameResultsTableTable.$convertercondition.toJson(condition)),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'userId': serializer.toJson<String>(userId),
      'note': serializer.toJson<String>(note),
      'manualReason': serializer.toJson<String>(manualReason),
      'photoCount': serializer.toJson<int>(photoCount),
      'photoPaths': serializer.toJson<String>(photoPaths),
      'gpsDistanceM': serializer.toJson<double?>(gpsDistanceM),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  OpnameRow copyWith(
          {int? id,
          String? periodId,
          String? assetId,
          OpnameMethod? method,
          OpnameStatus? status,
          AssetCondition? condition,
          DateTime? recordedAt,
          String? userId,
          String? note,
          String? manualReason,
          int? photoCount,
          String? photoPaths,
          Value<double?> gpsDistanceM = const Value.absent(),
          bool? synced}) =>
      OpnameRow(
        id: id ?? this.id,
        periodId: periodId ?? this.periodId,
        assetId: assetId ?? this.assetId,
        method: method ?? this.method,
        status: status ?? this.status,
        condition: condition ?? this.condition,
        recordedAt: recordedAt ?? this.recordedAt,
        userId: userId ?? this.userId,
        note: note ?? this.note,
        manualReason: manualReason ?? this.manualReason,
        photoCount: photoCount ?? this.photoCount,
        photoPaths: photoPaths ?? this.photoPaths,
        gpsDistanceM:
            gpsDistanceM.present ? gpsDistanceM.value : this.gpsDistanceM,
        synced: synced ?? this.synced,
      );
  OpnameRow copyWithCompanion(OpnameResultsTableCompanion data) {
    return OpnameRow(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      method: data.method.present ? data.method.value : this.method,
      status: data.status.present ? data.status.value : this.status,
      condition: data.condition.present ? data.condition.value : this.condition,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      note: data.note.present ? data.note.value : this.note,
      manualReason: data.manualReason.present
          ? data.manualReason.value
          : this.manualReason,
      photoCount:
          data.photoCount.present ? data.photoCount.value : this.photoCount,
      photoPaths:
          data.photoPaths.present ? data.photoPaths.value : this.photoPaths,
      gpsDistanceM: data.gpsDistanceM.present
          ? data.gpsDistanceM.value
          : this.gpsDistanceM,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpnameRow(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('assetId: $assetId, ')
          ..write('method: $method, ')
          ..write('status: $status, ')
          ..write('condition: $condition, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('userId: $userId, ')
          ..write('note: $note, ')
          ..write('manualReason: $manualReason, ')
          ..write('photoCount: $photoCount, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('gpsDistanceM: $gpsDistanceM, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      periodId,
      assetId,
      method,
      status,
      condition,
      recordedAt,
      userId,
      note,
      manualReason,
      photoCount,
      photoPaths,
      gpsDistanceM,
      synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpnameRow &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.assetId == this.assetId &&
          other.method == this.method &&
          other.status == this.status &&
          other.condition == this.condition &&
          other.recordedAt == this.recordedAt &&
          other.userId == this.userId &&
          other.note == this.note &&
          other.manualReason == this.manualReason &&
          other.photoCount == this.photoCount &&
          other.photoPaths == this.photoPaths &&
          other.gpsDistanceM == this.gpsDistanceM &&
          other.synced == this.synced);
}

class OpnameResultsTableCompanion extends UpdateCompanion<OpnameRow> {
  final Value<int> id;
  final Value<String> periodId;
  final Value<String> assetId;
  final Value<OpnameMethod> method;
  final Value<OpnameStatus> status;
  final Value<AssetCondition> condition;
  final Value<DateTime> recordedAt;
  final Value<String> userId;
  final Value<String> note;
  final Value<String> manualReason;
  final Value<int> photoCount;
  final Value<String> photoPaths;
  final Value<double?> gpsDistanceM;
  final Value<bool> synced;
  const OpnameResultsTableCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.method = const Value.absent(),
    this.status = const Value.absent(),
    this.condition = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.note = const Value.absent(),
    this.manualReason = const Value.absent(),
    this.photoCount = const Value.absent(),
    this.photoPaths = const Value.absent(),
    this.gpsDistanceM = const Value.absent(),
    this.synced = const Value.absent(),
  });
  OpnameResultsTableCompanion.insert({
    this.id = const Value.absent(),
    required String periodId,
    required String assetId,
    required OpnameMethod method,
    required OpnameStatus status,
    required AssetCondition condition,
    required DateTime recordedAt,
    this.userId = const Value.absent(),
    required String note,
    required String manualReason,
    required int photoCount,
    this.photoPaths = const Value.absent(),
    this.gpsDistanceM = const Value.absent(),
    required bool synced,
  })  : periodId = Value(periodId),
        assetId = Value(assetId),
        method = Value(method),
        status = Value(status),
        condition = Value(condition),
        recordedAt = Value(recordedAt),
        note = Value(note),
        manualReason = Value(manualReason),
        photoCount = Value(photoCount),
        synced = Value(synced);
  static Insertable<OpnameRow> custom({
    Expression<int>? id,
    Expression<String>? periodId,
    Expression<String>? assetId,
    Expression<String>? method,
    Expression<String>? status,
    Expression<String>? condition,
    Expression<DateTime>? recordedAt,
    Expression<String>? userId,
    Expression<String>? note,
    Expression<String>? manualReason,
    Expression<int>? photoCount,
    Expression<String>? photoPaths,
    Expression<double>? gpsDistanceM,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (assetId != null) 'asset_id': assetId,
      if (method != null) 'method': method,
      if (status != null) 'status': status,
      if (condition != null) 'condition': condition,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (userId != null) 'user_id': userId,
      if (note != null) 'note': note,
      if (manualReason != null) 'manual_reason': manualReason,
      if (photoCount != null) 'photo_count': photoCount,
      if (photoPaths != null) 'photo_paths': photoPaths,
      if (gpsDistanceM != null) 'gps_distance_m': gpsDistanceM,
      if (synced != null) 'synced': synced,
    });
  }

  OpnameResultsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? periodId,
      Value<String>? assetId,
      Value<OpnameMethod>? method,
      Value<OpnameStatus>? status,
      Value<AssetCondition>? condition,
      Value<DateTime>? recordedAt,
      Value<String>? userId,
      Value<String>? note,
      Value<String>? manualReason,
      Value<int>? photoCount,
      Value<String>? photoPaths,
      Value<double?>? gpsDistanceM,
      Value<bool>? synced}) {
    return OpnameResultsTableCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      assetId: assetId ?? this.assetId,
      method: method ?? this.method,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      recordedAt: recordedAt ?? this.recordedAt,
      userId: userId ?? this.userId,
      note: note ?? this.note,
      manualReason: manualReason ?? this.manualReason,
      photoCount: photoCount ?? this.photoCount,
      photoPaths: photoPaths ?? this.photoPaths,
      gpsDistanceM: gpsDistanceM ?? this.gpsDistanceM,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<String>(periodId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(
          $OpnameResultsTableTable.$convertermethod.toSql(method.value));
    }
    if (status.present) {
      map['status'] = Variable<String>(
          $OpnameResultsTableTable.$converterstatus.toSql(status.value));
    }
    if (condition.present) {
      map['condition'] = Variable<String>(
          $OpnameResultsTableTable.$convertercondition.toSql(condition.value));
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (manualReason.present) {
      map['manual_reason'] = Variable<String>(manualReason.value);
    }
    if (photoCount.present) {
      map['photo_count'] = Variable<int>(photoCount.value);
    }
    if (photoPaths.present) {
      map['photo_paths'] = Variable<String>(photoPaths.value);
    }
    if (gpsDistanceM.present) {
      map['gps_distance_m'] = Variable<double>(gpsDistanceM.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpnameResultsTableCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('assetId: $assetId, ')
          ..write('method: $method, ')
          ..write('status: $status, ')
          ..write('condition: $condition, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('userId: $userId, ')
          ..write('note: $note, ')
          ..write('manualReason: $manualReason, ')
          ..write('photoCount: $photoCount, ')
          ..write('photoPaths: $photoPaths, ')
          ..write('gpsDistanceM: $gpsDistanceM, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $AdjustmentsTableTable extends AdjustmentsTable
    with TableInfo<$AdjustmentsTableTable, AdjustmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdjustmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _assetIdMeta =
      const VerificationMeta('assetId');
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
      'asset_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changesMeta =
      const VerificationMeta('changes');
  @override
  late final GeneratedColumn<String> changes = GeneratedColumn<String>(
      'changes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, assetId, changes, reason, createdAt, userId, synced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adjustment_requests';
  @override
  VerificationContext validateIntegrity(Insertable<AdjustmentRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(_assetIdMeta,
          assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta));
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('changes')) {
      context.handle(_changesMeta,
          changes.isAcceptableOrUnknown(data['changes']!, _changesMeta));
    } else if (isInserting) {
      context.missing(_changesMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdjustmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdjustmentRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      assetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_id'])!,
      changes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changes'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
    );
  }

  @override
  $AdjustmentsTableTable createAlias(String alias) {
    return $AdjustmentsTableTable(attachedDatabase, alias);
  }
}

class AdjustmentRow extends DataClass implements Insertable<AdjustmentRow> {
  final int id;
  final String assetId;

  /// Map field → nilai baru, disimpan sebagai JSON.
  final String changes;
  final String reason;
  final DateTime createdAt;
  final String userId;
  final bool synced;
  const AdjustmentRow(
      {required this.id,
      required this.assetId,
      required this.changes,
      required this.reason,
      required this.createdAt,
      required this.userId,
      required this.synced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<String>(assetId);
    map['changes'] = Variable<String>(changes);
    map['reason'] = Variable<String>(reason);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['user_id'] = Variable<String>(userId);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  AdjustmentsTableCompanion toCompanion(bool nullToAbsent) {
    return AdjustmentsTableCompanion(
      id: Value(id),
      assetId: Value(assetId),
      changes: Value(changes),
      reason: Value(reason),
      createdAt: Value(createdAt),
      userId: Value(userId),
      synced: Value(synced),
    );
  }

  factory AdjustmentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdjustmentRow(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<String>(json['assetId']),
      changes: serializer.fromJson<String>(json['changes']),
      reason: serializer.fromJson<String>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      userId: serializer.fromJson<String>(json['userId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<String>(assetId),
      'changes': serializer.toJson<String>(changes),
      'reason': serializer.toJson<String>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'userId': serializer.toJson<String>(userId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  AdjustmentRow copyWith(
          {int? id,
          String? assetId,
          String? changes,
          String? reason,
          DateTime? createdAt,
          String? userId,
          bool? synced}) =>
      AdjustmentRow(
        id: id ?? this.id,
        assetId: assetId ?? this.assetId,
        changes: changes ?? this.changes,
        reason: reason ?? this.reason,
        createdAt: createdAt ?? this.createdAt,
        userId: userId ?? this.userId,
        synced: synced ?? this.synced,
      );
  AdjustmentRow copyWithCompanion(AdjustmentsTableCompanion data) {
    return AdjustmentRow(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      changes: data.changes.present ? data.changes.value : this.changes,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentRow(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('changes: $changes, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, assetId, changes, reason, createdAt, userId, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdjustmentRow &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.changes == this.changes &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt &&
          other.userId == this.userId &&
          other.synced == this.synced);
}

class AdjustmentsTableCompanion extends UpdateCompanion<AdjustmentRow> {
  final Value<int> id;
  final Value<String> assetId;
  final Value<String> changes;
  final Value<String> reason;
  final Value<DateTime> createdAt;
  final Value<String> userId;
  final Value<bool> synced;
  const AdjustmentsTableCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.changes = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
  });
  AdjustmentsTableCompanion.insert({
    this.id = const Value.absent(),
    required String assetId,
    required String changes,
    required String reason,
    required DateTime createdAt,
    this.userId = const Value.absent(),
    this.synced = const Value.absent(),
  })  : assetId = Value(assetId),
        changes = Value(changes),
        reason = Value(reason),
        createdAt = Value(createdAt);
  static Insertable<AdjustmentRow> custom({
    Expression<int>? id,
    Expression<String>? assetId,
    Expression<String>? changes,
    Expression<String>? reason,
    Expression<DateTime>? createdAt,
    Expression<String>? userId,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (changes != null) 'changes': changes,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (userId != null) 'user_id': userId,
      if (synced != null) 'synced': synced,
    });
  }

  AdjustmentsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? assetId,
      Value<String>? changes,
      Value<String>? reason,
      Value<DateTime>? createdAt,
      Value<String>? userId,
      Value<bool>? synced}) {
    return AdjustmentsTableCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      changes: changes ?? this.changes,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (changes.present) {
      map['changes'] = Variable<String>(changes.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('changes: $changes, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('userId: $userId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OpnameResultsTableTable opnameResultsTable =
      $OpnameResultsTableTable(this);
  late final $AdjustmentsTableTable adjustmentsTable =
      $AdjustmentsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [opnameResultsTable, adjustmentsTable];
}

typedef $$OpnameResultsTableTableCreateCompanionBuilder
    = OpnameResultsTableCompanion Function({
  Value<int> id,
  required String periodId,
  required String assetId,
  required OpnameMethod method,
  required OpnameStatus status,
  required AssetCondition condition,
  required DateTime recordedAt,
  Value<String> userId,
  required String note,
  required String manualReason,
  required int photoCount,
  Value<String> photoPaths,
  Value<double?> gpsDistanceM,
  required bool synced,
});
typedef $$OpnameResultsTableTableUpdateCompanionBuilder
    = OpnameResultsTableCompanion Function({
  Value<int> id,
  Value<String> periodId,
  Value<String> assetId,
  Value<OpnameMethod> method,
  Value<OpnameStatus> status,
  Value<AssetCondition> condition,
  Value<DateTime> recordedAt,
  Value<String> userId,
  Value<String> note,
  Value<String> manualReason,
  Value<int> photoCount,
  Value<String> photoPaths,
  Value<double?> gpsDistanceM,
  Value<bool> synced,
});

class $$OpnameResultsTableTableFilterComposer
    extends Composer<_$AppDatabase, $OpnameResultsTableTable> {
  $$OpnameResultsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get periodId => $composableBuilder(
      column: $table.periodId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<OpnameMethod, OpnameMethod, String>
      get method => $composableBuilder(
          column: $table.method,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<OpnameStatus, OpnameStatus, String>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<AssetCondition, AssetCondition, String>
      get condition => $composableBuilder(
          column: $table.condition,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manualReason => $composableBuilder(
      column: $table.manualReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get photoCount => $composableBuilder(
      column: $table.photoCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPaths => $composableBuilder(
      column: $table.photoPaths, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gpsDistanceM => $composableBuilder(
      column: $table.gpsDistanceM, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$OpnameResultsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OpnameResultsTableTable> {
  $$OpnameResultsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get periodId => $composableBuilder(
      column: $table.periodId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manualReason => $composableBuilder(
      column: $table.manualReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get photoCount => $composableBuilder(
      column: $table.photoCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPaths => $composableBuilder(
      column: $table.photoPaths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gpsDistanceM => $composableBuilder(
      column: $table.gpsDistanceM,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$OpnameResultsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpnameResultsTableTable> {
  $$OpnameResultsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodId =>
      $composableBuilder(column: $table.periodId, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OpnameMethod, String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OpnameStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssetCondition, String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get manualReason => $composableBuilder(
      column: $table.manualReason, builder: (column) => column);

  GeneratedColumn<int> get photoCount => $composableBuilder(
      column: $table.photoCount, builder: (column) => column);

  GeneratedColumn<String> get photoPaths => $composableBuilder(
      column: $table.photoPaths, builder: (column) => column);

  GeneratedColumn<double> get gpsDistanceM => $composableBuilder(
      column: $table.gpsDistanceM, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$OpnameResultsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OpnameResultsTableTable,
    OpnameRow,
    $$OpnameResultsTableTableFilterComposer,
    $$OpnameResultsTableTableOrderingComposer,
    $$OpnameResultsTableTableAnnotationComposer,
    $$OpnameResultsTableTableCreateCompanionBuilder,
    $$OpnameResultsTableTableUpdateCompanionBuilder,
    (
      OpnameRow,
      BaseReferences<_$AppDatabase, $OpnameResultsTableTable, OpnameRow>
    ),
    OpnameRow,
    PrefetchHooks Function()> {
  $$OpnameResultsTableTableTableManager(
      _$AppDatabase db, $OpnameResultsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpnameResultsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpnameResultsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpnameResultsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> periodId = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<OpnameMethod> method = const Value.absent(),
            Value<OpnameStatus> status = const Value.absent(),
            Value<AssetCondition> condition = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> manualReason = const Value.absent(),
            Value<int> photoCount = const Value.absent(),
            Value<String> photoPaths = const Value.absent(),
            Value<double?> gpsDistanceM = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              OpnameResultsTableCompanion(
            id: id,
            periodId: periodId,
            assetId: assetId,
            method: method,
            status: status,
            condition: condition,
            recordedAt: recordedAt,
            userId: userId,
            note: note,
            manualReason: manualReason,
            photoCount: photoCount,
            photoPaths: photoPaths,
            gpsDistanceM: gpsDistanceM,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String periodId,
            required String assetId,
            required OpnameMethod method,
            required OpnameStatus status,
            required AssetCondition condition,
            required DateTime recordedAt,
            Value<String> userId = const Value.absent(),
            required String note,
            required String manualReason,
            required int photoCount,
            Value<String> photoPaths = const Value.absent(),
            Value<double?> gpsDistanceM = const Value.absent(),
            required bool synced,
          }) =>
              OpnameResultsTableCompanion.insert(
            id: id,
            periodId: periodId,
            assetId: assetId,
            method: method,
            status: status,
            condition: condition,
            recordedAt: recordedAt,
            userId: userId,
            note: note,
            manualReason: manualReason,
            photoCount: photoCount,
            photoPaths: photoPaths,
            gpsDistanceM: gpsDistanceM,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OpnameResultsTableTable, OpnameRow>(table),
                    BaseReferences<_$AppDatabase, $OpnameResultsTableTable,
                        OpnameRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OpnameResultsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OpnameResultsTableTable,
    OpnameRow,
    $$OpnameResultsTableTableFilterComposer,
    $$OpnameResultsTableTableOrderingComposer,
    $$OpnameResultsTableTableAnnotationComposer,
    $$OpnameResultsTableTableCreateCompanionBuilder,
    $$OpnameResultsTableTableUpdateCompanionBuilder,
    (
      OpnameRow,
      BaseReferences<_$AppDatabase, $OpnameResultsTableTable, OpnameRow>
    ),
    OpnameRow,
    PrefetchHooks Function()>;
typedef $$AdjustmentsTableTableCreateCompanionBuilder
    = AdjustmentsTableCompanion Function({
  Value<int> id,
  required String assetId,
  required String changes,
  required String reason,
  required DateTime createdAt,
  Value<String> userId,
  Value<bool> synced,
});
typedef $$AdjustmentsTableTableUpdateCompanionBuilder
    = AdjustmentsTableCompanion Function({
  Value<int> id,
  Value<String> assetId,
  Value<String> changes,
  Value<String> reason,
  Value<DateTime> createdAt,
  Value<String> userId,
  Value<bool> synced,
});

class $$AdjustmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AdjustmentsTableTable> {
  $$AdjustmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));
}

class $$AdjustmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AdjustmentsTableTable> {
  $$AdjustmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetId => $composableBuilder(
      column: $table.assetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changes => $composableBuilder(
      column: $table.changes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));
}

class $$AdjustmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdjustmentsTableTable> {
  $$AdjustmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get changes =>
      $composableBuilder(column: $table.changes, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$AdjustmentsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AdjustmentsTableTable,
    AdjustmentRow,
    $$AdjustmentsTableTableFilterComposer,
    $$AdjustmentsTableTableOrderingComposer,
    $$AdjustmentsTableTableAnnotationComposer,
    $$AdjustmentsTableTableCreateCompanionBuilder,
    $$AdjustmentsTableTableUpdateCompanionBuilder,
    (
      AdjustmentRow,
      BaseReferences<_$AppDatabase, $AdjustmentsTableTable, AdjustmentRow>
    ),
    AdjustmentRow,
    PrefetchHooks Function()> {
  $$AdjustmentsTableTableTableManager(
      _$AppDatabase db, $AdjustmentsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdjustmentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdjustmentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdjustmentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> assetId = const Value.absent(),
            Value<String> changes = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              AdjustmentsTableCompanion(
            id: id,
            assetId: assetId,
            changes: changes,
            reason: reason,
            createdAt: createdAt,
            userId: userId,
            synced: synced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String assetId,
            required String changes,
            required String reason,
            required DateTime createdAt,
            Value<String> userId = const Value.absent(),
            Value<bool> synced = const Value.absent(),
          }) =>
              AdjustmentsTableCompanion.insert(
            id: id,
            assetId: assetId,
            changes: changes,
            reason: reason,
            createdAt: createdAt,
            userId: userId,
            synced: synced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AdjustmentsTableTable, AdjustmentRow>(table),
                    BaseReferences<_$AppDatabase, $AdjustmentsTableTable,
                        AdjustmentRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AdjustmentsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AdjustmentsTableTable,
    AdjustmentRow,
    $$AdjustmentsTableTableFilterComposer,
    $$AdjustmentsTableTableOrderingComposer,
    $$AdjustmentsTableTableAnnotationComposer,
    $$AdjustmentsTableTableCreateCompanionBuilder,
    $$AdjustmentsTableTableUpdateCompanionBuilder,
    (
      AdjustmentRow,
      BaseReferences<_$AppDatabase, $AdjustmentsTableTable, AdjustmentRow>
    ),
    AdjustmentRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OpnameResultsTableTableTableManager get opnameResultsTable =>
      $$OpnameResultsTableTableTableManager(_db, _db.opnameResultsTable);
  $$AdjustmentsTableTableTableManager get adjustmentsTable =>
      $$AdjustmentsTableTableTableManager(_db, _db.adjustmentsTable);
}
