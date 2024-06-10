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
  List<Widget> sortByButtonChildren = [
    const Text("Market Cap"),
    const Icon(Icons.bar_chart_rounded)
  ];

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
              child: ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: sortByButtonChildren,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ListView(
                        children: [
                          ListTile(
                            title: const Text("Market Cap"),
                            leading: const Icon(Icons.pie_chart),
                            onTap: () {
                              loadListings(order: "marketCap");
                              sortByButtonChildren = [
                                const Text("Market Cap"),
                                const Icon(Icons.pie_chart)
                              ];
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("24h Volume"),
                            leading: const Icon(Icons.currency_exchange),
                            onTap: () {
                              loadListings(order: "24hVolume");
                              sortByButtonChildren = [
                                const Text("24h Volume"),
                                const Icon(Icons.currency_exchange)
                              ];
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Price"),
                            leading: const Icon(Icons.area_chart_outlined),
                            onTap: () {
                              loadListings(order: "price");
                              sortByButtonChildren = [
                                const Text("Price"),
                                const Icon(Icons.currency_exchange)
                              ];
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Price Change 24h"),
                            leading: const Icon(Icons.show_chart),
                            onTap: () {
                              loadListings(order: "change");
                              sortByButtonChildren = [
                                const Text("Price Change 24h"),
                                const Icon(Icons.show_chart)
                              ];
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: const Text("Recently listed"),
                            leading: const Icon(Icons.new_releases_outlined),
                            onTap: () {
                              loadListings(order: "listedAt");
                              sortByButtonChildren = [
                                const Text("Recently listed"),
                                const Icon(Icons.new_releases_outlined)
                              ];
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              )
              // DropdownButton(
              //   isExpanded: true,
              //   value: selectedOrderDropdownItem,
              //   items: [
              //     DropdownMenuItem(
              //       value: 0,
              //       onTap: () => loadListings(order: "market_cap_desc"),
              //       child: const Text("Market Cap."),
              //     ),
              //     DropdownMenuItem(
              //       value: 1,
              //       onTap: () => loadListings(order: "volume_desc"),
              //       child: const Text("24h Volume"),
              //     ),
              //     DropdownMenuItem(
              //       value: 2,
              //       onTap: () => loadListings(order: "id_asc"),
              //       child: const Text("Name (A..Z)"),
              //     ),
              //     DropdownMenuItem(
              //       value: 3,
              //       onTap: () => loadListings(order: "id_desc"),
              //       child: const Text("Name (Z..A)"),
              //     )
              //   ],
              //   onChanged: (value) {
              //     setState(() {
              //       selectedOrderDropdownItem = value ?? 0;
              //     });
              //   },
              //   hint: const Text("Sort by"),
              // ),
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

  void loadListings({order = "marketCap"}) {
    getListings(order: order).then((values) {
      setState(() {
        listings = values;
      });
    });
  }

  void loadSearchResults(String query) {
    getListings(search: query).then((values) {
      setState(() {
        listings = values;
      });
    });
  }
}
