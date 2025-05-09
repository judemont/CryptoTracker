import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CryptosPieChart extends StatefulWidget {
  final List<PieChartSectionData> sections;
  const CryptosPieChart({super.key, required this.sections});

  @override
  State<CryptosPieChart> createState() => _CryptosPieChartState();
}

class _CryptosPieChartState extends State<CryptosPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PieChart(PieChartData(
        sections: widget.sections,
        pieTouchData: PieTouchData(
          touchCallback: (event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        )));
  }
}
