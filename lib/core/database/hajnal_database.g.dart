// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hajnal_database.dart';

// ignore_for_file: type=lint
class $RecoveryPeriodsTable extends RecoveryPeriods
    with TableInfo<$RecoveryPeriodsTable, RecoveryPeriod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryPeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startLocalDateMeta = const VerificationMeta(
    'startLocalDate',
  );
  @override
  late final GeneratedColumn<String> startLocalDate = GeneratedColumn<String>(
    'start_local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($RecoveryPeriodsTable.$convertercreatedAtUtc);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime> closedAtUtc =
      GeneratedColumn<DateTime>(
        'closed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($RecoveryPeriodsTable.$converterclosedAtUtcn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startLocalDate,
    createdAtUtc,
    closedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_periods';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryPeriod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_local_date')) {
      context.handle(
        _startLocalDateMeta,
        startLocalDate.isAcceptableOrUnknown(
          data['start_local_date']!,
          _startLocalDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startLocalDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryPeriod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryPeriod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startLocalDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_local_date'],
      )!,
      createdAtUtc: $RecoveryPeriodsTable.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      closedAtUtc: $RecoveryPeriodsTable.$converterclosedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}closed_at_utc'],
        ),
      ),
    );
  }

  @override
  $RecoveryPeriodsTable createAlias(String alias) {
    return $RecoveryPeriodsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcInstant();
  static TypeConverter<DateTime, DateTime> $converterclosedAtUtc =
      const UtcInstant();
  static TypeConverter<DateTime?, DateTime?> $converterclosedAtUtcn =
      NullAwareTypeConverter.wrap($converterclosedAtUtc);
}

