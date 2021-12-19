import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Makes sure Firebase is initialized before [child] enters the tree.
class InitFirebase extends StatelessWidget {
  final Widget child;

  const InitFirebase({Key? key, required this.child}) : super(key: key);

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
    UserCredential _ = await FirebaseAuth.instance.signInAnonymously();
  }
}
