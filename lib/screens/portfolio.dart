import 'package:cryptotracker/models/coin_price.dart';
import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/services/coins_api.dart';
import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/utils.dart';
import 'package:cryptotracker/widgets/new_portfolio_dialog.dart';
import 'package:cryptotracker/widgets/portfolio_coins_list.dart';
import 'package:cryptotracker/widgets/price_history_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      loadingError = false;
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
    super.initState();
    loadListings();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Portfolio"),
      ),
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
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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

    

        
          Container(
            height: 200,
            padding: const EdgeInsets.all(8.0),
            child: Container()
          ),
          Expanded(
            child: RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                await loadListings();
                return Future<void>.delayed(const Duration(seconds: 1));
              },
              child: !loadingError
                  ? (!isLoading
                      ? (listings.isNotEmpty
                          ? PortfolioCoinsList(
                              listings: listings,
                              onLongPress: (coin) {
                                amountController.text = coin.amount.toString();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Edit ${coin.name}"),
                                        content: Wrap(children: [
                                          TextField(
                                            controller: amountController,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                hintText: "Amount"),
                                          ),
                                          Text(coin.symbol ?? "",
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                        ]),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel")),
                                          TextButton(
                                              onPressed: () async {
                                                await DatabaseService
                                                    .removePortfolioCoin(
                                                        coin.id!);
                                                loadListings();

                                                if (mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text("Remove")),
                                          TextButton(
                                              onPressed: () async {
                                                if (amountController
                                                    .text.isNotEmpty) {
                                                  try {
                                                    double amount =
                                                        double.parse(
                                                            amountController
                                                                .text);
                                                    await DatabaseService
                                                        .updatePortfolioCoin(
                                                            coin.id!, amount);
                                                    loadListings();
                                                  } catch (e) {
                                                    // Handle invalid number input
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    "Please enter a valid number")));
                                                  }
                                                }

                                                if (mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: const Text("Save")),
                                        ],
                                      );
                                    });
                              },
                            )
                          : const Center(child: Text("Portfolio is empty")))
                      : const Center(child: CircularProgressIndicator()))
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Failed to load data"),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              loadListings();
                            },
                            child: const Text("Try again"),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
