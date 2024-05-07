import 'package:flutter/material.dart';

import '../models/crypto.dart';
import '../services/coins_api.dart';
import '../widgets/coins_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Crypto> listings = [];
  bool showSearchField = false;

  @override
  void initState() {
    loadListings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CryptoTracker"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() {
              showSearchField = !showSearchField;
            }),
          )
        ],
      ),
      body: Column(
        children: [
          Visibility(
              visible: showSearchField,
              child: TextField(
                onChanged: (value) {
                  if (value.length >= 3) {
                    loadSearchResults(value);
                  }
                },
              )),
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: CoinsList(
                    listings: listings,
                  ),
                  onRefresh: () async {
                    loadListings();
                    return Future<void>.delayed(const Duration(seconds: 2));
                  })),
        ],
      ),
    );
  }

  void loadListings() {
    getListings().then((values) {
      setState(() {
        listings = values;
      });
    });
  }

  void loadSearchResults(String query) {
    search(query).then((values) {
      setState(() {
        listings = values;
      });
    });
  }
}
