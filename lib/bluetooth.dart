import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class Bluetooth {
  static BluetoothDevice? device;
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
          ? FutureBuilder(
              future: flutterBlue.isAvailable,
              builder: (c, AsyncSnapshot<bool> snapshot) => (!snapshot.hasData)
                  ? const LoadingScreen(text: "Waiting for Bluetooth")
                  : (!snapshot.data!)
                      ? const InfoScreen(
                          icon: Icon(Icons.bluetooth_disabled),
                          text: "Bluetooth unavailable")
                      : StreamBuilder<List<ScanResult>>(
                          stream: flutterBlue.scanResults,
                          initialData: const [],
                          builder: (c, snapshot) => ListView(
                              children: snapshot.data!
                                  .map((result) => TextTile(
                                      title: result.device.name,
                                      text: result.device.id.toString(),
                                      onTap: () => setState(() =>
                                          selectedDevice = result.device)))
                                  .toList()),
                        ),
            )
          : FutureBuilder(
              future: _connectBT(),
              builder: (c, snapshot) {
                if (snapshot.hasError)
                  return const ErrorScreen(text: "Failed to connect to device");

                if (snapshot.connectionState == ConnectionState.waiting)
                  return const LoadingScreen(text: "Connecting to device...");

                return const InfoScreen(
                    icon: Icon(Icons.bluetooth_connected),
                    text: "Connected to device");
              }),
      floatingActionButton: StreamBuilder(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, AsyncSnapshot<bool> snapshot) => FloatingActionButton(
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

  Future _connectBT() async {
    // Don't connect if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty) {
      await selectedDevice!.connect();
    } else {
      print("BLUETOOTH: Already connected");
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
  BluetoothService? service;
  String serviceID = "";
  String charID = "";

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.device != null); // Needs connected BT device

    if (service == null) {
      return FutureBuilder(
          future: Bluetooth.device!.discoverServices(),
          initialData: const [],
          builder: (BuildContext c, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError)
              return const ErrorScreen(
                  text: "Unable to get services from device");

            if (snapshot.connectionState == ConnectionState.waiting)
              return const LoadingScreen(text: "Getting services...");

            return ListView(
              children: snapshot.data!
                  .map(
                    (serv) => TextTile(
                      title: serv.uuid.toString(),
                      onTap: () {
                        setState(() {
                          serviceID = serv.uuid.toString();
                          service = serv;
                        });
                      },
                    ),
                  )
                  .toList(),
            );
          });
    }

    return ListView(
      children: service!.characteristics
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
