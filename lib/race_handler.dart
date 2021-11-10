import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Helper class for creating, deleting and updating races
/// on the Firestore database.
///
/// Requires Firebase to be initalized (Firebase.initializeApp()).
class RaceHandler {
  final races = FirebaseFirestore.instance.collection("races");

  /// Get the current race.
  DocumentReference get currentRace => races.doc("current");

  /// Get the collection that contains all laps for the car with id [carID]
  /// on the current race.
  CollectionReference carCollection(carID) => currentRace.collection("$carID");

  /// nCars for [currentRace]
  Future<int> get nCars async => (await currentRace.get()).get("nCars");
  set nCars(value) => currentRace.update({"nCars": value.toInt()});

  /// Add time since last lap, or since the race was started if no laps have
  /// been run, to lap times of [carID] on the current race.
  Future addLap(int carID, {double? lapTime, int? lapN}) async {
    if (carID >= await nCars) return; // Trying to add lap to car not in race

    Timestamp timeNow = Timestamp.now();

    lapTime ??= await _getLapTime(carID, timeNow);
    lapN ??= (await carCollection(carID).get()).docs.length + 1;

    await carCollection(carID).add({
      "lapTime": lapTime,
      "lapNumber": lapN,
      "date": timeNow,
    });
  }

  /// Get time since last lap, or since race started if first lap.
  Future<double> _getLapTime(int carID, Timestamp timeNow) async {
    var query = await carCollection(carID)
        .orderBy("date", descending: true)
        .limit(1)
        .get();
    Timestamp timePrev = query.docs.isEmpty
        ? (await currentRace.get()).get("date") // Time since race started
        : query.docs[0].get("date"); // Time since last lap

    return (timeNow.millisecondsSinceEpoch - timePrev.millisecondsSinceEpoch) ~/
        10 /
        100;
  }

  /// Delete all laps on current race
  Future clearCurrentRace() async {
    for (var i = 0; i < (await nCars); i++)
      for (var doc in (await carCollection(i).get()).docs)
        await doc.reference.delete();

    await currentRace.update({"date": Timestamp.now()});
  }

  /// Copy current race to a new race, then clear current laps
  Future saveCurrentRace() async {
    var data = (await currentRace.get()).data() as Map<String, dynamic>;
    data["date"] = Timestamp.now();
    var newRace = await races.add(data);

    // Copy laps
    for (var carID = 0; carID < (await nCars); carID++) {
      var coll = await carCollection(carID).get();
      for (var doc in coll.docs) {
        var data = doc.data() as Map<String, dynamic>;
        newRace.collection("$carID").doc(doc.id).set(data);
      }
    }
    await clearCurrentRace();
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
