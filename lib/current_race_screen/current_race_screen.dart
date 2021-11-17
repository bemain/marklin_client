import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/current_race_screen/dialogs.dart';
import 'package:marklin_bluetooth/race_handler.dart';
import 'package:marklin_bluetooth/race_viewer.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Screen for watching and restarting the current race.
class CurrentRaceScreen extends StatefulWidget {
  const CurrentRaceScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CurrentRaceScreenState();
}

class CurrentRaceScreenState extends State<CurrentRaceScreen> {
  final RaceHandler raceHandler = RaceHandler();

  bool _paused = false;

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
      body: FutureBuilder<DocumentSnapshot>(
        future: raceHandler.currentRace.get(),
        builder: niceAsyncBuilder(
          loadingText: "Determining number of cars...",
          activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
            return RaceViewer(raceDoc: snapshot.data);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_paused ? Icons.play_arrow : Icons.pause),
        onPressed: () {
          setState(() {
            _paused = !_paused;
            if (_paused) {
              showNewDialog(context);
            }
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
