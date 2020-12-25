import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/widgets.dart';

class RaceBrowserScreen extends StatefulWidget {
  RaceBrowserScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RaceBrowserScreenState();
}

class RaceBrowserScreenState extends State<RaceBrowserScreen> {
  CollectionReference races = FirebaseFirestore.instance.collection("races");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Race Browser"),
      ),
      body: RaceSelector(
        onSelect: (raceSnapshot) => Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => RaceViewer(raceSnapshot))),
      ),
    );
  }
}

class RaceViewer extends StatelessWidget {
  RaceViewer(this.raceSnapshot, {Key key}) : super(key: key);

  final DocumentSnapshot raceSnapshot;

  @override
  Widget build(BuildContext context) {
    var race = raceSnapshot.data();
    return Scaffold(
      appBar: AppBar(
        title: Text("${race["dateTime"].toDate().toString()}"),
      ),
      body: _buildGridView(race),
    );
  }

  Widget _buildGridView(Map race) {
    int nCars = 2;

    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: nCars),
      itemCount: List.generate(nCars, (i) => race["$i"].length)
          .fold(0, (p, c) => p + c),
      itemBuilder: (c, i) =>
          _buildListItem(race["${i % nCars}"][i ~/ nCars].toDouble()),
    );
  }

  Widget _buildListItem(double lapTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Center(child: Text(lapTime.toString())),
        ),
      ),
    );
  }
}
