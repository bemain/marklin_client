import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Makes sure Firebase is initialized before [child] enters the tree.
class InitFirebase extends StatefulWidget {
  final Widget child;

  const InitFirebase({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => InitFirebaseState();
}

class InitFirebaseState extends State<InitFirebase> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (c, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: LoadingScreen(text: "Initalizing Firebase..."));
        }

        if (snapshot.hasError) {
          return Scaffold(body: ErrorScreen(text: "Error: ${snapshot.error}"));
        }

        return widget.child;
      },
    );
  }
}
