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
          margin: const EdgeInsets.only(left: 20),
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
              Container(
                  width: double.infinity,
                  height: 300,
                  child: LineChart(LineChartData(
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
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
    print(pricesHistory);
    for (var i = 0; i < pricesHistory.length; i++) {
      setState(() {
        pricesHistoryChartData.add(FlSpot(
            i.toDouble(),
            pricesHistory[i].price! > 1000
                ? (pricesHistory[i].price!.round().toDouble())
                : (pricesHistory[i].price!)));
      });
      print(pricesHistoryChartData);
    }
  }
}
