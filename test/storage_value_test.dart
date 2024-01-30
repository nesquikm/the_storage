import 'package:flutter_test/flutter_test.dart';
import 'package:the_storage/src/storage.dart';

void main() {
  group('StorageValue', () {
    test('can be instantiated', () async {
      expect(const StorageValue('', ''), isNotNull);
    });

    test('comparable test', () async {
      expect(
        const StorageValue('', ''),
        equals(const StorageValue('', '')),
      );
      expect(
        const StorageValue('a', 'b'),
        equals(const StorageValue('a', 'b')),
      );
      expect(
        const StorageValue('a', 'b'),
        isNot(const StorageValue('a', 'c')),
      );
      expect(
        const StorageValue('a', 'b'),
        isNot(const StorageValue('c', 'b')),
      );
    });
  });
}
