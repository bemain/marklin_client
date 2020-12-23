import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:marklin_bluetooth/race_browser.dart';
import 'package:marklin_bluetooth/widgets.dart';

class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<int> laps = List.filled(4, 0);
  List<List<double>> lapTimes = List.filled(4, []);
  List<Stopwatch> lapTimers = List.filled(4, Stopwatch()..start());

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
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _lapViewer(0),
            VerticalDivider(
              thickness: 1.0,
            ),
            _lapViewer(1),
          ],
        ));
  }

  Widget _lapViewer(int carIndex) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Expanded(
          child: Center(
              child: Text(
        "${laps[carIndex]}",
        textScaleFactor: 5.0,
      ))),
      RaisedButton(
        onPressed: () {
          setState(() {
            laps[carIndex]++;
            lapTimes[carIndex]
                .add(lapTimers[carIndex].elapsedMilliseconds / 1000);
            lapTimers[carIndex].reset();

            print(lapTimes[carIndex]);
          });
        },
        color: Theme.of(context).primaryColor,
        child: Icon(Icons.plus_one),
      )
    ]);
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
                  "You are about to restart the race and clear all laps. \n\nDo you wish to continue?"),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel")),
                FlatButton(
                    onPressed: () {
                      setState(() {
                        laps = [0, 0];
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text("Yes")),
              ],
            ));
  }
}
