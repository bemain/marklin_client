import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/current_race_screen/dialogs.dart';
import 'package:marklin_bluetooth/race_handler.dart';
import 'package:marklin_bluetooth/utils.dart';

import 'package:marklin_bluetooth/widgets.dart';

/// Screen for watching and restarting the current race.
class CurrentRaceScreen extends StatefulWidget {
  const CurrentRaceScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CurrentRaceScreenState();
}

class CurrentRaceScreenState extends State<CurrentRaceScreen> {
  RaceHandler raceHandler = RaceHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Race"),
        actions: [
          IconButton(
              onPressed: () => showNewDialog(context),
              icon: const Icon(Icons.add, color: Colors.white)),
        ],
      ),
      body: FutureBuilder<int>(
        future: raceHandler.nCars,
        builder: niceAsyncBuilder(
          loadingText: "Determining number of cars...",
          activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
            return Row(
              children: List.generate(
                snapshot.data! * 2 - 1,
                (i) => i.isEven
                    ? Expanded(child: lapViewer(i ~/ 2))
                    : const VerticalDivider(thickness: 1.0),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget lapViewer(int carID) {
    return StreamBuilder<QuerySnapshot>(
      stream: raceHandler
          .carCollection(carID)
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
                    title: "${doc.get("lapNumber")}  |  ${doc.get("lapTime")}s",
                    text: dateString(doc.get("date").toDate()),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  void showNewDialog(BuildContext context) async {
    bool ret = false;
    await showDialog(
      context: context,
      builder: (c) => SaveRaceDialog(
        onCancel: () {
          ret = true;
        },
        onSave: () {
          raceHandler.saveCurrentRace().then((_) => setState(() {}));
        },
        onDiscard: () {
          raceHandler.clearCurrentRace();
        },
      ),
    );
    if (ret) return;

    await showDialog(
      context: context,
      builder: (c) => NewRaceDialog(
        onNew: (nCars) {
          raceHandler.nCars = nCars;
        },
      ),
    );

    setState(() {});
  }
}
