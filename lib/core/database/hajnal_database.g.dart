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
          (
            RecoveryPeriod,
            BaseReferences<
              _$HajnalDatabase,
              $RecoveryPeriodsTable,
              RecoveryPeriod
            >,
          ),
          RecoveryPeriod,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        RecoveryPeriod,
        BaseReferences<_$HajnalDatabase, $RecoveryPeriodsTable, RecoveryPeriod>,
      ),
      RecoveryPeriod,
      PrefetchHooks Function()
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

class $HajnalDatabaseManager {
  final _$HajnalDatabase _db;
  $HajnalDatabaseManager(this._db);
  $$RecoveryPeriodsTableTableManager get recoveryPeriods =>
      $$RecoveryPeriodsTableTableManager(_db, _db.recoveryPeriods);
  $$ArtworkOverridesTableTableManager get artworkOverrides =>
      $$ArtworkOverridesTableTableManager(_db, _db.artworkOverrides);
  $$LockSettingsTableTableManager get lockSettings =>
      $$LockSettingsTableTableManager(_db, _db.lockSettings);
}
