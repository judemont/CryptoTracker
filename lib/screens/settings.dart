import 'package:cryptotracker/main.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/currency.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String currency = "";
  String theme = "";

  List<Currency> availableCurrencies = [];
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
        body: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Options",
              style: TextStyle(fontSize: 20),
            ),
            ListTile(
              title: const Text("Theme"),
              leading: const Icon(Icons.color_lens),
              subtitle: Text(theme.toCapitalized()),
              onTap: () {
                showModalBottomSheet(
                    elevation: 0,
                    context: context,
                    builder: (context) {
                      return ListView(
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
                                  title: Text(
                                      "${e.name ?? ""} (${e.symbol ?? ""})"),
                                  leading: e.iconUrl == null
                                      ? const Icon(Icons.monetization_on)
                                      : Container(
                                          width: 30,
                                          height: 30,
                                          child: getCoinLogoWidget(
                                              e.iconUrl ?? "")),
                                  onTap: () {
                                    Database.setValue(
                                        "settings", "currency", e.symbol);
                                    loadSettingsValues();
                                    Navigator.of(context).pop();
                                  },
                                ))
                            .toList(),
                      );
                    },
                  );
                }),
            const Text(
              "About",
              style: TextStyle(fontSize: 20),
            ),
            ListTile(
              title: const Text("Source Code"),
              leading: const Icon(Icons.code),
              subtitle: const Text("github.com/judemont/CryptoTracker"),
              onTap: () => launchUrl(
                  Uri.parse("https://github.com/judemont/CryptoTracker")),
            ),
            ListTile(
              title: const Text("Rate CryptoTracker on Google Play"),
              leading: const Icon(Icons.star),
              subtitle: const Text(
                  "play.google.com/store/apps/details?id=jdm.apps.cryptotracker"),
              onTap: () => launchUrl(Uri.parse(
                  "https://play.google.com/store/apps/details?id=jdm.apps.cryptotracker")),
            ),
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
