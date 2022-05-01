import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/race_browser_screen/lap_viewer_screen.dart';
import 'package:marklin_bluetooth/race_browser_screen/race_viewer_screen.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Widget for viewing the races currently on the database
class RaceBrowserScreen extends StatefulWidget {
  const RaceBrowserScreen({Key? key, this.includeCurrentRace = false})
      : super(key: key);

  final bool includeCurrentRace;

  @override
  State<StatefulWidget> createState() => RaceBrowserScreenState();
}

class RaceBrowserScreenState extends State<RaceBrowserScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool popHandled = await navigatorKey.currentState?.maybePop() ?? false;
        return !popHandled;
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: "/",
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (c) {
            switch (settings.name) {
              case "/":
                return _racesList();

              case "/race":
                assert(
                  settings.arguments is DocumentSnapshot<Race>,
                  "Invalid raceSnap given for route to RaceViewerScreen",
                );

                return RaceViewerScreen(
                  raceSnap: settings.arguments as DocumentSnapshot<Race>,
                );

              case "/lap":
                assert(
                  settings.arguments is MapEntry<int, Map<int, Lap>>,
                  "Invalid lapEntry given for route to LapViewerScreen",
                );

                MapEntry<int, Map<int, Lap>> lapEntry =
                    settings.arguments as MapEntry<int, Map<int, Lap>>;
                return LapViewerScreen(
                  lapNumber: lapEntry.key,
                  laps: lapEntry.value,
                );

              default:
                throw (Exception("Unknown route: ${settings.name}"));
            }
          });
        },
      ),
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
          onTap: () {
            Navigator.of(context).pushNamed("/race", arguments: raceSnap);
          }),
    );
  }
}
