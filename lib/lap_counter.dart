import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:marklin_bluetooth/widgets.dart';

class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  CollectionReference races = FirebaseFirestore.instance.collection("races");
  DocumentReference race;
  Stream<DocumentSnapshot> raceStream;

  List<Stopwatch> lapTimers = List.generate(4, (index) => Stopwatch()..start());

  @override
  void initState() {
    super.initState();

    race = races.doc("test");
    raceStream = races.doc("test").snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => _showQuitDialog(context),
              icon: Icon(Icons.bluetooth_disabled, color: Colors.white)),
          title: Text("Lap Counter"),
          actions: [
            IconButton(
                onPressed: () => _showRestartDialog(context),
                icon: Icon(Icons.clear, color: Colors.white))
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: raceStream,
            builder: (c, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return InfoScreen(
                  icon: CircularProgressIndicator(),
                  text: "Connecting to device...",
                );

              if (snapshot.hasError)
                return InfoScreen(
                  icon: Icon(Icons.error),
                  text: "Error: ${snapshot.error}",
                );

              var doc = snapshot.data.data();
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
            }));
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
        RaisedButton(
          onPressed: () {
            setState(() {
              var time = lapTimers[carID].elapsedMilliseconds / 1000;
              lapTimers[carID].reset();

              // Write to database
              race.get().then((doc) {
                var newTimes = doc.data()["$carID"] + [time];
                race.update({"$carID": newTimes});
              });
            });
          },
          color: Theme.of(context).primaryColor,
          child: Icon(Icons.plus_one),
        )
      ],
    );
  }

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => QuitDialog(
        onQuit: () => widget.device.disconnect(),
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Restart race?"),
        content: Text(
            "You are about to restart the race and clear all laps. This action can't be undone. \nContinue?"),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          FlatButton(
              onPressed: () {
                setState(() {
                  // Clear lap times on database
                  race.update({"0": [], "1": []});

                  // Restart timers
                  for (final timer in lapTimers) {
                    timer.reset();
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text("Yes")),
        ],
      ),
    );
  }
}
