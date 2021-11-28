import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
          Race race = snapshot.data;

          return Row(
            children: List.generate(
              race.nCars * 2 - 1,
              (i) => i.isEven
                  ? Expanded(child: lapViewer(raceRef, i ~/ 2))
                  : const VerticalDivider(thickness: 1.0),
            ),
          );
        },
      ),
    );
  }

  Widget lapViewer(RaceReference raceRef, int carID) {
    return StreamBuilder<QuerySnapshot>(
      stream: raceRef.docRef
          .collection("$carID")
          .orderBy("date", descending: true)
          .snapshots(),
      builder: niceAsyncBuilder(
        loadingText: "Getting lap times...",
        activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          return ListView(
            children: docs
                .map(
                  (doc) => TextTile(
                    title: "${doc.get("lapNumber")} | ${doc.get("lapTime")}s",
                    text: dateString((doc.get("date") as Timestamp).toDate()),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
