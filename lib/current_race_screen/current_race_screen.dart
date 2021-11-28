import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/current_race_screen/dialogs.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/race_viewer.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Screen for watching and restarting the current race.
class CurrentRaceScreen extends StatefulWidget {
  const CurrentRaceScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CurrentRaceScreenState();
}

class CurrentRaceScreenState extends State<CurrentRaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Race"),
      ),
      body: RaceViewer(raceRef: Races.currentRaceRef),
      floatingActionButton: StreamBuilder<bool>(
        stream: Races.currentRaceRef.runningStream,
        builder: niceAsyncBuilder(
          activeBuilder: (c, snapshot) {
            bool running = snapshot.data;
            return FloatingActionButton(
              child: Icon(running ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  if (running) {
                    // Stop race
                    showNewDialog(context);
                  } else {
                    // Start race
                    Races.currentRaceDoc.update({
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
          await Races.saveCurrentRace();
          restartRace(nCars);
        },
        onDiscard: (int nCars) async {
          await Races.currentRaceRef.clear();
          restartRace(nCars);
        },
      ),
    );
  }

  void restartRace(int nCars) async {
    await Races.currentRaceDoc.update({
      "running": false,
      "nCars": nCars,
    });
    setState(() {});
  }
}
