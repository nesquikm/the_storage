import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:the_storage/src/abstract_storage.dart';
import 'package:the_storage/src/cipher_storage.dart';
import 'package:the_storage/src/encrypt_helper.dart';
import 'package:the_storage/src/reactive_storage.dart';
import 'package:the_storage/src/storage.dart';

/// The storage interface
typedef TheStorageInterface = AbstractStorage<String>;

/// The reactive interface
typedef ReactiveInterface = ReactiveStorage<String>;

/// The storage: fast and secure
class TheStorage implements TheStorageInterface, ReactiveInterface {
  /// Get storage instance
  factory TheStorage.i() {
    _instance ??= TheStorage._();
    return _instance!;
  }
  TheStorage._();
  static TheStorage? _instance;

  final _log = Logger('TheLogger');

  final _cipherStorage = CipherStorage();
  late EncryptHelper _encryptHelper;
  final _storage = Storage();

  bool _initialized = false;

  /// (key, domain, defaultValue, keepAlive) -> BehaviorSubject of value
  final Map<(String, String, String?, bool), BehaviorSubject<String?>>
      _subjects = {};

  /// (domain, keepAlive) -> BehaviorSubject of domain
  final Map<(String, bool), BehaviorSubject<Map<String, String>>>
      _domainSubjects = {};

  /// (domain, keepAlive) -> BehaviorSubject of domain keys
  final Map<(String, bool), BehaviorSubject<List<String>>> _domainKeysSubjects =
      {};

  /// Init encrypted storage
  Future<void> init([String dbName = AbstractStorage.storageFileName]) async {
    if (_initialized) {
      _log.warning('TheStorage is already initialized!');
      return;
    }

    _initialized = true;

    await Future.wait([
      _cipherStorage.init(),
      _storage.init(dbName),
    ]);
    _encryptHelper = EncryptHelper(_cipherStorage);
  }

  /// Dispose storage
  Future<void> dispose() async {
    _assureInitialized();

    _clearSubjects();

    await _storage.dispose();

    _instance = null;
  }

  @override
  Future<void> reset() async {
    _assureInitialized();

    await _storage.reset();

    _notifyClearAll();

    await dispose();
    // _initialized = false;
  }

  @override
  Future<void> clearAll() async {
    _assureInitialized();

    await _storage.clearAll();

    _notifyClearAll();
  }

  @override
  Future<void> clearDomain([
    String domain = AbstractStorage.defaultDomain,
  ]) async {
    _assureInitialized();

    await _storage.clearDomain(domain);

    await _notifyAllSubjects(null, domain: domain);
  }

