import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/home.dart';
import 'package:marklin_bluetooth/firebase/init_firebase.dart';

// TODO: Store speed history locally
// TODO: Fix BT Connection, auto connect
// TODO: Average speed during a few seconds when plotting
// TODO: Set running false when starting new race
// TODO: Lock auto rotation
// TODO: Fix first lap logging
// TODO: Race browser: fix back button navigation
// TODO: Add option to disable lap reporting
// TODO: Start speed at 0
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
