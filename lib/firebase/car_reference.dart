import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/old_lap.dart';

class CarReference {
  final int carID;

  final CollectionReference<Map<String, dynamic>> collRef;
  final CollectionReference<OldLap> lapsRef;

  CarReference({required this.carID, required this.collRef})
      : lapsRef = collRef.withConverter<OldLap>(
          fromFirestore: (snapshot, _) => OldLap.fromJson(snapshot.data()!),
          toFirestore: (lap, _) => lap.toJson(),
        );

  /// The current lap for the car that [this] references.
  OldLap currentLap = OldLap(
    date: DateTime.now(),
    lapNumber: 1,
    lapTime: const Duration(),
  );

  /// The snapshots of all the laps currently on the database.
  Future<List<DocumentSnapshot<OldLap>>> getLapDocs() async {
    return (await lapsRef.orderBy("lapNumber", descending: true).get()).docs;
  }

  /// Get all the laps currently on the database.
  Future<List<OldLap>> getLaps() async {
    var docSnaps = await getLapDocs();
    return docSnaps.map((doc) => doc.data()!).toList();
  }

  Future<void> clear() async {
    // Delete laps
    for (var lap in (await getLapDocs())) {
      await lap.reference.delete();
    }
    // Reset current lap
    currentLap = OldLap(
      date: DateTime.now(),
      lapNumber: 1,
      lapTime: const Duration(),
    );
  }
}
