import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/utils.dart';
import 'package:cryptotracker/widgets/crypto_market_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  int selectedTimePriceChartInterval = 1;
  double priceChangePercentage = 0;
  List favorites = [];

  Crypto crypto = Crypto();

  double touchedPrice = 0.0;
  DateTime touchedTime = DateTime.now();
  bool isTouchingChart = false;

  @override
  void initState() {
    loadCoinData().then((value) {
      loadPriceHistory(1);
      priceChangePercentage = crypto.priceChangePercentageDay ?? 0;
    });
    loadFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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

                    Database.setValue("portfolio", "favorites", favorites);
                    print(favorites);
                    loadFavorites();
                  },
                  icon: Icon(favorites.contains(crypto.id)
                      ? Icons.star
                      : Icons.star_border)))
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () => loadCoinData().then((value) {
                loadPriceHistory(1);
                priceChangePercentage = crypto.priceChangePercentageDay ?? 0;
              }),
          child: Container(
              margin: const EdgeInsets.only(left: 10),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Wrap(
                    children: [
                      if (crypto.logoUrl != null)
                        Image.network(
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            );
                          },
                          crypto.logoUrl!,
                          width: 40.0,
                        ),
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
                      Text(formatePrice(crypto.price,
                          Database.getValue("settings", "currency"))),
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
                            Text(formatePrice(touchedPrice,
                                Database.getValue("settings", "currency"))),
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
                  pricesHistoryChartData.isNotEmpty
                      ? Container(
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
                                      tooltipBgColor: Colors.white.withAlpha(0),
                                      getTooltipItems: (lineBarSpots) {
                                        return [
                                          LineTooltipItem("", const TextStyle())
                                        ];
                                      }),
                                  touchCallback: (touchEvent,
                                      LineTouchResponse? touchResponse) {
                                    if (touchResponse?.lineBarSpots != null) {
                                      setState(() {
                                        touchedTime =
                                            DateTime.fromMillisecondsSinceEpoch(
                                                touchResponse!
                                                    .lineBarSpots!.first.x
                                                    .round());

                                        touchedPrice =
                                            touchResponse.lineBarSpots!.first.y;
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
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                      color: Colors.purple,
                                      dotData: FlDotData(show: false),
                                      spots: pricesHistoryChartData,
                                      belowBarData: BarAreaData(
                                          show: true,
                                          color:
                                              Colors.purple.withOpacity(0.6)))
                                ],
                              ))))
                      : Center(
                          child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                        )),
                  const SizedBox(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        border: Border.all(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: Wrap(
                      // alignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 1
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent)),
                          child: Text("1D",
                              style: TextStyle(
                                  color: selectedTimePriceChartInterval == 1
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color)),
                          onPressed: () => setState(() {
                            selectedTimePriceChartInterval = 1;
                            loadPriceHistory(1);
                            priceChangePercentage =
                                crypto.priceChangePercentageDay ?? 0;
                          }),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 2
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent)),
                          child: Text("1W",
                              style: TextStyle(
                                  color: selectedTimePriceChartInterval == 2
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color)),
                          onPressed: () => setState(() {
                            selectedTimePriceChartInterval = 2;
                            loadPriceHistory(7);
                            priceChangePercentage =
                                crypto.priceChangePercentageWeek ?? 0;
                          }),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 3
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent)),
                          child: Text("30D",
                              style: TextStyle(
                                  color: selectedTimePriceChartInterval == 3
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color)),
                          onPressed: () => setState(() {
                            selectedTimePriceChartInterval = 3;
                            loadPriceHistory(30);
                            priceChangePercentage =
                                crypto.priceChangePercentageMonth ?? 0;
                          }),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 4
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent)),
                          child: Text("1Y",
                              style: TextStyle(
                                  color: selectedTimePriceChartInterval == 4
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color)),
                          onPressed: () => setState(() {
                            selectedTimePriceChartInterval = 4;
                            loadPriceHistory(365);
                            priceChangePercentage =
                                crypto.priceChangePercentageYear ?? 0;
                          }),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 5
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent)),
                          child: Text("5Y",
                              style: TextStyle(
                                  color: selectedTimePriceChartInterval == 5
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color)),
                          onPressed: () => setState(() {
                            selectedTimePriceChartInterval = 5;
                            loadMaxPriceHistory();
                            priceChangePercentage =
                                crypto.priceChangePercentageYear ?? 0;
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: CryptoMarketStats(crypto: crypto),
                  )
                ],
              )))),
    );
  }

  Future<void> loadPriceHistory(int daysNum, {bool max = false}) async {
    getPricesHistory(crypto.id!, daysNum).then((values) {
      setState(() {
        pricesHistory = values;
      });
      loadPricesHistoryChartData();
    });
  }

  Future<void> loadMaxPriceHistory() async {
    print("BABABA");
    getMaxPricesHistory(crypto.symbol!).then((values) {
      setState(() {
        pricesHistory = values;
      });
      loadPricesHistoryChartData();
    });
  }

  Future<void> loadCoinData() async {
    var values = await getCoinData(widget.cryptoId);
    setState(() {
      crypto = values;
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
      favorites = Database.getValue("portfolio", "favorites") ?? [];
    });
  }
}
