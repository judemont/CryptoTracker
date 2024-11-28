import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/crypto.dart';

class CryptoMarketStats extends StatefulWidget {
  final Crypto crypto;
  const CryptoMarketStats({super.key, required this.crypto});

  @override
  _CryptoMarketStatsState createState() => _CryptoMarketStatsState();
}

class _CryptoMarketStatsState extends State<CryptoMarketStats> {
  @override
  Widget build(BuildContext context) {
    // String currency = SettingsDb.getValue("settings", "currencyId");
    String currencySymbol = SettingsDb.getValue("settings", "currencySymbol");

    Uri? homePageUri = Uri.tryParse(widget.crypto.website ?? "");

    String cryptoDescriptionText = (widget.crypto.description ?? "")
        .replaceAllMapped(
            RegExp(r'<a[^>]*>([^<]+)<\/a>'), (match) => match.group(1)!);

    return Column(
      children: [
        const Text(
          "Infos  :",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        statRow("Market Cap.",
            Text(formatePrice(widget.crypto.marketCap, currencySymbol))),
        statRow(
            "Volume", Text(formatePrice(widget.crypto.volume, currencySymbol))),
        Visibility(
            visible: widget.crypto.ath != null,
            child: statRow("All Time High",
                Text(formatePrice(widget.crypto.ath, currencySymbol)))),
        statRow(
            "Max Supply",
            Text(formatePrice(
                widget.crypto.totalSupply, widget.crypto.symbol ?? ""))),
        statRow(
            "Circulating Supply",
            Text(formatePrice(
                widget.crypto.circulatingSupply, widget.crypto.symbol ?? ""))),
        statRow(
            "% of supply in circulation",
            Text(
                "${((widget.crypto.circulatingSupply ?? 0) / (widget.crypto.totalSupply ?? 0) * 100).toStringAsFixed(2)}%")),
        Visibility(
          visible: homePageUri != null,
          child: statRow(
              "Homepage",
              InkWell(
                onTap: () => launchUrl(homePageUri!),
                child: Text(
                  homePageUri?.host.replaceFirst("www.", "") ?? "",
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )),
        ),
        Visibility(
          visible: (widget.crypto.description ?? "").isNotEmpty,
          child: Column(
            children: [
              const Text(
                "Description :",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(cryptoDescriptionText),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> getCategoriesElements() {
    List<Widget> categoriesElements = [];

    for (var category in widget.crypto.categories ?? []) {
      categoriesElements.add(Chip(label: Text(category)));
    }

    return categoriesElements;
  }

  Widget statRow(String name, Widget value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text("$name:"),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: value,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
