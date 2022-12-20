import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/old_race.dart';
import 'package:marklin_bluetooth/firebase/old_race_reference.dart';

/// Helper class for creating, deleting and updating races
/// on the Firestore database.
///
/// Requires Firebase to be initalized (Firebase.initializeApp()).
class Races {
  /// All the races on the database
  static final CollectionReference<OldRace> races =
      FirebaseFirestore.instance.collection("races").withConverter<OldRace>(
            fromFirestore: (snapshot, _) => OldRace.fromJson(snapshot.data()!),
            toFirestore: (race, _) => race.toJson(),
          );

  static final DocumentReference<OldRace> currentRaceDoc = races.doc("current");
  static final OldRaceReference currentRaceRef =
      OldRaceReference(docRef: currentRaceDoc);

  /// Copy current race to a new race, then clear the current race.
  static Future<void> saveCurrentRace() async {
    OldRace race = (await currentRaceDoc.get()).data()!;
    race.date = Timestamp.now();
    DocumentReference<OldRace> newRaceDocRef = await races.add(race);

    // Copy laps
    for (var carID = 0; carID < (await currentRaceRef.race).nCars; carID++) {
      for (var lapSnap in await currentRaceRef.carRef(carID).getLapDocs()) {
        newRaceDocRef
            .collection("$carID")
            .doc(lapSnap.id)
            .set(lapSnap.data()!.toJson());
      }
    }
    await OldRaceReference(docRef: currentRaceDoc).clear();
  }
}
