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

  @override
  void initState() {
    loadSettingsValues();
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
                trailing: Text(preferences.currency ?? ""),
                onTap: () {
                  getAvailableCurrencies().then((curr) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ListView(
                          children: curr
                              .map((e) => ListTile(
                                    title: Text(e),
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
                  });
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
