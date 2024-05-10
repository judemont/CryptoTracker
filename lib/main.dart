import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';
import 'pages_layout.dart';
import 'screens/home.dart';

import 'theme.dart';

void main() {
  Database.init().then((value) {
    Database.addDefaultValues();
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
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
        theme: catppuccinTheme(catppuccin.latte),
        darkTheme: catppuccinTheme(catppuccin.macchiato),
        home: const PagesLayout(child: Home()));
  }

  void updateTheme() {
    String dataThemeMode = Database.getValue("settings", "theme");
    switch (dataThemeMode) {
      case "dark":
        setState(() {
          _themeMode = ThemeMode.dark;
        });
      case "light":
        setState(() {
          _themeMode = ThemeMode.light;
        });
      case "system":
        setState(() {
          _themeMode = ThemeMode.system;
        });
    }
  }
}
