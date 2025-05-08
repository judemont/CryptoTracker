import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/utils.dart';
import 'package:cryptotracker/widgets/new_portfolio_dialog.dart';
import 'package:cryptotracker/widgets/portfolio_coins_list.dart';
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
  double totalValue = 0;
  double totalChange = 0;
  TextEditingController amountController = TextEditingController();

  Future<void> loadListings() async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Crypto> portfolio = await DatabaseService.getPortfolio();

      List<Crypto> cryptoLists = [];
      setState(() {
        totalValue = 0;
        totalChange = 0;
      });

      for (var i = 0; i < portfolio.length; i++) {
        Crypto? value = await getCoinData(portfolio[i].id!);
        if (value != null) {
          value.amount = portfolio[i].amount;
          setState(() {
            totalValue += (value.price ?? 0) * (value.amount ?? 0);
            totalChange += (value.priceChangePercentageDay ?? 0) *
                (value.price ?? 0) *
                (value.amount ?? 0) /
                100;
          });
          cryptoLists.add(value);
        }
      }
      cryptoLists.sort((a, b) {
        return ((b.price ?? 0) * (b.amount ?? 0))
            .compareTo((a.price ?? 0) * (a.amount ?? 0));
      });

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
  void initState() {
    loadListings();
    super.initState();
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
                return NewPortfolioDialog(
                  onAddCoin: () => loadListings(),
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            formatePrice(
                totalValue, SettingsDb.getValue("settings", "currencySymbol")),
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            formatePrice(
                totalChange, SettingsDb.getValue("settings", "currencySymbol")),
            style: TextStyle(
                fontSize: 15,
                color: totalChange > 0 ? Colors.green : Colors.red),
          ),
          const SizedBox(height: 10),
          Expanded(
              child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  child: !loadingError
                      ? (!isLoading
                          ? (listings.isNotEmpty
                              ? PortfolioCoinsList(
                                  listings: listings,
                                  onLongPress: (coin) {
                                    amountController.text =
                                        coin.amount.toString();
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Edit ${coin.name}"),
                                            content: Wrap(children: [
                                              TextField(
                                                controller: amountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    hintText: "Amount"),
                                              ),
                                              Text(coin.symbol ?? "",
                                                  style: const TextStyle(
                                                      fontSize: 20)),
                                            ]),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    await DatabaseService
                                                        .removePortfolioCoin(
                                                            coin.id!);
                                                    loadListings();

                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                  child: const Text("Remove")),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Cancel")),
                                              TextButton(
                                                  onPressed: () async {
                                                    await DatabaseService
                                                        .updatePortfolioCoin(
                                                            coin.id!,
                                                            double.parse(
                                                                amountController
                                                                    .text));
                                                    loadListings();

                                                    if (mounted) {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }
                                                  },
                                                  child: const Text("Save")),
                                            ],
                                          );
                                        });
                                  },
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
