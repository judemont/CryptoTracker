import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/services/settingsDB.dart';
import 'package:cryptotracker/utils/utils.dart';
import 'package:cryptotracker/widgets/crypto_market_stats.dart';
import 'package:cryptotracker/widgets/price_history_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/coin_price.dart';
import '../models/crypto.dart';
import '../services/coins_api.dart';

class DetailedView extends StatefulWidget {
  final String cryptoId;
  const DetailedView({super.key, required this.cryptoId});

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  List<CoinPrice> pricesHistory = [];
  List<ShowingTooltipIndicators> chartIndicators = [];
  String selectedTimePriceChartInterval = "24h";
  double priceChangePercentage = 0;
  List favorites = [];

  Crypto crypto = Crypto();

  double touchedPrice = 0.0;
  DateTime touchedTime = DateTime.now();
  bool isTouchingChart = false;
  bool isLoading = false;
  bool loadingError = false;

  @override
  void initState() {
    loadCoinData().then((value) {
      loadPriceHistory("24h");
      priceChangePercentage = crypto.priceChangePercentageDay ?? 0;
    });
    loadFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const timePeriods = ["24h", "1w", "1m", "3m", "6m", "1y", "all"];

    List<Widget> timePeriodsButtons = [];

    for (var timePeriod in timePeriods) {
      timePeriodsButtons.add(Container(
        width: 40,
        alignment: Alignment.center,
        child: TextButton(
          style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              backgroundColor: WidgetStateProperty.all(
                  selectedTimePriceChartInterval == timePeriod
                      ? const Color.fromARGB(255, 0, 38, 255)
                      : Colors.transparent)),
          child: Text(timePeriod,
              style: TextStyle(
                  color: selectedTimePriceChartInterval == timePeriod
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color)),
          onPressed: () => setState(() {
            selectedTimePriceChartInterval = timePeriod;
            loadPriceHistory(timePeriod);
          }),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          Visibility(
              visible: crypto.id != null,
              child: IconButton(
                  onPressed: () {
                    if (!favorites.contains(crypto.id)) {
                      setState(() {
                        favorites.add(crypto.id);
                      });
                      DatabaseService.newFavorite(crypto.id!);
                    } else {
                      setState(() {
                        favorites.remove(crypto.id);
                        DatabaseService.removeFavoriteFromCrypto(crypto.id!);
                      });
                    }

                    // SettingsDb.setValue("portfolio", "favoritesIds", favorites); // TODO
                    loadFavorites();
                  },
                  icon: Icon(favorites.contains(crypto.id)
                      ? Icons.star
                      : Icons.star_border)))
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () => loadCoinData().then((value) {
                loadPriceHistory("24h");
                priceChangePercentage = crypto.priceChangePercentageDay ?? 0;
              }),
          child: !loadingError
              ? (!isLoading
                  ? Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                            children: [
                              SizedBox(
                                  width: 50,
                                  height: 50,
                                  child:
                                      getCoinLogoWidget(crypto.logoUrl ?? "")),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                crypto.name ?? "",
                                style: const TextStyle(fontSize: 25),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                formatePrice(
                                    crypto.price,
                                    SettingsDb.getValue(
                                        "settings", "currencySymbol")),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                "$priceChangePercentage%",
                                style: TextStyle(
                                    fontSize: 13,
                                    color: priceChangePercentage >= 0
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          isTouchingChart
                              ? Column(
                                  children: [
                                    Text(
                                      formatePrice(
                                          touchedPrice,
                                          SettingsDb.getValue(
                                              "settings", "currencySymbol")),
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    Text(DateFormat('MM/dd/yyyy hh:mm')
                                        .format(touchedTime))
                                  ],
                                )
                              : const SizedBox(
                                  height: 40,
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              margin: const EdgeInsets.only(right: 10),
                              height: 200,
                              child: PriceHistoryChart(
                                priceHistory: pricesHistory,
                                onTouch: (touchedTime, touchedPrice) {
                                  setState(() {
                                    isTouchingChart = true;
                                    this.touchedTime = touchedTime;
                                    this.touchedPrice = touchedPrice;
                                  });
                                },
                                onUntouch: () {
                                  setState(() {
                                    isTouchingChart = false;
                                  });
                                },
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                border: Border.all(),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: timePeriodsButtons),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: CryptoMarketStats(crypto: crypto),
                          )
                        ],
                      )))
                  : const Center(
                      child: CircularProgressIndicator(),
                    ))
              : Center(
                  child: ElevatedButton(
                    child: const Text("Try again"),
                    onPressed: () {
                      loadCoinData().then((value) {
                        loadPriceHistory("24h");
                        priceChangePercentage =
                            crypto.priceChangePercentageDay ?? 0;
                      });
                    },
                  ),
                )),
    );
  }

  Future<void> loadPriceHistory(String timePeriod, {bool max = false}) async {
    setState(() {
      isLoading = true;
      loadingError = false;
    });
    getPricesHistory(crypto.id!, timePeriod).then((values) {
      setState(() {
        if (values != null) {
          pricesHistory = values;
        } else {
          loadingError = true;
        }
        isLoading = false;
      });
    });
  }

  Future<void> loadCoinData() async {
    setState(() {
      isLoading = true;
      loadingError = false;
    });
    var values = await getCoinData(widget.cryptoId);
    setState(() {
      isLoading = false;
      if (values != null) {
        crypto = values;
      } else {
        loadingError = true;
      }
    });
  }

  Future<void> loadFavorites() async {
    favorites = await DatabaseService.getFavorites();
    setState(() {
      // favorites = SettingsDb.getValue("portfolio", "favoritesIds") ?? []; // TODO
    });
  }
}
