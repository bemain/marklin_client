import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/race_reference.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

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
                  ? Expanded(child: LapsViewer(carRef: raceRef.carRef(i ~/ 2)))
                  : const VerticalDivider(thickness: 1.0),
            ),
          );
        },
      ),
    );
  }
}

class LapsViewer extends StatelessWidget {
  final CarReference carRef;
  final Function(DocumentReference<Lap> lapRef)? onLapSelected;

  const LapsViewer({Key? key, required this.carRef, this.onLapSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Lap>>(
      stream: carRef.lapsRef.orderBy("date", descending: true).snapshots(),
      builder: niceAsyncBuilder(
        loadingText: "Getting lap times...",
        activeBuilder: (BuildContext c, snapshot) {
          List<QueryDocumentSnapshot<Lap>> docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((lapSnap) {
              Lap lap = lapSnap.data();
              return TextTile(
                title: "${lap.lapNumber} | ${lap.lapTime}s",
                text: dateString((lap.date).toDate()),
                onTap: () => onLapSelected?.call(lapSnap.reference),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
