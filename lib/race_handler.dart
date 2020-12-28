import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for creating, deleting and updating races
/// on the Firestore database.
class RaceHandler {
  // TODO: Add sandbox mode that doesn't read / write to the database. For testing and offline mode
  CollectionReference races = FirebaseFirestore.instance.collection("races");
  DocumentReference _race;
  Stream<DocumentSnapshot> stream;

  // Getters + Setters
  DocumentReference get race => _race;
  set race(DocumentReference newRace) {
    _race = newRace;
    stream = newRace.snapshots();
  }

  set raceByName(String name) => race = races.doc(name);

  // Constructors
  RaceHandler(raceName) {
    raceByName = raceName;
  }

  // Methods
  Future<void> addLap(int carID, double lapTime) async {
    var doc = await race.get();
    var newTimes = doc.data()["$carID"] + [lapTime];

    await race.update({"$carID": newTimes});
  }

  Future<void> clearLaps() async {
    await race.update({"0": [], "1": []});
  }

  /// Creates a new race on the database and switches to it
  Future<void> startRace() async {
    race = await races.add({"dateTime": Timestamp.now(), "0": [], "1": []});
  }
}
