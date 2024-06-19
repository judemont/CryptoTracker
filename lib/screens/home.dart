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
  String listingOrder = "marketCap";
  List<Widget> sortByButtonChildren = [
    const Text("Market Cap"),
    const Icon(Icons.bar_chart_rounded)
  ];
  int listingOffset = 0;
  final int listingLimit = 50;
  String searchValue = "";

  String listingOrderDirection = "desc";
  bool isLoading = false;
  bool listingError = false;

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
                  searchValue = value;
                  loadSearchResults(value);
                },
              )),
          Container(
              margin: const EdgeInsets.only(left: 20, right: 10),
              child: Row(children: [
                Expanded(
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
                                  listingOrder = "marketCap";
                                  loadListings(
                                      order: listingOrder,
                                      orderDirection: listingOrderDirection);
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
                                  listingOrder = "24hVolume";
                                  loadListings(
                                      order: listingOrder,
                                      orderDirection: listingOrderDirection);
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
                                  listingOrder = "price";
                                  loadListings(
                                      order: listingOrder,
                                      orderDirection: listingOrderDirection);
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
                                  listingOrder = "change";
                                  loadListings(
                                      order: listingOrder,
                                      orderDirection: listingOrderDirection);
                                  sortByButtonChildren = [
                                    const Text("Price Change 24h"),
                                    const Icon(Icons.show_chart)
                                  ];
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Recently listed"),
                                leading:
                                    const Icon(Icons.new_releases_outlined),
                                onTap: () {
                                  listingOrder = "listedAt";
                                  loadListings(
                                      order: listingOrder,
                                      orderDirection: listingOrderDirection);
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
                  ),
                ),
                IconButton(
                    onPressed: (() {
                      setState(() {
                        listingOrderDirection =
                            listingOrderDirection == "desc" ? "asc" : "desc";
                      });
                      loadListings(
                          order: listingOrder,
                          orderDirection: listingOrderDirection);
                    }),
                    icon: Icon(listingOrderDirection == "desc"
                        ? Icons.arrow_downward_sharp
                        : Icons.arrow_upward_sharp))
              ])),
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: !listingError
                      ? (!isLoading
                          ? CoinsList(
                              listings: listings,
                              onScrollEnd: () {
                                if (searchValue.isEmpty) {
                                  listingOffset += listingLimit;
                                  loadListings(
                                      clearListings: false,
                                      limit: listingLimit,
                                      offset: listingOffset,
                                      order: listingOrder);
                                }
                              },
                            )
                          : const Center(child: CircularProgressIndicator()))
                      : Center(
                          child: ElevatedButton(
                            child: const Text("Try again"),
                            onPressed: () {
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

  Future<void> loadListings({
    order = "marketCap",
    limit = 50,
    offset = 0,
    clearListings = true,
    orderDirection = "desc",
  }) async {
    setState(() {
      isLoading = true;
      listingError = false;
    });
    var values = await getListings(
      order: order,
      limit: limit,
      offset: offset,
      orderDirection: orderDirection,
    );
    setState(() {
      isLoading = false;
      if (clearListings) {
        listings = [];
      }
      if (values != null) {
        listings.addAll(values);
      } else {
        listingError = true;
      }
    });
  }

  void loadSearchResults(String query) {
    setState(() {
      isLoading = true;
      listingError = false;
    });
    getListings(search: query).then((values) {
      setState(() {
        isLoading = false;
        if (values != null) {
          listings = values;
        } else {
          listingError = true;
        }
      });
    });
  }
}
