import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/race_handler.dart';

import 'package:marklin_bluetooth/widgets.dart';

/// Receives lap times from [Bluetooth.device] and stores them on a Cloud Firestore
/// database, using [RaceHandler] to read and write data.
///
/// Also features buttons for adding laps manually (used for debugging).
class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  RaceHandler? raceHandler;

  List<Stopwatch> lapTimers = List.generate(4, (i) => Stopwatch()..start());

  @override
  void initState() {
    assert(Bluetooth.device != null); // Needs connected BT device

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lap Counter"),
          leading: IconButton(
              onPressed: () => _showQuitDialog(context),
              icon: Icon(Icons.bluetooth_disabled, color: Colors.white)),
          actions: [
            IconButton(
                onPressed: () => _showStartDialog(context),
                icon: Icon(Icons.add, color: Colors.white)),
            IconButton(
                onPressed: () => _showRestartDialog(context),
                icon: Icon(Icons.clear, color: Colors.white)),
          ],
        ),
        body: FutureBuilder(
            future: initFirebase(),
            builder: (c, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return LoadingScreen(text: "Initalizing Firebase...");

              if (snapshot.hasError)
                return ErrorScreen(text: "Error: ${snapshot.error}");

              return StreamBuilder<DocumentSnapshot>(
                  stream: raceHandler!.currentRaceStream,
                  builder: (c, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return LoadingScreen(text: "Getting lap times...");

                    if (snapshot.hasError)
                      return ErrorScreen(text: "Error: ${snapshot.error}");

                    var doc = snapshot.data!.data()! as Map<String, dynamic>;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _lapViewer(0, doc["0"].length),
                        VerticalDivider(
                          thickness: 1.0,
                        ),
                        _lapViewer(1, doc["1"].length),
                      ],
                    );
                  });
            }));
  }

  Future initFirebase() async {
    await Firebase.initializeApp(); // Initialize Firebase
    raceHandler = RaceHandler();
  }

  Widget _lapViewer(int carID, int laps) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Center(
            child: Text(
              "$laps",
              textScaleFactor: 5.0,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              // Add lap to database
              var lapTime = lapTimers[carID].elapsedMilliseconds / 1000;
              raceHandler?.addLap(carID, lapTime);

              // Restart timer
              lapTimers[carID].reset();
            });
          },
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor)),
          child: Icon(Icons.plus_one),
        )
      ],
    );
  }

  /// Popup Dialog for exiting this widget
  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => QuitDialog(
        onQuit: () => Bluetooth.device!.disconnect(),
      ),
    );
  }

  /// Popup Dialog for starting a new race
  void _showStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Start new race"),
        content: Text(
            "You are about to start a new race.\nThe current race will be saved to the database, and can be viewed through the RaceViewer screen."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
              onPressed: () {
                // Save current race to database
                raceHandler?.saveCurrentRace().then((_) => setState(() {}));

                Navigator.of(context).pop();
              },
              child: Text("Continue")),
        ],
      ),
    );
  }

  /// Popup Dialog for restarting the current race
  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Restart race?"),
        content: Text(
            "You are about to restart the race and clear all laps. This action can't be undone."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
              onPressed: () {
                setState(() {
                  // Clear laps on database
                  raceHandler?.clearCurrentRace();

                  // Restart timers
                  for (final timer in lapTimers) {
                    timer.reset();
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("Continue")),
        ],
      ),
    );
  }
}
