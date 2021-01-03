import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for creating, deleting and updating races
/// on the Firestore database.
class RaceHandler {
  static final races = FirebaseFirestore.instance.collection("races");
  final DocumentReference race = races.doc("current");
  final Stream<DocumentSnapshot> stream = races.doc("current").snapshots();

  // Constructors
  RaceHandler();

  // Methods
  Future<void> addLap(int carID, double lapTime) async {
    var doc = await race.get();
    var newTimes = doc.data()["$carID"] + [lapTime];

    await race.update({"$carID": newTimes, "dateTime": Timestamp.now()});
  }

  Future<void> clearLaps() async {
    await race.update({"0": [], "1": []});
  }

  /// Copy current race to a separate race, then clear laps
  Future<void> saveRace() async {
    var data = (await race.get()).data();
    data["dateTime"] = Timestamp.now();
    await races.add(data);

    clearLaps();
  }
}
