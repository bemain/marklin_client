import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/home.dart';
import 'package:marklin_bluetooth/firebase/init_firebase.dart';
import 'package:marklin_bluetooth/theme.dart';

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
      theme: generateTheme(Colors.blue),
      home: const InitFirebase(child: HomeScreen()),
    );
  }
}
