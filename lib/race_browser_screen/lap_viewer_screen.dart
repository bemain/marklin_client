import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/old_lap.dart';
import 'package:marklin_bluetooth/race_browser_screen/speed_plot.dart';

class LapViewerScreen extends StatelessWidget {
  /// Widget for displaying speed history for laps with the same number as a chart.
  const LapViewerScreen({
    Key? key,
    required this.lapNumber,
    required this.laps,
  }) : super(key: key);

  final int lapNumber;

  /// The laps to display, where the value is the lap and the key is the carID.
  final Map<int, OldLap> laps;

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
                child: SpeedPlot(laps: laps),
              ),
            ),
          )
        ],
      ),
    );
  }
}
