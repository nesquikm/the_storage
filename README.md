# TheStorage

A fast and secure storage library for Flutter.

## Features

- Fast and efficient storage operations
- Secure data encryption
- Easy-to-use API

## Getting started

To use this package, add `the_storage` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

## Usage

Import the package:

```dart
import 'package:the_storage/the_storage.dart';
```

Get an instance of the logger and initialize it:

```dart
TheStorage.i().init();
```

TheStorage is a singleton, so you can get the same instance anywhere in your app:

```dart
instance = TheStorage.i();
```

You can specify file name for storage:

```dart
TheStorage.i().init(dbName: 'my_storage.db');
```

This should be done as early as possible in your app, and only once. Before calling `init()` second time, you should call `dispose()` method.

To write key-value pair to storage, use the `set()` method:

```dart
TheStorage.i().set('myKey', 'myValue');
```

To read value from storage, use the `get()` method:

```dart
final data = await TheStorage.i().get('myKey');
```

You can use domains to separate your data. To write key-value pair to storage with domain, use the `domain` argument:

```dart
await TheStorage.i().set('myKey', 'myValue', domain: 'myDomain');
final data = await TheStorage.i().get('myKey', domain: 'myDomain');
```

Additionally you can delete key-value pair from storage:

```dart
await TheStorage.i().delete(
  'myKey',
  domain: 'myDomain',
);
```

Also you can use batch operations to write multiple key-value pairs in domain, specify domain and whether to overwrite existing values:

```dart
await TheStorage.i().setDomain(
  {
    'myKey': 'myValue',
    'myKey2': 'myValue2',
  },
  domain: 'myDomain',
  overwrite: false,
);
```

Read all key-value pairs or only keys from domain:

```dart
final data = await TheStorage.i().getDomain(
  domain: 'myDomain',
);

final keys = await TheStorage.i().getDomainKeys(
  domain: 'myDomain',
);
```

And delete data from domain:

```dart
await TheStorage.i().deleteDomain(
  [
    'myKey',
    'myKey2',
  ],
  domain: 'myDomain',
);
```

You can clear all data from storage:

```dart
await TheStorage.i().clear();
```

For debugging purposes you can reset storage, it will delete storage file and dispose storage instance. So, you should call `init()` method again after reset:

```dart
await TheStorage.i().reset();
```

## Encryption

TheStorage stores key and initial vector using [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) package. Every record key is encrypted using AES with 256-bit key and 128-bit initial vector. To encrypt the record data, the same 256-bit key and a unique (for each record) 128-bit seed vector are used, which is stored with the encrypted data. So, every record has its own initial vector. This approach makes impossible replay attacks by comparing encrypted data with already known source data.

## Storage

TheStorage uses [sqflite](https://pub.dev/packages/sqflite) package to store data. This is a fast and reliable solution for storing data on the device. TheStorage uses a single table to store all data and indexes to speed up data search.

## Testing

This package includes several unit tests for its features. To run the tests, use the following command:

```bash
flutter test
```
