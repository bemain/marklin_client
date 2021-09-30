import 'package:cloud_firestore/cloud_firestore.dart';

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
    await races.add(data);

    clearCurrentRace();
  }
}
