import 'package:rxdart/rxdart.dart';
import 'package:the_storage/src/abstract_storage.dart';

/// Reactive interface for the storage.
///
/// This interface provides reactive streams for accessing and observing
/// storage values. It leverages [BehaviorSubject] from the `rxdart` package
/// to emit the current value and any subsequent changes.
abstract class ReactiveStorage<StorageValueType> {
  /// Subscribes to the value associated with the given [key] in the specified
  /// [domain].
  ///
  /// This method returns a [ValueStream] that emits the current value of the
  /// [key] and any subsequent changes. If the key is not found, it will emit
  /// [defaultValue]. The [keepAlive] parameter determines whether the subject
  /// should stay alive after the last subscriber has unsubscribed, keeping the
  /// data in memory instead of reacquiring it from the storage.
  ///
  /// Example:
  /// ```dart
  /// final stream = await reactiveStorage.subscribe(
  ///   'myKey',
  ///   defaultValue: 'default',
  /// );
  /// stream.listen((value) {
  ///   print('Current value: $value');
  /// });
  /// ```
  ///
  /// Parameters:
  /// - `key`: The key to subscribe to.
  /// - `defaultValue`: The value to emit if the key is not found. Defaults to
  ///   `null`.
  /// - `domain`: The domain to retrieve the value from. Defaults to
  ///   [AbstractStorage.defaultDomain].
  /// - `keepAlive`: Whether to keep the subject alive after the last subscriber
  ///   has unsubscribed. Defaults to `true`.
  ///
  /// Returns:
  /// - A [Future] that completes with a [ValueStream] emitting the current
  ///   value and any subsequent changes.
  Future<ValueStream<StorageValueType?>> subscribe(
    String key, {
    StorageValueType? defaultValue,
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  });

  /// Subscribes to the key-value pairs map from the specified [domain].
  ///
  /// This method returns a [ValueStream] that emits the current key-value pairs
  /// map from the [domain] and any subsequent changes. The [keepAlive]
  /// parameter determines whether the subject should stay alive after the last
  /// subscriber has unsubscribed, keeping the data in memory instead of
  /// reacquiring it from the storage.
  ///
  /// Example:
  /// ```dart
  /// final stream = await reactiveStorage.subscribeDomain(domain: 'myDomain');
  /// stream.listen((map) {
  ///   print('Current key-value pairs: $map');
  /// });
  /// ```
  ///
  /// Parameters:
  /// - `domain`: The domain to retrieve the key-value pairs from. Defaults to
  ///   [AbstractStorage.defaultDomain].
  /// - `keepAlive`: Whether to keep the subject alive after the last subscriber
  ///   has unsubscribed. Defaults to `true`.
  ///
  /// Returns:
  /// - A [Future] that completes with a [ValueStream] emitting the current
  ///   key-value pairs map and any subsequent changes.
  Future<ValueStream<Map<String, StorageValueType>>> subscribeDomain({
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  });

  /// Subscribes to the keys from the specified [domain].
  ///
  /// This method returns a [ValueStream] that emits the current keys from the
  /// [domain] and any subsequent changes. The [keepAlive] parameter determines
  /// whether the subject should stay alive after the last subscriber has
  /// unsubscribed, keeping the data in memory instead of reacquiring it from
  /// the storage.
  ///
  /// Example:
  /// ```dart
  /// final stream = await reactiveStorage.subscribeDomainKeys(
  ///   domain: 'myDomain',
  /// );
  /// stream.listen((keys) {
  ///   print('Current keys: $keys');
  /// });
  /// ```
  ///
  /// Parameters:
  /// - `domain`: The domain to retrieve the keys from. Defaults to
  ///   [AbstractStorage.defaultDomain].
  /// - `keepAlive`: Whether to keep the subject alive after the last subscriber
  ///   has unsubscribed. Defaults to `true`.
  ///
  /// Returns:
  /// - A [Future] that completes with a [ValueStream] emitting the current keys
  ///   and any subsequent changes.
  Future<ValueStream<List<String>>> subscribeDomainKeys({
    String domain = AbstractStorage.defaultDomain,
    bool keepAlive = true,
  });
}
