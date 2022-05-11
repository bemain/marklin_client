import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';

class SpeedPlot extends StatefulWidget {
  const SpeedPlot({
    Key? key,
    required this.laps,
  }) : super(key: key);

  final Map<int, Lap> laps;

  @override
  State<StatefulWidget> createState() => SpeedPlotState();
}

class SpeedPlotState extends State<SpeedPlot> {
  /// How many speed entries to average into each point on the plot.
  int averageN = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
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
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: averageN.toDouble(),
                min: 1,
                max: 25,
                divisions: 24,
                label: "$averageN",
                onChanged: (value) => setState(() {
                  averageN = value.toInt();
                }),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                showDuration: Duration(seconds: 3),
                preferBelow: false,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                message:
                    "How many speed entries to average into each point on the plot",
                child: Icon(Icons.info_outline),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<LineChartBarData> getChartData() {
    return widget.laps.entries.map((car) {
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
          dotData: FlDotData(show: false),
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
