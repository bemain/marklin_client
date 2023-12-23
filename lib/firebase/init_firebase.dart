import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/widgets.dart';

class InitFirebase extends StatelessWidget {
  /// Makes sure Firebase is initialized before [child] enters the tree.
  const InitFirebase({super.key, required this.child});

  /// Widget to display when Firebase is initalized.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _init(),
        builder: niceAsyncBuilder(
          loadingText: "Initializing Firebase...",
          activeBuilder: (c, snapshot) => child,
        ),
      ),
    );
  }

  Future _init() async {
    await Firebase.initializeApp();
    await FirebaseAuth.instance.signInAnonymously();
  }
}
