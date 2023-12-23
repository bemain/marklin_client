import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/race_reference.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';
import 'package:stream_transform/stream_transform.dart';

class RaceViewerScreen extends StatelessWidget {
  /// Widget for displaying lap times and other information about [raceSnap].
  const RaceViewerScreen({
    super.key,
    required this.raceSnap,
    this.sortDescending = false,
  });

  /// The race to display information about.
  final DocumentSnapshot<Race> raceSnap;

  /// If true, will sort laps in descending order.
  final bool sortDescending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Browser"),
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: const Text("Viewing race"),
              subtitle: Text(dateString(raceSnap.data()!.date.toDate())),
            ),
          ),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text("Laps:"),
                ),
                const Divider(),
                _lapsList(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _lapsList(BuildContext context) {
    return StreamBuilder<Map<int, Map<int, Lap>>>(
      stream: lapsStream(),
      builder: niceAsyncBuilder(
        loadingText: "Getting laps...",
        activeBuilder: (BuildContext c, snapshot) {
          var laps = snapshot.data!.entries.toList();
          laps.sort(
              (a, b) => (sortDescending ? -1 : 1) * b.key.compareTo(a.key));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: laps.map((entry) => _lapTile(context, entry)).toList(),
          );
        },
      ),
    );
  }

  Widget _lapTile(BuildContext context, MapEntry<int, Map<int, Lap>> entry) {
    return ListTile(
        leading: Text("${entry.key}."),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: entry.value.values
              .map((lap) => Text("${lap.lapTime.inMilliseconds / 1000}"))
              .toList(),
        ),
        onTap: () {
          Navigator.of(context).pushNamed("/lap", arguments: entry);
        });
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
