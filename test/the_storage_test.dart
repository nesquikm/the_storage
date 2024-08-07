import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:the_storage/the_storage.dart';

const dbName = 'the_storage_test.db';

const String testDomainName0 = 'test domain name 0';
final Map<String, String> testKeyValuePairs0 = {
  for (var id in List<int>.generate(256, (index) => index))
    'key 0: $id': 'value: 0: $id',
};

final Map<String, String> testKeyValuePairs0Update = {
  for (var id in List<int>.generate(256, (index) => index))
    'key 0: $id': 'value: 0: $id update',
};

final Map<String, String> testKeyValuePairs1 = {
  for (var id in List<int>.generate(128, (index) => index))
    'key 1: $id': 'value: 0: $id',
};

void main() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory, do not use isolate here
  databaseFactory = databaseFactoryFfiNoIsolate;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await TheStorage.i().init(dbName);
    await TheStorage.i().clearAll();
  });

  tearDown(
    () async {
      await TheStorage.i().reset();
    },
  );

  group('TheStorage can be instantiated', () {
    test('can be instantiated', () async {
      final storage = TheStorage.i();
      expect(storage, isNotNull);
    });
  });

  group('TheStorage db tests', () {
    test('init and check empty', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);
    });

    test('signle pair set and check in default domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      await storage.set('testKey', 'testValue');
      expect(await storage.get('testKey'), 'testValue');
    });

    test('signle pair set, update and check in default domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      await storage.set('testKey', 'testValue');
      await storage.set('testKey', 'testValue updated');
      expect(await storage.get('testKey'), 'testValue updated');
      expect(await storage.getDomain(), hasLength(1));
    });

    test('signle pair set and delete in default domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      await storage.set('testKey0', 'testValue0');
      await storage.set('testKey1', 'testValue1');
      await storage.set('testKey2', 'testValue2');
      expect(await storage.getDomain(), hasLength(3));

      await storage.delete('testKey1');
      expect(await storage.getDomain(), hasLength(2));
      expect(await storage.get('testKey0'), 'testValue0');
      expect(await storage.get('testKey1'), isNull);
      expect(await storage.get('testKey2'), 'testValue2');
    });

    test('signle pair set, NOT update and check in default domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      await storage.set('testKey', 'testValue');
      await storage.set('testKey', 'testValue updated', overwrite: false);
      expect(await storage.get('testKey'), 'testValue');
      expect(await storage.getDomain(), hasLength(1));
    });

    test('signle check default value in default domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      expect(await storage.get('testKey'), isNull);
      expect(
        await storage.get('testKey', defaultValue: 'default value'),
        'default value',
      );
    });

    test('signle pair set and check in custom domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);

      await storage.set('testKey', 'testValue', domain: testDomainName0);
      expect(await storage.get('testKey'), isNull);
      expect(
        await storage.get('testKey', domain: testDomainName0),
        'testValue',
      );
    });

    test('signle check default value in custom domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);

      expect(await storage.get('testKey', domain: testDomainName0), isNull);
      expect(
        await storage.get(
          'testKey',
          domain: testDomainName0,
          defaultValue: 'default value',
        ),
        'default value',
      );
    });

    test('separated domain cleaning', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);

      await storage.set('testKey', 'testValue');
      await storage.set('testKey', 'testValue', domain: testDomainName0);

      expect(await storage.getDomain(), hasLength(1));
      expect(await storage.getDomain(domain: testDomainName0), hasLength(1));

      await storage.clearDomain(testDomainName0);
      expect(await storage.getDomain(), hasLength(1));
      expect(await storage.getDomain(domain: testDomainName0), hasLength(0));

      await storage.clearDomain();
      expect(await storage.getDomain(), isEmpty);
      expect(await storage.getDomain(domain: testDomainName0), isEmpty);
    });

    test('multiple pairs set and check in default domain', () async {
      final storage = TheStorage.i();
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
    });

    test('multiple pairs set, update and check in default domain', () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      await storage.setDomain(testKeyValuePairs0);
      await storage.setDomain(testKeyValuePairs0Update);
      expect(await storage.getDomain(), hasLength(testKeyValuePairs0.length));
      expect(await storage.getDomain(), testKeyValuePairs0Update);
    });

    test('multiple pairs set, NOT update and check in default domain',
        () async {
      final storage = TheStorage.i();
      expect(await storage.getDomain(), isEmpty);

      await storage.setDomain(testKeyValuePairs0);
      await storage.setDomain(testKeyValuePairs0Update, overwrite: false);
      expect(await storage.getDomain(), hasLength(testKeyValuePairs0.length));
      expect(await storage.getDomain(), testKeyValuePairs0);
    });

    test('multiple pairs set, update, append and check in default domain',
        () async {
      final storage = TheStorage.i();
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
    });

    test('multiple pairs set, append and partially delete in default domain',
        () async {
      final storage = TheStorage.i();
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
    });
  });

  group('TheStorage multiple init/reset', () {
    test(
      'correct data after dispose and init',
      () async {
        await TheStorage.i().set('testKey', 'testValue');
        expect(await TheStorage.i().get('testKey'), 'testValue');
        expect(await TheStorage.i().getDomainKeys(), hasLength(1));

        await TheStorage.i().dispose();

        await TheStorage.i().init(dbName);
        expect(await TheStorage.i().get('testKey'), 'testValue');
        expect(await TheStorage.i().getDomainKeys(), hasLength(1));
      },
    );

    test(
      'correct data after dispose and init, then reset db, init and check',
      () async {
        await TheStorage.i().set('testKey', 'testValue');
        expect(await TheStorage.i().get('testKey'), 'testValue');

        await TheStorage.i().dispose();

        await TheStorage.i().init(dbName);
        expect(await TheStorage.i().get('testKey'), 'testValue');
        expect(await TheStorage.i().getDomainKeys(), hasLength(1));

        await TheStorage.i().reset();

        await TheStorage.i().init(dbName);
        expect(await TheStorage.i().get('testKey'), null);
        expect(await TheStorage.i().getDomainKeys(), isEmpty);
      },
    );
  });
}
