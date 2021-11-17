import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/race_handler.dart';
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
  final RaceHandler raceHandler = RaceHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Browser"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              raceHandler.races.orderBy("date", descending: true).snapshots(),
          builder: niceAsyncBuilder(
            loadingText: "Getting races...",
            activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
              List<DocumentSnapshot> docs = snapshot.data!.docs;

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

  Widget raceCard(DocumentSnapshot raceDoc) {
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
  final RaceHandler raceHandler = RaceHandler();

  RaceViewerScreen({Key? key, required this.raceDoc}) : super(key: key);

  final DocumentSnapshot raceDoc;

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

String raceString(DocumentSnapshot raceDoc) {
  Map<String, dynamic> data = raceDoc.data() as Map<String, dynamic>;
  DateTime date = (data["date"] as Timestamp).toDate();
  return (raceDoc.id == "current") ? "Current" : dateString(date);
}
