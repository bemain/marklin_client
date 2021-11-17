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
      floatingActionButton: StreamBuilder<bool>(
        stream: raceHandler.runningStream,
        builder: niceAsyncBuilder(
          activeBuilder: (c, snapshot) {
            bool running = snapshot.data;
            return FloatingActionButton(
              child: Icon(running ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  if (running) {
                    // Stop race
                    raceHandler.running = false;
                    showNewDialog(context);
                  } else {
                    // Start race
                    raceHandler.currentRace.update({
                      "date": Timestamp.now(),
                      "running": true,
                    });
                  }
                });
              },
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void showNewDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (c) => NewRaceDialog(
        onSave: (int nCars) async {
          await raceHandler.saveCurrentRace();
          raceHandler.nCars = nCars;
          setState(() {});
        },
        onDiscard: (int nCars) async {
          await raceHandler.clearCurrentRace();
          raceHandler.nCars = nCars;
          setState(() {});
        },
      ),
    );
  }
}
