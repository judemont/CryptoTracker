import 'package:cryptotracker/screens/detailed_view.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/crypto.dart';
import '../pages_layout.dart';

class CoinsList extends StatefulWidget {
  final List<Crypto> listings;
  const CoinsList({super.key, required this.listings});

  @override
  State<CoinsList> createState() => _CoinsListState();
}

class _CoinsListState extends State<CoinsList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.listings.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(widget.listings[index].name ?? ""),
            subtitle: Visibility(
                visible: widget.listings[index].symbol != null,
                child:
                    Text(widget.listings[index].symbol?.toUpperCase() ?? "")),
            leading: Container(
              child: getCoinLogoWidget(widget.listings[index].logoUrl ?? ""),
              width: 50,
              height: 50,
            ),
            trailing:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Visibility(
                  visible: widget.listings[index].price != null,
                  child: Text(formatePrice(widget.listings[index].price,
                      Database.getValue("settings", "currency")))),
              Visibility(
                visible:
                    widget.listings[index].priceChangePercentageDay != null,
                child: Text(
                  "${widget.listings[index].priceChangePercentageDay ?? 0.0}%",
                  style: TextStyle(
                      fontSize: 13,
                      color: (widget.listings[index].priceChangePercentageDay ??
                                  0) >=
                              0
                          ? Colors.green
                          : Colors.red),
                ),
              ),
            ]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PagesLayout(
                        displayNavBar: false,
                        child: DetailedView(
                          cryptoId: widget.listings[index].id!,
                        ))),
              );
            },
          );
        });
  }

  Widget getCoinLogoWidget(String logoUrl) {
    if (logoUrl.contains(".svg")) {
      return SvgPicture.network(
        logoUrl,
      );
    } else {
      return Image.network(
        logoUrl,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: Theme.of(context).colorScheme.onPrimary,
          );
        },
      );
    }
  }
}
