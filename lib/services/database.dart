import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Database {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    const List<String> hiveBoxsNames = ["settings", "portfolio"];

    for (var boxName in hiveBoxsNames) {
      await Hive.openBox(boxName);
    }
  }

  static void addDefaultValues() {
    Box settingsBox = Hive.box("settings");
    if (settingsBox.get("currencyId") == null) {
      settingsBox.put("currencyId", "yhjMzLPhuIDl");
    }
    if (settingsBox.get("currencySymbol") == null) {
      settingsBox.put("currencySymbol", "USD");
    }
    if (settingsBox.get("theme") == null) {
      settingsBox.put("theme", "system");
    }
    Box portfolioBox = Hive.box("portfolio");
    if (portfolioBox.get("favoritesIds") == null) {
      portfolioBox.put("favoritesIds", []);
    }
  }

  static void resetAll(String boxName) {
    Box box = Hive.box(boxName);
    box.clear();
  }

  static void setValue(String boxName, String key, dynamic value) {
    Box box = Hive.box(boxName);
    box.put(key, value);
  }

  static dynamic getValue(String boxName, String key) {
    Box box = Hive.box(boxName);
    var value = box.get(key);
    return value;
  }

  static void removeValue(String boxName, String key) {
    Box box = Hive.box(boxName);
    box.delete(key);
  }
}
