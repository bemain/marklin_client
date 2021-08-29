import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Helper widget for connecting to Bluetooth device.
///
/// Replaces itself with [connectedScreen] when connected to [device],
/// and shows loading / error or connected screen while connecting.
class BTConnect extends StatefulWidget {
  BTConnect({Key? key, required this.device, required this.connectedScreen})
      : super(key: key);

  final BluetoothDevice device;
  final Widget connectedScreen;

  @override
  State<StatefulWidget> createState() => BTConnectState();
}

class BTConnectState extends State<BTConnect> {
  Future? _futureConnect;
  bool connected = false;

  @override
  void initState() {
    super.initState();

    _futureConnect = _connectBT(widget.device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _futureConnect,
        builder: (c, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return InfoScreen(
                icon: Icon(Icons.bluetooth_disabled),
                text: "Bluetooth unavailable",
              );
            case ConnectionState.waiting:
              return InfoScreen(
                icon: CircularProgressIndicator(),
                text: "Connecting to device...",
              );

            default:
              if (snapshot.hasError)
                return InfoScreen(
                  icon: Icon(Icons.error),
                  text: "Error: ${snapshot.error}",
                );
              else {
                connected = true;
                return InfoScreen(
                  icon: Icon(Icons.bluetooth_connected),
                  text: "Connected to device",
                );
              }
          }
        },
      ),
    );
  }

  Future<void> _connectBT(BluetoothDevice device) async {
    // Don't connect if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty)
      widget.device.connect();

    // Start timer for switching screen
    Timer.periodic(
      Duration(seconds: 1),
      (timer) => _replaceScreen(timer, context),
    );
  }

  Future<void> _replaceScreen(Timer timer, BuildContext context) async {
    if (connected) {
      timer.cancel();
      // Replace with new screen
      await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (c) => widget.connectedScreen));
    }
  }
}
