import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
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

class SelectDeviceScreen extends StatefulWidget {
  final Function(BluetoothDevice device)? onDeviceConnected;

  const SelectDeviceScreen({Key? key, this.onDeviceConnected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SelectDeviceScreenState();
}

class SelectDeviceScreenState extends State<SelectDeviceScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  BluetoothDevice? selectedDevice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bluetooth Device"),
      ),
      body: (selectedDevice == null)
          ? StreamBuilder<List<ScanResult>>(
              stream: flutterBlue.scanResults,
              initialData: const [],
              builder: (c, snapshot) => ListView(
                  children: snapshot.data!
                      .map((result) => TextTile(
                          title: result.device.name,
                          text: result.device.id.toString(),
                          onTap: () {
                            setState(() => selectedDevice = result.device);
                          }))
                      .toList()),
            )
          : FutureBuilder(
              future: _connectBT(),
              builder: niceAsyncBuilder(
                loadingText: "Connecting to device...",
                errorText: "Unable to connect to device",
                activeBuilder: (BuildContext c, snapshot) {
                  return const InfoScreen(
                      icon: Icon(Icons.bluetooth_connected),
                      text: "Connected to device");
                },
              ),
            ),
      floatingActionButton: StreamBuilder(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, AsyncSnapshot<bool> snapshot) => FloatingActionButton(
          heroTag: "select_bt_device",
          child:
              Icon(snapshot.data! ? Icons.bluetooth_searching : Icons.search),
          onPressed: () {
            if (!snapshot.data!) {
              flutterBlue.startScan(timeout: const Duration(seconds: 4));
            }
          },
        ),
      ),
    );
  }

  Future<void> _connectBT() async {
    // Don't connect if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty) {
      await selectedDevice!.connect();
    } else {
      debugPrint("BLUETOOTH: Already connected");
    }

    widget.onDeviceConnected?.call(selectedDevice!);
  }
}

class SelectServiceScreen extends StatelessWidget {
  const SelectServiceScreen({Key? key, this.onServiceSelected})
      : super(key: key);

  final Function(String serviceID, BluetoothService service)? onServiceSelected;

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.device != null); // Needs connected BT device

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bluetooth Service"),
      ),
      body: FutureBuilder<List<BluetoothService>>(
        future: Bluetooth.device!.discoverServices(),
        initialData: const [],
        builder: niceAsyncBuilder(
          loadingText: "Getting services...",
          activeBuilder: (BuildContext c, snapshot) {
            return ListView(
              children: snapshot.data!
                  .map((serv) => TextTile(
                        title: serv.uuid.toString(),
                        onTap: () {
                          onServiceSelected?.call(serv.uuid.toString(), serv);
                        },
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class SelectCharacteristicScreen extends StatelessWidget {
  const SelectCharacteristicScreen({
    Key? key,
    this.onCharSelected,
    this.title = const Text("Select Bluetooth Characteristic"),
  }) : super(key: key);

  final Widget title;
  final Function(String charID, BluetoothCharacteristic char)? onCharSelected;

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.service != null); // Needs BT service

    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      body: ListView(
        children: Bluetooth.service!.characteristics
            .map(
              (char) => TextTile(
                title: char.uuid.toString(),
                onTap: () {
                  onCharSelected?.call(char.uuid.toString(), char);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
