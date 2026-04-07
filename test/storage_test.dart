import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_storage/src/db/storage_database.dart';
import 'package:the_storage/src/storage.dart';

const String testDomainName0 = 'test domain name 0';
final Map<String, StorageValue> testKeyValuePairs0 = {
  for (var id in List<int>.generate(256, (index) => index))
    'key 0: $id': StorageValue('value: 0: $id', 'iv: 0: $id'),
};

final Map<String, StorageValue> testKeyValuePairs0Update = {
  for (var id in List<int>.generate(256, (index) => index))
    'key 0: $id': StorageValue('value: 0: $id update', 'iv: 0: $id update'),
};

final Map<String, StorageValue> testKeyValuePairs1 = {
  for (var id in List<int>.generate(128, (index) => index))
    'key 1: $id': StorageValue('value: 1: $id', 'iv: 1: $id'),
};

final Map<String, StorageValue> testKeyValuePairs2 = {
  for (var id in List<int>.generate(2048, (index) => index))
    'key 2: $id': StorageValue('value: 2: $id', 'iv: 2: $id'),
};

StorageDatabase _createTestDatabase() {
  return StorageDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}

void main() {
  group('Storage can be instantiated', () {
    test('can be instantiated', () {
      expect(Storage(), isNotNull);
    });
  });

  group('Storage db tests', () {
    late StorageDatabase db;

    setUp(() async {
      db = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db);
      await storage.clearAll();
      await storage.dispose();
    });

    tearDown(() async {
      await db.close();
    });

    test('init and check empty', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);
      await storage.dispose();
    });

    test('signle pair set and check in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);

      await storage.set('testKey', const StorageValue('testValue', 'testIv'));
      expect(
        await storage.get('testKey'),
        const StorageValue('testValue', 'testIv'),
      );
      await storage.dispose();
    });

    test('signle pair set, update and check in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);

      await storage.set(
        'testKey',
        const StorageValue('testValue', 'testIv'),
      );
      await storage.set(
        'testKey',
        const StorageValue('testValue updated', 'testIv updated'),
      );
      expect(
        await storage.get('testKey'),
        const StorageValue('testValue updated', 'testIv updated'),
      );
      expect(await storage.getDomain(), hasLength(1));
      await storage.dispose();
    });

    test('signle pair set and delete in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);

      await storage.set(
        'testKey0',
        const StorageValue('testValue0', 'testIv0'),
      );
      await storage.set(
        'testKey1',
        const StorageValue('testValue1', 'testIv1'),
      );
      await storage.set(
        'testKey2',
        const StorageValue('testValue2', 'testIv2'),
      );
      expect(await storage.getDomain(), hasLength(3));

      await storage.delete('testKey1');
      expect(await storage.getDomain(), hasLength(2));
      expect(
        await storage.get('testKey0'),
        const StorageValue('testValue0', 'testIv0'),
      );
      expect(await storage.get('testKey1'), isNull);
      expect(
        await storage.get('testKey2'),
        const StorageValue('testValue2', 'testIv2'),
      );
      await storage.dispose();
    });

    test('signle pair set, NOT update and check in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);

      await storage.set('testKey', const StorageValue('testValue', 'testIv'));
      await storage.set(
        'testKey',
        const StorageValue('testValue0 updated', 'testIv0updated'),
        overwrite: false,
      );
      expect(
        await storage.get('testKey'),
        const StorageValue('testValue', 'testIv'),
      );
      expect(await storage.getDomain(), hasLength(1));
      await storage.dispose();
    });

    test('signle check default value in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);

      expect(await storage.get('testKey'), isNull);
      expect(
        await storage.get(
          'testKey',
          defaultValue: const StorageValue('default value', 'default iv'),
        ),
        const StorageValue('default value', 'default iv'),
      );
      await storage.dispose();
    });

    test('signle pair set and check in custom domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);

      await storage.set(
        'testKey',
        const StorageValue('testValue', 'testIv'),
        domain: testDomainName0,
      );
      expect(await storage.get('testKey'), isNull);
      expect(
        await storage.get('testKey', domain: testDomainName0),
        const StorageValue('testValue', 'testIv'),
      );
      await storage.dispose();
    });

    test('signle check default value in custom domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);

      expect(await storage.get('testKey', domain: testDomainName0), isNull);
      expect(
        await storage.get(
          'testKey',
          domain: testDomainName0,
          defaultValue: const StorageValue('default value', 'default iv'),
        ),
        const StorageValue('default value', 'default iv'),
      );
      await storage.dispose();
    });

    test('separated domain cleaning', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);

      await storage.set(
        'testKey',
        const StorageValue('testValue', 'testIv'),
      );
      await storage.set(
        'testKey',
        const StorageValue('testValue', 'testIv'),
        domain: testDomainName0,
      );

      expect(await storage.getDomain(), hasLength(1));
      expect(await storage.getDomain(domain: testDomainName0), hasLength(1));

      await storage.clearDomain(testDomainName0);
      expect(await storage.getDomain(), hasLength(1));
      expect(await storage.getDomain(domain: testDomainName0), hasLength(0));

      await storage.clearDomain();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);
      await storage.dispose();
    });

    test('multiple pairs set and check in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomainKeys(), isEmpty);

      await storage.setDomain(testKeyValuePairs0);
      expect(
        await storage.getDomain(),
        hasLength(testKeyValuePairs0.length),
      );
      expect(
        await storage.getDomainKeys(),
        hasLength(testKeyValuePairs0.length),
      );
      expect(await storage.getDomain(), testKeyValuePairs0);
      expect(
        (await storage.getDomainKeys())..sort(),
        testKeyValuePairs0.keys.toList()..sort(),
      );
      for (final pair in testKeyValuePairs0.entries) {
        expect(await storage.get(pair.key), pair.value);
      }
      await storage.dispose();
    });

    test('multiple pairs set, update and check in default domain', () async {
      final db2 = _createTestDatabase();
      final storage = Storage();
      await storage.init('storage_test.db', db2);
      await storage.clearAll();
      expect(await storage.getDomain(), isEmpty);

      await storage.setDomain(testKeyValuePairs0);
      await storage.setDomain(testKeyValuePairs0Update);
      expect(await storage.getDomain(), hasLength(testKeyValuePairs0.length));
      expect(await storage.getDomain(), testKeyValuePairs0Update);
      await storage.dispose();
    });

    test(
      'multiple pairs set, NOT update and check in default domain',
      () async {
        final db2 = _createTestDatabase();
        final storage = Storage();
        await storage.init('storage_test.db', db2);
        await storage.clearAll();
        expect(await storage.getDomain(), isEmpty);

        await storage.setDomain(testKeyValuePairs0);
        await storage.setDomain(testKeyValuePairs0Update, overwrite: false);
        expect(await storage.getDomain(), hasLength(testKeyValuePairs0.length));
        expect(await storage.getDomain(), testKeyValuePairs0);
        await storage.dispose();
      },
    );

    test(
      'multiple pairs set, update, append and check in default domain',
      () async {
        final db2 = _createTestDatabase();
        final storage = Storage();
        await storage.init('storage_test.db', db2);
        await storage.clearAll();
        expect(await storage.getDomain(), isEmpty);

        await storage.setDomain(testKeyValuePairs0);
        await storage.setDomain(testKeyValuePairs0Update);
        await storage.setDomain(testKeyValuePairs1);
        expect(
          await storage.getDomain(),
          hasLength(
            testKeyValuePairs0.length + testKeyValuePairs1.length,
          ),
        );
        expect(
          await storage.getDomain(),
          {
            ...testKeyValuePairs0Update,
            ...testKeyValuePairs1,
          },
        );
        await storage.dispose();
      },
    );

    test(
      'multiple pairs set, append and partially delete in default domain',
      () async {
        final db2 = _createTestDatabase();
        final storage = Storage();
        await storage.init('storage_test.db', db2);
        await storage.clearAll();
        expect(await storage.getDomain(), isEmpty);

        await storage.setDomain(testKeyValuePairs0);
        await storage.setDomain(testKeyValuePairs1);
        expect(
          await storage.getDomain(),
          hasLength(
            testKeyValuePairs0.length + testKeyValuePairs1.length,
          ),
        );
        await storage.deleteDomain(List.from(testKeyValuePairs0.keys));
        expect(
          await storage.getDomain(),
          hasLength(
            testKeyValuePairs1.length,
          ),
        );
        expect(
          await storage.getDomain(),
          {
            ...testKeyValuePairs1,
          },
        );
        await storage.dispose();
      },
    );

    test(
      'huge pair list delete test (query splitting) in default domain',
      () async {
        final db2 = _createTestDatabase();
        final storage = Storage();
        await storage.init('storage_test.db', db2);
        await storage.clearAll();
        expect(await storage.getDomain(), isEmpty);

        await storage.setDomain(testKeyValuePairs2);
        expect(
          await storage.getDomain(),
          hasLength(testKeyValuePairs2.length),
        );
        await storage.deleteDomain(List.from(testKeyValuePairs2.keys));
        expect(await storage.getDomain(), isEmpty);
        await storage.dispose();
      },
    );
  });
}
