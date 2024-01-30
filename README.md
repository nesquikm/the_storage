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
TheStorage.i().set('myKey', 'myValue', domain: 'myDomain');
final data = await TheStorage.i().get('myKey', domain: 'myDomain');
```

Also you can use batch operations to read write multiple key-value pairs, clear a whole database or domain. Just check documentation for `TheStorage` class.

## Testing

This package includes several unit tests for its features. To run the tests, use the following command:

```bash
flutter test
```
