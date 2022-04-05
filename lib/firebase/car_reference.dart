import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';

class CarReference {
  final CollectionReference<Map<String, dynamic>> collRef;
  final CollectionReference<Lap> lapsRef;

  CarReference({required this.collRef})
      : lapsRef = collRef.withConverter<Lap>(
          fromFirestore: (snapshot, _) => Lap.fromJson(snapshot.data()!),
          toFirestore: (lap, _) => lap.toJson(),
        );

  /// The current lap for the car that [this] references.
  Lap currentLap = Lap(date: Timestamp.now(), lapNumber: 0, lapTime: 0);

  /// The snapshots of all the laps currently on the database.
  Future<List<DocumentSnapshot<Lap>>> getLapDocs() async {
    return (await lapsRef.orderBy("lapNumber", descending: true).get()).docs;
  }

  /// Get all the laps currently on the database.
  Future<List<Lap>> getLaps() async {
    var docSnaps = await getLapDocs();
    return docSnaps.map((doc) => doc.data()!).toList();
  }
}
