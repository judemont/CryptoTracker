import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';
import 'pages_layout.dart';
import 'screens/home.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

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
          // To use the Playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
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
