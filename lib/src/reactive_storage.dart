import 'package:rxdart/rxdart.dart';

import 'package:the_storage/src/abstract_storage.dart';

/// Reactive interface for the storage
abstract class ReactiveStorage<StorageValueType> {
  /// Returns a [BehaviorSubject] that will emit the current value of the [key]
  /// and [domain]. If not found will return [defaultValue]. [keepAlive] will
  /// keep the subject alive after the last subscriber has unsubscribed, so the
  /// data will stay in memory instead of being reacquired from the storage.
  Future<ValueStream<StorageValueType?>> subscribe(
    String key, {
    StorageValueType? defaultValue,
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  });

  /// Returns a [BehaviorSubject] that will emit the key-value pairs map from
  /// [domain]. [keepAlive] will keep the subject alive after the last
  /// subscriber has unsubscribed, so the data will stay in memory instead of
  /// being reacquired from the storage.
  Future<ValueStream<Map<String, StorageValueType>>> subscribeDomain({
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  });

  /// Returns a [BehaviorSubject] that will emit the keys from [domain].
  /// [keepAlive] will keep the subject alive after the last subscriber has
  /// unsubscribed, so the data will stay in memory instead of being reacquired
  /// from the storage.
  Future<ValueStream<List<String>>> subscribeDomainKeys({
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  });
}
