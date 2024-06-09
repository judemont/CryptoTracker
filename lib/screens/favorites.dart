import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:flutter/material.dart';

import '../widgets/coins_list.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<Crypto> listings = [];
  @override
  void initState() {
    loadListings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: Column(
        children: [
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: listings.isNotEmpty
                      ? CoinsList(
                          listings: listings,
                        )
                      : const Center(
                          child: Text("No favorites yet"),
                        ),
                  onRefresh: () async {
                    loadListings();
                    return Future<void>.delayed(const Duration(seconds: 2));
                  })),
        ],
      ),
    );
  }

  void loadListings({order = "market_cap_desk"}) {
    List<String> favorites =
        Database.getValue("portfolio", "favs").cast<String>();
    print(favorites);
    if (favorites.isNotEmpty) {
      getListings(ids: favorites).then((values) {
        setState(() {
          listings = values;
        });
      });
    }
  }
}
