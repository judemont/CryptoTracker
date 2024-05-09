import 'dart:io';

import 'package:hive/hive.dart';

class Database {
  static Future<void> initBoxs() async {
    var path = Directory.current.path;
    Hive.init(path);
    const List<String> hiveBoxsNames = ["settings"];

    for (var boxName in hiveBoxsNames) {
      await Hive.openBox(boxName);
    }
  }

  static void addDefaultValues() {
    Box settingsBox = Hive.box("settings");
    settingsBox.put("currency", "usd");
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
