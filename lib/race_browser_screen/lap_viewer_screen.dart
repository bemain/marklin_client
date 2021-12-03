import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/lap.dart';

class LapViewerScreen extends StatelessWidget {
  final DocumentSnapshot<Lap> lapSnap;

  const LapViewerScreen({Key? key, required this.lapSnap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Lap lap = lapSnap.data()!;
    return Scaffold(
      appBar: AppBar(
        title: Text("Viewing lap : ${lap.lapNumber}"),
      ),
    );
  }
}
