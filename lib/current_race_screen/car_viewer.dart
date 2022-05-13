import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/race_browser_screen/lap_viewer_screen.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

class CarViewer extends StatelessWidget {
  /// Widget for displaying all the laps for a car as a list.
  const CarViewer({Key? key, required this.carRef}) : super(key: key);

  /// Reference to the car for which to display laps.
  final CarReference carRef;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Lap>>(
      stream: carRef.lapsRef.orderBy("date", descending: true).snapshots(),
      builder: niceAsyncBuilder(
        loadingText: "Getting lap times...",
        activeBuilder: (BuildContext c, snapshot) {
          List<QueryDocumentSnapshot<Lap>> docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((lapSnap) {
              Lap lap = lapSnap.data();
              return TextTile(
                  title:
                      "${lap.lapNumber} | ${lap.lapTime.inMilliseconds / 1000}s",
                  text: dateString((lap.date)),
                  onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (c) => (LapViewerScreen(
                            lapNumber: lap.lapNumber,
                            laps: {carRef.carID: lap},
                          )),
                        ),
                      ));
            }).toList(),
          );
        },
      ),
    );
  }
}
