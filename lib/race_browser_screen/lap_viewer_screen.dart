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
    int averageN = 10;

    return laps.entries.map((car) {
      var speedHist = car.value.speedHistory.entries.toList();
      speedHist.sort((a, b) => a.key.compareTo(b.key)); // Sort speed entries

      List<FlSpot> spots = []; // Points to plot for this car

      int timeSum = 0;
      double speedSum = 0;

      /// How many entries have been summed for this point
      /// Can't just assume [averageN] entries have been summed, since that doesn't apply to the first point
      int entriesAdded = 0;
      speedHist.asMap().forEach((index, speedEntry) {
        speedSum += speedEntry.value;
        timeSum += speedEntry.key;
        entriesAdded++;
        if (index % averageN == 0) {
          spots.add(
            FlSpot(
              timeSum / entriesAdded / 1000,
              speedSum / entriesAdded,
            ),
          );
          // Reset variables
          speedSum = 0;
          timeSum = 0;
          entriesAdded = 0;
        }
      });

      return LineChartBarData(
          isCurved: true,
          dotData: FlDotData(show: true),
          color: [
            Colors.green,
            Colors.purple,
            Colors.orange,
            Colors.grey,
          ][car.key],
          spots: spots);
    }).toList();
  }
}
