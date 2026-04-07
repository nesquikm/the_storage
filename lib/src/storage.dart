import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:the_storage/src/abstract_storage.dart';
import 'package:the_storage/src/db/storage_database.dart';

const _sqLiteSliceSize = 512;

/// Storage (db backend)
class Storage implements AbstractStorage<StorageValue> {
  /// Create a new storage
  Storage();

  late StorageDatabase _database;
  final _log = Logger('TheStorage: Storage');

  /// Init storage
  Future<void> init([
    String dbName = AbstractStorage.storageFileName,
    @visibleForTesting StorageDatabase? database,
  ]) async {
    WidgetsFlutterBinding.ensureInitialized();

    _database = database ?? StorageDatabase.withName(dbName);

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

    _log.finest('reset');
  }

  @override
  Future<void> clearAll() async {
    await _database.delete(_database.storageEntries).go();

    _log.finest('storage cleared');
  }

  @override
  Future<void> clearDomain([
    String? domain = AbstractStorage.defaultDomain,
  ]) async {
    await (_database.delete(_database.storageEntries)
          ..where((t) => t.domain.equals(domain!)))
        .go();

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

    final mode = overwrite ? InsertMode.replace : InsertMode.insertOrIgnore;

    await _database.batch((batch) {
      for (final entry in pairs.entries) {
        batch.insert(
          _database.storageEntries,
          StorageEntriesCompanion.insert(
            domain: domain,
            key: entry.key,
            value: entry.value.value,
            iv: entry.value.iv,
          ),
          mode: mode,
        );
      }
    });
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
    for (final slice in keys.slices(_sqLiteSliceSize)) {
      await (_database.delete(_database.storageEntries)
            ..where(
              (t) => t.domain.equals(domain) & t.key.isIn(slice),
            ))
          .go();
    }
  }

  @override
  Future<StorageValue?> get(
    String key, {
    StorageValue? defaultValue,
    String domain = AbstractStorage.defaultDomain,
  }) async {
    final row = await (_database.select(_database.storageEntries)
          ..where(
            (t) => t.domain.equals(domain) & t.key.equals(key),
          ))
        .getSingleOrNull();

    return row != null ? StorageValue(row.value, row.iv) : defaultValue;
  }

  @override
  Future<Map<String, StorageValue>> getDomain({
    String domain = AbstractStorage.defaultDomain,
  }) async {
    final rows = await (_database.select(_database.storageEntries)
          ..where((t) => t.domain.equals(domain)))
        .get();

    return {
      for (final row in rows)
        row.key: StorageValue(row.value, row.iv),
    };
  }

  @override
  Future<List<String>> getDomainKeys({
    String domain = AbstractStorage.defaultDomain,
  }) async {
    final rows = await (_database.select(_database.storageEntries)
          ..where((t) => t.domain.equals(domain)))
        .get();

    return [
      for (final row in rows) row.key,
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
