import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/car_reference.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';
import 'package:marklin_bluetooth/utils.dart';
import 'package:marklin_bluetooth/widgets.dart';

class LapsViewer extends StatelessWidget {
  final CarReference carRef;
  final Function(DocumentReference<Lap> lapRef)? onLapSelected;

  const LapsViewer({Key? key, required this.carRef, this.onLapSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Lap>>(
      stream: carRef.lapsRef.orderBy("date", descending: true).snapshots(),
      builder: niceAsyncBuilder(
        loadingText: "Getting lap times...",
        activeBuilder: (BuildContext c, snapshot) {
          List<QueryDocumentSnapshot<Lap>> docs = snapshot.data!.docs;
          return ListView(
            children: docs.map((lapSnap) {
              Lap lap = lapSnap.data();
              return TextTile(
                title: "${lap.lapNumber} | ${lap.lapTime}s",
                text: dateString((lap.date).toDate()),
                onTap: () => onLapSelected?.call(lapSnap.reference),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
