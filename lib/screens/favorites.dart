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
  bool isLoading = false;
  bool loadingError = false;

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
                  child: !loadingError
                      ? (!isLoading
                          ? CoinsList(
                              listings: listings,
                            )
                          : const Center(child: CircularProgressIndicator()))
                      : Center(
                          child: ElevatedButton(
                            child: const Text("Try again"),
                            onPressed: () {
                              setState(() {
                                loadingError = false;
                              });
                              loadListings();
                            },
                          ),
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
    setState(() {
      isLoading = true;
    });

    List<String> favorites =
        Database.getValue("portfolio", "favoritesIds").cast<String>();

    // getListings(ids: favorites).then((values) {  TODO
    //   setState(() {
    //     isLoading = false;
    //     if (values != null) {
    //       listings = values;
    //     } else {
    //       loadingError = true;
    //     }
    //   });
    // });
  }
}
