import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RaceBrowserScreen extends StatefulWidget {
  RaceBrowserScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RaceBrowserScreenState();
}

class RaceBrowserScreenState extends State<RaceBrowserScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Race Browser"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('races').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();

            return _buildListView(snapshot.data.docs);
          }),
    );
  }

  Widget _buildListView(List<DocumentSnapshot> snapshots) {
    return ListView(
      children: snapshots
          .map((snapshot) => _buildListItem(context, snapshot))
          .toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    Race race = Race.fromSnapshot(snapshot);

    return Padding(
      key: ValueKey(race.dateTime),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(race.dateTime.toString()),
          trailing:
              Text("${race.lapTimes[0].length} / ${race.lapTimes[1].length}"),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RaceViewer(race),
          )),
        ),
      ),
    );
  }
}

class RaceViewer extends StatelessWidget {
  RaceViewer(this.race, {Key key}) : super(key: key);

  final Race race;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${race.dateTime}"),
      ),
      body: _buildGridView(race),
    );
  }

  Widget _buildGridView(Race race) {
    int nCars = race.lapTimes.length;

    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: nCars),
      itemCount: List.generate(nCars, (i) => race.lapTimes[i].length)
          .fold(0, (p, c) => p + c),
      itemBuilder: (c, i) =>
          _buildListItem(race.lapTimes[i % nCars][i ~/ nCars].toDouble()),
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

class Race {
  List<List<dynamic>> lapTimes = [];
  DateTime dateTime;
  DocumentReference reference;

  Race.fromMap(Map<String, dynamic> map, {this.reference}) {
    assert(map["dateTime"] != null);
    this.dateTime = map["dateTime"].toDate();

    for (int i = 0; i < 4; i++) if (map["$i"] != null) lapTimes.add(map["$i"]);
  }

  Race.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Race<$dateTime:$lapTimes>";
}
