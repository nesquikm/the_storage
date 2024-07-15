import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:the_storage/the_storage.dart';

const dbName = 'reactive_test.db';

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

  group('Reactive tests: keepAlive', () {
    test('reactive test keep keepAlive', () async {
      final storage = TheStorage.i();

      await expectLater(
        await storage.subscribe('testKey'),
        await storage.subscribe('testKey'),
      );

      await expectLater(
        await storage.subscribeDomain(),
        await storage.subscribeDomain(),
      );

      await expectLater(
        await storage.subscribeDomainKeys(),
        await storage.subscribeDomainKeys(),
      );
    });

    test('reactive test create keepAlive after not keepAlive', () async {
      final storage = TheStorage.i();

      await expectLater(
        await storage.subscribe('testKey', keepAlive: false),
        isNot(await storage.subscribe('testKey')),
      );

      await expectLater(
        await storage.subscribeDomain(keepAlive: false),
        isNot(await storage.subscribeDomain()),
      );

      await expectLater(
        await storage.subscribeDomainKeys(keepAlive: false),
        isNot(await storage.subscribeDomainKeys()),
      );
    });

    test('reactive test create not keepAlive after keepAlive', () async {
      final storage = TheStorage.i();

      await expectLater(
        await storage.subscribe('testKey'),
        isNot(await storage.subscribe('testKey', keepAlive: false)),
      );

      await expectLater(
        await storage.subscribeDomain(),
        isNot(await storage.subscribeDomain(keepAlive: false)),
      );

      await expectLater(
        await storage.subscribeDomainKeys(),
        isNot(await storage.subscribeDomainKeys(keepAlive: false)),
      );
    });

    test('reactive test keep not keepAlive after not keepAlive', () async {
      final storage = TheStorage.i();

      await expectLater(
        await storage.subscribe('testKey', keepAlive: false),
        await storage.subscribe('testKey', keepAlive: false),
      );

      await expectLater(
        await storage.subscribeDomain(keepAlive: false),
        await storage.subscribeDomain(keepAlive: false),
      );

      await expectLater(
        await storage.subscribeDomainKeys(keepAlive: false),
        await storage.subscribeDomainKeys(keepAlive: false),
      );
    });

    test('reactive test create not keepAlive after cancelled not keepAlive',
        () async {
      final storage = TheStorage.i();

      final s = await storage.subscribe('testKey', keepAlive: false);
      await s.listen((_) {}).cancel();

      expect(
        s,
        isNot(await storage.subscribe('testKey', keepAlive: false)),
      );

      final sd = await storage.subscribeDomain(keepAlive: false);
      await sd.listen((_) {}).cancel();

      await expectLater(
        sd,
        isNot(await storage.subscribeDomain(keepAlive: false)),
      );

      final sdk = await storage.subscribeDomainKeys(keepAlive: false);
      await sdk.listen((_) {}).cancel();

      await expectLater(
        sdk,
        isNot(await storage.subscribeDomainKeys(keepAlive: false)),
      );
    });
  });

  group('Reactive tests: subscriptions', () {
    test('reactive init and check empty', () async {
      final storage = TheStorage.i();

      await expectLater(
        await storage.subscribe('testKey'),
        emits(null),
      );

      await expectLater(
        await storage.subscribeDomain(),
        emits(<String, String>{}),
      );

      await expectLater(
        await storage.subscribeDomain(domain: testDomainName0),
        emits(<String, String>{}),
      );

      await expectLater(
        await storage.subscribeDomainKeys(),
        emits([]),
      );

      await expectLater(
        await storage.subscribeDomainKeys(domain: testDomainName0),
        emits([]),
      );
    });

    test('reactive signle pair set and check', () async {
      final storage = TheStorage.i();

      await storage.set('testKey', 'testValue');

      await expectLater(
        await storage.subscribe('testKey'),
        emits('testValue'),
      );
    });

    test('reactive signle pair set and check, keepAlive = false', () async {
      final storage = TheStorage.i();

      await storage.set('testKey', 'testValue');

      final s = await storage.subscribe('testKey', keepAlive: false);
      await expectLater(
        s,
        emits('testValue'),
      );

      await s.listen((_) {}).cancel();

      final s1 = await storage.subscribe('testKey', keepAlive: false);
      await expectLater(
        s1,
        emits('testValue'),
      );
    });

    test('reactive subsciption test: stream order, set', () async {
      final storage = TheStorage.i();

      final other = OtherSubsciptions.createOther(storage);

      final subscription = await storage.subscribe('testKey');
      final subscriptionExpecter = expectLater(
        subscription,
        emitsInOrder([
          null,
          'testValue',
          'testValue2',
        ]),
      );

      final subscriptionDomain = await storage.subscribeDomain();
      final subscriptionDomainExpecter = expectLater(
        subscriptionDomain,
        emitsInOrder([
          <String, String>{},
          {'testKey': 'testValue'},
          {'testKey': 'testValue2'},
          {'testKey': 'testValue2', 'testKey2': 'testValue2'},
        ]),
      );

      final subscriptionDomainKeys = await storage.subscribeDomainKeys();
      final subscriptionDomainKeysExpecter = expectLater(
        subscriptionDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          <String>{},
          {'testKey'},
          {'testKey'},
          {'testKey', 'testKey2'},
        ]),
      );

      await storage.set('testKey', 'testValue');
      await storage.set('testKey', 'testValue2');
      await storage.set('testKey', 'testValue3', domain: testDomainName0);
      await storage.set('testKey2', 'testValue2');

      await other;

      await subscriptionExpecter;
      await subscriptionDomainExpecter;
      await subscriptionDomainKeysExpecter;
    });

    test('reactive subsciption test: stream order, setDomain', () async {
      final storage = TheStorage.i();

      final other = OtherSubsciptions.createOther(storage);

      final subscription = await storage.subscribe('testKey');
      final subscriptionExpecter = expectLater(
        subscription,
        emitsInOrder([
          null,
          'testValue',
          'testValue2',
        ]),
      );

      final subscriptionDomain = await storage.subscribeDomain();
      final subscriptionDomainExpecter = expectLater(
        subscriptionDomain,
        emitsInOrder([
          <String, String>{},
          {'testKey': 'testValue'},
          {'testKey': 'testValue2'},
          {'testKey': 'testValue2', 'testKey2': 'testValue2'},
          {
            'testKey': 'testValue2',
            'testKey4': 'testValue4',
            'testKey2': 'testValue2',
          },
        ]),
      );

      final subscriptionDomainKeys = await storage.subscribeDomainKeys();
      final subscriptionDomainKeysExpecter = expectLater(
        subscriptionDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          <String>{},
          {'testKey'},
          {'testKey'},
          {'testKey', 'testKey2'},
          {'testKey', 'testKey2', 'testKey4'},
        ]),
      );

      await storage.setDomain({'testKey': 'testValue'});
      await storage.setDomain({'testKey': 'testValue2'});
      await storage
          .setDomain({'testKey': 'testValue3'}, domain: testDomainName0);
      await storage.setDomain({'testKey2': 'testValue2'});
      await storage
          .setDomain({'testKey2': 'testValue2', 'testKey4': 'testValue4'});

      await other;

      await subscriptionExpecter;
      await subscriptionDomainExpecter;
      await subscriptionDomainKeysExpecter;
    });

    test('reactive subsciption test: stream order, delete', () async {
      final storage = TheStorage.i();

      final other = OtherSubsciptions.createOther(storage);

      await storage.set('testKey', 'testValue');
      await storage.set('testKey', 'testValue3', domain: testDomainName0);
      await storage.set('testKey2', 'testValue2');

      final subscription = await storage.subscribe('testKey');
      final subscriptionExpecter = expectLater(
        subscription,
        emitsInOrder([
          'testValue',
          null,
        ]),
      );

      final subscriptionDomain = await storage.subscribeDomain();
      final subscriptionDomainExpecter = expectLater(
        subscriptionDomain,
        emitsInOrder([
          {'testKey': 'testValue', 'testKey2': 'testValue2'},
          {'testKey2': 'testValue2'},
          <String, String>{},
        ]),
      );

      final subscriptionDomainKeys = await storage.subscribeDomainKeys();
      final subscriptionDomainKeysExpecter = expectLater(
        subscriptionDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          {'testKey', 'testKey2'},
          {'testKey2'},
          <String>{},
        ]),
      );

      await storage.delete('testKey');
      await storage.delete('testKey', domain: testDomainName0);
      await storage.delete('testKey2');

      await other;

      await subscriptionExpecter;
      await subscriptionDomainExpecter;
      await subscriptionDomainKeysExpecter;
    });

    test('reactive subsciption test: stream order, deleteDomain', () async {
      final storage = TheStorage.i();

      final other = OtherSubsciptions.createOther(storage);

      await storage.setDomain({
        'testKey1': 'testValue1',
        'testKey2': 'testValue2',
        'testKey3': 'testValue3',
      });
      await storage.setDomain(
        {
          'testKey1': 'testValue1',
          'testKey2': 'testValue2',
          'testKey3': 'testValue3',
        },
        domain: testDomainName0,
      );

      final subscription = await storage.subscribe('testKey1');
      final subscriptionExpecter = expectLater(
        subscription,
        emitsInOrder([
          'testValue1',
        ]),
      );

      final subscriptionDomain = await storage.subscribeDomain();
      final subscriptionDomainExpecter = expectLater(
        subscriptionDomain,
        emitsInOrder([
          {
            'testKey1': 'testValue1',
            'testKey2': 'testValue2',
            'testKey3': 'testValue3',
          },
          {
            'testKey1': 'testValue1',
          },
        ]),
      );

      final subscriptionSecondDomain =
          await storage.subscribeDomain(domain: testDomainName0);
      final subscriptionSecondDomainExpecter = expectLater(
        subscriptionSecondDomain,
        emitsInOrder([
          {
            'testKey1': 'testValue1',
            'testKey2': 'testValue2',
            'testKey3': 'testValue3',
          },
          {
            'testKey3': 'testValue3',
          },
        ]),
      );

      final subscriptionDomainKeys = await storage.subscribeDomainKeys();
      final subscriptionDomainKeysExpecter = expectLater(
        subscriptionDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          {'testKey1', 'testKey2', 'testKey3'},
          {'testKey1'},
        ]),
      );

      final subscriptionSecondDomainKeys =
          await storage.subscribeDomainKeys(domain: testDomainName0);
      final subscriptionSecondDomainKeysExpecter = expectLater(
        subscriptionSecondDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          {'testKey1', 'testKey2', 'testKey3'},
          {'testKey3'},
        ]),
      );

      await storage.deleteDomain(['testKey2', 'testKey3']);
      await storage
          .deleteDomain(['testKey1', 'testKey2'], domain: testDomainName0);

      await other;

      await subscriptionExpecter;
      await subscriptionDomainExpecter;
      await subscriptionSecondDomainExpecter;
      await subscriptionDomainKeysExpecter;
      await subscriptionSecondDomainKeysExpecter;
    });

    test('reactive subsciption test: stream order, clearDomain', () async {
      final storage = TheStorage.i();

      final other = OtherSubsciptions.createOther(storage);

      await storage.setDomain({
        'testKey1': 'testValue1',
        'testKey2': 'testValue2',
        'testKey3': 'testValue3',
      });
      await storage.setDomain(
        {
          'testKey1': 'testValue1',
          'testKey2': 'testValue2',
          'testKey3': 'testValue3',
        },
        domain: testDomainName0,
      );

      final subscription = await storage.subscribe('testKey1');
      final subscriptionExpecter = expectLater(
        subscription,
        emitsInOrder([
          'testValue1',
          null,
        ]),
      );

      final subscriptionDomain = await storage.subscribeDomain();
      final subscriptionDomainExpecter = expectLater(
        subscriptionDomain,
        emitsInOrder([
          {
            'testKey1': 'testValue1',
            'testKey2': 'testValue2',
            'testKey3': 'testValue3',
          },
          <String, String>{},
        ]),
      );

      final subscriptionSecondDomain =
          await storage.subscribeDomain(domain: testDomainName0);
      final subscriptionSecondDomainExpecter = expectLater(
        subscriptionSecondDomain,
        emitsInOrder([
          {
            'testKey1': 'testValue1',
            'testKey2': 'testValue2',
            'testKey3': 'testValue3',
          },
          <String, String>{},
        ]),
      );

      final subscriptionDomainKeys = await storage.subscribeDomainKeys();
      final subscriptionDomainKeysExpecter = expectLater(
        subscriptionDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          {'testKey1', 'testKey2', 'testKey3'},
          <String>{},
        ]),
      );

      final subscriptionSecondDomainKeys =
          await storage.subscribeDomainKeys(domain: testDomainName0);
      final subscriptionSecondDomainKeysExpecter = expectLater(
        subscriptionSecondDomainKeys.asyncMap(Set.of),
        emitsInOrder([
          {'testKey1', 'testKey2', 'testKey3'},
          <String>{},
        ]),
      );

      await storage.clearDomain();
      await storage.clearDomain(testDomainName0);

      await other;

      await subscriptionExpecter;
      await subscriptionDomainExpecter;
      await subscriptionSecondDomainExpecter;
      await subscriptionDomainKeysExpecter;
      await subscriptionSecondDomainKeysExpecter;
    });
  });
}

class OtherSubsciptions {
  OtherSubsciptions._();

  static Future<void> createOther(TheStorage storage) async {
    final sOther1 = await storage.subscribe('testKey42');
    final sOther1Expecter = expectLater(
      sOther1,
      emitsInOrder([
        null,
      ]),
    );

    final sOther2 =
        await storage.subscribe('testKey69', domain: testDomainName0);
    final sOther2Expecter = expectLater(
      sOther2,
      emitsInOrder([
        null,
      ]),
    );

    final sOther3 = await storage.subscribeDomain(domain: 'other domain');
    final sOther3Expecter = expectLater(
      sOther3,
      emitsInOrder([
        <String, String>{},
      ]),
    );

    final sOther4 = await storage.subscribeDomainKeys(domain: 'other domain');
    final sOther4Expecter = expectLater(
      sOther4,
      emitsInOrder([
        <String>{},
      ]),
    );

    await Future.wait(
      [
        sOther1Expecter,
        sOther2Expecter,
        sOther3Expecter,
        sOther4Expecter,
      ],
    );
  }
}
