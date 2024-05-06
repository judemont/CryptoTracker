import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    loadPriceHistory().then((values) => loadPricesHistoryChartData());

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
            ],
          )),
    );
  }

  Future<void> loadPriceHistory() async {
    var values = await getPricesHistory(widget.crypto.symbol!, 25);
    setState(() {
      pricesHistory = values;
    });
  }

  Future<void> loadPricesHistoryChartData() async {
    for (var i = 0; i < pricesHistory.length; i++) {
      setState(() {
        pricesHistoryChartData.add(FlSpot(
            pricesHistory[i].dateTime?.millisecondsSinceEpoch.toDouble() ?? 0.0,
            pricesHistory[i].price! > 1000
                ? (pricesHistory[i].price!.round().toDouble())
                : (pricesHistory[i].price!)));
      });
    }
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
