import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/race_reference.dart';
import 'package:marklin_bluetooth/race_browser_screen/car_viewer.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

/// Widget for displaying lap times and other information about [raceSnap].
/// TODO: Add button for deleting race
class RaceViewerScreen extends StatelessWidget {
  const RaceViewerScreen({Key? key, required this.raceSnap}) : super(key: key);

  final DocumentSnapshot<Race> raceSnap;

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
            var laps = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: laps.entries
                  .map((entry) => TextTile(title: "${entry.key}"))
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

class RaceViewer extends StatelessWidget {
  const RaceViewer({Key? key, required this.raceRef}) : super(key: key);

  final RaceReference raceRef;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Race>(
      future: raceRef.race,
      builder: niceAsyncBuilder(
        loadingText: "Determining number of cars...",
        activeBuilder: (BuildContext c, AsyncSnapshot<Race> snapshot) {
          Race race = snapshot.data!;

          return Row(
            children: List.generate(
              race.nCars * 2 - 1,
              (i) => i.isEven
                  ? Expanded(child: CarViewer(carRef: raceRef.carRef(i ~/ 2)))
                  : const VerticalDivider(thickness: 1.0),
            ),
          );
        },
      ),
    );
  }
}
