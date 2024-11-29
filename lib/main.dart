import 'package:cryptotracker/services/settingsDB.dart';
import 'package:flutter/material.dart';
import 'pages_layout.dart';
import 'screens/home.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  SettingsDb.init().then((value) {
    SettingsDb.addDefaultValues();
    runApp(const MyApp());
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
        theme: FlexThemeData.light(
          scheme: FlexScheme.materialBaseline,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 7,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 10,
            blendOnColors: false,
            useTextTheme: true,
            useM2StyleDividerInM3: true,
            alignedDropdown: true,
            useInputDecoratorThemeInDialogs: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.materialBaseline,
          surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
          blendLevel: 13,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 20,
            useTextTheme: true,
            useM2StyleDividerInM3: true,
            alignedDropdown: true,
            useInputDecoratorThemeInDialogs: true,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          swapLegacyOnMaterial3: true,
          // To use the Playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        home: const PagesLayout(child: Home()));
  }

  void updateTheme() {
    String dataThemeMode = SettingsDb.getValue("settings", "theme");
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
