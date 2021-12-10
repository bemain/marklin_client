import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:marklin_bluetooth/firebase/lap.dart';

/// Widget for displaying laps in a chart.
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
    var series = laps.entries.map((entry) {
      var speedHist = entry.value.speedHistory.entries.toList();
      speedHist.sort((a, b) => a.key.compareTo(b.key));
      return charts.Series<MapEntry<int, double>, int>(
        id: "speedHist",
        data: speedHist,
        domainFn: (lapEntry, index) => lapEntry.key,
        measureFn: (lapEntry, index) => lapEntry.value,
        colorFn: (lapEntry, index) => charts.ColorUtil.fromDartColor([
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.grey,
        ][entry.key]),
      );
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing lap : $lapNumber"),
      ),
      body: Center(child: charts.LineChart(series)),
    );
  }
}
