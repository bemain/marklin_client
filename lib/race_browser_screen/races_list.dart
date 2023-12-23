import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

class RacesList extends StatefulWidget {
  /// Displays the races on Firebase as a list.
  /// Includes button to remove races.
  const RacesList({super.key, this.includeCurrentRace = false});

  /// If true, will include "current" race in the list.
  final bool includeCurrentRace;

  @override
  State<StatefulWidget> createState() => RacesListState();
}

class RacesListState extends State<RacesList> {
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
                  races.map((raceSnap) => _raceCard(c, raceSnap)).toList(),
            );
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
          onTap: () {
            Navigator.of(context).pushNamed("/race", arguments: raceSnap);
          }),
    );
  }
}
