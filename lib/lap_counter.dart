import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/race_handler.dart';

import 'package:marklin_bluetooth/widgets.dart';

/// Receives lap times from [Bluetooth.device] and stores them on a Cloud
/// Firestore database, using [RaceHandler] to read and write data.
///
/// Also features buttons for adding laps manually (used for debugging).
class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  RaceHandler raceHandler = RaceHandler();

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
        actions: [
          IconButton(
              onPressed: () => showNewDialog(context),
              icon: Icon(Icons.add, color: Colors.white)),
        ],
      ),
      body: Row(children: [
        Expanded(child: lapViewer(0)),
        VerticalDivider(
          thickness: 1.0,
        ),
        Expanded(child: lapViewer(1))
      ]),
    );
  }

  Widget lapViewer(int carID) {
    return StreamBuilder<QuerySnapshot>(
        stream: raceHandler
            .carCollection(carID)
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (c, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return LoadingScreen(text: "Getting lap times...");

          if (snapshot.hasError)
            return ErrorScreen(text: "Error: ${snapshot.error}");

          return Column(children: [
            Expanded(
                child: ListView(
              children: snapshot.data!.docs
                  .map(
                    (doc) => TextTile(
                      title:
                          "${doc.get("lapNumber")}  |  ${doc.get("lapTime")}s",
                      text: (doc.get("date") as Timestamp).toDate().toString(),
                    ),
                  )
                  .toList(),
            )),
            ElevatedButton(
              onPressed: () {
                // Add lap to database
                var lapTime = lapTimers[carID].elapsedMilliseconds / 1000;
                raceHandler.addLap(carID, lapTime,
                    lapN: snapshot.data!.docs.length + 1);

                // Restart timer
                lapTimers[carID].reset();
              },
              child: TimerText(stopwatch: lapTimers[carID]),
            ),
          ]);
        });
  }

  void showNewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => StartDialog(
        onSave: () {
          raceHandler.saveCurrentRace().then((_) => setState(() {}));
          restartTimers();
        },
        onDiscard: () {
          raceHandler.clearCurrentRace();
          restartTimers();
        },
      ),
    );
  }

  void restartTimers() {
    for (final timer in lapTimers) {
      timer.reset();
    }
  }
}

/// Popup dialog for starting a new race.
/// Includes option to save or discard current race.
class StartDialog extends StatefulWidget {
  final Function? onCancel;
  final Function? onDiscard;
  final Function? onSave;

  StartDialog({Key? key, this.onCancel, this.onDiscard, this.onSave})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StartDialogState();
}

class StartDialogState extends State<StartDialog> {
  bool discardDialog = false;

  @override
  Widget build(BuildContext context) {
    return (!discardDialog)
        ? AlertDialog(
            title: Text("Start new race"),
            content: Text(
                "You are about to start a new race.\nSave the current race to the database?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  widget.onCancel?.call();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text("Discard"),
                onPressed: () {
                  setState(() {
                    discardDialog = true;
                  });
                },
              ),
              TextButton(
                child: Text("Save", style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  widget.onSave?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text("Discard race?"),
            content: Text(
                "You are about to restart the race and clear all laps. \nThis action can't be undone."),
            actions: [
              TextButton(
                child: Text("Cancel", style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    discardDialog = false;
                  });
                },
              ),
              TextButton(
                child: Text("Discard"),
                onPressed: () {
                  widget.onDiscard?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
  }
}
