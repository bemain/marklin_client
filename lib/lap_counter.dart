import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'widgets.dart';

class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  final firestore = Firestore.instance;

  List<int> laps = List.filled(4, 0);
  List<List<double>> lapTimes = List.filled(4, []);
  List<Stopwatch> lapTimers = List.filled(4, Stopwatch()..start());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (c) => QuitDialog(
                        onQuit: () => widget.device.disconnect(),
                      )),
              icon: Icon(Icons.bluetooth_disabled, color: Colors.white)),
          title: Text("Lap Counter"),
          actions: [
            IconButton(
                onPressed: () => showDialog(
                    context: context, builder: (c) => _restartDialog(context)),
                icon: Icon(Icons.clear, color: Colors.white))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('races').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();

              return _buildListView(snapshot.data.documents);
            }));
  }

  Widget _buildListView(List<DocumentSnapshot> snapshots) {
    return ListView(
      children: snapshots.map((snapshot) => _buildListItem(snapshot)).toList(),
    );
  }

  Widget _buildListItem(DocumentSnapshot snapshot) {
    Record record = Record.fromSnapshot(snapshot);

    return Padding(
      key: ValueKey(record.time),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.time.toString()),
          trailing: Text(record.someInt.toString()),
          onTap: () => print(record),
        ),
      ),
    );
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

  Widget _restartDialog(context) {
    return AlertDialog(
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
    );
  }
}

class Record {
  final int someInt;
  //final Map<String, List<int>> lapTimes;
  final DateTime time;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['someInt'] != null),
        assert(map['time'] != null),
        assert(map['lapTimes'] != null),
        time = map['time'].toDate(),
        someInt = map['someInt'];
  //lapTimes = Map<String, dynamic>.from(map["lapTimes"]);

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$time:$someInt>";
}
