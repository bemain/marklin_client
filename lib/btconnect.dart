import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/controller.dart';
import 'package:marklin_bluetooth/widgets.dart';

class FindDevicesScreen extends StatelessWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect Bluetooth"),
      ),
      body: SingleChildScrollView(
          child: FutureBuilder(
        future: flutterBlue.isAvailable,
        builder: (c, snapshot) => !snapshot.hasData
            ? InfoScreen(
                icon: CircularProgressIndicator(),
                text: "Waiting for Bluetooth")
            : (snapshot.data == false)
                ? InfoScreen(
                    icon: Icon(Icons.bluetooth_disabled),
                    text: "Bluetooth unavailable")
                : StreamBuilder<List<ScanResult>>(
                    stream: flutterBlue.scanResults,
                    initialData: [],
                    builder: (c, snapshot) => Column(
                          children: snapshot.data
                              .map((r) => BluetoothDeviceTile(
                                    device: r.device,
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ControllerScreen(
                                                      device: r.device)));
                                    },
                                  ))
                              .toList(),
                        )),
      )),
      floatingActionButton: StreamBuilder(
          stream: flutterBlue.isScanning,
          initialData: false,
          builder: (c, snapshot) => FloatingActionButton(
              child: Icon(
                  snapshot.data ? Icons.bluetooth_searching : Icons.search),
              onPressed: () {
                if (!snapshot.data)
                  // Not scanning
                  flutterBlue.startScan(timeout: Duration(seconds: 4));
              })),
    );
  }
}
