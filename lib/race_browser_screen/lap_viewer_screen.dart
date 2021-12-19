import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LapViewerScreen extends StatelessWidget {
  final DocumentSnapshot<Lap> lapSnap;

  const LapViewerScreen({Key? key, required this.lapSnap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Lap lap = lapSnap.data()!;
    var speedHist = lap.speedHistory.entries.toList();
    speedHist.sort((a, b) => a.key.compareTo(b.key));
    charts.Series<MapEntry<int, double>, int> series = charts.Series(
      id: "speedHist",
      data: speedHist,
      domainFn: (lapEntry, index) => lapEntry.key,
      measureFn: (lapEntry, index) => lapEntry.value,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing lap : ${lap.lapNumber}"),
      ),
      body: Center(
        child: charts.LineChart([series]),
      ),
    );
  }
}
