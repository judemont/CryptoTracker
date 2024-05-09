import 'package:cryptotracker/models/preferences.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Preferences preferences = Preferences();
  List<String> availableCurrencies = [];
  @override
  void initState() {
    loadSettingsValues();
    getAvailableCurrencies().then((currs) {
      availableCurrencies = currs;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ListView(
          children: [
            ListTile(
                title: const Text("Currency"),
                leading: Icon(Icons.attach_money),
                subtitle: Text(preferences.currency?.toUpperCase() ?? ""),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        children: availableCurrencies
                            .map((e) => ListTile(
                                  title: Text(e.toUpperCase()),
                                  onTap: () {
                                    Database.setValue(
                                        "settings", "currency", e);
                                    loadSettingsValues();
                                    Navigator.of(context).pop();
                                  },
                                ))
                            .toList(),
                      );
                    },
                  );
                })
          ],
        ));
  }

  void loadSettingsValues() {
    setState(() {
      preferences.currency = Database.getValue("settings", "currency") ?? "";
    });
  }
}
