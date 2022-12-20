import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/old_race.dart';
import 'package:marklin_bluetooth/firebase/old_speed_entry.dart';

/// Helper class for interacting with a Race on the database.
class OldRaceReference {
  /// The Race Document on firebase that [this] references.
  final DocumentReference<OldRace> docRef;

  /// The Race that [this] references.
  Future<OldRace> get race async => (await docRef.get()).data()!;

  /// Whether [this.race] is running or not.
  Stream<bool> get runningStream =>
      docRef.snapshots().map((doc) => doc.get("running"));

  OldRaceReference({required this.docRef})
      : carRefs = List.generate(
            4,
            (carID) => CarReference(
                  carID: carID,
                  collRef: docRef.collection("$carID"),
                ));

  final List<CarReference> carRefs;

  /// The reference to the car with id [carID] on [this.race].
  CarReference carRef(int carID) => carRefs[carID];

  /// Add time since current lap to lap times of [carID] on [this.race],
  /// if current lap exists.
  Future<void> addLap(int carID, {Duration? lapTime, int? lapN}) async {
    OldRace race = await this.race;
    if (!race.running) return; // Not running
    if (carID >= race.nCars) return; // Trying to add lap to car not in race

    CarReference car = carRef(carID);

    DateTime timeNow = DateTime.now();

    lapTime ??= timeNow.difference(car.currentLap.date);

    // Create new lap
    car.currentLap.lapTime = lapTime;
    await car.lapsRef.add(car.currentLap);

    // Update current lap
    car.currentLap.date = timeNow;
    car.currentLap.lapNumber = car.currentLap.lapNumber + 1;
  }

  /// Add [speed] to speed history of the current lap of car with id [carID]
  /// on [this.race].
  Future<void> addSpeedEntry(int carID, double speed) async {
    OldRace race = (await this.race);
    if (!race.running) return; // Not running
    if (carID >= race.nCars) return; // Trying to add lap to car not in race

    CarReference car = carRef(carID);

    Duration relTime = DateTime.now().difference(car.currentLap.date);

    car.currentLap.speedHistory.add(OldSpeedEntry(relTime, speed));
  }

  /// Delete all laps on [this.race].
  Future<void> clear() async {
    Timestamp timeNow = Timestamp.now();

    // Reset cars
    for (CarReference car in carRefs) {
      car.clear();
    }

    // Reset date
    await docRef.update({"date": timeNow});
  }

  /// Delete [this.race] from the database.
  Future<void> delete() async {
    await docRef.delete();
  }
}
