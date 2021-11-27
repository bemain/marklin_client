import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/race_viewer.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Widget for viewing the races currently on the database
class RaceBrowserScreen extends StatefulWidget {
  const RaceBrowserScreen({Key? key, this.includeCurrentRace = true})
      : super(key: key);

  final bool includeCurrentRace;

  @override
  State<StatefulWidget> createState() => RaceBrowserScreenState();
}

class RaceBrowserScreenState extends State<RaceBrowserScreen> {
  final Races raceHandler = Races();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Browser"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Races.races.orderBy("date", descending: true).snapshots(),
          builder: niceAsyncBuilder(
            loadingText: "Getting races...",
            activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
              List<DocumentSnapshot<Race>> docs = snapshot.data!.docs;

              if (!widget.includeCurrentRace) {
                // Remove current race
                docs.removeWhere((element) => element.id == "current");
              }

              return ListView(
                  children: docs.map((doc) => raceCard(doc)).toList());
            },
          )),
    );
  }

  Widget raceCard(DocumentSnapshot<Race> raceDoc) {
    var title = raceString(raceDoc);
    return TextTile(
      title: title,
      text: raceDoc.id,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (c) => (RaceViewerScreen(raceDoc: raceDoc))),
      ),
    );
  }
}

/// Widget for displaying lap times and other information about [raceDoc].
/// TODO: Add button for deleting race
class RaceViewerScreen extends StatelessWidget {
  final Races raceHandler = Races();

  RaceViewerScreen({Key? key, required this.raceDoc}) : super(key: key);

  final DocumentSnapshot<Race> raceDoc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Viewing race: ${raceString(raceDoc)}"),
        ),
        body: RaceViewer(
          raceDoc: raceDoc,
        ));
  }
}

String raceString(DocumentSnapshot<Race> raceDoc) {
  Race race = raceDoc.data()!;
  DateTime date = race.date.toDate();
  return (raceDoc.id == "current") ? "Current" : dateString(date);
}
