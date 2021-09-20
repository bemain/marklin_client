import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class Bluetooth {
  static BluetoothDevice? device;
}

class SelectDeviceScreen extends StatefulWidget {
  final Function(BluetoothDevice)? onDeviceConnected;

  SelectDeviceScreen({Key? key, this.onDeviceConnected}) : super(key: key);

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
        title: Text("Connect to Bluetooth Device"),
      ),
      body: (selectedDevice == null)
          ? FutureBuilder(
              future: flutterBlue.isAvailable,
              builder: (c, AsyncSnapshot<bool> snapshot) => (!snapshot.hasData)
                  ? LoadingScreen(text: "Waiting for Bluetooth")
                  : (!snapshot.data!)
                      ? InfoScreen(
                          icon: Icon(Icons.bluetooth_disabled),
                          text: "Bluetooth unavailable")
                      : StreamBuilder<List<ScanResult>>(
                          stream: flutterBlue.scanResults,
                          initialData: [],
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
                  return ErrorScreen(text: "Failed to connect to device");

                if (snapshot.connectionState == ConnectionState.waiting)
                  return LoadingScreen(text: "Connecting to device...");

                return InfoScreen(
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
            if (!snapshot.data!) // Not scanning
              flutterBlue.startScan(timeout: Duration(seconds: 4));
          },
        ),
      ),
    );
  }

  Future _connectBT() async {
    // Don't connect if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty)
      await selectedDevice!.connect();

    Bluetooth.device = selectedDevice;

    // Start timer for switching screen
    Timer(Duration(seconds: 1), () {
      widget.onDeviceConnected?.call(selectedDevice!);
    });
  }
}

class CharacteristicSelectorScreen extends StatefulWidget {
  CharacteristicSelectorScreen({Key? key, this.onCharSelected})
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

    if (service == null)
      return FutureBuilder(
          future: Bluetooth.device!.discoverServices(),
          initialData: [],
          builder: (BuildContext c, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasError)
              return ErrorScreen(text: "Unable to get services from device");

            if (snapshot.connectionState == ConnectionState.waiting)
              return LoadingScreen(text: "Getting services...");

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
