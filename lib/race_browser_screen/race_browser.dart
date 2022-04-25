import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/race_browser_screen/race_viewer_screen.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

class RaceBrowserScreen extends StatefulWidget {
  /// Widget for viewing the races currently on the database.
  const RaceBrowserScreen({Key? key, this.includeCurrentRace = false})
      : super(key: key);

  /// If true, will include "current" race in the list.
  final bool includeCurrentRace;

  @override
  State<StatefulWidget> createState() => RaceBrowserScreenState();
}

class RaceBrowserScreenState extends State<RaceBrowserScreen> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        /// Will always return _racesList.
        /// To push any other screen, use Navigator.push()
        return MaterialPageRoute(builder: (c) => _racesList());
      },
    );
  }

  Widget _racesList() {
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
                    races.map((raceSnap) => _raceCard(c, raceSnap)).toList());
          },
        ),
      ),
    );
  }

  /// Widget for displaying basic information about a race as a Card.
  Widget _raceCard(BuildContext context, DocumentSnapshot<Race> raceSnap) {
    return Card(
      child: ListTile(
        title: Text(raceString(raceSnap)),
        subtitle: Text(raceSnap.id),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => showDialog(
            context: context,
            builder: (c) => ConfirmationDialog(
              text:
                  "Are you sure you want to delete this race? \nID: ${raceSnap.id}",
              onConfirm: () => setState(() {
                raceSnap.reference.delete();
              }),
            ),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (c) => (RaceViewerScreen(raceSnap: raceSnap))),
        ),
      ),
    );
  }
}
