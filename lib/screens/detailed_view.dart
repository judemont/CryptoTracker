import 'package:cryptotracker/services/database.dart';
import 'package:cryptotracker/utils.dart';
import 'package:cryptotracker/widgets/crypto_market_stats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
                              color: Theme.of(context).colorScheme.onPrimary,
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
                    height: 20,
                  ),
                  pricesHistoryChartData.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(right: 10),
                          height: 300,
                          child: LineChart(LineChartData(
                              lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                      fitInsideHorizontally: true,
                                      fitInsideVertically: true,
                                      getTooltipItems: getTooltipItems)),
                              borderData: FlBorderData(show: true),
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  dotData: const FlDotData(show: false),
                                  spots: pricesHistoryChartData,
                                )
                              ])))
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
                        color: Theme.of(context).primaryColor,
                        border: Border.all(),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    child: ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 1
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.transparent)),
                          child: const Text("1D"),
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
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.transparent)),
                          child: const Text("1W"),
                          onPressed: () => setState(() {
                            selectedTimePriceChartInterval = 2;
                            loadPriceHistory(7);
                            priceChangePercentage =
                                crypto.priceChangePercentageWeek ?? 0;
                            print(crypto.priceChangePercentageWeek);
                          }),
                        ),
                        TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  selectedTimePriceChartInterval == 3
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.transparent)),
                          child: const Text("30D"),
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
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.transparent)),
                          child: const Text("1Y"),
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
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.transparent)),
                          child: const Text("5Y"),
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

  List<LineTooltipItem> getTooltipItems(List<LineBarSpot> lineBarSpots) {
    List<LineTooltipItem> tooltipItems = [];
    for (var lineBarSpot in lineBarSpots) {
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(lineBarSpot.x.toInt());

      tooltipItems.add(LineTooltipItem(
          "", TextStyle(color: Theme.of(context).primaryColor),
          children: [
            TextSpan(
                text: formatePrice(
                    lineBarSpot.y, Database.getValue("settings", "currency")),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: "\n"),
            TextSpan(text: "${date.hour}:${date.minute}:${date.second}"),
            const TextSpan(text: "\n"),
            TextSpan(text: "${date.month}/${date.day}/${date.year}"),
          ]));
    }

    return tooltipItems;
  }
}
