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
  int selectedOrderDropdownItem = 0;

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
            onPressed: () {
              setState(() {
                showSearchField = !showSearchField;
              });
              if (!showSearchField) {}
            },
          )
        ],
      ),
      body: Column(
        children: [
          Visibility(
              visible: showSearchField,
              child: TextField(
                autofocus: showSearchField,
                decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    hintText: 'Search',
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showSearchField = false;
                          });
                          loadListings();
                        },
                        icon: const Icon(Icons.close))),
                onChanged: (value) {
                  if (value.length >= 2) {
                    loadSearchResults(value);
                  } else {
                    loadListings();
                  }
                },
              )),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 10),
            child: DropdownButton(
              isExpanded: true,
              value: selectedOrderDropdownItem,
              items: [
                DropdownMenuItem(
                  value: 0,
                  onTap: () => loadListings(order: "market_cap_desc"),
                  child: const Text("Market Cap."),
                ),
                DropdownMenuItem(
                  value: 1,
                  onTap: () => loadListings(order: "volume_desc"),
                  child: const Text("24h Volume"),
                ),
                DropdownMenuItem(
                  value: 2,
                  onTap: () => loadListings(order: "id_asc"),
                  child: const Text("Name (A..Z)"),
                ),
                DropdownMenuItem(
                  value: 3,
                  onTap: () => loadListings(order: "id_desc"),
                  child: const Text("Name (Z..A)"),
                )
              ],
              onChanged: (value) {
                setState(() {
                  selectedOrderDropdownItem = value ?? 0;
                });
              },
              hint: const Text("Sort by"),
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: listings.isNotEmpty
                      ? CoinsList(
                          listings: listings,
                        )
                      : Center(
                          child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
                  onRefresh: () async {
                    loadListings();
                    return Future<void>.delayed(const Duration(seconds: 2));
                  })),
        ],
      ),
    );
  }

  void loadListings({order = "market_cap_desk"}) {
    getListings(order: order).then((values) {
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
