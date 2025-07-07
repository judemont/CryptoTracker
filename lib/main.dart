import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/services/alert_service.dart';
import 'package:flutter/material.dart';
import 'pages_layout.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  SettingsDb.init().then((value) {
    SettingsDb.addDefaultValues();
    AlertService.initialize().then((_) {
      AlertService.requestPermissions();
      AlertService.startMonitoring();
    });
    runApp(
      const MyApp(),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    updateTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CryptoTracker',
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const PagesLayout(currentSection: 0),
    );
  }

  void updateTheme() {
    String dataThemeMode = SettingsDb.getValue("settings", "theme");
    switch (dataThemeMode) {
      case "dark":
        setState(() {
          _themeMode = ThemeMode.dark;
        });
        break;
      case "light":
        setState(() {
          _themeMode = ThemeMode.light;
        });
        break;
      case "system":
        setState(() {
          _themeMode = ThemeMode.system;
        });
        break;
    }
  }
}
