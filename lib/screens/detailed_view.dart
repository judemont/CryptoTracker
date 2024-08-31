import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/utils.dart';
import 'package:cryptotracker/widgets/crypto_market_stats.dart';
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
  List<FlSpot> pricesHistoryChartData = [];
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
    const timePeriods = ["1h", "24h", "7d", "30d", "1y", "5y"];

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
                      ? Theme.of(context).primaryColor
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
                    } else {
                      setState(() {
                        favorites.remove(crypto.id);
                      });
                    }

                    Database.setValue("portfolio", "favoritesIds", favorites);
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
                              Text(formatePrice(
                                  crypto.price,
                                  Database.getValue(
                                      "settings", "currencySymbol"))),
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
                                    Text(formatePrice(
                                        touchedPrice,
                                        Database.getValue(
                                            "settings", "currencySymbol"))),
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
                              height: 300,
                              child: Listener(
                                  onPointerDown: (event) => setState(() {
                                        isTouchingChart = true;
                                      }),
                                  onPointerUp: (event) => setState(() {
                                        isTouchingChart = false;
                                      }),
                                  child: LineChart(LineChartData(
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                          // tooltipBgColor:
                                          //     Colors.white.withAlpha(0),
                                          getTooltipColor: (touchedSpot) =>
                                              Colors.white.withAlpha(0),
                                          getTooltipItems: (lineBarSpots) {
                                            return [
                                              const LineTooltipItem(
                                                  "", TextStyle())
                                            ];
                                          }),
                                      touchCallback: (touchEvent,
                                          LineTouchResponse? touchResponse) {
                                        if (touchResponse?.lineBarSpots !=
                                            null) {
                                          setState(() {
                                            touchedTime = DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    touchResponse!
                                                        .lineBarSpots!.first.x
                                                        .round());

                                            touchedPrice = touchResponse
                                                .lineBarSpots!.first.y;
                                            // isTouchingChart = true;
                                          });
                                          if (touchEvent is FlLongPressEnd ||
                                              touchEvent is FlPanCancelEvent ||
                                              touchEvent is FlTapUpEvent) {
                                            setState(() {
                                              isTouchingChart = false;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                    borderData: FlBorderData(show: true),
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                          color: Colors.purple,
                                          dotData: const FlDotData(show: false),
                                          spots: pricesHistoryChartData,
                                          belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.purple
                                                  .withOpacity(0.6)))
                                    ],
                                  )))),
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
      });
      loadPricesHistoryChartData().then((value) => setState(() {
            isLoading = false;
          }));
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

  Future<void> loadPricesHistoryChartData() async {
    setState(() {
      pricesHistoryChartData.clear();
      for (var i = 0; i < pricesHistory.length; i++) {
        if (pricesHistory[i].price != null) {
          pricesHistoryChartData.add(FlSpot(
              pricesHistory[i].dateTime?.millisecondsSinceEpoch.toDouble() ??
                  0.0,
              pricesHistory[i].price!));
        }
      }
    });
  }

  void loadFavorites() {
    setState(() {
      favorites = Database.getValue("portfolio", "favoritesIds") ?? [];
    });
  }
}
