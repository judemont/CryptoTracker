import 'package:cryptotracker/main.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/currency.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String currency = "";
  String currencySymbol = "";
  String theme = "";
  List<Currency> availableCurrencies = [];

  bool isLoading = false;
  bool loadingError = false;

  @override
  void initState() {
    super.initState();
    loadSettingsValues();

    getAvailableCurrencies().then((value) => {
          setState(() {
            isLoading = false;
            if (value != null) {
              availableCurrencies = value;
            } else {
              loadingError = true;
            }
          })
        });
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
              subtitle: Text(currencySymbol),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      void loadCurrencies({
                        bool addAll = false,
                      }) {
                        loadingError = false;
                        isLoading = true;

                        getAvailableCurrencies().then((value) => {
                              setState(() {
                                isLoading = false;
                                if (value != null) {
                                  if (addAll) {
                                    availableCurrencies.addAll(value);
                                  } else {
                                    availableCurrencies = value;
                                  }
                                } else {
                                  loadingError = true;
                                }
                              })
                            });
                      }

                      return Column(
                        children: [
                          Expanded(
                            // Wrap ListView with Expanded
                            child: !loadingError
                                ? (!isLoading
                                    ? ListView.builder(
                                        itemCount: availableCurrencies.length,
                                        itemBuilder: (context, index) {
                                          Currency currency =
                                              availableCurrencies[index];

                                          return ListTile(
                                            title: Text(
                                                "${currency.name ?? ""} (${currency.symbol ?? ""})"),
                                            leading: currency.iconUrl == null
                                                ? const Icon(
                                                    Icons.monetization_on)
                                                : SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                    child: getCoinLogoWidget(
                                                        currency.iconUrl ?? ""),
                                                  ),
                                            onTap: () {
                                              Database.setValue(
                                                  "settings",
                                                  "currencySymbol",
                                                  currency.symbol);
                                              Database.setValue("settings",
                                                  "currency", currency.name);
                                              Database.setValue(
                                                  "settings",
                                                  "currencyRate",
                                                  currency.rate);
                                              loadSettingsValues();
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      ))
                                : Center(
                                    child: ElevatedButton(
                                      child: const Text("Try again"),
                                      onPressed: () => loadCurrencies(),
                                    ),
                                  ),
                          ),
                        ],
                      );
                    });
                  },
                );
              },
            ),
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
      currencySymbol = Database.getValue("settings", "currencySymbol") ?? "";
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
