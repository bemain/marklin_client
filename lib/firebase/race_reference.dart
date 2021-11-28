import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';

/// Helper class for interacting with a Race on the database.
class RaceReference {
  RaceReference({required this.docRef});

  /// The Race Document on firebase that [this] references.
  final DocumentReference<Race> docRef;

  /// The Race that [this] references.
  Future<Race> get race async => (await docRef.get()).data()!;

  /// The reference to the car with id [carID] on [race].
  CarReference carRef(int carID) =>
      CarReference(collRef: docRef.collection("$carID"));

  /// Whether [race] is running or not.
  Stream<bool> get runningStream =>
      docRef.snapshots().map((doc) => doc.get("running"));

  /// Add time since last lap, or since the race was started if no laps have
  /// been run, to lap times of [carID] on the Race that [this] references.
  Future<void> addLap(int carID, {double? lapTime, int? lapN}) async {
    if (carID >= (await this.race).nCars) {
      return; // Trying to add lap to car not in race
    }

    Race race = await this.race;
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

  /// Delete all laps on the Race that [this] references.
  Future<void> clear() async {
    for (var carID = 0; carID < (await race).nCars; carID++) {
      for (var lap in (await carRef(carID).lapsRef.get()).docs) {
        await lap.reference.delete();
      }
    }

    await docRef.update({"date": Timestamp.now()});
  }
}
