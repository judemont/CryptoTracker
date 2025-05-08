import 'package:cryptotracker/screens/portfolio_coin_detailed_view.dart';
import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/utils.dart';
import 'package:flutter/material.dart';

import '../models/crypto.dart';
import '../pages_layout.dart';

class PortfolioCoinsList extends StatefulWidget {
  final List<Crypto> listings;
  final Function? onScrollEnd;
  const PortfolioCoinsList(
      {super.key, required this.listings, this.onScrollEnd});

  @override
  State<PortfolioCoinsList> createState() => _CoinsListState();
}

class _CoinsListState extends State<PortfolioCoinsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.listings.length,
        itemBuilder: (BuildContext context, int index) {
          double amountValue = (widget.listings[index].price ?? 0) *
              (widget.listings[index].amount ?? 0);

          if (index >= widget.listings.length - 5) {
            if (widget.onScrollEnd != null) {
              widget.onScrollEnd!();
            }
          }
          return ListTile(
            title: Text(widget.listings[index].name ?? ""),
            subtitle: Visibility(
                visible: widget.listings[index].symbol != null,
                child: Text(
                    "${widget.listings[index].amount} ${widget.listings[index].symbol ?? ""}")),
            leading: SizedBox(
              width: 50,
              height: 50,
              child: getCoinLogoWidget(widget.listings[index].logoUrl ?? ""),
            ),
            trailing:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Visibility(
                  visible: widget.listings[index].price != null,
                  child: Text(
                    formatePrice(amountValue,
                        SettingsDb.getValue("settings", "currencySymbol")),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Text(
                  widget.listings[index].price != null
                      ? formatePrice(
                          amountValue /
                              100 *
                              (widget.listings[index]
                                      .priceChangePercentageDay ??
                                  1),
                          SettingsDb.getValue("settings", "currencySymbol"))
                      : "",
                  style: TextStyle(
                      color: widget.listings[index].priceChangePercentageDay !=
                                  null &&
                              widget.listings[index].priceChangePercentageDay! >
                                  0
                          ? Colors.green
                          : Colors.red)),
            ]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PagesLayout(
                        displayNavBar: false,
                        child: PortfolioCoinDetailedView(
                          cryptoId: widget.listings[index].id!,
                          amount: widget.listings[index].amount??1,
                        ))),
              );
            },
          );
        });
  }
}
