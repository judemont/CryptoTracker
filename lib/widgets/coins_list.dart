import 'package:cryptotracker/screens/detailed_view.dart';
import 'package:cryptotracker/utils.dart';
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
            subtitle:
                Text("${roundPrice(widget.listings[index].price ?? 0.0)}\$"),
            leading: Image.network(widget.listings[index].logoUrl ?? ""),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PagesLayout(
                            child: DetailedView(
                          crypto: widget.listings[index],
                        ))),
              );
            },
          );
        });
  }
}
