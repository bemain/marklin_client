import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/race_reference.dart';

/// Helper class for creating, deleting and updating races
/// on the Firestore database.
///
/// Requires Firebase to be initalized (Firebase.initializeApp()).
class Races {
  /// All the races on the database
  static CollectionReference<Race> races =
      FirebaseFirestore.instance.collection("races").withConverter<Race>(
            fromFirestore: (snapshot, _) => Race.fromJson(snapshot.data()!),
            toFirestore: (race, _) => race.toJson(),
          );

  static DocumentReference<Race> currentRaceDoc = races.doc("current");
  static RaceReference currentRaceRef = RaceReference(docRef: currentRaceDoc);

  /// Copy current race to a new race, then clear the current race.
  static Future<void> saveCurrentRace() async {
    Race race = (await currentRaceDoc.get()).data()!;
    race.date = Timestamp.now();
    DocumentReference<Race> newRaceDocRef = await races.add(race);

    // Copy laps
    for (var carID = 0; carID < (await currentRaceRef.race).nCars; carID++) {
      for (var lapSnap in await currentRaceRef
          .carRef(carID)
          .getLapDocs(includeCurrent: false)) {
        newRaceDocRef
            .collection("$carID")
            .doc(lapSnap.id)
            .set(lapSnap.data()!.toJson());
      }
    }
    await RaceReference(docRef: currentRaceDoc).clear();
  }
}
