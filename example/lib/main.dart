// This is an example app, so we don't need public member API docs.
// ignore_for_file: public_member_api_docs

import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:the_storage/the_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheStorage Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    TheStorage.i().init();
  }

  @override
  void dispose() {
    TheStorage.i().dispose();
    super.dispose();
  }

  Future<void> writeDb() async {
    await TheStorage.i().set('myKey', 'myValue');
    developer.log("write to DB: myKey: 'myValue'");
  }

  Future<void> readDb() async {
    developer
        .log("read from DB: myKey: '${await TheStorage.i().get('myKey')}'");
  }

  Future<void> clearDb() async {
    await TheStorage.i().clearAll();
    developer.log('clear DB');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: writeDb,
              child: const Text('Write to DB'),
            ),
            ElevatedButton(
              onPressed: readDb,
              child: const Text('Read from DB'),
            ),
            ElevatedButton(
              onPressed: clearDb,
              child: const Text('Clear DB'),
            ),
          ],
        ),
      ),
    );
  }
}
