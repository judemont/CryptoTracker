import 'package:cryptotracker/models/news.dart';
import 'package:cryptotracker/widgets/news_list.dart';
import 'package:flutter/material.dart';

import '../services/coins_api.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<News> listings = [];
  int selectedOrderDropdownItem = 0;
  String listingOrder = "trending";
  List<Widget> sortByButtonChildren = [
    const Text("Trending"),
    const Icon(Icons.trending_up)
  ];
  int listingPage = 1;

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
        title: const Text("News"),
      ),
      body: Column(
        children: [
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
                                title: const Text("Trending"),
                                leading:
                                    const Icon(Icons.local_fire_department),
                                onTap: () {
                                  listingOrder = "trending";
                                  loadListings(order: listingOrder);
                                  sortByButtonChildren = [
                                    const Text("trending"),
                                    const Icon(Icons.local_fire_department)
                                  ];
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Handpicked"),
                                leading: const Icon(Icons.stars_outlined),
                                onTap: () {
                                  listingOrder = "handpicked";
                                  loadListings(order: listingOrder);
                                  sortByButtonChildren = [
                                    const Text("handpicked"),
                                    const Icon(Icons.stars_outlined)
                                  ];
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Latest"),
                                leading:
                                    const Icon(Icons.new_releases_outlined),
                                onTap: () {
                                  listingOrder = "latest";
                                  loadListings(order: listingOrder);
                                  sortByButtonChildren = [
                                    const Text("Latest"),
                                    const Icon(Icons.new_releases_outlined)
                                  ];
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Bullish"),
                                leading: const Icon(Icons.trending_up),
                                onTap: () {
                                  listingOrder = "bullish";
                                  loadListings(order: listingOrder);
                                  sortByButtonChildren = [
                                    const Text("Bullish"),
                                    const Icon(Icons.show_chart)
                                  ];
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                title: const Text("Bearish"),
                                leading: const Icon(Icons.trending_down),
                                onTap: () {
                                  listingOrder = "bearish";
                                  loadListings(order: listingOrder);
                                  sortByButtonChildren = [
                                    const Text("Bearish"),
                                    const Icon(Icons.trending_down)
                                  ];
                                  Navigator.pop(context);
                                },
                              ),
                              // ListTile(
                              //   title: const Text("Recently listed"),
                              //   leading:
                              //       const Icon(Icons.new_releases_outlined),
                              //   onTap: () {
                              //     listingOrder = "listedAt";
                              //     loadListings(
                              //         order: listingOrder,
                              //         orderDirection: listingOrderDirection);
                              //     sortByButtonChildren = [
                              //       const Text("Recently listed"),
                              //       const Icon(Icons.new_releases_outlined)
                              //     ];
                              //     Navigator.pop(context);
                              //   },
                              // ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ])),
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: !listingError
                      ? (!isLoading
                          ? NewsList(
                              listings: listings,
                              onScrollEnd: () {
                                listingPage += 1;
                                loadListings(
                                    clearListings: false,
                                    page: listingPage,
                                    order: listingOrder);
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
    order = "trending",
    page = 1,
    clearListings = true,
  }) async {
    isLoading = true;
    listingError = false;

    var values = await getNews(type: order, page: page);

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
}
