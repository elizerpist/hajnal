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

class $PracticeCardsTable extends PracticeCards
    with TableInfo<$PracticeCardsTable, PracticeCardData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PracticeCardsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cardTextMeta = const VerificationMeta(
    'cardText',
  );
  @override
  late final GeneratedColumn<String> cardText = GeneratedColumn<String>(
    'card_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptKindMeta = const VerificationMeta(
    'promptKind',
  );
  @override
  late final GeneratedColumn<String> promptKind = GeneratedColumn<String>(
    'prompt_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceReferenceMeta = const VerificationMeta(
    'sourceReference',
  );
  @override
  late final GeneratedColumn<String> sourceReference = GeneratedColumn<String>(
    'source_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTextMeta = const VerificationMeta(
    'sourceText',
  );
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
    'source_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> createdAtUtc =
      GeneratedColumn<DateTime>(
        'created_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeCardsTable.$convertercreatedAtUtc);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, DateTime> updatedAtUtc =
      GeneratedColumn<DateTime>(
        'updated_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PracticeCardsTable.$converterupdatedAtUtc);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, DateTime>
  activatedAtUtc = GeneratedColumn<DateTime>(
    'activated_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  ).withConverter<DateTime?>($PracticeCardsTable.$converteractivatedAtUtcn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardText,
    title,
    promptKind,
    status,
    sourceReference,
    sourceName,
    sourceText,
    createdAtUtc,
    updatedAtUtc,
    activatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'practice_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<PracticeCardData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_text')) {
      context.handle(
        _cardTextMeta,
        cardText.isAcceptableOrUnknown(data['card_text']!, _cardTextMeta),
      );
    } else if (isInserting) {
      context.missing(_cardTextMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('prompt_kind')) {
      context.handle(
        _promptKindMeta,
        promptKind.isAcceptableOrUnknown(data['prompt_kind']!, _promptKindMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('source_reference')) {
      context.handle(
        _sourceReferenceMeta,
        sourceReference.isAcceptableOrUnknown(
          data['source_reference']!,
          _sourceReferenceMeta,
        ),
      );
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    }
    if (data.containsKey('source_text')) {
      context.handle(
        _sourceTextMeta,
        sourceText.isAcceptableOrUnknown(data['source_text']!, _sourceTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PracticeCardData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PracticeCardData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_text'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      promptKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_kind'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      sourceReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_reference'],
      ),
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      ),
      sourceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_text'],
      ),
      createdAtUtc: $PracticeCardsTable.$convertercreatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}created_at_utc'],
        )!,
      ),
      updatedAtUtc: $PracticeCardsTable.$converterupdatedAtUtc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}updated_at_utc'],
        )!,
      ),
      activatedAtUtc: $PracticeCardsTable.$converteractivatedAtUtcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}activated_at_utc'],
        ),
      ),
    );
  }

  @override
  $PracticeCardsTable createAlias(String alias) {
    return $PracticeCardsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, DateTime> $convertercreatedAtUtc =
      const UtcInstant();
  static TypeConverter<DateTime, DateTime> $converterupdatedAtUtc =
      const UtcInstant();
  static TypeConverter<DateTime, DateTime> $converteractivatedAtUtc =
      const UtcInstant();
  static TypeConverter<DateTime?, DateTime?> $converteractivatedAtUtcn =
      NullAwareTypeConverter.wrap($converteractivatedAtUtc);
}

