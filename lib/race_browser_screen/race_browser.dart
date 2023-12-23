import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/race_browser_screen/lap_viewer_screen.dart';
import 'package:marklin_bluetooth/race_browser_screen/race_viewer_screen.dart';
import 'package:marklin_bluetooth/race_browser_screen/races_list.dart';

class RaceBrowserScreen extends StatefulWidget {
  /// Widget for viewing the races currently on the database.
  const RaceBrowserScreen({super.key});

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
                return const RacesList();

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
}
