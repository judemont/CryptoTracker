import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class Database {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    const List<String> hiveBoxsNames = ["settings"];

    for (var boxName in hiveBoxsNames) {
      await Hive.openBox(boxName);
    }
  }

  static void addDefaultValues() {
    Box settingsBox = Hive.box("settings");
    if (settingsBox.get("currency") == null) {
      settingsBox.put("currency", "usd");
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
}