class PracticeCardData extends DataClass
    implements Insertable<PracticeCardData> {
  final int id;
  final String cardText;
  final String? title;
  final String? promptKind;
  final String status;
  final String? sourceReference;
  final String? sourceName;
  final String? sourceText;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? activatedAtUtc;
  const PracticeCardData({
    required this.id,
    required this.cardText,
    this.title,
    this.promptKind,
    required this.status,
    this.sourceReference,
    this.sourceName,
    this.sourceText,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.activatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_text'] = Variable<String>(cardText);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || promptKind != null) {
      map['prompt_kind'] = Variable<String>(promptKind);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || sourceReference != null) {
      map['source_reference'] = Variable<String>(sourceReference);
    }
    if (!nullToAbsent || sourceName != null) {
      map['source_name'] = Variable<String>(sourceName);
    }
    if (!nullToAbsent || sourceText != null) {
      map['source_text'] = Variable<String>(sourceText);
    }
    {
      map['created_at_utc'] = Variable<DateTime>(
        $PracticeCardsTable.$convertercreatedAtUtc.toSql(createdAtUtc),
      );
    }
    {
      map['updated_at_utc'] = Variable<DateTime>(
        $PracticeCardsTable.$converterupdatedAtUtc.toSql(updatedAtUtc),
      );
    }
    if (!nullToAbsent || activatedAtUtc != null) {
      map['activated_at_utc'] = Variable<DateTime>(
        $PracticeCardsTable.$converteractivatedAtUtcn.toSql(activatedAtUtc),
      );
    }
    return map;
  }

  PracticeCardsCompanion toCompanion(bool nullToAbsent) {
    return PracticeCardsCompanion(
      id: Value(id),
      cardText: Value(cardText),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      promptKind: promptKind == null && nullToAbsent
          ? const Value.absent()
          : Value(promptKind),
      status: Value(status),
      sourceReference: sourceReference == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceReference),
      sourceName: sourceName == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceName),
      sourceText: sourceText == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceText),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      activatedAtUtc: activatedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(activatedAtUtc),
    );
  }

  factory PracticeCardData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PracticeCardData(
      id: serializer.fromJson<int>(json['id']),
      cardText: serializer.fromJson<String>(json['cardText']),
      title: serializer.fromJson<String?>(json['title']),
      promptKind: serializer.fromJson<String?>(json['promptKind']),
      status: serializer.fromJson<String>(json['status']),
      sourceReference: serializer.fromJson<String?>(json['sourceReference']),
      sourceName: serializer.fromJson<String?>(json['sourceName']),
      sourceText: serializer.fromJson<String?>(json['sourceText']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      activatedAtUtc: serializer.fromJson<DateTime?>(json['activatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardText': serializer.toJson<String>(cardText),
      'title': serializer.toJson<String?>(title),
      'promptKind': serializer.toJson<String?>(promptKind),
      'status': serializer.toJson<String>(status),
      'sourceReference': serializer.toJson<String?>(sourceReference),
      'sourceName': serializer.toJson<String?>(sourceName),
      'sourceText': serializer.toJson<String?>(sourceText),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'activatedAtUtc': serializer.toJson<DateTime?>(activatedAtUtc),
    };
  }

  PracticeCardData copyWith({
    int? id,
    String? cardText,
    Value<String?> title = const Value.absent(),
    Value<String?> promptKind = const Value.absent(),
    String? status,
    Value<String?> sourceReference = const Value.absent(),
    Value<String?> sourceName = const Value.absent(),
    Value<String?> sourceText = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> activatedAtUtc = const Value.absent(),
  }) => PracticeCardData(
    id: id ?? this.id,
    cardText: cardText ?? this.cardText,
    title: title.present ? title.value : this.title,
    promptKind: promptKind.present ? promptKind.value : this.promptKind,
    status: status ?? this.status,
    sourceReference: sourceReference.present
        ? sourceReference.value
        : this.sourceReference,
    sourceName: sourceName.present ? sourceName.value : this.sourceName,
    sourceText: sourceText.present ? sourceText.value : this.sourceText,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    activatedAtUtc: activatedAtUtc.present
        ? activatedAtUtc.value
        : this.activatedAtUtc,
  );
  PracticeCardData copyWithCompanion(PracticeCardsCompanion data) {
    return PracticeCardData(
      id: data.id.present ? data.id.value : this.id,
      cardText: data.cardText.present ? data.cardText.value : this.cardText,
      title: data.title.present ? data.title.value : this.title,
      promptKind: data.promptKind.present
          ? data.promptKind.value
          : this.promptKind,
      status: data.status.present ? data.status.value : this.status,
      sourceReference: data.sourceReference.present
          ? data.sourceReference.value
          : this.sourceReference,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      sourceText: data.sourceText.present
          ? data.sourceText.value
          : this.sourceText,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      activatedAtUtc: data.activatedAtUtc.present
          ? data.activatedAtUtc.value
          : this.activatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PracticeCardData(')
          ..write('id: $id, ')
          ..write('cardText: $cardText, ')
          ..write('title: $title, ')
          ..write('promptKind: $promptKind, ')
          ..write('status: $status, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceText: $sourceText, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('activatedAtUtc: $activatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardText,
    title,
    promptKind,
    status,
    sourceReference,
    sourceName,
    sourceText,
    createdAtUtc,
    updatedAtUtc,
    activatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PracticeCardData &&
          other.id == this.id &&
          other.cardText == this.cardText &&
          other.title == this.title &&
          other.promptKind == this.promptKind &&
          other.status == this.status &&
          other.sourceReference == this.sourceReference &&
          other.sourceName == this.sourceName &&
          other.sourceText == this.sourceText &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.activatedAtUtc == this.activatedAtUtc);
}

class PracticeCardsCompanion extends UpdateCompanion<PracticeCardData> {
  final Value<int> id;
  final Value<String> cardText;
  final Value<String?> title;
  final Value<String?> promptKind;
  final Value<String> status;
  final Value<String?> sourceReference;
  final Value<String?> sourceName;
  final Value<String?> sourceText;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> activatedAtUtc;
  const PracticeCardsCompanion({
    this.id = const Value.absent(),
    this.cardText = const Value.absent(),
    this.title = const Value.absent(),
    this.promptKind = const Value.absent(),
    this.status = const Value.absent(),
    this.sourceReference = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.activatedAtUtc = const Value.absent(),
  });
  PracticeCardsCompanion.insert({
    this.id = const Value.absent(),
    required String cardText,
    this.title = const Value.absent(),
    this.promptKind = const Value.absent(),
    required String status,
    this.sourceReference = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceText = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.activatedAtUtc = const Value.absent(),
  }) : cardText = Value(cardText),
       status = Value(status),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<PracticeCardData> custom({
    Expression<int>? id,
    Expression<String>? cardText,
    Expression<String>? title,
    Expression<String>? promptKind,
    Expression<String>? status,
    Expression<String>? sourceReference,
    Expression<String>? sourceName,
    Expression<String>? sourceText,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? activatedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardText != null) 'card_text': cardText,
      if (title != null) 'title': title,
      if (promptKind != null) 'prompt_kind': promptKind,
      if (status != null) 'status': status,
      if (sourceReference != null) 'source_reference': sourceReference,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceText != null) 'source_text': sourceText,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (activatedAtUtc != null) 'activated_at_utc': activatedAtUtc,
    });
  }

  PracticeCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardText,
    Value<String?>? title,
    Value<String?>? promptKind,
    Value<String>? status,
    Value<String?>? sourceReference,
    Value<String?>? sourceName,
    Value<String?>? sourceText,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? activatedAtUtc,
  }) {
    return PracticeCardsCompanion(
      id: id ?? this.id,
      cardText: cardText ?? this.cardText,
      title: title ?? this.title,
      promptKind: promptKind ?? this.promptKind,
      status: status ?? this.status,
      sourceReference: sourceReference ?? this.sourceReference,
      sourceName: sourceName ?? this.sourceName,
      sourceText: sourceText ?? this.sourceText,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      activatedAtUtc: activatedAtUtc ?? this.activatedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardText.present) {
      map['card_text'] = Variable<String>(cardText.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (promptKind.present) {
      map['prompt_kind'] = Variable<String>(promptKind.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sourceReference.present) {
      map['source_reference'] = Variable<String>(sourceReference.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(
        $PracticeCardsTable.$convertercreatedAtUtc.toSql(createdAtUtc.value),
      );
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(
        $PracticeCardsTable.$converterupdatedAtUtc.toSql(updatedAtUtc.value),
      );
    }
    if (activatedAtUtc.present) {
      map['activated_at_utc'] = Variable<DateTime>(
        $PracticeCardsTable.$converteractivatedAtUtcn.toSql(
          activatedAtUtc.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PracticeCardsCompanion(')
          ..write('id: $id, ')
          ..write('cardText: $cardText, ')
          ..write('title: $title, ')
          ..write('promptKind: $promptKind, ')
          ..write('status: $status, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceText: $sourceText, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('activatedAtUtc: $activatedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $DailyReflectionsTable extends DailyReflections
    with TableInfo<$DailyReflectionsTable, DailyReflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyReflectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<int> periodId = GeneratedColumn<int>(
    'period_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recovery_periods (id)',
    ),
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('best'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _practiceSnapshotMeta = const VerificationMeta(
    'practiceSnapshot',
  );
  @override
  late final GeneratedColumn<String> practiceSnapshot = GeneratedColumn<String>(
    'practice_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observationMeta = const VerificationMeta(
    'observation',
  );
  @override
  late final GeneratedColumn<String> observation = GeneratedColumn<String>(
    'observation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  List<GeneratedColumn> get $columns => [
    id,
    periodId,
    localDate,
    mood,
    prompt,
    body,
    practiceSnapshot,
    observation,
    note,
    completed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyReflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_periodIdMeta);
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('practice_snapshot')) {
      context.handle(
        _practiceSnapshotMeta,
        practiceSnapshot.isAcceptableOrUnknown(
          data['practice_snapshot']!,
          _practiceSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('observation')) {
      context.handle(
        _observationMeta,
        observation.isAcceptableOrUnknown(
          data['observation']!,
          _observationMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  DailyReflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyReflection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_id'],
      )!,
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood'],
      ),
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      practiceSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}practice_snapshot'],
      ),
      observation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observation'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $DailyReflectionsTable createAlias(String alias) {
    return $DailyReflectionsTable(attachedDatabase, alias);
  }
}

class DailyReflection extends DataClass implements Insertable<DailyReflection> {
  final int id;
  final int periodId;
  final String localDate;
  final int? mood;
  final String prompt;
  final String body;
  final String? practiceSnapshot;
  final String? observation;
  final String note;
  final bool completed;
  const DailyReflection({
    required this.id,
    required this.periodId,
    required this.localDate,
    this.mood,
    required this.prompt,
    required this.body,
    this.practiceSnapshot,
    this.observation,
    required this.note,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['period_id'] = Variable<int>(periodId);
    map['local_date'] = Variable<String>(localDate);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    map['prompt'] = Variable<String>(prompt);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || practiceSnapshot != null) {
      map['practice_snapshot'] = Variable<String>(practiceSnapshot);
    }
    if (!nullToAbsent || observation != null) {
      map['observation'] = Variable<String>(observation);
    }
    map['note'] = Variable<String>(note);
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  DailyReflectionsCompanion toCompanion(bool nullToAbsent) {
    return DailyReflectionsCompanion(
      id: Value(id),
      periodId: Value(periodId),
      localDate: Value(localDate),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      prompt: Value(prompt),
      body: Value(body),
      practiceSnapshot: practiceSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(practiceSnapshot),
      observation: observation == null && nullToAbsent
          ? const Value.absent()
          : Value(observation),
      note: Value(note),
      completed: Value(completed),
    );
  }

  factory DailyReflection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyReflection(
      id: serializer.fromJson<int>(json['id']),
      periodId: serializer.fromJson<int>(json['periodId']),
      localDate: serializer.fromJson<String>(json['localDate']),
      mood: serializer.fromJson<int?>(json['mood']),
      prompt: serializer.fromJson<String>(json['prompt']),
      body: serializer.fromJson<String>(json['body']),
      practiceSnapshot: serializer.fromJson<String?>(json['practiceSnapshot']),
      observation: serializer.fromJson<String?>(json['observation']),
      note: serializer.fromJson<String>(json['note']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'periodId': serializer.toJson<int>(periodId),
      'localDate': serializer.toJson<String>(localDate),
      'mood': serializer.toJson<int?>(mood),
      'prompt': serializer.toJson<String>(prompt),
      'body': serializer.toJson<String>(body),
      'practiceSnapshot': serializer.toJson<String?>(practiceSnapshot),
      'observation': serializer.toJson<String?>(observation),
      'note': serializer.toJson<String>(note),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  DailyReflection copyWith({
    int? id,
    int? periodId,
    String? localDate,
    Value<int?> mood = const Value.absent(),
    String? prompt,
    String? body,
    Value<String?> practiceSnapshot = const Value.absent(),
    Value<String?> observation = const Value.absent(),
    String? note,
    bool? completed,
  }) => DailyReflection(
    id: id ?? this.id,
    periodId: periodId ?? this.periodId,
    localDate: localDate ?? this.localDate,
    mood: mood.present ? mood.value : this.mood,
    prompt: prompt ?? this.prompt,
    body: body ?? this.body,
    practiceSnapshot: practiceSnapshot.present
        ? practiceSnapshot.value
        : this.practiceSnapshot,
    observation: observation.present ? observation.value : this.observation,
    note: note ?? this.note,
    completed: completed ?? this.completed,
  );
  DailyReflection copyWithCompanion(DailyReflectionsCompanion data) {
    return DailyReflection(
      id: data.id.present ? data.id.value : this.id,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      mood: data.mood.present ? data.mood.value : this.mood,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      body: data.body.present ? data.body.value : this.body,
      practiceSnapshot: data.practiceSnapshot.present
          ? data.practiceSnapshot.value
          : this.practiceSnapshot,
      observation: data.observation.present
          ? data.observation.value
          : this.observation,
      note: data.note.present ? data.note.value : this.note,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyReflection(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('localDate: $localDate, ')
          ..write('mood: $mood, ')
          ..write('prompt: $prompt, ')
          ..write('body: $body, ')
          ..write('practiceSnapshot: $practiceSnapshot, ')
          ..write('observation: $observation, ')
          ..write('note: $note, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    periodId,
    localDate,
    mood,
    prompt,
    body,
    practiceSnapshot,
    observation,
    note,
    completed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyReflection &&
          other.id == this.id &&
          other.periodId == this.periodId &&
          other.localDate == this.localDate &&
          other.mood == this.mood &&
          other.prompt == this.prompt &&
          other.body == this.body &&
          other.practiceSnapshot == this.practiceSnapshot &&
          other.observation == this.observation &&
          other.note == this.note &&
          other.completed == this.completed);
}

class DailyReflectionsCompanion extends UpdateCompanion<DailyReflection> {
  final Value<int> id;
  final Value<int> periodId;
  final Value<String> localDate;
  final Value<int?> mood;
  final Value<String> prompt;
  final Value<String> body;
  final Value<String?> practiceSnapshot;
  final Value<String?> observation;
  final Value<String> note;
  final Value<bool> completed;
  const DailyReflectionsCompanion({
    this.id = const Value.absent(),
    this.periodId = const Value.absent(),
    this.localDate = const Value.absent(),
    this.mood = const Value.absent(),
    this.prompt = const Value.absent(),
    this.body = const Value.absent(),
    this.practiceSnapshot = const Value.absent(),
    this.observation = const Value.absent(),
    this.note = const Value.absent(),
    this.completed = const Value.absent(),
  });
  DailyReflectionsCompanion.insert({
    this.id = const Value.absent(),
    required int periodId,
    required String localDate,
    this.mood = const Value.absent(),
    this.prompt = const Value.absent(),
    this.body = const Value.absent(),
    this.practiceSnapshot = const Value.absent(),
    this.observation = const Value.absent(),
    this.note = const Value.absent(),
    this.completed = const Value.absent(),
  }) : periodId = Value(periodId),
       localDate = Value(localDate);
  static Insertable<DailyReflection> custom({
    Expression<int>? id,
    Expression<int>? periodId,
    Expression<String>? localDate,
    Expression<int>? mood,
    Expression<String>? prompt,
    Expression<String>? body,
    Expression<String>? practiceSnapshot,
    Expression<String>? observation,
    Expression<String>? note,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (periodId != null) 'period_id': periodId,
      if (localDate != null) 'local_date': localDate,
      if (mood != null) 'mood': mood,
      if (prompt != null) 'prompt': prompt,
      if (body != null) 'body': body,
      if (practiceSnapshot != null) 'practice_snapshot': practiceSnapshot,
      if (observation != null) 'observation': observation,
      if (note != null) 'note': note,
      if (completed != null) 'completed': completed,
    });
  }

  DailyReflectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? periodId,
    Value<String>? localDate,
    Value<int?>? mood,
    Value<String>? prompt,
    Value<String>? body,
    Value<String?>? practiceSnapshot,
    Value<String?>? observation,
    Value<String>? note,
    Value<bool>? completed,
  }) {
    return DailyReflectionsCompanion(
      id: id ?? this.id,
      periodId: periodId ?? this.periodId,
      localDate: localDate ?? this.localDate,
      mood: mood ?? this.mood,
      prompt: prompt ?? this.prompt,
      body: body ?? this.body,
      practiceSnapshot: practiceSnapshot ?? this.practiceSnapshot,
      observation: observation ?? this.observation,
      note: note ?? this.note,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<int>(periodId.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (practiceSnapshot.present) {
      map['practice_snapshot'] = Variable<String>(practiceSnapshot.value);
    }
    if (observation.present) {
      map['observation'] = Variable<String>(observation.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyReflectionsCompanion(')
          ..write('id: $id, ')
          ..write('periodId: $periodId, ')
          ..write('localDate: $localDate, ')
          ..write('mood: $mood, ')
          ..write('prompt: $prompt, ')
          ..write('body: $body, ')
          ..write('practiceSnapshot: $practiceSnapshot, ')
          ..write('observation: $observation, ')
          ..write('note: $note, ')
          ..write('completed: $completed')
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
  late final $PracticeCardsTable practiceCards = $PracticeCardsTable(this);
  late final $DailyReflectionsTable dailyReflections = $DailyReflectionsTable(
    this,
  );
  late final Index oneActivePeriod = Index(
    'one_active_period',
    'CREATE UNIQUE INDEX one_active_period ON recovery_periods ((1)) WHERE closed_at_utc IS NULL',
  );
  late final Index oneActivePractice = Index(
    'one_active_practice',
    'CREATE UNIQUE INDEX one_active_practice ON practice_cards (status) WHERE status = \'active\'',
  );
  late final Index reflectionPeriodDay = Index(
    'reflection_period_day',
    'CREATE UNIQUE INDEX reflection_period_day ON daily_reflections (period_id, local_date)',
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
    practiceCards,
    dailyReflections,
    oneActivePeriod,
    oneActivePractice,
    reflectionPeriodDay,
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

  static MultiTypedResultKey<$DailyReflectionsTable, List<DailyReflection>>
  _dailyReflectionsRefsTable(_$HajnalDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.dailyReflections,
        aliasName: $_aliasNameGenerator(
          db.recoveryPeriods.id,
          db.dailyReflections.periodId,
        ),
      );

  $$DailyReflectionsTableProcessedTableManager get dailyReflectionsRefs {
    final manager = $$DailyReflectionsTableTableManager(
      $_db,
      $_db.dailyReflections,
    ).filter((f) => f.periodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _dailyReflectionsRefsTable($_db),
    );
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

  Expression<bool> dailyReflectionsRefs(
    Expression<bool> Function($$DailyReflectionsTableFilterComposer f) f,
  ) {
    final $$DailyReflectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyReflections,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReflectionsTableFilterComposer(
            $db: $db,
            $table: $db.dailyReflections,
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

  Expression<T> dailyReflectionsRefs<T extends Object>(
    Expression<T> Function($$DailyReflectionsTableAnnotationComposer a) f,
  ) {
    final $$DailyReflectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.dailyReflections,
      getReferencedColumn: (t) => t.periodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DailyReflectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dailyReflections,
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
          PrefetchHooks Function({
            bool survivalNotesRefs,
            bool dailyReflectionsRefs,
          })
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
          prefetchHooksCallback:
              ({survivalNotesRefs = false, dailyReflectionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (survivalNotesRefs) db.survivalNotes,
                    if (dailyReflectionsRefs) db.dailyReflections,
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.periodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (dailyReflectionsRefs)
                        await $_getPrefetchedData<
                          RecoveryPeriod,
                          $RecoveryPeriodsTable,
                          DailyReflection
                        >(
                          currentTable: table,
                          referencedTable: $$RecoveryPeriodsTableReferences
                              ._dailyReflectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecoveryPeriodsTableReferences(
                                db,
                                table,
                                p0,
                              ).dailyReflectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.periodId == item.id,
                              ),
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
      PrefetchHooks Function({
        bool survivalNotesRefs,
        bool dailyReflectionsRefs,
      })
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
typedef $$PracticeCardsTableCreateCompanionBuilder =
    PracticeCardsCompanion Function({
      Value<int> id,
      required String cardText,
      Value<String?> title,
      Value<String?> promptKind,
      required String status,
      Value<String?> sourceReference,
      Value<String?> sourceName,
      Value<String?> sourceText,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<DateTime?> activatedAtUtc,
    });
typedef $$PracticeCardsTableUpdateCompanionBuilder =
    PracticeCardsCompanion Function({
      Value<int> id,
      Value<String> cardText,
      Value<String?> title,
      Value<String?> promptKind,
      Value<String> status,
      Value<String?> sourceReference,
      Value<String?> sourceName,
      Value<String?> sourceText,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<DateTime?> activatedAtUtc,
    });

class $$PracticeCardsTableFilterComposer
    extends Composer<_$HajnalDatabase, $PracticeCardsTable> {
  $$PracticeCardsTableFilterComposer({
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

  ColumnFilters<String> get cardText => $composableBuilder(
    column: $table.cardText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptKind => $composableBuilder(
    column: $table.promptKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime>
  get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, DateTime>
  get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, DateTime>
  get activatedAtUtc => $composableBuilder(
    column: $table.activatedAtUtc,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$PracticeCardsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $PracticeCardsTable> {
  $$PracticeCardsTableOrderingComposer({
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

  ColumnOrderings<String> get cardText => $composableBuilder(
    column: $table.cardText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptKind => $composableBuilder(
    column: $table.promptKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activatedAtUtc => $composableBuilder(
    column: $table.activatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PracticeCardsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $PracticeCardsTable> {
  $$PracticeCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardText =>
      $composableBuilder(column: $table.cardText, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get promptKind => $composableBuilder(
    column: $table.promptKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceText => $composableBuilder(
    column: $table.sourceText,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get createdAtUtc =>
      $composableBuilder(
        column: $table.createdAtUtc,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, DateTime> get updatedAtUtc =>
      $composableBuilder(
        column: $table.updatedAtUtc,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, DateTime> get activatedAtUtc =>
      $composableBuilder(
        column: $table.activatedAtUtc,
        builder: (column) => column,
      );
}

class $$PracticeCardsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $PracticeCardsTable,
          PracticeCardData,
          $$PracticeCardsTableFilterComposer,
          $$PracticeCardsTableOrderingComposer,
          $$PracticeCardsTableAnnotationComposer,
          $$PracticeCardsTableCreateCompanionBuilder,
          $$PracticeCardsTableUpdateCompanionBuilder,
          (
            PracticeCardData,
            BaseReferences<
              _$HajnalDatabase,
              $PracticeCardsTable,
              PracticeCardData
            >,
          ),
          PracticeCardData,
          PrefetchHooks Function()
        > {
  $$PracticeCardsTableTableManager(
    _$HajnalDatabase db,
    $PracticeCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PracticeCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PracticeCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PracticeCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardText = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> promptKind = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> sourceReference = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> sourceText = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> activatedAtUtc = const Value.absent(),
              }) => PracticeCardsCompanion(
                id: id,
                cardText: cardText,
                title: title,
                promptKind: promptKind,
                status: status,
                sourceReference: sourceReference,
                sourceName: sourceName,
                sourceText: sourceText,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                activatedAtUtc: activatedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardText,
                Value<String?> title = const Value.absent(),
                Value<String?> promptKind = const Value.absent(),
                required String status,
                Value<String?> sourceReference = const Value.absent(),
                Value<String?> sourceName = const Value.absent(),
                Value<String?> sourceText = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> activatedAtUtc = const Value.absent(),
              }) => PracticeCardsCompanion.insert(
                id: id,
                cardText: cardText,
                title: title,
                promptKind: promptKind,
                status: status,
                sourceReference: sourceReference,
                sourceName: sourceName,
                sourceText: sourceText,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                activatedAtUtc: activatedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PracticeCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $PracticeCardsTable,
      PracticeCardData,
      $$PracticeCardsTableFilterComposer,
      $$PracticeCardsTableOrderingComposer,
      $$PracticeCardsTableAnnotationComposer,
      $$PracticeCardsTableCreateCompanionBuilder,
      $$PracticeCardsTableUpdateCompanionBuilder,
      (
        PracticeCardData,
        BaseReferences<_$HajnalDatabase, $PracticeCardsTable, PracticeCardData>,
      ),
      PracticeCardData,
      PrefetchHooks Function()
    >;
typedef $$DailyReflectionsTableCreateCompanionBuilder =
    DailyReflectionsCompanion Function({
      Value<int> id,
      required int periodId,
      required String localDate,
      Value<int?> mood,
      Value<String> prompt,
      Value<String> body,
      Value<String?> practiceSnapshot,
      Value<String?> observation,
      Value<String> note,
      Value<bool> completed,
    });
typedef $$DailyReflectionsTableUpdateCompanionBuilder =
    DailyReflectionsCompanion Function({
      Value<int> id,
      Value<int> periodId,
      Value<String> localDate,
      Value<int?> mood,
      Value<String> prompt,
      Value<String> body,
      Value<String?> practiceSnapshot,
      Value<String?> observation,
      Value<String> note,
      Value<bool> completed,
    });

final class $$DailyReflectionsTableReferences
    extends
        BaseReferences<
          _$HajnalDatabase,
          $DailyReflectionsTable,
          DailyReflection
        > {
  $$DailyReflectionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RecoveryPeriodsTable _periodIdTable(_$HajnalDatabase db) =>
      db.recoveryPeriods.createAlias(
        $_aliasNameGenerator(
          db.dailyReflections.periodId,
          db.recoveryPeriods.id,
        ),
      );

  $$RecoveryPeriodsTableProcessedTableManager get periodId {
    final $_column = $_itemColumn<int>('period_id')!;

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

class $$DailyReflectionsTableFilterComposer
    extends Composer<_$HajnalDatabase, $DailyReflectionsTable> {
  $$DailyReflectionsTableFilterComposer({
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

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get practiceSnapshot => $composableBuilder(
    column: $table.practiceSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
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

class $$DailyReflectionsTableOrderingComposer
    extends Composer<_$HajnalDatabase, $DailyReflectionsTable> {
  $$DailyReflectionsTableOrderingComposer({
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

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get practiceSnapshot => $composableBuilder(
    column: $table.practiceSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
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

class $$DailyReflectionsTableAnnotationComposer
    extends Composer<_$HajnalDatabase, $DailyReflectionsTable> {
  $$DailyReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get practiceSnapshot => $composableBuilder(
    column: $table.practiceSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observation => $composableBuilder(
    column: $table.observation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

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

class $$DailyReflectionsTableTableManager
    extends
        RootTableManager<
          _$HajnalDatabase,
          $DailyReflectionsTable,
          DailyReflection,
          $$DailyReflectionsTableFilterComposer,
          $$DailyReflectionsTableOrderingComposer,
          $$DailyReflectionsTableAnnotationComposer,
          $$DailyReflectionsTableCreateCompanionBuilder,
          $$DailyReflectionsTableUpdateCompanionBuilder,
          (DailyReflection, $$DailyReflectionsTableReferences),
          DailyReflection,
          PrefetchHooks Function({bool periodId})
        > {
  $$DailyReflectionsTableTableManager(
    _$HajnalDatabase db,
    $DailyReflectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyReflectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> periodId = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int?> mood = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> practiceSnapshot = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => DailyReflectionsCompanion(
                id: id,
                periodId: periodId,
                localDate: localDate,
                mood: mood,
                prompt: prompt,
                body: body,
                practiceSnapshot: practiceSnapshot,
                observation: observation,
                note: note,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int periodId,
                required String localDate,
                Value<int?> mood = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> practiceSnapshot = const Value.absent(),
                Value<String?> observation = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<bool> completed = const Value.absent(),
              }) => DailyReflectionsCompanion.insert(
                id: id,
                periodId: periodId,
                localDate: localDate,
                mood: mood,
                prompt: prompt,
                body: body,
                practiceSnapshot: practiceSnapshot,
                observation: observation,
                note: note,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DailyReflectionsTableReferences(db, table, e),
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
                                referencedTable:
                                    $$DailyReflectionsTableReferences
                                        ._periodIdTable(db),
                                referencedColumn:
                                    $$DailyReflectionsTableReferences
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

typedef $$DailyReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$HajnalDatabase,
      $DailyReflectionsTable,
      DailyReflection,
      $$DailyReflectionsTableFilterComposer,
      $$DailyReflectionsTableOrderingComposer,
      $$DailyReflectionsTableAnnotationComposer,
      $$DailyReflectionsTableCreateCompanionBuilder,
      $$DailyReflectionsTableUpdateCompanionBuilder,
      (DailyReflection, $$DailyReflectionsTableReferences),
      DailyReflection,
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
  $$PracticeCardsTableTableManager get practiceCards =>
      $$PracticeCardsTableTableManager(_db, _db.practiceCards);
  $$DailyReflectionsTableTableManager get dailyReflections =>
      $$DailyReflectionsTableTableManager(_db, _db.dailyReflections);
}
