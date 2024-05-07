import 'package:cryptotracker/screens/detailed_view.dart';
import 'package:flutter/material.dart';

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
                visible: widget.listings[index].price != null,
                child: Text("${widget.listings[index].price ?? 0.0}\$")),
            leading: Image.network(widget.listings[index].logoUrl ?? ""),
            trailing: Visibility(
              visible: widget.listings[index].priceChangePercentageDay != null,
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PagesLayout(
                            child: DetailedView(
                          cryptoId: widget.listings[index].id!,
                        ))),
              );
            },
          );
        });
  }
}