  @override
  Future<void> delete(
    String key, {
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    await _storage.delete(_encryptHelper.encrypt(key), domain: domain);

    await _notifyAllSubjects(key, domain: domain);
  }

  @override
  Future<void> deleteDomain(
    List<String> keys, {
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    await _storage.deleteDomain(
      keys.map((key) => _encryptHelper.encrypt(key)).toList(),
      domain: domain,
    );

    await _notifyAllSubjects(null, domain: domain);
  }

  @override
  Future<String?> get(
    String key, {
    String? defaultValue,
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    final storageValue = await _storage.get(
      _encryptHelper.encrypt(key),
      defaultValue: defaultValue != null
          ? StorageValue(_encryptHelper.encrypt(defaultValue), '')
          : null,
      domain: domain,
    );

    return _encryptHelper.decryptNullable(
      storageValue?.value,
      storageValue?.iv,
    );
  }

  @override
  Future<Map<String, String>> getDomain({
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    final pairs = await _storage.getDomain(
      domain: domain,
    );

    return pairs.map(
      (key, value) => MapEntry(
        _encryptHelper.decrypt(key),
        _encryptHelper.decrypt(value.value, value.iv),
      ),
    );
  }

  @override
  Future<List<String>> getDomainKeys({
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    final keys = await _storage.getDomainKeys(
      domain: domain,
    );

    return keys.map((key) => _encryptHelper.decrypt(key)).toList();
  }

  @override
  Future<void> set(
    String key,
    String value, {
    String domain = AbstractStorage.defaultDomain,
    bool overwrite = true,
  }) async {
    _assureInitialized();

    final iv = CipherStorage.ivFromSecureRandom().base64;

    await _storage.set(
      _encryptHelper.encrypt(key),
      StorageValue(_encryptHelper.encrypt(value, iv), iv),
      domain: domain,
      overwrite: overwrite,
    );

    await _notifyAllSubjects(key, domain: domain);
  }

  @override
  Future<void> setDomain(
    Map<String, String> pairs, {
    String domain = AbstractStorage.defaultDomain,
    bool overwrite = true,
  }) async {
    _assureInitialized();

    await _storage.setDomain(
      pairs.map((key, value) {
        final iv = CipherStorage.ivFromSecureRandom().base64;

        return MapEntry(
          _encryptHelper.encrypt(key),
          StorageValue(_encryptHelper.encrypt(value, iv), iv),
        );
      }),
      domain: domain,
      overwrite: overwrite,
    );

    await _notifyAllSubjects(null, domain: domain);
  }

  void _assureInitialized() {
    if (!_initialized) {
      throw Exception('TheStorage is not initialized!');
    }
  }

  @override
  Future<ValueStream<String?>> subscribe(
    String key, {
    String? defaultValue,
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  }) async {
    _assureInitialized();

    final subject = _subjects[(key, domain, defaultValue, keepAlive)];
    if (subject != null) {
      return subject.stream;
    }

    final data = await get(key, defaultValue: defaultValue, domain: domain);

    final newSubject = BehaviorSubject<String?>.seeded(
      data,
      onCancel: keepAlive
          ? null
          : () {
              _subjects[(key, domain, defaultValue, keepAlive)]?.close();
              _subjects.remove((key, domain, defaultValue, keepAlive));
            },
    );
    _subjects[(key, domain, defaultValue, keepAlive)] = newSubject;

    return newSubject.stream;
  }

  @override
  Future<ValueStream<Map<String, String>>> subscribeDomain({
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  }) async {
    _assureInitialized();

    final subject = _domainSubjects[(domain, keepAlive)];
    if (subject != null) {
      return subject.stream;
    }

    final data = await getDomain(domain: domain);

    final newSubject = BehaviorSubject<Map<String, String>>.seeded(
      data,
      onCancel: keepAlive
          ? null
          : () {
              _domainSubjects[(domain, keepAlive)]?.close();
              _domainSubjects.remove((domain, keepAlive));
            },
    );
    _domainSubjects[(domain, keepAlive)] = newSubject;

    return newSubject.stream;
  }

  @override
  Future<ValueStream<List<String>>> subscribeDomainKeys({
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  }) async {
    _assureInitialized();

    final subject = _domainKeysSubjects[(domain, keepAlive)];
    if (subject != null) {
      return subject.stream;
    }

    final data = await getDomainKeys(domain: domain);

    final newSubject = BehaviorSubject<List<String>>.seeded(
      data,
      onCancel: keepAlive
          ? null
          : () {
              _domainKeysSubjects[(domain, keepAlive)]?.close();
              _domainKeysSubjects.remove((domain, keepAlive));
            },
    );
    _domainKeysSubjects[(domain, keepAlive)] = newSubject;

    return newSubject.stream;
  }

  void _clearSubjects() {
    for (final subject in _subjects.values) {
      subject.close();
    }
    _subjects.clear();

    for (final subject in _domainSubjects.values) {
      subject.close();
    }
    _domainSubjects.clear();

    for (final subject in _domainKeysSubjects.values) {
      subject.close();
    }
    _domainKeysSubjects.clear();
  }

  void _notifyClearAll() {
    for (final subject in _subjects.values) {
      subject.add(null);
    }

    for (final subject in _domainSubjects.values) {
      subject.add({});
    }

    for (final subject in _domainKeysSubjects.values) {
      subject.add([]);
    }
  }

  Future<void> _notifyAllSubjects(
    String? key, {
    required String domain,
  }) async {
    await Future.wait([
      _notifySubjects(key, domain: domain),
      _notifyDomainSubjects(domain),
      _notifyDomainKeysSubjects(domain),
    ]);
  }

  /// Notify all [_subjects] filtered by [key] and [domain]. If [key] is null
  /// then all [_subjects] with [domain] will be notified.
  Future<void> _notifySubjects(
    String? key, {
    required String domain,
  }) async {
    if (_subjects.isEmpty) {
      return;
    }

    if (key == null) {
      final domainPairs = await getDomain(domain: domain);
      for (final entry
          in _subjects.entries.where((entry) => entry.key.$2 == domain)) {
        entry.value.add(domainPairs[entry.key.$1]);
      }
      return;
    }

    final value = await get(key, domain: domain);
    for (final entry in _subjects.entries
        .where((entry) => entry.key.$1 == key && entry.key.$2 == domain)) {
      entry.value.add(value);
    }
  }

  /// Notify all [_domainSubjects] filtered by [domain].
  Future<void> _notifyDomainSubjects(String domain) async {
    if (_domainSubjects.isEmpty) {
      return;
    }

    final domainPairs = await getDomain(domain: domain);
    for (final entry
        in _domainSubjects.entries.where((entry) => entry.key.$1 == domain)) {
      entry.value.add(domainPairs);
    }
  }

  /// Notify all [_domainKeysSubjects] filtered by [domain].
  Future<void> _notifyDomainKeysSubjects(String domain) async {
    if (_domainKeysSubjects.isEmpty) {
      return;
    }

    final domainKeys = await getDomainKeys(domain: domain);
    for (final entry in _domainKeysSubjects.entries
        .where((entry) => entry.key.$1 == domain)) {
      entry.value.add(domainKeys);
    }
  }
}
