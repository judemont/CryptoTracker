import 'package:cryptotracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/crypto.dart';

class CryptoMarketStats extends StatefulWidget {
  final Crypto crypto;
  const CryptoMarketStats({Key? key, required this.crypto}) : super(key: key);

  @override
  _CryptoMarketStatsState createState() => _CryptoMarketStatsState();
}

class _CryptoMarketStatsState extends State<CryptoMarketStats> {
  bool showAllDescriptions = false;

  @override
  Widget build(BuildContext context) {
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
        statRow(
            "Market cap. Rank", Text(widget.crypto.marketCapRank.toString())),
        statRow("Market Cap.", Text(formatePrice(widget.crypto.marketCap))),
        statRow("Volume", Text(formatePrice(widget.crypto.volume))),
        statRow("24h High", Text(formatePrice(widget.crypto.dayHigh))),
        statRow("24h Low", Text(formatePrice(widget.crypto.dayLow))),
        statRow("All Time High", Text(formatePrice(widget.crypto.ath))),
        statRow(
            "Total Supply",
            Text(formatePrice(widget.crypto.totalSupply,
                symbol: widget.crypto.symbol))),
        statRow(
            "Circulating Supply",
            Text(formatePrice(widget.crypto.circulatingSupply,
                symbol: widget.crypto.symbol))),
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
        const Text(
          "Description :",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(showAllDescriptions
            ? cryptoDescriptionText
            : (cryptoDescriptionText.length > 200
                ? "${cryptoDescriptionText.substring(0, 200)}..."
                : cryptoDescriptionText)),
        TextButton(
            onPressed: () => setState(() {
                  showAllDescriptions = !showAllDescriptions;
                }),
            child: Text(
              showAllDescriptions ? "less" : "more",
            ))
      ],
    );
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
