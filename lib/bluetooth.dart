import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class Bluetooth {
  static BluetoothDevice? device;

  static String serviceID = "0000181c-0000-1000-8000-00805f9b34fb";

  static String speedCharID = "0000180c-0000-1000-8000-00805f9b34fb";
  static String lapCharID = "0000181c-0000-1000-8000-00805f9b34fb";
}

class SelectDeviceScreen extends StatefulWidget {
  final Function(BluetoothDevice)? onDeviceConnected;

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
        title: const Text("Connect to Bluetooth Device"),
      ),
      body: (selectedDevice == null)
          ? FutureBuilder<bool>(
              future: flutterBlue.isAvailable,
              builder: niceAsyncBuilder(
                loadingText: "Waiting for Bluetooth...",
                errorText: "Bluetooth unavailable",
                activeBuilder: (BuildContext c, snapshot) {
                  return StreamBuilder<List<ScanResult>>(
                    stream: flutterBlue.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) => ListView(
                        children: snapshot.data!
                            .map((result) => TextTile(
                                title: result.device.name,
                                text: result.device.id.toString(),
                                onTap: () => setState(
                                    () => selectedDevice = result.device)))
                            .toList()),
                  );
                },
              ),
            )
          : FutureBuilder(
              future: _connectBT(),
              builder: niceAsyncBuilder(
                loadingText: "Connecting to device...",
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

    Bluetooth.device = selectedDevice;

    // Start timer for switching screen
    Timer(const Duration(seconds: 1), () {
      widget.onDeviceConnected?.call(selectedDevice!);
    });
  }
}

class CharacteristicSelectorScreen extends StatefulWidget {
  const CharacteristicSelectorScreen({Key? key, this.onCharSelected})
      : super(key: key);

  final Function(String serviceID, String charID)? onCharSelected;

  @override
  State<StatefulWidget> createState() {
    return CharacteristicSelectorScreenState();
  }
}

class CharacteristicSelectorScreenState
    extends State<CharacteristicSelectorScreen> {
  BluetoothService? _service;
  String serviceID = "";
  String charID = "";

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.device != null); // Needs connected BT device

    if (_service == null) {
      return FutureBuilder<List<BluetoothService>>(
        future: Bluetooth.device!.discoverServices(),
        initialData: const [],
        builder: niceAsyncBuilder(
          loadingText: "Getting services...",
          activeBuilder: (BuildContext c, snapshot) {
            return ListView(
              children: snapshot.data!
                  .map(
                    (serv) => TextTile(
                      title: serv.uuid.toString(),
                      onTap: () {
                        setState(() {
                          serviceID = serv.uuid.toString();
                          _service = serv;
                        });
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );
    }

    return ListView(
      children: _service!.characteristics
          .map(
            (char) => TextTile(
              title: char.uuid.toString(),
              onTap: () {
                setState(() {
                  charID = char.uuid.toString();
                });
                widget.onCharSelected?.call(serviceID, charID);
              },
            ),
          )
          .toList(),
    );
  }
}
