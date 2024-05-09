import 'dart:io';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'pages_layout.dart';
import 'screens/home.dart';

import 'theme.dart';

Future<void> main() async {
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
  Database.initBoxs().then((value) {
    Database.addDefaultValues();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'CryptoTracker',
        theme: catppuccinTheme(catppuccin.macchiato),
        home: const PagesLayout(child: Home()));
  }
}
