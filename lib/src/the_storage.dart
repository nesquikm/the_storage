import 'package:logging/logging.dart';
import 'package:the_storage/src/abstract_storage.dart';
import 'package:the_storage/src/cipher_storage.dart';
import 'package:the_storage/src/encrypt_helper.dart';
import 'package:the_storage/src/storage.dart';

/// The storage interface
typedef TheStorageInterface = AbstractStorage<String>;

/// The storage: fast and secure
class TheStorage extends TheStorageInterface {
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

    await _storage.dispose();

    _instance = null;
  }

  @override
  Future<void> reset() async {
    _assureInitialized();

    await _storage.reset();

    await dispose();
    // _initialized = false;
  }

  @override
  Future<void> clearAll() async {
    _assureInitialized();

    return _storage.clearAll();
  }

  @override
  Future<void> clearDomain([
    String? domain = AbstractStorage.defaultDomain,
  ]) async {
    _assureInitialized();

    return _storage.clearDomain(domain);
  }

  @override
  Future<void> delete(
    String key, {
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    return _storage.delete(_encryptHelper.encrypt(key), domain: domain);
  }

  @override
  Future<void> deleteDomain(
    List<String> keys, {
    String domain = AbstractStorage.defaultDomain,
  }) async {
    _assureInitialized();

    return _storage.deleteDomain(
      keys.map((key) => _encryptHelper.encrypt(key)).toList(),
      domain: domain,
    );
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

    return _storage.set(
      _encryptHelper.encrypt(key),
      StorageValue(_encryptHelper.encrypt(value, iv), iv),
      domain: domain,
      overwrite: overwrite,
    );
  }

  @override
  Future<void> setDomain(
    Map<String, String> pairs, {
    String domain = AbstractStorage.defaultDomain,
    bool overwrite = true,
  }) async {
    _assureInitialized();

    return _storage.setDomain(
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
  }

  void _assureInitialized() {
    if (!_initialized) {
      throw Exception('TheStorage is not initialized!');
    }
  }
}
