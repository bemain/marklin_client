import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/race_reference.dart';
import 'package:marklin_bluetooth/race_browser_screen/lap_viewer_screen.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

/// Widget for displaying lap times and other information about [raceSnap].
class RaceViewerScreen extends StatelessWidget {
  const RaceViewerScreen({
    Key? key,
    required this.raceSnap,
    this.sortDescending = false,
  }) : super(key: key);

  final DocumentSnapshot<Race> raceSnap;
  final bool sortDescending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing race: ${raceString(raceSnap)}"),
      ),
      body: StreamBuilder<Map<int, Map<int, Lap>>>(
        stream: lapsStream(),
        builder: niceAsyncBuilder(
          loadingText: "Getting laps...",
          activeBuilder: (BuildContext c, snapshot) {
            var laps = snapshot.data!.entries.toList();
            laps.sort(
                (a, b) => (sortDescending ? -1 : 1) * b.key.compareTo(a.key));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: laps
                  .map((entry) => TextTile(
                        title: "${entry.key}",
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (c) => LapViewerScreen(
                                      lapNumber: entry.key,
                                      laps: entry.value,
                                    ))),
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Stream<Map<int, Map<int, Lap>>> lapsStream() {
    RaceReference raceRef = RaceReference(docRef: raceSnap.reference);
    int nCars = raceSnap.data()!.nCars;

    final Stream<QuerySnapshot<Lap>> first =
        raceRef.carRef(0).lapsRef.snapshots();
    final List<Stream<QuerySnapshot<Lap>>> others = List.generate(
        nCars - 1, (carID) => raceRef.carRef(carID + 1).lapsRef.snapshots());

    return first.combineLatestAll(others).map(_getLapsFromQuery);
  }

  Map<int, Map<int, Lap>> _getLapsFromQuery(List<QuerySnapshot<Lap>> cars) {
    Map<int, Map<int, Lap>> lapsByLap = {};

    cars.asMap().forEach((int carID, QuerySnapshot<Lap> lapsQuery) {
      List<Lap> laps = lapsQuery.docs.map((lapSnap) => lapSnap.data()).toList();
      for (Lap lap in laps) {
        lapsByLap.putIfAbsent(lap.lapNumber, () => {});
        lapsByLap[lap.lapNumber]![carID] = lap;
      }
    });
    return lapsByLap;
  }
}
