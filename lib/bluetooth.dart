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
                      : SingleChildScrollView(
                          child: StreamBuilder<List<ScanResult>>(
                            stream: flutterBlue.scanResults,
                            initialData: [],
                            builder: (c, snapshot) => Column(
                              children: snapshot.data!
                                  .map((result) => BluetoothDeviceTile(
                                      device: result.device,
                                      onTap: () => setState(() =>
                                          selectedDevice = result.device)))
                                  .toList(),
                            ),
                          ),
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
    await selectedDevice!.connect();

    Bluetooth.device = selectedDevice;

    // Start timer for switching screen
    Timer(Duration(seconds: 1), () {
      widget.onDeviceConnected?.call(selectedDevice!);
      Navigator.of(context).pop();
    });
  }
}

class BluetoothDeviceTile extends StatelessWidget {
  const BluetoothDeviceTile({Key? key, required this.device, this.onTap})
      : super(key: key);

  final BluetoothDevice device;
  final Function()? onTap;

  Widget _buildTitle(BuildContext context) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: _buildTitle(context),
      onPressed: onTap,
    );
  }
}
