import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/screens/settings.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/widgets/newPortfolioDialog.dart';
import 'package:cryptotracker/widgets/portfolioCoinsList.dart';
import 'package:flutter/material.dart';

class Portfolio extends StatefulWidget {
  const Portfolio({super.key});

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  bool isLoading = false;
  bool loadingError = false;
  List<Crypto> listings = [];

  Future<void> loadListings() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Crypto> portfolio = await DatabaseService.getPortfolio();

      List<Crypto> cryptoLists = [];

      for (var i = 0; i < portfolio.length; i++) {
        Crypto? value = await getCoinData(portfolio[i].id!);
        if (value != null) {
          value.amount = portfolio[i].amount;
          cryptoLists.add(value);
        }
      }

      setState(() {
        listings = cryptoLists;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadingError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Portfolio")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Newportfoliodialog(
                  onAddCoin: () => loadListings(),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: !loadingError
                      ? (!isLoading
                          ? (listings.isNotEmpty
                              ? Portfoliocoinslist(
                                  listings: listings,
                                )
                              : const Center(
                                  child: Text("Portfolio is empty"),
                                ))
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
}
