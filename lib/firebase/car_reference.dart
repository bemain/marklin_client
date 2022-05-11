import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';

class CarReference {
  final int carID;

  final CollectionReference<Map<String, dynamic>> collRef;
  final CollectionReference<Lap> lapsRef;

  CarReference({required this.carID, required this.collRef})
      : lapsRef = collRef.withConverter<Lap>(
          fromFirestore: (snapshot, _) => Lap.fromJson(snapshot.data()!),
          toFirestore: (lap, _) => lap.toJson(),
        );

  /// The current lap for the car that [this] references.
  Lap currentLap = Lap(
    date: DateTime.now(),
    lapNumber: 1,
    lapTime: const Duration(),
  );

  /// The snapshots of all the laps currently on the database.
  Future<List<DocumentSnapshot<Lap>>> getLapDocs() async {
    return (await lapsRef.orderBy("lapNumber", descending: true).get()).docs;
  }

  /// Get all the laps currently on the database.
  Future<List<Lap>> getLaps() async {
    var docSnaps = await getLapDocs();
    return docSnaps.map((doc) => doc.data()!).toList();
  }

  Future<void> clear() async {
    // Delete laps
    for (var lap in (await getLapDocs())) {
      await lap.reference.delete();
    }
    // Reset current lap
    currentLap = Lap(
      date: DateTime.now(),
      lapNumber: 1,
      lapTime: const Duration(),
    );
  }
}