class RecoveryPeriod extends DataClass implements Insertable<RecoveryPeriod> {
  final int id;
  final String startLocalDate;
  final DateTime createdAtUtc;
  final DateTime? closedAtUtc;
  const RecoveryPeriod({
    required this.id,
    required this.startLocalDate,
    required this.createdAtUtc,
    this.closedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_local_date'] = Variable<String>(startLocalDate);
    {
      map['created_at_utc'] = Variable<DateTime>(
        $RecoveryPeriodsTable.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    if (!nullToAbsent || closedAtUtc != null) {
      map['closed_at_utc'] = Variable<DateTime>(
        $RecoveryPeriodsTable.$converterclosedAtUtcn.toSql(closedAtUtc),
      );
    }
    return map;
  }

  RecoveryPeriodsCompanion toCompanion(bool nullToAbsent) {
    return RecoveryPeriodsCompanion(
      id: Value(id),
      startLocalDate: Value(startLocalDate),
      createdAtUtc: Value(createdAtUtc),
      closedAtUtc: closedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAtUtc),
    );
  }

  factory RecoveryPeriod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryPeriod(
      id: serializer.fromJson<int>(json['id']),
      startLocalDate: serializer.fromJson<String>(json['startLocalDate']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      closedAtUtc: serializer.fromJson<DateTime?>(json['closedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startLocalDate': serializer.toJson<String>(startLocalDate),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'closedAtUtc': serializer.toJson<DateTime?>(closedAtUtc),
    };
  }

  RecoveryPeriod copyWith({
    int? id,
    String? startLocalDate,
    DateTime? createdAtUtc,
    Value<DateTime?> closedAtUtc = const Value.absent(),
  }) => RecoveryPeriod(
    id: id ?? this.id,
    startLocalDate: startLocalDate ?? this.startLocalDate,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    closedAtUtc: closedAtUtc.present ? closedAtUtc.value : this.closedAtUtc,
  );
  RecoveryPeriod copyWithCompanion(RecoveryPeriodsCompanion data) {
    return RecoveryPeriod(
      id: data.id.present ? data.id.value : this.id,
      startLocalDate: data.startLocalDate.present
          ? data.startLocalDate.value
          : this.startLocalDate,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      closedAtUtc: data.closedAtUtc.present
          ? data.closedAtUtc.value
          : this.closedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryPeriod(')
          ..write('id: $id, ')
          ..write('startLocalDate: $startLocalDate, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('closedAtUtc: $closedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, startLocalDate, createdAtUtc, closedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryPeriod &&
          other.id == this.id &&
          other.startLocalDate == this.startLocalDate &&
          other.createdAtUtc == this.createdAtUtc &&
          other.closedAtUtc == this.closedAtUtc);
}

class RecoveryPeriodsCompanion extends UpdateCompanion<RecoveryPeriod> {
  final Value<int> id;
  final Value<String> startLocalDate;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime?> closedAtUtc;
  const RecoveryPeriodsCompanion({
    this.id = const Value.absent(),
    this.startLocalDate = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.closedAtUtc = const Value.absent(),
  });
  RecoveryPeriodsCompanion.insert({
    this.id = const Value.absent(),
    required String startLocalDate,
    required DateTime createdAtUtc,
    this.closedAtUtc = const Value.absent(),
  }) : startLocalDate = Value(startLocalDate),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<RecoveryPeriod> custom({
    Expression<int>? id,
    Expression<String>? startLocalDate,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? closedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startLocalDate != null) 'start_local_date': startLocalDate,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (closedAtUtc != null) 'closed_at_utc': closedAtUtc,
    });
  }

  RecoveryPeriodsCompanion copyWith({
    Value<int>? id,
    Value<String>? startLocalDate,
    Value<DateTime>? createdAtUtc,
    Value<DateTime?>? closedAtUtc,
  }) {
    return RecoveryPeriodsCompanion(
      id: id ?? this.id,
      startLocalDate: startLocalDate ?? this.startLocalDate,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      closedAtUtc: closedAtUtc ?? this.closedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startLocalDate.present) {
      map['start_local_date'] = Variable<String>(startLocalDate.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        $RecoveryPeriodsTable.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (closedAtUtc.present) {
      map['closed_at_utc'] = Variable<DateTime>(
        $RecoveryPeriodsTable.$converterclosedAtUtcn.toSql(closedAtUtc.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryPeriodsCompanion(')
          ..write('id: $id, ')
          ..write('startLocalDate: $startLocalDate, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('closedAtUtc: $closedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $ArtworkOverridesTable extends ArtworkOverrides
    with TableInfo<$ArtworkOverridesTable, ArtworkOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworkOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<String> revision = GeneratedColumn<String>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [role, filename, revision];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artwork_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtworkOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {role};
  @override
  ArtworkOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtworkOverride(
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ArtworkOverridesTable createAlias(String alias) {
    return $ArtworkOverridesTable(attachedDatabase, alias);
  }
}

class ArtworkOverride extends DataClass implements Insertable<ArtworkOverride> {
  final String role;
  final String filename;
  final String revision;
  const ArtworkOverride({
    required this.role,
    required this.filename,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['role'] = Variable<String>(role);
    map['filename'] = Variable<String>(filename);
    map['revision'] = Variable<String>(revision);
    return map;
  }

  ArtworkOverridesCompanion toCompanion(bool nullToAbsent) {
    return ArtworkOverridesCompanion(
      role: Value(role),
      filename: Value(filename),
      revision: Value(revision),
    );
  }

  factory ArtworkOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtworkOverride(
      role: serializer.fromJson<String>(json['role']),
      filename: serializer.fromJson<String>(json['filename']),
      revision: serializer.fromJson<String>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'role': serializer.toJson<String>(role),
      'filename': serializer.toJson<String>(filename),
      'revision': serializer.toJson<String>(revision),
    };
  }

  ArtworkOverride copyWith({
    String? role,
    String? filename,
    String? revision,
  }) => ArtworkOverride(
    role: role ?? this.role,
    filename: filename ?? this.filename,
    revision: revision ?? this.revision,
  );
  ArtworkOverride copyWithCompanion(ArtworkOverridesCompanion data) {
    return ArtworkOverride(
      role: data.role.present ? data.role.value : this.role,
      filename: data.filename.present ? data.filename.value : this.filename,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkOverride(')
          ..write('role: $role, ')
          ..write('filename: $filename, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(role, filename, revision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtworkOverride &&
          other.role == this.role &&
          other.filename == this.filename &&
          other.revision == this.revision);
}

class ArtworkOverridesCompanion extends UpdateCompanion<ArtworkOverride> {
  final Value<String> role;
  final Value<String> filename;
  final Value<String> revision;
  final Value<int> rowid;
  const ArtworkOverridesCompanion({
    this.role = const Value.absent(),
    this.filename = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtworkOverridesCompanion.insert({
    required String role,
    required String filename,
    required String revision,
    this.rowid = const Value.absent(),
  }) : role = Value(role),
       filename = Value(filename),
       revision = Value(revision);
  static Insertable<ArtworkOverride> custom({
    Expression<String>? role,
    Expression<String>? filename,
    Expression<String>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (role != null) 'role': role,
      if (filename != null) 'filename': filename,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtworkOverridesCompanion copyWith({
    Value<String>? role,
    Value<String>? filename,
    Value<String>? revision,
    Value<int>? rowid,
  }) {
    return ArtworkOverridesCompanion(
      role: role ?? this.role,
      filename: filename ?? this.filename,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (revision.present) {
      map['revision'] = Variable<String>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkOverridesCompanion(')
          ..write('role: $role, ')
          ..write('filename: $filename, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LockSettingsTable extends LockSettings
    with TableInfo<$LockSettingsTable, LockSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LockSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<int> mode = GeneratedColumn<int>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _credentialSlotMeta = const VerificationMeta(
    'credentialSlot',
  );
  @override
  late final GeneratedColumn<String> credentialSlot = GeneratedColumn<String>(
    'credential_slot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retryDeadlineMeta = const VerificationMeta(
    'retryDeadline',
  );
  @override
  late final GeneratedColumn<int> retryDeadline = GeneratedColumn<int>(
    'retry_deadline',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _retryBootMeta = const VerificationMeta(
    'retryBoot',
  );
  @override
  late final GeneratedColumn<String> retryBoot = GeneratedColumn<String>(
    'retry_boot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    credentialSlot,
    failedAttempts,
    retryDeadline,
    retryBoot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lock_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LockSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('credential_slot')) {
      context.handle(
        _credentialSlotMeta,
        credentialSlot.isAcceptableOrUnknown(
          data['credential_slot']!,
          _credentialSlotMeta,
        ),
      );
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('retry_deadline')) {
      context.handle(
        _retryDeadlineMeta,
        retryDeadline.isAcceptableOrUnknown(
          data['retry_deadline']!,
          _retryDeadlineMeta,
        ),
      );
    }
    if (data.containsKey('retry_boot')) {
      context.handle(
        _retryBootMeta,
        retryBoot.isAcceptableOrUnknown(data['retry_boot']!, _retryBootMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LockSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LockSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mode'],
      )!,
      credentialSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credential_slot'],
      ),
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      retryDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_deadline'],
      )!,
      retryBoot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retry_boot'],
      )!,
    );
  }

  @override
  $LockSettingsTable createAlias(String alias) {
    return $LockSettingsTable(attachedDatabase, alias);
  }
}

class LockSetting extends DataClass implements Insertable<LockSetting> {
  final int id;
  final int mode;
  final String? credentialSlot;
  final int failedAttempts;
  final int retryDeadline;
  final String retryBoot;
  const LockSetting({
    required this.id,
    required this.mode,
    this.credentialSlot,
    required this.failedAttempts,
    required this.retryDeadline,
    required this.retryBoot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mode'] = Variable<int>(mode);
    if (!nullToAbsent || credentialSlot != null) {
      map['credential_slot'] = Variable<String>(credentialSlot);
    }
    map['failed_attempts'] = Variable<int>(failedAttempts);
    map['retry_deadline'] = Variable<int>(retryDeadline);
    map['retry_boot'] = Variable<String>(retryBoot);
    return map;
  }

  LockSettingsCompanion toCompanion(bool nullToAbsent) {
    return LockSettingsCompanion(
      id: Value(id),
      mode: Value(mode),
      credentialSlot: credentialSlot == null && nullToAbsent
          ? const Value.absent()
          : Value(credentialSlot),
      failedAttempts: Value(failedAttempts),
      retryDeadline: Value(retryDeadline),
      retryBoot: Value(retryBoot),
    );
  }

  factory LockSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LockSetting(
      id: serializer.fromJson<int>(json['id']),
      mode: serializer.fromJson<int>(json['mode']),
      credentialSlot: serializer.fromJson<String?>(json['credentialSlot']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      retryDeadline: serializer.fromJson<int>(json['retryDeadline']),
      retryBoot: serializer.fromJson<String>(json['retryBoot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mode': serializer.toJson<int>(mode),
      'credentialSlot': serializer.toJson<String?>(credentialSlot),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'retryDeadline': serializer.toJson<int>(retryDeadline),
      'retryBoot': serializer.toJson<String>(retryBoot),
    };
  }

  LockSetting copyWith({
    int? id,
    int? mode,
    Value<String?> credentialSlot = const Value.absent(),
    int? failedAttempts,
    int? retryDeadline,
    String? retryBoot,
  }) => LockSetting(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    credentialSlot: credentialSlot.present
        ? credentialSlot.value
        : this.credentialSlot,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    retryDeadline: retryDeadline ?? this.retryDeadline,
    retryBoot: retryBoot ?? this.retryBoot,
  );
  LockSetting copyWithCompanion(LockSettingsCompanion data) {
    return LockSetting(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      credentialSlot: data.credentialSlot.present
          ? data.credentialSlot.value
          : this.credentialSlot,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      retryDeadline: data.retryDeadline.present
          ? data.retryDeadline.value
          : this.retryDeadline,
      retryBoot: data.retryBoot.present ? data.retryBoot.value : this.retryBoot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LockSetting(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('credentialSlot: $credentialSlot, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('retryDeadline: $retryDeadline, ')
          ..write('retryBoot: $retryBoot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    credentialSlot,
    failedAttempts,
    retryDeadline,
    retryBoot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LockSetting &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.credentialSlot == this.credentialSlot &&
          other.failedAttempts == this.failedAttempts &&
          other.retryDeadline == this.retryDeadline &&
          other.retryBoot == this.retryBoot);
}

class LockSettingsCompanion extends UpdateCompanion<LockSetting> {
  final Value<int> id;
  final Value<int> mode;
  final Value<String?> credentialSlot;
  final Value<int> failedAttempts;
  final Value<int> retryDeadline;
  final Value<String> retryBoot;
  const LockSettingsCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.credentialSlot = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.retryDeadline = const Value.absent(),
    this.retryBoot = const Value.absent(),
  });
  LockSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int mode,
    this.credentialSlot = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.retryDeadline = const Value.absent(),
    this.retryBoot = const Value.absent(),
  }) : mode = Value(mode);
  static Insertable<LockSetting> custom({
    Expression<int>? id,
    Expression<int>? mode,
    Expression<String>? credentialSlot,
    Expression<int>? failedAttempts,
    Expression<int>? retryDeadline,
    Expression<String>? retryBoot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (credentialSlot != null) 'credential_slot': credentialSlot,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (retryDeadline != null) 'retry_deadline': retryDeadline,
      if (retryBoot != null) 'retry_boot': retryBoot,
    });
  }

  LockSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? mode,
    Value<String?>? credentialSlot,
    Value<int>? failedAttempts,
    Value<int>? retryDeadline,
    Value<String>? retryBoot,
  }) {
    return LockSettingsCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      credentialSlot: credentialSlot ?? this.credentialSlot,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      retryDeadline: retryDeadline ?? this.retryDeadline,
      retryBoot: retryBoot ?? this.retryBoot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<int>(mode.value);
    }
    if (credentialSlot.present) {
      map['credential_slot'] = Variable<String>(credentialSlot.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (retryDeadline.present) {
      map['retry_deadline'] = Variable<int>(retryDeadline.value);
    }
    if (retryBoot.present) {
      map['retry_boot'] = Variable<String>(retryBoot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LockSettingsCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('credentialSlot: $credentialSlot, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('retryDeadline: $retryDeadline, ')
          ..write('retryBoot: $retryBoot')
          ..write(')'))
        .toString();
  }
}

class $OnboardingProfilesTable extends OnboardingProfiles
    with TableInfo<$OnboardingProfilesTable, OnboardingProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OnboardingProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _motivationMeta = const VerificationMeta(
    'motivation',
  );
  @override
  late final GeneratedColumn<String> motivation = GeneratedColumn<String>(
    'motivation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _modulesMeta = const VerificationMeta(
    'modules',
  );
  @override
  late final GeneratedColumn<int> modules = GeneratedColumn<int>(
    'modules',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, motivation, modules, completed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onboarding_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<OnboardingProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('motivation')) {
      context.handle(
        _motivationMeta,
        motivation.isAcceptableOrUnknown(data['motivation']!, _motivationMeta),
      );
    }
    if (data.containsKey('modules')) {
      context.handle(
        _modulesMeta,
        modules.isAcceptableOrUnknown(data['modules']!, _modulesMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OnboardingProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OnboardingProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      motivation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivation'],
      )!,
      modules: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}modules'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $OnboardingProfilesTable createAlias(String alias) {
    return $OnboardingProfilesTable(attachedDatabase, alias);
  }
}

class OnboardingProfile extends DataClass
    implements Insertable<OnboardingProfile> {
  final int id;
  final String motivation;
  final int modules;
  final bool completed;
  const OnboardingProfile({
    required this.id,
    required this.motivation,
    required this.modules,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['motivation'] = Variable<String>(motivation);
    map['modules'] = Variable<int>(modules);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  OnboardingProfilesCompanion toCompanion(bool nullToAbsent) {
    return OnboardingProfilesCompanion(
      id: Value(id),
      motivation: Value(motivation),
      modules: Value(modules),
      completed: Value(completed),
    );
  }

  factory OnboardingProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OnboardingProfile(
      id: serializer.fromJson<int>(json['id']),
      motivation: serializer.fromJson<String>(json['motivation']),
      modules: serializer.fromJson<int>(json['modules']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'motivation': serializer.toJson<String>(motivation),
      'modules': serializer.toJson<int>(modules),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  OnboardingProfile copyWith({
    int? id,
    String? motivation,
    int? modules,
    bool? completed,
  }) => OnboardingProfile(
    id: id ?? this.id,
    motivation: motivation ?? this.motivation,
    modules: modules ?? this.modules,
    completed: completed ?? this.completed,
  );
  OnboardingProfile copyWithCompanion(OnboardingProfilesCompanion data) {
    return OnboardingProfile(
      id: data.id.present ? data.id.value : this.id,
      motivation: data.motivation.present
          ? data.motivation.value
          : this.motivation,
      modules: data.modules.present ? data.modules.value : this.modules,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingProfile(')
          ..write('id: $id, ')
          ..write('motivation: $motivation, ')
          ..write('modules: $modules, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, motivation, modules, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnboardingProfile &&
          other.id == this.id &&
          other.motivation == this.motivation &&
          other.modules == this.modules &&
          other.completed == this.completed);
}

class OnboardingProfilesCompanion extends UpdateCompanion<OnboardingProfile> {
  final Value<int> id;
  final Value<String> motivation;
  final Value<int> modules;
  final Value<bool> completed;
  const OnboardingProfilesCompanion({
    this.id = const Value.absent(),
    this.motivation = const Value.absent(),
    this.modules = const Value.absent(),
    this.completed = const Value.absent(),
  });
  OnboardingProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.motivation = const Value.absent(),
    this.modules = const Value.absent(),
    this.completed = const Value.absent(),
  });
  static Insertable<OnboardingProfile> custom({
    Expression<int>? id,
    Expression<String>? motivation,
    Expression<int>? modules,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (motivation != null) 'motivation': motivation,
      if (modules != null) 'modules': modules,
      if (completed != null) 'completed': completed,
    });
  }

  OnboardingProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? motivation,
    Value<int>? modules,
    Value<bool>? completed,
  }) {
    return OnboardingProfilesCompanion(
      id: id ?? this.id,
      motivation: motivation ?? this.motivation,
      modules: modules ?? this.modules,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (motivation.present) {
      map['motivation'] = Variable<String>(motivation.value);
    }
    if (modules.present) {
      map['modules'] = Variable<int>(modules.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingProfilesCompanion(')
          ..write('id: $id, ')
          ..write('motivation: $motivation, ')
          ..write('modules: $modules, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $SponsorContactsTable extends SponsorContacts
    with TableInfo<$SponsorContactsTable, SponsorContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SponsorContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, phone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sponsor_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SponsorContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SponsorContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SponsorContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
    );
  }

  @override
  $SponsorContactsTable createAlias(String alias) {
    return $SponsorContactsTable(attachedDatabase, alias);
  }
}

class SponsorContact extends DataClass implements Insertable<SponsorContact> {
  final int id;
  final String name;
  final String phone;
  const SponsorContact({
    required this.id,
    required this.name,
    required this.phone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    return map;
  }

  SponsorContactsCompanion toCompanion(bool nullToAbsent) {
    return SponsorContactsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
    );
  }

  factory SponsorContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SponsorContact(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
    };
  }

  SponsorContact copyWith({int? id, String? name, String? phone}) =>
      SponsorContact(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
      );
  SponsorContact copyWithCompanion(SponsorContactsCompanion data) {
    return SponsorContact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SponsorContact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SponsorContact &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone);
}

class SponsorContactsCompanion extends UpdateCompanion<SponsorContact> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  const SponsorContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
  });
  SponsorContactsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SponsorContact> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    });
  }

  SponsorContactsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? phone,
  }) {
    return SponsorContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SponsorContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }
}

class $OnboardingDraftsTable extends OnboardingDrafts
    with TableInfo<$OnboardingDraftsTable, OnboardingDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OnboardingDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onboarding_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<OnboardingDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OnboardingDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OnboardingDraft(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $OnboardingDraftsTable createAlias(String alias) {
    return $OnboardingDraftsTable(attachedDatabase, alias);
  }
}

class OnboardingDraft extends DataClass implements Insertable<OnboardingDraft> {
  final int id;
  final String payload;
  const OnboardingDraft({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  OnboardingDraftsCompanion toCompanion(bool nullToAbsent) {
    return OnboardingDraftsCompanion(id: Value(id), payload: Value(payload));
  }

  factory OnboardingDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OnboardingDraft(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  OnboardingDraft copyWith({int? id, String? payload}) =>
      OnboardingDraft(id: id ?? this.id, payload: payload ?? this.payload);
  OnboardingDraft copyWithCompanion(OnboardingDraftsCompanion data) {
    return OnboardingDraft(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingDraft(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnboardingDraft &&
          other.id == this.id &&
          other.payload == this.payload);
}

class OnboardingDraftsCompanion extends UpdateCompanion<OnboardingDraft> {
  final Value<int> id;
  final Value<String> payload;
  const OnboardingDraftsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
  });
  OnboardingDraftsCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
  }) : payload = Value(payload);
  static Insertable<OnboardingDraft> custom({
    Expression<int>? id,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
    });
  }

  OnboardingDraftsCompanion copyWith({Value<int>? id, Value<String>? payload}) {
    return OnboardingDraftsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingDraftsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $StyleSettingsTable extends StyleSettings
    with TableInfo<$StyleSettingsTable, StyleSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StyleSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, revision, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'style_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<StyleSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StyleSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StyleSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $StyleSettingsTable createAlias(String alias) {
    return $StyleSettingsTable(attachedDatabase, alias);
  }
}

class StyleSetting extends DataClass implements Insertable<StyleSetting> {
  final int id;
  final int revision;
  final String payload;
  const StyleSetting({
    required this.id,
    required this.revision,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['revision'] = Variable<int>(revision);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  StyleSettingsCompanion toCompanion(bool nullToAbsent) {
    return StyleSettingsCompanion(
      id: Value(id),
      revision: Value(revision),
      payload: Value(payload),
    );
  }

  factory StyleSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StyleSetting(
      id: serializer.fromJson<int>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'revision': serializer.toJson<int>(revision),
      'payload': serializer.toJson<String>(payload),
    };
  }

  StyleSetting copyWith({int? id, int? revision, String? payload}) =>
      StyleSetting(
        id: id ?? this.id,
        revision: revision ?? this.revision,
        payload: payload ?? this.payload,
      );
  StyleSetting copyWithCompanion(StyleSettingsCompanion data) {
    return StyleSetting(
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StyleSetting(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, revision, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StyleSetting &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.payload == this.payload);
}

class StyleSettingsCompanion extends UpdateCompanion<StyleSetting> {
  final Value<int> id;
  final Value<int> revision;
  final Value<String> payload;
  const StyleSettingsCompanion({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.payload = const Value.absent(),
  });
  StyleSettingsCompanion.insert({
    this.id = const Value.absent(),
    required int revision,
    required String payload,
  }) : revision = Value(revision),
       payload = Value(payload);
  static Insertable<StyleSetting> custom({
    Expression<int>? id,
    Expression<int>? revision,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (payload != null) 'payload': payload,
    });
  }

  StyleSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? revision,
    Value<String>? payload,
  }) {
    return StyleSettingsCompanion(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StyleSettingsCompanion(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $SurvivalSessionsTable extends SurvivalSessions
    with TableInfo<$SurvivalSessionsTable, SurvivalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurvivalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'survival_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurvivalSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurvivalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurvivalSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $SurvivalSessionsTable createAlias(String alias) {
    return $SurvivalSessionsTable(attachedDatabase, alias);
  }
}

class SurvivalSession extends DataClass implements Insertable<SurvivalSession> {
  final int id;
  final String payload;
  const SurvivalSession({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  SurvivalSessionsCompanion toCompanion(bool nullToAbsent) {
    return SurvivalSessionsCompanion(id: Value(id), payload: Value(payload));
  }

  factory SurvivalSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurvivalSession(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  SurvivalSession copyWith({int? id, String? payload}) =>
      SurvivalSession(id: id ?? this.id, payload: payload ?? this.payload);
  SurvivalSession copyWithCompanion(SurvivalSessionsCompanion data) {
    return SurvivalSession(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurvivalSession(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurvivalSession &&
          other.id == this.id &&
          other.payload == this.payload);
}

class SurvivalSessionsCompanion extends UpdateCompanion<SurvivalSession> {
  final Value<int> id;
  final Value<String> payload;
  const SurvivalSessionsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
  });
  SurvivalSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
  }) : payload = Value(payload);
  static Insertable<SurvivalSession> custom({
    Expression<int>? id,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
    });
  }

  SurvivalSessionsCompanion copyWith({Value<int>? id, Value<String>? payload}) {
    return SurvivalSessionsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurvivalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $SurvivalNotesTable extends SurvivalNotes
    with TableInfo<$SurvivalNotesTable, SurvivalNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurvivalNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SurvivalNotesTable.$convertercreatedAtUtc);
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recovery_periods (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, body, createdAtUtc, periodId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'survival_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SurvivalNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurvivalNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurvivalNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAtUtc: $SurvivalNotesTable.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      ),
    );
  }

  @override
  $SurvivalNotesTable createAlias(String alias) {
    return $SurvivalNotesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcInstant();
}

class SurvivalNote extends DataClass implements Insertable<SurvivalNote> {
  final int id;
  final String body;
  final DateTime createdAtUtc;
  final int? periodId;
  const SurvivalNote({
    required this.id,
    required this.body,
    required this.createdAtUtc,
    this.periodId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(body);
    {
      map['created_at_utc'] = Variable<DateTime>(
        $SurvivalNotesTable.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    if (!nullToAbsent || periodId != null) {
      map['period_id'] = Variable<int>(periodId);
    }
    return map;
  }

  SurvivalNotesCompanion toCompanion(bool nullToAbsent) {
    return SurvivalNotesCompanion(
      id: Value(id),
      body: Value(body),
      createdAtUtc: Value(createdAtUtc),
      periodId: periodId == null && nullToAbsent
          ? const Value.absent()
          : Value(periodId),
    );
  }

  factory SurvivalNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurvivalNote(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      periodId: serializer.fromJson<int?>(json['periodId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'periodId': serializer.toJson<int?>(periodId),
    };
  }

  SurvivalNote copyWith({
    int? id,
    String? body,
    DateTime? createdAtUtc,
    Value<int?> periodId = const Value.absent(),
  }) => SurvivalNote(
    id: id ?? this.id,
    body: body ?? this.body,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    periodId: periodId.present ? periodId.value : this.periodId,
  );
  SurvivalNote copyWithCompanion(SurvivalNotesCompanion data) {
    return SurvivalNote(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurvivalNote(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('periodId: $periodId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, body, createdAtUtc, periodId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurvivalNote &&
          other.id == this.id &&
          other.body == this.body &&
          other.createdAtUtc == this.createdAtUtc &&
          other.periodId == this.periodId);
}

class SurvivalNotesCompanion extends UpdateCompanion<SurvivalNote> {
  final Value<int> id;
  final Value<String> body;
  final Value<DateTime> createdAtUtc;
  final Value<int?> periodId;
  const SurvivalNotesCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.periodId = const Value.absent(),
  });
  SurvivalNotesCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    required DateTime createdAtUtc,
    this.periodId = const Value.absent(),
  }) : body = Value(body),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<SurvivalNote> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? periodId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (periodId != null) 'period_id': periodId,
    });
  }

  SurvivalNotesCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<DateTime>? createdAtUtc,
    Value<int?>? periodId,
  }) {
    return SurvivalNotesCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      periodId: periodId ?? this.periodId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        $SurvivalNotesTable.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurvivalNotesCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('periodId: $periodId')
          ..write(')'))
        .toString();
  }
}

abstract class _$HajnalDatabase extends GeneratedDatabase {
  _$HajnalDatabase(QueryExecutor e) : super(e);
  $HajnalDatabaseManager get managers => $HajnalDatabaseManager(this);
  late final $RecoveryPeriodsTable recoveryPeriods = $RecoveryPeriodsTable(
    this,
  );
  late final $ArtworkOverridesTable artworkOverrides = $ArtworkOverridesTable(
    this,
  );
  late final $LockSettingsTable lockSettings = $LockSettingsTable(this);
  late final $OnboardingProfilesTable onboardingProfiles =
      $OnboardingProfilesTable(this);
  late final $SponsorContactsTable sponsorContacts = $SponsorContactsTable(
    this,
  );
  late final $OnboardingDraftsTable onboardingDrafts = $OnboardingDraftsTable(
    this,
  );
  late final $StyleSettingsTable styleSettings = $StyleSettingsTable(this);
  late final $SurvivalSessionsTable survivalSessions = $SurvivalSessionsTable(
    this,
  );
  late final $SurvivalNotesTable survivalNotes = $SurvivalNotesTable(this);
  late final Index oneActivePeriod = Index(
    'one_active_period',
    'CREATE UNIQUE INDEX one_active_period ON recovery_periods ((1)) WHERE closed_at_utc IS NULL',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    recoveryPeriods,
    artworkOverrides,
    lockSettings,
    onboardingProfiles,
    sponsorContacts,
    onboardingDrafts,
    styleSettings,
    survivalSessions,
    survivalNotes,
    oneActivePeriod,
  ];
}

typedef $$RecoveryPeriodsTableCreateCompanionBuilder =
    RecoveryPeriodsCompanion Function({
      Value<int> id,
      required String startLocalDate,
      required DateTime createdAtUtc,
      Value<DateTime?> closedAtUtc,
    });
typedef $$RecoveryPeriodsTableUpdateCompanionBuilder =
    RecoveryPeriodsCompanion Function({
      Value<int> id,
      Value<String> startLocalDate,
      Value<DateTime> createdAtUtc,
      Value<DateTime?> closedAtUtc,
    });

final class $$RecoveryPeriodsTableReferences
    extends
        BaseReferences<
          _$HajnalDatabase,
          $RecoveryPeriodsTable,
          RecoveryPeriod
        > {
  $$RecoveryPeriodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SurvivalNotesTable, List<SurvivalNote>>
  _survivalNotesRefsTable(_$HajnalDatabase db) => MultiTypedResultKey.fromTable(
    db.survivalNotes,
    aliasName: $_aliasNameGenerator(
      db.recoveryPeriods.id,
      db.survivalNotes.periodId,
    ),
  );

  $$SurvivalNotesTableProcessedTableManager get survivalNotesRefs {
    final manager = $$SurvivalNotesTableTableManager(
      $_db,
      $_db.survivalNotes,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_survivalNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecoveryPeriodsTableFilterComposer
    extends Composer<_$HajnalDatabase, $RecoveryPeriodsTable> {
  $$RecoveryPeriodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startLocalDate => $composableBuilder(
    column: $table.startLocalDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime>
  get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, DateTime>
  get closedAtUtc => $composableBuilder(
    column: $table.closedAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> survivalNotesRefs(
    Expression<bool> Function($$SurvivalNotesTableFilterComposer f) f,
  ) {
    final $$SurvivalNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.survivalNotes,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurvivalNotesTableFilterComposer(
            $db: $db,
            $table: $db.survivalNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecoveryPeriodsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $RecoveryPeriodsTable> {
  $$RecoveryPeriodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startLocalDate => $composableBuilder(
    column: $table.startLocalDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAtUtc => $composableBuilder(
    column: $table.closedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoveryPeriodsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $RecoveryPeriodsTable> {
  $$RecoveryPeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startLocalDate => $composableBuilder(
    column: $table.startLocalDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get createdAtUtc =>
      $composableBuilder(
        column: $table.createdAtUtc,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, DateTime> get closedAtUtc =>
      $composableBuilder(
        column: $table.closedAtUtc,
        builder: (column) => column,
      );

  Expression<T> survivalNotesRefs<T extends Object>(
    Expression<T> Function($$SurvivalNotesTableAnnotationComposer a) f,
  ) {
    final $$SurvivalNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.survivalNotes,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SurvivalNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.survivalNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecoveryPeriodsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $RecoveryPeriodsTable,
          RecoveryPeriod,
          $$RecoveryPeriodsTableFilterComposer,
          $$RecoveryPeriodsTableOrderingComposer,
          $$RecoveryPeriodsTableAnnotationComposer,
          $$RecoveryPeriodsTableCreateCompanionBuilder,
          $$RecoveryPeriodsTableUpdateCompanionBuilder,
          (RecoveryPeriod, $$RecoveryPeriodsTableReferences),
          RecoveryPeriod,
          PrefetchHooks Function({bool survivalNotesRefs})
        > {
  $$RecoveryPeriodsTableTableManager(
    _$HajnalDatabase db,
    $RecoveryPeriodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveryPeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveryPeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveryPeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startLocalDate = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime?> closedAtUtc = const Value.absent(),
              }) => RecoveryPeriodsCompanion(
                id: id,
                startLocalDate: startLocalDate,
                createdAtUtc: createdAtUtc,
                closedAtUtc: closedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startLocalDate,
                required DateTime createdAtUtc,
                Value<DateTime?> closedAtUtc = const Value.absent(),
              }) => RecoveryPeriodsCompanion.insert(
                id: id,
                startLocalDate: startLocalDate,
                createdAtUtc: createdAtUtc,
                closedAtUtc: closedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecoveryPeriodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({survivalNotesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (survivalNotesRefs) db.survivalNotes,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (survivalNotesRefs)
                    await $_getPrefetchedData<
                      RecoveryPeriod,
                      $RecoveryPeriodsTable,
                      SurvivalNote
                    >(
                      currentTable: table,
                      referencedTable: $$RecoveryPeriodsTableReferences
                          ._survivalNotesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RecoveryPeriodsTableReferences(
                            db,
                            table,
                            p0,
                          ).survivalNotesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.periodId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecoveryPeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $RecoveryPeriodsTable,
      RecoveryPeriod,
      $$RecoveryPeriodsTableFilterComposer,
      $$RecoveryPeriodsTableOrderingComposer,
      $$RecoveryPeriodsTableAnnotationComposer,
      $$RecoveryPeriodsTableCreateCompanionBuilder,
      $$RecoveryPeriodsTableUpdateCompanionBuilder,
      (RecoveryPeriod, $$RecoveryPeriodsTableReferences),
      RecoveryPeriod,
      PrefetchHooks Function({bool survivalNotesRefs})
    >;
typedef $$ArtworkOverridesTableCreateCompanionBuilder =
    ArtworkOverridesCompanion Function({
      required String role,
      required String filename,
      required String revision,
      Value<int> rowid,
    });
typedef $$ArtworkOverridesTableUpdateCompanionBuilder =
    ArtworkOverridesCompanion Function({
      Value<String> role,
      Value<String> filename,
      Value<String> revision,
      Value<int> rowid,
    });

class $$ArtworkOverridesTableFilterComposer
    extends Composer<_$HajnalDatabase, $ArtworkOverridesTable> {
  $$ArtworkOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtworkOverridesTableOrderingComposer
    extends Composer<_$HajnalDatabase, $ArtworkOverridesTable> {
  $$ArtworkOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtworkOverridesTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $ArtworkOverridesTable> {
  $$ArtworkOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ArtworkOverridesTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $ArtworkOverridesTable,
          ArtworkOverride,
          $$ArtworkOverridesTableFilterComposer,
          $$ArtworkOverridesTableOrderingComposer,
          $$ArtworkOverridesTableAnnotationComposer,
          $$ArtworkOverridesTableCreateCompanionBuilder,
          $$ArtworkOverridesTableUpdateCompanionBuilder,
          (
            ArtworkOverride,
            BaseReferences<
              _$HajnalDatabase,
              $ArtworkOverridesTable,
              ArtworkOverride
            >,
          ),
          ArtworkOverride,
          PrefetchHooks Function()
        > {
  $$ArtworkOverridesTableTableManager(
    _$HajnalDatabase db,
    $ArtworkOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworkOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworkOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworkOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> role = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtworkOverridesCompanion(
                role: role,
                filename: filename,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String role,
                required String filename,
                required String revision,
                Value<int> rowid = const Value.absent(),
              }) => ArtworkOverridesCompanion.insert(
                role: role,
                filename: filename,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArtworkOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $ArtworkOverridesTable,
      ArtworkOverride,
      $$ArtworkOverridesTableFilterComposer,
      $$ArtworkOverridesTableOrderingComposer,
      $$ArtworkOverridesTableAnnotationComposer,
      $$ArtworkOverridesTableCreateCompanionBuilder,
      $$ArtworkOverridesTableUpdateCompanionBuilder,
      (
        ArtworkOverride,
        BaseReferences<
          _$HajnalDatabase,
          $ArtworkOverridesTable,
          ArtworkOverride
        >,
      ),
      ArtworkOverride,
      PrefetchHooks Function()
    >;
typedef $$LockSettingsTableCreateCompanionBuilder =
    LockSettingsCompanion Function({
      Value<int> id,
      required int mode,
      Value<String?> credentialSlot,
      Value<int> failedAttempts,
      Value<int> retryDeadline,
      Value<String> retryBoot,
    });
typedef $$LockSettingsTableUpdateCompanionBuilder =
    LockSettingsCompanion Function({
      Value<int> id,
      Value<int> mode,
      Value<String?> credentialSlot,
      Value<int> failedAttempts,
      Value<int> retryDeadline,
      Value<String> retryBoot,
    });

class $$LockSettingsTableFilterComposer
    extends Composer<_$HajnalDatabase, $LockSettingsTable> {
  $$LockSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credentialSlot => $composableBuilder(
    column: $table.credentialSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryDeadline => $composableBuilder(
    column: $table.retryDeadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retryBoot => $composableBuilder(
    column: $table.retryBoot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LockSettingsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $LockSettingsTable> {
  $$LockSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credentialSlot => $composableBuilder(
    column: $table.credentialSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryDeadline => $composableBuilder(
    column: $table.retryDeadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retryBoot => $composableBuilder(
    column: $table.retryBoot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LockSettingsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $LockSettingsTable> {
  $$LockSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get credentialSlot => $composableBuilder(
    column: $table.credentialSlot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryDeadline => $composableBuilder(
    column: $table.retryDeadline,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retryBoot =>
      $composableBuilder(column: $table.retryBoot, builder: (column) => column);
}

class $$LockSettingsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $LockSettingsTable,
          LockSetting,
          $$LockSettingsTableFilterComposer,
          $$LockSettingsTableOrderingComposer,
          $$LockSettingsTableAnnotationComposer,
          $$LockSettingsTableCreateCompanionBuilder,
          $$LockSettingsTableUpdateCompanionBuilder,
          (
            LockSetting,
            BaseReferences<_$HajnalDatabase, $LockSettingsTable, LockSetting>,
          ),
          LockSetting,
          PrefetchHooks Function()
        > {
  $$LockSettingsTableTableManager(_$HajnalDatabase db, $LockSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LockSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LockSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LockSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> mode = const Value.absent(),
                Value<String?> credentialSlot = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<int> retryDeadline = const Value.absent(),
                Value<String> retryBoot = const Value.absent(),
              }) => LockSettingsCompanion(
                id: id,
                mode: mode,
                credentialSlot: credentialSlot,
                failedAttempts: failedAttempts,
                retryDeadline: retryDeadline,
                retryBoot: retryBoot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int mode,
                Value<String?> credentialSlot = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<int> retryDeadline = const Value.absent(),
                Value<String> retryBoot = const Value.absent(),
              }) => LockSettingsCompanion.insert(
                id: id,
                mode: mode,
                credentialSlot: credentialSlot,
                failedAttempts: failedAttempts,
                retryDeadline: retryDeadline,
                retryBoot: retryBoot,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LockSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $LockSettingsTable,
      LockSetting,
      $$LockSettingsTableFilterComposer,
      $$LockSettingsTableOrderingComposer,
      $$LockSettingsTableAnnotationComposer,
      $$LockSettingsTableCreateCompanionBuilder,
      $$LockSettingsTableUpdateCompanionBuilder,
      (
        LockSetting,
        BaseReferences<_$HajnalDatabase, $LockSettingsTable, LockSetting>,
      ),
      LockSetting,
      PrefetchHooks Function()
    >;
typedef $$OnboardingProfilesTableCreateCompanionBuilder =
    OnboardingProfilesCompanion Function({
      Value<int> id,
      Value<String> motivation,
      Value<int> modules,
      Value<bool> completed,
    });
typedef $$OnboardingProfilesTableUpdateCompanionBuilder =
    OnboardingProfilesCompanion Function({
      Value<int> id,
      Value<String> motivation,
      Value<int> modules,
      Value<bool> completed,
    });

class $$OnboardingProfilesTableFilterComposer
    extends Composer<_$HajnalDatabase, $OnboardingProfilesTable> {
  $$OnboardingProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivation => $composableBuilder(
    column: $table.motivation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get modules => $composableBuilder(
    column: $table.modules,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OnboardingProfilesTableOrderingComposer
    extends Composer<_$HajnalDatabase, $OnboardingProfilesTable> {
  $$OnboardingProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivation => $composableBuilder(
    column: $table.motivation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modules => $composableBuilder(
    column: $table.modules,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OnboardingProfilesTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $OnboardingProfilesTable> {
  $$OnboardingProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get motivation => $composableBuilder(
    column: $table.motivation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get modules =>
      $composableBuilder(column: $table.modules, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$OnboardingProfilesTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $OnboardingProfilesTable,
          OnboardingProfile,
          $$OnboardingProfilesTableFilterComposer,
          $$OnboardingProfilesTableOrderingComposer,
          $$OnboardingProfilesTableAnnotationComposer,
          $$OnboardingProfilesTableCreateCompanionBuilder,
          $$OnboardingProfilesTableUpdateCompanionBuilder,
          (
            OnboardingProfile,
            BaseReferences<
              _$HajnalDatabase,
              $OnboardingProfilesTable,
              OnboardingProfile
            >,
          ),
          OnboardingProfile,
          PrefetchHooks Function()
        > {
  $$OnboardingProfilesTableTableManager(
    _$HajnalDatabase db,
    $OnboardingProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OnboardingProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OnboardingProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OnboardingProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> motivation = const Value.absent(),
                Value<int> modules = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => OnboardingProfilesCompanion(
                id: id,
                motivation: motivation,
                modules: modules,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> motivation = const Value.absent(),
                Value<int> modules = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => OnboardingProfilesCompanion.insert(
                id: id,
                motivation: motivation,
                modules: modules,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OnboardingProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $OnboardingProfilesTable,
      OnboardingProfile,
      $$OnboardingProfilesTableFilterComposer,
      $$OnboardingProfilesTableOrderingComposer,
      $$OnboardingProfilesTableAnnotationComposer,
      $$OnboardingProfilesTableCreateCompanionBuilder,
      $$OnboardingProfilesTableUpdateCompanionBuilder,
      (
        OnboardingProfile,
        BaseReferences<
          _$HajnalDatabase,
          $OnboardingProfilesTable,
          OnboardingProfile
        >,
      ),
      OnboardingProfile,
      PrefetchHooks Function()
    >;
typedef $$SponsorContactsTableCreateCompanionBuilder =
    SponsorContactsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> phone,
    });
typedef $$SponsorContactsTableUpdateCompanionBuilder =
    SponsorContactsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> phone,
    });

class $$SponsorContactsTableFilterComposer
    extends Composer<_$HajnalDatabase, $SponsorContactsTable> {
  $$SponsorContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SponsorContactsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $SponsorContactsTable> {
  $$SponsorContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SponsorContactsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $SponsorContactsTable> {
  $$SponsorContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);
}

class $$SponsorContactsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $SponsorContactsTable,
          SponsorContact,
          $$SponsorContactsTableFilterComposer,
          $$SponsorContactsTableOrderingComposer,
          $$SponsorContactsTableAnnotationComposer,
          $$SponsorContactsTableCreateCompanionBuilder,
          $$SponsorContactsTableUpdateCompanionBuilder,
          (
            SponsorContact,
            BaseReferences<
              _$HajnalDatabase,
              $SponsorContactsTable,
              SponsorContact
            >,
          ),
          SponsorContact,
          PrefetchHooks Function()
        > {
  $$SponsorContactsTableTableManager(
    _$HajnalDatabase db,
    $SponsorContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SponsorContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SponsorContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SponsorContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
              }) => SponsorContactsCompanion(id: id, name: name, phone: phone),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> phone = const Value.absent(),
              }) => SponsorContactsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SponsorContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $SponsorContactsTable,
      SponsorContact,
      $$SponsorContactsTableFilterComposer,
      $$SponsorContactsTableOrderingComposer,
      $$SponsorContactsTableAnnotationComposer,
      $$SponsorContactsTableCreateCompanionBuilder,
      $$SponsorContactsTableUpdateCompanionBuilder,
      (
        SponsorContact,
        BaseReferences<_$HajnalDatabase, $SponsorContactsTable, SponsorContact>,
      ),
      SponsorContact,
      PrefetchHooks Function()
    >;
typedef $$OnboardingDraftsTableCreateCompanionBuilder =
    OnboardingDraftsCompanion Function({
      Value<int> id,
      required String payload,
    });
typedef $$OnboardingDraftsTableUpdateCompanionBuilder =
    OnboardingDraftsCompanion Function({Value<int> id, Value<String> payload});

class $$OnboardingDraftsTableFilterComposer
    extends Composer<_$HajnalDatabase, $OnboardingDraftsTable> {
  $$OnboardingDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OnboardingDraftsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $OnboardingDraftsTable> {
  $$OnboardingDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OnboardingDraftsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $OnboardingDraftsTable> {
  $$OnboardingDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$OnboardingDraftsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $OnboardingDraftsTable,
          OnboardingDraft,
          $$OnboardingDraftsTableFilterComposer,
          $$OnboardingDraftsTableOrderingComposer,
          $$OnboardingDraftsTableAnnotationComposer,
          $$OnboardingDraftsTableCreateCompanionBuilder,
          $$OnboardingDraftsTableUpdateCompanionBuilder,
          (
            OnboardingDraft,
            BaseReferences<
              _$HajnalDatabase,
              $OnboardingDraftsTable,
              OnboardingDraft
            >,
          ),
          OnboardingDraft,
          PrefetchHooks Function()
        > {
  $$OnboardingDraftsTableTableManager(
    _$HajnalDatabase db,
    $OnboardingDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OnboardingDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OnboardingDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OnboardingDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => OnboardingDraftsCompanion(id: id, payload: payload),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
              }) => OnboardingDraftsCompanion.insert(id: id, payload: payload),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OnboardingDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $OnboardingDraftsTable,
      OnboardingDraft,
      $$OnboardingDraftsTableFilterComposer,
      $$OnboardingDraftsTableOrderingComposer,
      $$OnboardingDraftsTableAnnotationComposer,
      $$OnboardingDraftsTableCreateCompanionBuilder,
      $$OnboardingDraftsTableUpdateCompanionBuilder,
      (
        OnboardingDraft,
        BaseReferences<
          _$HajnalDatabase,
          $OnboardingDraftsTable,
          OnboardingDraft
        >,
      ),
      OnboardingDraft,
      PrefetchHooks Function()
    >;
typedef $$StyleSettingsTableCreateCompanionBuilder =
    StyleSettingsCompanion Function({
      Value<int> id,
      required int revision,
      required String payload,
    });
typedef $$StyleSettingsTableUpdateCompanionBuilder =
    StyleSettingsCompanion Function({
      Value<int> id,
      Value<int> revision,
      Value<String> payload,
    });

class $$StyleSettingsTableFilterComposer
    extends Composer<_$HajnalDatabase, $StyleSettingsTable> {
  $$StyleSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StyleSettingsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $StyleSettingsTable> {
  $$StyleSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StyleSettingsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $StyleSettingsTable> {
  $$StyleSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$StyleSettingsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $StyleSettingsTable,
          StyleSetting,
          $$StyleSettingsTableFilterComposer,
          $$StyleSettingsTableOrderingComposer,
          $$StyleSettingsTableAnnotationComposer,
          $$StyleSettingsTableCreateCompanionBuilder,
          $$StyleSettingsTableUpdateCompanionBuilder,
          (
            StyleSetting,
            BaseReferences<_$HajnalDatabase, $StyleSettingsTable, StyleSetting>,
          ),
          StyleSetting,
          PrefetchHooks Function()
        > {
  $$StyleSettingsTableTableManager(
    _$HajnalDatabase db,
    $StyleSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StyleSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StyleSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StyleSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => StyleSettingsCompanion(
                id: id,
                revision: revision,
                payload: payload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int revision,
                required String payload,
              }) => StyleSettingsCompanion.insert(
                id: id,
                revision: revision,
                payload: payload,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StyleSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $StyleSettingsTable,
      StyleSetting,
      $$StyleSettingsTableFilterComposer,
      $$StyleSettingsTableOrderingComposer,
      $$StyleSettingsTableAnnotationComposer,
      $$StyleSettingsTableCreateCompanionBuilder,
      $$StyleSettingsTableUpdateCompanionBuilder,
      (
        StyleSetting,
        BaseReferences<_$HajnalDatabase, $StyleSettingsTable, StyleSetting>,
      ),
      StyleSetting,
      PrefetchHooks Function()
    >;
typedef $$SurvivalSessionsTableCreateCompanionBuilder =
    SurvivalSessionsCompanion Function({
      Value<int> id,
      required String payload,
    });
typedef $$SurvivalSessionsTableUpdateCompanionBuilder =
    SurvivalSessionsCompanion Function({Value<int> id, Value<String> payload});

class $$SurvivalSessionsTableFilterComposer
    extends Composer<_$HajnalDatabase, $SurvivalSessionsTable> {
  $$SurvivalSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SurvivalSessionsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $SurvivalSessionsTable> {
  $$SurvivalSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SurvivalSessionsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $SurvivalSessionsTable> {
  $$SurvivalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$SurvivalSessionsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $SurvivalSessionsTable,
          SurvivalSession,
          $$SurvivalSessionsTableFilterComposer,
          $$SurvivalSessionsTableOrderingComposer,
          $$SurvivalSessionsTableAnnotationComposer,
          $$SurvivalSessionsTableCreateCompanionBuilder,
          $$SurvivalSessionsTableUpdateCompanionBuilder,
          (
            SurvivalSession,
            BaseReferences<
              _$HajnalDatabase,
              $SurvivalSessionsTable,
              SurvivalSession
            >,
          ),
          SurvivalSession,
          PrefetchHooks Function()
        > {
  $$SurvivalSessionsTableTableManager(
    _$HajnalDatabase db,
    $SurvivalSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurvivalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurvivalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurvivalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> payload = const Value.absent(),
              }) => SurvivalSessionsCompanion(id: id, payload: payload),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String payload,
              }) => SurvivalSessionsCompanion.insert(id: id, payload: payload),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SurvivalSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $SurvivalSessionsTable,
      SurvivalSession,
      $$SurvivalSessionsTableFilterComposer,
      $$SurvivalSessionsTableOrderingComposer,
      $$SurvivalSessionsTableAnnotationComposer,
      $$SurvivalSessionsTableCreateCompanionBuilder,
      $$SurvivalSessionsTableUpdateCompanionBuilder,
      (
        SurvivalSession,
        BaseReferences<
          _$HajnalDatabase,
          $SurvivalSessionsTable,
          SurvivalSession
        >,
      ),
      SurvivalSession,
      PrefetchHooks Function()
    >;
typedef $$SurvivalNotesTableCreateCompanionBuilder =
    SurvivalNotesCompanion Function({
      Value<int> id,
      required String body,
      required DateTime createdAtUtc,
      Value<int?> periodId,
    });
typedef $$SurvivalNotesTableUpdateCompanionBuilder =
    SurvivalNotesCompanion Function({
      Value<int> id,
      Value<String> body,
      Value<DateTime> createdAtUtc,
      Value<int?> periodId,
    });

final class $$SurvivalNotesTableReferences
    extends
        BaseReferences<_$HajnalDatabase, $SurvivalNotesTable, SurvivalNote> {
  $$SurvivalNotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecoveryPeriodsTable _periodIdTable(_$HajnalDatabase db) =>
      db.recoveryPeriods.createAlias(
        $_aliasNameGenerator(db.survivalNotes.periodId, db.recoveryPeriods.id),
      );

  $$RecoveryPeriodsTableProcessedTableManager? get periodId {
    final $_column = $_itemColumn<int>('period_id');
    if ($_column == null) return null;
    final manager = $$RecoveryPeriodsTableTableManager(
      $_db,
      $_db.recoveryPeriods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_periodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SurvivalNotesTableFilterComposer
    extends Composer<_$HajnalDatabase, $SurvivalNotesTable> {
  $$SurvivalNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime>
  get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$RecoveryPeriodsTableFilterComposer get periodId {
    final $$RecoveryPeriodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.recoveryPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecoveryPeriodsTableFilterComposer(
            $db: $db,
            $table: $db.recoveryPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SurvivalNotesTableOrderingComposer
    extends Composer<_$HajnalDatabase, $SurvivalNotesTable> {
  $$SurvivalNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$RecoveryPeriodsTableOrderingComposer get periodId {
    final $$RecoveryPeriodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.recoveryPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecoveryPeriodsTableOrderingComposer(
            $db: $db,
            $table: $db.recoveryPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SurvivalNotesTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $SurvivalNotesTable> {
  $$SurvivalNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get createdAtUtc =>
      $composableBuilder(
        column: $table.createdAtUtc,
        builder: (column) => column,
      );

  $$RecoveryPeriodsTableAnnotationComposer get periodId {
    final $$RecoveryPeriodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.periodId,
      referencedTable: $db.recoveryPeriods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecoveryPeriodsTableAnnotationComposer(
            $db: $db,
            $table: $db.recoveryPeriods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SurvivalNotesTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $SurvivalNotesTable,
          SurvivalNote,
          $$SurvivalNotesTableFilterComposer,
          $$SurvivalNotesTableOrderingComposer,
          $$SurvivalNotesTableAnnotationComposer,
          $$SurvivalNotesTableCreateCompanionBuilder,
          $$SurvivalNotesTableUpdateCompanionBuilder,
          (SurvivalNote, $$SurvivalNotesTableReferences),
          SurvivalNote,
          PrefetchHooks Function({bool periodId})
        > {
  $$SurvivalNotesTableTableManager(
    _$HajnalDatabase db,
    $SurvivalNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurvivalNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurvivalNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurvivalNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<int?> periodId = const Value.absent(),
              }) => SurvivalNotesCompanion(
                id: id,
                body: body,
                createdAtUtc: createdAtUtc,
                periodId: periodId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String body,
                required DateTime createdAtUtc,
                Value<int?> periodId = const Value.absent(),
              }) => SurvivalNotesCompanion.insert(
                id: id,
                body: body,
                createdAtUtc: createdAtUtc,
                periodId: periodId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SurvivalNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({periodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (periodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.periodId,
                                referencedTable: $$SurvivalNotesTableReferences
                                    ._periodIdTable(db),
                                referencedColumn: $$SurvivalNotesTableReferences
                                    ._periodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SurvivalNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $SurvivalNotesTable,
      SurvivalNote,
      $$SurvivalNotesTableFilterComposer,
      $$SurvivalNotesTableOrderingComposer,
      $$SurvivalNotesTableAnnotationComposer,
      $$SurvivalNotesTableCreateCompanionBuilder,
      $$SurvivalNotesTableUpdateCompanionBuilder,
      (SurvivalNote, $$SurvivalNotesTableReferences),
      SurvivalNote,
      PrefetchHooks Function({bool periodId})
    >;

class $HajnalDatabaseManager {
  final _$HajnalDatabase _db;
  $HajnalDatabaseManager(this._db);
  $$RecoveryPeriodsTableTableManager get recoveryPeriods =>
      $$RecoveryPeriodsTableTableManager(_db, _db.recoveryPeriods);
  $$ArtworkOverridesTableTableManager get artworkOverrides =>
      $$ArtworkOverridesTableTableManager(_db, _db.artworkOverrides);
  $$LockSettingsTableTableManager get lockSettings =>
      $$LockSettingsTableTableManager(_db, _db.lockSettings);
  $$OnboardingProfilesTableTableManager get onboardingProfiles =>
      $$OnboardingProfilesTableTableManager(_db, _db.onboardingProfiles);
  $$SponsorContactsTableTableManager get sponsorContacts =>
      $$SponsorContactsTableTableManager(_db, _db.sponsorContacts);
  $$OnboardingDraftsTableTableManager get onboardingDrafts =>
      $$OnboardingDraftsTableTableManager(_db, _db.onboardingDrafts);
  $$StyleSettingsTableTableManager get styleSettings =>
      $$StyleSettingsTableTableManager(_db, _db.styleSettings);
  $$SurvivalSessionsTableTableManager get survivalSessions =>
      $$SurvivalSessionsTableTableManager(_db, _db.survivalSessions);
  $$SurvivalNotesTableTableManager get survivalNotes =>
      $$SurvivalNotesTableTableManager(_db, _db.survivalNotes);
}
