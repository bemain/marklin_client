import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Widget for connecting to Bluetooth device.
/// Runs [onConnected] when connected to [device],
/// and shows loading / error or connected screen.
class BTConnect extends StatefulWidget {
  BTConnect({Key key, @required this.device, @required this.onConnected})
      : super(key: key);

  final BluetoothDevice device;
  final Function(BluetoothDevice device) onConnected;

  @override
  State<StatefulWidget> createState() => BTConnectState();
}

class BTConnectState extends State<BTConnect> {
  Future<void> _futureConnect;

  @override
  void initState() {
    super.initState();

    _futureConnect = _connectBT(widget.device);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
              return InfoScreen(
                icon: Icon(Icons.bluetooth_connected),
                text: "Connected to device",
              );
            }
        }
      },
    );
  }

  Future<void> _connectBT(BluetoothDevice device) async {
    // Check if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty)
      widget.device.connect();
    widget.onConnected(widget.device);
  }
}
