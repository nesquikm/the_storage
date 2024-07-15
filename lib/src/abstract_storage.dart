import 'dart:async';

/// AbstractStorage: storage interface
abstract class AbstractStorage<StorageValueType> {
  /// Default domain name
  static const String defaultDomain = 'default';

  /// Default storage file name
  static const storageFileName = 'storage.db';

  /// Reset storage
  Future<void> reset();

  /// Clear storage: all records
  Future<void> clearAll();

  /// Clear storage: all records in one domain
  Future<void> clearDomain([String domain = defaultDomain]);

  /// Write the key-value pair.
  ///
  /// [value] will be written for the [key] in [domain].
  /// If the pair was already existed it will be overwritten if [overwrite]
  /// is true (by default)
  Future<void> set(
    String key,
    StorageValueType value, {
    String domain = defaultDomain,
    bool overwrite = true,
  });

  /// Write the key-value pair map.
  ///
  /// [pairs] will be written in [domain].
  /// If the pair was already existed it will be overwritten if [overwrite]
  /// is true (by default). Unspecified in [pairs] in db will not be altered
  /// or deleted.
  Future<void> setDomain(
    Map<String, StorageValueType> pairs, {
    String domain = defaultDomain,
    bool overwrite = true,
  });

  /// Delete by [key] from [domain].
  Future<void> delete(
    String key, {
    String domain = defaultDomain,
  });

  /// Delete by [keys] from [domain].
  Future<void> deleteDomain(
    List<String> keys, {
    String domain = defaultDomain,
  });

  /// Get value by [key] and [domain]. If not found will return [defaultValue]
  Future<StorageValueType?> get(
    String key, {
    StorageValueType? defaultValue,
    String domain = defaultDomain,
  });

  /// Get key-value pairs map from [domain].
  Future<Map<String, StorageValueType>> getDomain({
    String domain = defaultDomain,
  });

  /// Get keys from [domain]
  Future<List<String>> getDomainKeys({
    String domain = defaultDomain,
  });
}
