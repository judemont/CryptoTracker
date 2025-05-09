import 'package:cryptotracker/models/coin_price.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceHistoryChart extends StatefulWidget {
  final List<CoinPrice> priceHistory;
  final void Function(DateTime touchedTime, double touchedPrice)? onTouch;
  final void Function()? onUntouch;
  const PriceHistoryChart(
      {super.key, required this.priceHistory, this.onTouch, this.onUntouch});

  @override
  State<PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends State<PriceHistoryChart> {
  List<FlSpot> pricesHistoryChartData = [];
  bool isTouchingChart = false;
  DateTime touchedTime = DateTime.now();
  double touchedPrice = 0;

  Future<void> loadPricesHistoryChartData() async {
    setState(() {
      pricesHistoryChartData.clear();
      for (var i = 0; i < widget.priceHistory.length; i++) {
        if (widget.priceHistory[i].price != null) {
          pricesHistoryChartData.add(FlSpot(
              widget.priceHistory[i].dateTime?.millisecondsSinceEpoch
                      .toDouble() ??
                  0.0,
              widget.priceHistory[i].price!));
        }
      }
    });
  }

  @override
  void initState() {
    loadPricesHistoryChartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (event) {
          setState(() {
            isTouchingChart = true;
          });
          widget.onTouch?.call(touchedTime, touchedPrice);
        },
        onPointerUp: (event) {
          setState(() {
            isTouchingChart = false;
          });
          widget.onUntouch?.call();
        },
        child: LineChart(LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                // tooltipBgColor:
                //     Colors.white.withAlpha(0),
                getTooltipColor: (touchedSpot) => Colors.white.withAlpha(0),
                getTooltipItems: (lineBarSpots) {
                  return [const LineTooltipItem("", TextStyle())];
                }),
            touchCallback: (touchEvent, LineTouchResponse? touchResponse) {
              if (touchResponse?.lineBarSpots != null) {
                setState(() {
                  touchedTime = DateTime.fromMillisecondsSinceEpoch(
                      touchResponse!.lineBarSpots!.first.x.round());

                  touchedPrice = touchResponse.lineBarSpots!.first.y;
                });
                if (touchEvent is FlLongPressEnd ||
                    touchEvent is FlPanCancelEvent ||
                    touchEvent is FlTapUpEvent) {
                  setState(() {
                    isTouchingChart = false;
                  });
                  widget.onUntouch?.call();
                } else if (isTouchingChart) {
                  widget.onTouch?.call(touchedTime, touchedPrice);
                }
              }
            },
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color.fromARGB(255, 0, 19, 226),
                        const Color.fromARGB(146, 0, 19, 226),
                        const Color.fromARGB(0, 0, 19, 226)
                      ])),
              isCurved: true,
              color: const Color.fromARGB(255, 0, 26, 255),
              dotData: const FlDotData(show: false),
              spots: pricesHistoryChartData,
            )
          ],
        )));
  }
}
