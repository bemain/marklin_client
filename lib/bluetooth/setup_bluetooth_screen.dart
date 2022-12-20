import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/bluetooth/select_characteristic.dart';
import 'package:marklin_bluetooth/bluetooth/select_device.dart';
import 'package:marklin_bluetooth/bluetooth/select_service.dart';
import 'package:marklin_bluetooth/widgets.dart';

class SetupBTScreen extends StatefulWidget {
  /// Setups Bluetooth; this includes 4 steps:
  /// 1) Inits Blutooth
  /// 2) Lets user select BT Device, then connects
  /// 3) Lets user select BT Service
  /// 4) Lets user select BT Characterstic for both speed and lap
  /// Then runs [onSetupComplete].
  ///
  /// If [tryAutoConnect] is true, tries to complete steps automatically,
  /// using IDs provided by [Bluetooth] singleton.
  const SetupBTScreen({
    Key? key,
    required this.onSetupComplete,
    this.tryAutoConnect = true,
  }) : super(key: key);

  /// Called when all steps have been completed.
  /// Unless [debugMode] (the first argument) is true, Bluetooth is then fully
  /// configured and device, service and characteristics for both speed and lap
  /// have been determined and registered to [Bluetooth] singleton.
  ///
  /// If [debugMode] is true, no device has been connected, and ControllerScreen
  /// should instead enter debug mode.
  final Function(bool debugMode) onSetupComplete;

  /// If true, will try to automatically connect to Bluetooth device and
  /// determine service and characteristics,
  /// using IDs provided by [Bluetooth] singleton.
  final bool tryAutoConnect;

  @override
  State<StatefulWidget> createState() => _SetupBTScreenState();
}

class _SetupBTScreenState extends State<SetupBTScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  int setupStage = 1;
  bool debugMode = false;

  @override
  Widget build(BuildContext context) {
    switch (setupStage) {
      case 1: // Check if Bluetooth is available
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
          autoconnectID: widget.tryAutoConnect ? Bluetooth.deviceID : null,
          onDeviceConnected: (BluetoothDevice device) {
            Bluetooth.device = device;
            queueNextStage();
          },
          onDebugModeSelected: () {
            debugMode = true;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              setState(() {
                // Skip rest of setup
                setupStage = -1;
              });
            });
          },
        );
      case 3: // Select Bluetooth Service
        return SelectServiceScreen(
          autoconnectID: widget.tryAutoConnect ? Bluetooth.serviceID : null,
          onServiceSelected: (String serviceID, BluetoothService service) {
            //Bluetooth.serviceID = serviceID;
            Bluetooth.service = service;
            queueNextStage();
          },
        );

      case 4: // Select speed char
        return SelectCharacteristicScreen(
          title: const Text("Select Speed Characteristic"),
          autoconnectID: widget.tryAutoConnect ? Bluetooth.speedCharID : null,
          onCharSelected: (String charID, BluetoothCharacteristic char) {
            Bluetooth.speedChar = char;
            queueNextStage();
          },
        );
      case 5: // Select lap char
        return SelectCharacteristicScreen(
          title: const Text("Select Lap Characteristic"),
          autoconnectID: widget.tryAutoConnect ? Bluetooth.lapCharID : null,
          onCharSelected: (String charID, BluetoothCharacteristic char) {
            Bluetooth.lapChar = char;
            queueNextStage();
          },
        );

      default:
        // Wait 1 sec before triggering callback
        Timer(const Duration(seconds: 1), () {
          widget.onSetupComplete.call(debugMode);
        });

        return const InfoScreen(
          icon: Icon(Icons.bluetooth_connected),
          text: "Bluetooth setup complete",
        );
    }
  }

  void queueNextStage() {
    // Wait until end of frame before changing stage
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        setupStage++;
      });
    });
  }
}
