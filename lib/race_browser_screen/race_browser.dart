import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/race_browser_screen/race_viewer.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Race Browser"),
      ),
      body: StreamBuilder<QuerySnapshot<Race>>(
          stream: Races.races.orderBy("date", descending: true).snapshots(),
          builder: niceAsyncBuilder(
            loadingText: "Getting races...",
            activeBuilder: (BuildContext c, snapshot) {
              List<DocumentSnapshot<Race>> races = snapshot.data!.docs;

              if (!widget.includeCurrentRace) {
                // Remove current race
                races.removeWhere((raceSnap) => raceSnap.id == "current");
              }

              return ListView(
                  children:
                      races.map((raceSnap) => raceCard(raceSnap)).toList());
            },
          )),
    );
  }

  Widget raceCard(DocumentSnapshot<Race> raceSnap) {
    var title = raceString(raceSnap);
    return TextTile(
      title: title,
      text: raceSnap.id,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (c) => (RaceViewerScreen(raceSnap: raceSnap))),
      ),
    );
  }
}
