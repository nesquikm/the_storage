import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:the_storage/src/abstract_storage.dart';

const _sqLiteSliceSize = 512;

/// Storage (db backend)
class Storage implements AbstractStorage<StorageValue> {
  /// Create a new storage
  Storage();

  late final Database _database;
  final _log = Logger('TheStorage: Storage');
  late final String _dbName;

  /// Init storage
  Future<void> init([String dbName = AbstractStorage.storageFileName]) async {
    WidgetsFlutterBinding.ensureInitialized();

    _dbName = dbName;

    _database = await openDatabase(
      join(
        await getDatabasesPath(),
        dbName,
      ),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
      version: 1,
    );

    _log.finest('initialized');
  }

  /// Dispose storage
  Future<void> dispose() async {
    await _database.close();
  }

  @override
  Future<void> reset() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _database.close();
    await deleteDatabase(
      join(
        await getDatabasesPath(),
        _dbName,
      ),
    );

    _log.finest('reset');
  }

  Future<void> _onCreate(Database db, int _) async {
    await db.execute(
      '''
        CREATE TABLE storage (
          domain TEXT NOT NULL,
          key TEXT NOT NULL,
          value TEXT NOT NULL,
          iv TEXT NOT NULL,
          PRIMARY KEY (domain, key)
        );
      ''',
    );
    await db.execute(
      '''
        CREATE INDEX storage_domain_index ON storage(domain);
      ''',
    );

    _log.finest('database created');
  }

  FutureOr<void> _onUpgrade(Database _, int oldVersion, int newVersion) {
    _log
      ..finest('database upgraded from $oldVersion to $newVersion')
      ..warning('no upgrade migrations found');
  }

  FutureOr<void> _onDowngrade(Database _, int oldVersion, int newVersion) {
    _log
      ..finest('database downgraded from $oldVersion to $newVersion')
      ..warning('no downgrade migrations found');
  }

  @override
  Future<void> clearAll() async {
    const query = '''
      DELETE FROM storage;
    ''';

    await _database.execute(query);

    _log.finest('storage cleared');
  }

  @override
  Future<void> clearDomain([
    String? domain = AbstractStorage.defaultDomain,
  ]) async {
    final query = '''
      DELETE FROM storage WHERE domain = '$domain';
    ''';

    await _database.execute(query);

    _log.finest('domain $domain cleared');
  }

  @override
  Future<void> set(
    String key,
    StorageValue value, {
    String domain = AbstractStorage.defaultDomain,
    bool overwrite = true,
  }) async {
    return setDomain(
      {
        key: value,
      },
      domain: domain,
      overwrite: overwrite,
    );
  }

  @override
  Future<void> setDomain(
    Map<String, StorageValue> pairs, {
    String domain = AbstractStorage.defaultDomain,
    bool overwrite = true,
  }) async {
    if (pairs.isEmpty) {
      _log.info('setAll called with empty pair map');

      return;
    }

    var isFirst = true;
    final values = pairs.entries.fold('', (previousValue, pair) {
      final prefix = isFirst ? '' : ', ';
      final result =
          // ignore: lines_longer_than_80_chars
          "$previousValue$prefix('$domain', '${pair.key}', '${pair.value.value}', '${pair.value.iv}' )";
      isFirst = false;

      return result;
    });

    final conflictClause = overwrite ? 'REPLACE' : 'IGNORE';
    final query = '''
      INSERT OR $conflictClause INTO storage (domain, key, value, iv) VALUES $values;
    ''';

    await _database.execute(query);
  }

  @override
  Future<void> delete(
    String key, {
    String domain = AbstractStorage.defaultDomain,
  }) async {
    return deleteDomain([key], domain: domain);
  }

  @override
  Future<void> deleteDomain(
    List<String> keys, {
    String domain = AbstractStorage.defaultDomain,
  }) async {
    if (keys.isEmpty) {
      _log.info('deleteDomain called with empty key list');

      return;
    }

    // SQLite has a limit of 999 variables per query
    keys.slices(_sqLiteSliceSize).forEach((keys) async {
      var isFirst = true;
      final andClause = keys.fold('', (previousValue, key) {
        final prefix = isFirst ? '' : ' OR ';
        final result = "$previousValue$prefix(key = '$key')";
        isFirst = false;

        return result;
      });

      final query = '''
        DELETE FROM storage WHERE domain = '$domain' AND ($andClause)
      ''';

      await _database.execute(query);
    });
  }

  @override
  Future<StorageValue?> get(
    String key, {
    StorageValue? defaultValue,
    String domain = AbstractStorage.defaultDomain,
  }) async {
    final list = await _database.rawQuery(
      '''
        SELECT value, iv FROM storage WHERE domain = '$domain' and key = '$key' LIMIT 1;
      ''',
    );

    return list.isNotEmpty
        ? StorageValue(
            list.first['value']! as String,
            list.first['iv']! as String,
          )
        : defaultValue;
  }

  @override
  Future<Map<String, StorageValue>> getDomain({
    String domain = AbstractStorage.defaultDomain,
  }) async {
    final list = await _database.rawQuery(
      '''
        SELECT key, value, iv FROM storage WHERE domain = '$domain';
      ''',
    );

    return {
      // There is no way to write null in these fields
      // ignore: cast_nullable_to_non_nullable
      for (final pair in list)
        pair['key']! as String: StorageValue(
          pair['value']! as String,
          pair['iv']! as String,
        ),
    };
  }

  @override
  Future<List<String>> getDomainKeys({
    String domain = AbstractStorage.defaultDomain,
  }) async {
    final list = await _database.rawQuery(
      '''
      SELECT key FROM storage WHERE domain = '$domain';
    ''',
    );

    return [
      // There is no way to write null in these fields
      // ignore: cast_nullable_to_non_nullable
      for (final pair in list) pair['key']! as String,
    ];
  }
}

/// Storage value unit
@immutable
class StorageValue implements Comparable<StorageValue> {
  /// Create a new storage value unit
  const StorageValue(this.value, this.iv);

  /// Value
  final String value;

  /// Initialization vector
  final String iv;

  @override
  int compareTo(StorageValue other) {
    return (value.compareTo(other.value) == 0 && iv.compareTo(other.iv) == 0)
        ? 0
        : 1;
  }

  @override
  bool operator ==(Object other) {
    return other is StorageValue && other.value == value && other.iv == iv;
  }

  @override
  int get hashCode {
    return value.hashCode + iv.hashCode;
  }
}
