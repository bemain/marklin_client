import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/race_handler.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Widget for viewing the races currently on the database
class RaceBrowserScreen extends StatefulWidget {
  RaceBrowserScreen({Key? key}) : super(key: key);

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
      body: RacePicker(
        onSelect: (doc) => Navigator.of(context).push(
          MaterialPageRoute(builder: (c) => (RaceViewer(raceDoc: doc))),
        ),
      ),
    );
  }
}

/// Widget for displaying lap times and other information about [raceDoc].
/// TODO: Add button for deleting race
class RaceViewer extends StatelessWidget {
  final RaceHandler raceHandler = RaceHandler();

  RaceViewer({Key? key, required this.raceDoc}) : super(key: key);

  final DocumentSnapshot raceDoc;

  @override
  Widget build(BuildContext context) {
    var race = raceDoc.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text("${race["dateTime"].toDate().toString()}"),
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
          ]);
        });
  }
}
