import 'package:cryptotracker/main.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String currency = "";
  String theme = "";

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
              title: const Text("Theme"),
              leading: const Icon(Icons.color_lens),
              subtitle: Text(theme.toCapitalized()),
              onTap: () {
                showModalBottomSheet(
                    elevation: 0,
                    context: context,
                    builder: (context) {
                      return Wrap(
                        children: [
                          ListTile(
                            title: const Text("Light"),
                            leading: const Icon(Icons.light_mode),
                            onTap: () {
                              Database.setValue("settings", "theme", "light");
                              loadSettingsValues();
                              MyApp.of(context)!.updateTheme();
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: const Text("Dark"),
                            leading: const Icon(Icons.dark_mode),
                            onTap: () {
                              Database.setValue("settings", "theme", "dark");
                              loadSettingsValues();
                              MyApp.of(context)!.updateTheme();

                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            title: const Text("System"),
                            leading: const Icon(Icons.settings),
                            onTap: () {
                              Database.setValue("settings", "theme", "system");
                              loadSettingsValues();
                              MyApp.of(context)!.updateTheme();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
            ListTile(
                title: const Text("Currency"),
                leading: const Icon(Icons.attach_money),
                subtitle: Text(currency.toUpperCase()),
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
                }),
          ],
        ));
  }

  void loadSettingsValues() {
    setState(() {
      currency = Database.getValue("settings", "currency") ?? "";
      theme = Database.getValue("settings", "theme") ?? "";
    });
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
