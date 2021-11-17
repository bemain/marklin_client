import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/race_handler.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

class RaceViewer extends StatelessWidget {
  RaceViewer({Key? key, required this.raceDoc}) : super(key: key);

  final RaceHandler raceHandler = RaceHandler();
  final DocumentSnapshot raceDoc;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        raceDoc.get("nCars") * 2 - 1,
        (i) => i.isEven
            ? Expanded(child: lapViewer(raceDoc, i ~/ 2))
            : const VerticalDivider(thickness: 1.0),
      ),
    );
  }

  Widget lapViewer(DocumentSnapshot raceDoc, int carID) {
    return StreamBuilder<QuerySnapshot>(
      stream: raceDoc.reference
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
