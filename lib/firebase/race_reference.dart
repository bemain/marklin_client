import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';

/// Helper class for interacting with a Race on the database.
class RaceReference {
  /// The Race Document on firebase that [this] references.
  final DocumentReference<Race> docRef;

  /// The Race that [this] references.
  Future<Race> get race async => (await docRef.get()).data()!;

  /// Whether [this.race] is running or not.
  Stream<bool> get runningStream =>
      docRef.snapshots().map((doc) => doc.get("running"));

  RaceReference({required this.docRef});

  /// The reference to the car with id [carID] on [this.race].
  CarReference carRef(int carID) =>
      CarReference(collRef: docRef.collection("$carID"));

  /// Add time since last lap, or since the race was started if no laps have
  /// been run, to lap times of [carID] on [this.race].
  Future<void> addLap(int carID, {double? lapTime, int? lapN}) async {
    if (carID >= (await race).nCars)
      return; // Trying to add lap to car not in race

    CarReference car = carRef(carID);
    Lap currentLap = await car.currentLap;

    Timestamp timeNow = Timestamp.now();

    lapTime ??= (timeNow.millisecondsSinceEpoch -
            currentLap.date.millisecondsSinceEpoch) ~/
        10 /
        100;
    lapN = currentLap.lapNumber + 1;

    // Create new lap
    await car.lapsRef.add(Lap(
      date: currentLap.date,
      lapTime: lapTime,
      lapNumber: currentLap.lapNumber,
    ));

    // Update current lap
    await car.currentLapRef.set(Lap(
      date: timeNow,
      lapTime: 0,
      lapNumber: currentLap.lapNumber + 1,
    ));
  }

  /// Delete all laps on [this.race].
  Future<void> clear() async {
    Timestamp timeNow = Timestamp.now();

    for (var carID = 0; carID < (await race).nCars; carID++) {
      CarReference car = carRef(carID);
      // Delete laps
      for (var lap in (await car.getLapDocs(includeCurrent: true))) {
        await lap.reference.delete();
      }
      // Create current lap
      await car.lapsRef.doc("current").set((Lap(
            date: timeNow,
            lapTime: 0,
            lapNumber: 1,
          )));
    }

    await docRef.update({"date": timeNow});
  }
}
