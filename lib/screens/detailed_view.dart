import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../models/coin_price.dart';
import '../models/crypto.dart';
import '../services/coins_api.dart';

class DetailedView extends StatefulWidget {
  final Crypto crypto;
  const DetailedView({super.key, required this.crypto});

  @override
  State<DetailedView> createState() => _DetailedViewState();
}

class _DetailedViewState extends State<DetailedView> {
  List<CoinPrice> pricesHistory = [];
  List<FlSpot> pricesHistoryChartData = [];
  List<ShowingTooltipIndicators> chartIndicators = [];
  int selectedTimePriceChartInterval = 1;

  @override
  void initState() {
    loadPriceHistory("minute", 1440, interval: 5);

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
                    widget.crypto.logoUrl ?? "",
                    width: 30.0,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.crypto.name ?? "",
                    style: const TextStyle(fontSize: 25),
                  )
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
                          dotData: const FlDotData(show: false),
                          spots: pricesHistoryChartData,
                        )
                      ]))),
              const SizedBox(
                height: 5,
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              selectedTimePriceChartInterval == 0
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.transparent)),
                      child: const Text("1H"),
                      onPressed: () => setState(() {
                        selectedTimePriceChartInterval = 0;
                        loadPriceHistory("minute", 60);
                      }),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              selectedTimePriceChartInterval == 1
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.transparent)),
                      child: const Text("1D"),
                      onPressed: () => setState(() {
                        selectedTimePriceChartInterval = 1;
                        loadPriceHistory("minute", 288, interval: 5);
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
                        loadPriceHistory("minute", 336, interval: 30);
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
                        loadPriceHistory("hour", 720);
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
                        loadPriceHistory("day", 365);
                      }),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Future<void> loadPriceHistory(String unit, int limit,
      {int interval = 1}) async {
    getPricesHistory(widget.crypto.symbol!, limit,
            unit: unit, interval: interval)
        .then((values) {
      setState(() {
        pricesHistory = values;
      });
      loadPricesHistoryChartData();
    });
  }

  Future<void> loadPricesHistoryChartData() async {
    setState(() {
      pricesHistoryChartData.clear();
      for (var i = 0; i < pricesHistory.length; i++) {
        pricesHistoryChartData.add(FlSpot(
            pricesHistory[i].dateTime?.millisecondsSinceEpoch.toDouble() ?? 0.0,
            double.parse(pricesHistory[i].price!.toStringAsFixed(
                5 - pricesHistory[i].price.toString().split(".")[0].length))));
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
            text: "${lineBarSpot.y}\$",
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
