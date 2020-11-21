import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/btconnect.dart';
import 'package:marklin_bluetooth/controller.dart';
import 'package:marklin_bluetooth/find_devices.dart';
import 'package:marklin_bluetooth/lap_counter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Märklin BLE Car Controller",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "/": (context) => FindDevicesScreen(),
        "/controller": (context) => ControllerScreen(),
        "/lapCounter": (context) => LapCounterScreen(),
      },
    );
  }
}
