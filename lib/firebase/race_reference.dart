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
    Race race = await this.race;

    if (carID >= race.nCars) return; // Trying to add lap to car not in race

    CarReference car = carRef(carID);
    Lap? lastLap = await car.lastLap;

    Timestamp timeNow = Timestamp.now();
    Timestamp timePrev = lastLap?.date ?? // Time since last lap
        race.date; // Time since race started

    lapTime ??=
        (timeNow.millisecondsSinceEpoch - timePrev.millisecondsSinceEpoch) ~/
            10 /
            100;
    lapN = (lastLap?.lapNumber ?? 0) + 1;

    await car.lapsRef.add(Lap(
      date: timeNow,
      lapTime: lapTime,
      lapNumber: lapN,
    ));
  }

  /// Delete all laps on [this.race].
  Future<void> clear() async {
    for (var carID = 0; carID < (await race).nCars; carID++) {
      for (var lap in (await carRef(carID).getLapDocs(includeCurrent: false))) {
        await lap.reference.delete();
      }
    }

    await docRef.update({"date": Timestamp.now()});
  }
}
