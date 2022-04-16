import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/bluetooth/select_characteristic.dart';
import 'package:marklin_bluetooth/bluetooth/select_device.dart';
import 'package:marklin_bluetooth/bluetooth/select_service.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Setups Bluetooth; this includes 4 steps:
/// 1) Inits Blutooth
/// 2) Lets user select BT Device, then connects
/// 3) Lets user select BT Service
/// 4) Lets user select BT Characterstic for both speed and lap
/// Then runs [onSetupComplete]
class SetupBTScreen extends StatefulWidget {
  const SetupBTScreen({Key? key, required this.onSetupComplete})
      : super(key: key);

  final Function onSetupComplete;

  @override
  State<StatefulWidget> createState() => _SetupBTScreenState();
}

class _SetupBTScreenState extends State<SetupBTScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  int setupStage = 1;

  @override
  Widget build(BuildContext context) {
    switch (setupStage) {
      case 1: // Init Bluetooth
        return FutureBuilder(
          future: flutterBlue.isAvailable,
          builder: niceAsyncBuilder<bool>(
            loadingText: "Waiting for Bluetooth...",
            errorText: "Bluetooth unavailable",
            activeBuilder: (c, snapshot) {
              if (!snapshot.data!) // Bluetooth unavailable
              {
                return const ErrorScreen(text: "Bluetooth unavailable");
              }
              queueNextStage();
              return const InfoScreen(
                icon: Icon(Icons.bluetooth),
                text: "Bluetooth available",
              );
            },
          ),
        );
      case 2: // Select + connect to Bluetooth Device
        return SelectDeviceScreen(
          onDeviceConnected: (BluetoothDevice device) {
            Bluetooth.device = device;
            queueNextStage();
          },
        );
      case 3: // Select Bluetooth Service
        return SelectServiceScreen(
          onServiceSelected: (String serviceID, BluetoothService service) {
            //Bluetooth.serviceID = serviceID;
            Bluetooth.service = service;
            queueNextStage();
          },
        );

      case 4: // Select speed char
        return SelectCharacteristicScreen(
          title: const Text("Select Speed Characteristic"),
          onCharSelected: (String charID, BluetoothCharacteristic char) {
            Bluetooth.speedChar = char;
            queueNextStage();
          },
        );
      case 5: // Select lap char
        return SelectCharacteristicScreen(
          title: const Text("Select Lap Characteristic"),
          onCharSelected: (String charID, BluetoothCharacteristic char) {
            Bluetooth.lapChar = char;
            queueNextStage();
          },
        );

      default:
        // Wait 1 sec before triggering callback
        Timer(const Duration(seconds: 1), () {
          widget.onSetupComplete.call();
        });

        return const InfoScreen(
          icon: Icon(Icons.bluetooth_connected),
          text: "Bluetooth setup complete",
        );
    }
  }

  void queueNextStage() {
    // Wait 1 sec before moving to next stage
    Timer(const Duration(seconds: 0), () {
      setState(() {
        setupStage++;
      });
    });
  }
}
