import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/widgets.dart';

final int nCars = 2;

/// Helper class for creating, deleting and updating races
/// on the Firestore database.
///
/// Requires Firebase to be initalized (Firebase.initializeApp()).
class RaceHandler {
  static final races = FirebaseFirestore.instance.collection("races");
  final DocumentReference currentRace = races.doc("current");

  /// Realtime changes to the current race
  /// Subscribe with listen()
  Stream<DocumentSnapshot> get currentRaceStream => currentRace.snapshots();

  /// Get the collection that contains all laps for the car with id [carID]
  /// on the current race.
  CollectionReference carCollection(carID) => currentRace.collection("$carID");

  /// Add [lapTime] to lap times of [carID] on current race
  Future addLap(int carID, double lapTime, {int? lapN}) async {
    await carCollection(carID).add({
      "lapTime": lapTime,
      "lapNumber": lapN ?? 0,
      "date": Timestamp.now(),
    });
  }

  /// Delete all laps on current race
  Future clearCurrentRace() async {
    for (var i = 0; i < nCars; i++)
      for (var doc in (await carCollection(i).get()).docs)
        await doc.reference.delete();
  }

  /// Copy current race to a new race, then clear current laps
  Future saveCurrentRace() async {
    var data = (await currentRace.get()).data() as Map<String, dynamic>;
    data["date"] = Timestamp.now();
    var newRace = await races.add(data);

    // Copy laps
    for (var carID = 0; carID < nCars; carID++) {
      var coll = await carCollection(carID).get();
      for (var doc in coll.docs) {
        var data = doc.data() as Map<String, dynamic>;
        newRace.collection("$carID").doc(doc.id).set(data);
      }
    }

    clearCurrentRace();
  }
}

/// Makes sure Firebase is initialized before [child] enters the tree.
class InitFirebase extends StatefulWidget {
  final Widget child;

  InitFirebase({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InitFirebaseState();
}

class InitFirebaseState extends State<InitFirebase> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (c, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Scaffold(body: LoadingScreen(text: "Initalizing Firebase..."));

        if (snapshot.hasError)
          return Scaffold(body: ErrorScreen(text: "Error: ${snapshot.error}"));

        return widget.child;
      },
    );
  }
}
