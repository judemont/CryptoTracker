import 'package:cryptotracker/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

  Crypto crypto = Crypto();

  @override
  void initState() {
    loadCoinData().then((value) {
      loadPriceHistory(1);
      priceChangePercentage = crypto.priceChangePercentageDay ?? 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
      ),
      body: Container(
          margin: const EdgeInsets.only(left: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Image.network(
                    crypto.logoUrl ?? "https://www.coingecko.com/favicon.ico",
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
                  Text("${crypto.price ?? 0.0}\$"),
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
              Container(
                  margin: const EdgeInsets.only(right: 10),
                  height: 300,
                  child: LineChart(LineChartData(
                      lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: getTooltipItems)),
                      borderData: FlBorderData(show: true),
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          color: Theme.of(context).colorScheme.onPrimary,
                          dotData: const FlDotData(show: false),
                          spots: pricesHistoryChartData,
                        )
                      ]))),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(20))),
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
                  ],
                ),
              )
            ],
          )),
    );
  }

  Future<void> loadPriceHistory(int daysNum) async {
    getPricesHistory(crypto.id!, daysNum).then((values) {
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
        pricesHistoryChartData.add(FlSpot(
            pricesHistory[i].dateTime?.millisecondsSinceEpoch.toDouble() ?? 0.0,
            pricesHistory[i].price ?? 0.0));
      }
    });
  }

  List<LineTooltipItem> getTooltipItems(List<LineBarSpot> lineBarSpots) {
    List<LineTooltipItem> tooltipItems = [];
    for (var lineBarSpot in lineBarSpots) {
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(lineBarSpot.x.toInt());

      tooltipItems.add(LineTooltipItem("", const TextStyle(), children: [
        TextSpan(
            text: "${roundPrice(lineBarSpot.y)}\$",
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
