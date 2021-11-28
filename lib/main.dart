import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/home.dart';
import 'package:marklin_bluetooth/firebase/init_firebase.dart';

// TODO: Plot speed during the lap.
// TODO: Fix Firestore rules

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Märklin BLE Car Controller",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const InitFirebase(child: HomeScreen()));
  }
}
