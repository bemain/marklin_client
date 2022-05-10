import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';

/// Widget for displaying speed history for laps with the same number as a chart.
class LapViewerScreen extends StatelessWidget {
  final int lapNumber;

  /// The laps to display, where the value is the lap and the key is the carID.
  final Map<int, Lap> laps;

  const LapViewerScreen({
    Key? key,
    required this.lapNumber,
    required this.laps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Browser"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: ListTile(
              title: Text("Viewing lap nr. $lapNumber"),
              subtitle: const Text("Speed history:"),
            ),
          ),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: LineChart(
                  LineChartData(
                    lineBarsData: getChartData(),
                    minX: 0,
                    minY: 0,
                    maxY: 100,
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<LineChartBarData> getChartData() {
    return laps.entries.map((car) {
      var speedHist = car.value.speedHistory.entries.toList();
      speedHist.sort((a, b) => a.key.compareTo(b.key)); // Sort speed entries

      return LineChartBarData(
        isCurved: true,
        dotData: FlDotData(show: false),
        color: [
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.grey,
        ][car.key],
        spots: speedHist.map((speedEntry) {
          return FlSpot(
            speedEntry.key.toDouble() / 1000,
            speedEntry.value,
          );
        }).toList(),
      );
    }).toList();
  }
}
