import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/firebase/race.dart';

class RaceReference {
  RaceReference({required this.docRef});

  final DocumentReference<Race> docRef;

  Future<Race> get() async => (await docRef.get()).data()!;

  CarReference carRef(int carID) =>
      CarReference(collRef: docRef.collection("$carID"));

  /// Whether the current race is running or not.
  Stream<bool> get runningStream =>
      docRef.snapshots().map((doc) => doc.get("running"));

  /// Add time since last lap, or since the race was started if no laps have
  /// been run, to lap times of [carID] on the current race.
  Future addLap(int carID, {double? lapTime, int? lapN}) async {
    if (carID >= (await get()).nCars) {
      return; // Trying to add lap to car not in race
    }

    Race race = await get();
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

  /// Delete all laps on this race
  Future clear() async {
    for (var carID = 0; carID < (await get()).nCars; carID++) {
      for (var lap in (await carRef(carID).lapsRef.get()).docs) {
        await lap.reference.delete();
      }
    }

    await docRef.update({"date": Timestamp.now()});
  }
}
