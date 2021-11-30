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

  // The reference to the current lap for the car that [this] references.
  DocumentReference<Lap> get currentLapRef => lapsRef.doc("current");

  /// The current lap for the car that [this] references.
  Future<Lap?> get currentLap async => (await currentLapRef.get()).data();

  /// The snapshots of all the laps currently on the database.
  Future<List<DocumentSnapshot<Lap>>> getLapDocs(
      {includeCurrent = false}) async {
    var docs =
        (await lapsRef.orderBy("lapNumber", descending: true).get()).docs;
    if (!includeCurrent) docs.removeWhere((docSnap) => docSnap.id == "current");
    return docs;
  }

  /// Get all the laps currently on the database.
  Future<List<Lap>> getLaps({includeCurrent = false}) async {
    var docSnaps = (await getLapDocs(includeCurrent: includeCurrent));
    return docSnaps.map((doc) => doc.data()!).toList();
  }
}
