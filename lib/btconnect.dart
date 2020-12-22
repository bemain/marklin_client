import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// A helper widget for connecting to Bluetooth device.
/// Returns [child] when connected to [device],
/// otherwise returns loading / error screen.
///
/// Wrap widgets that require a connected Bluetooth device
/// with this widget.
class BTConnect extends StatefulWidget {
  BTConnect({Key key, @required this.device, @required this.child})
      : super(key: key);

  final BluetoothDevice device;
  final Widget child;

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
              return (snapshot.hasError)
                  ? Center(child: Text('Error: ${snapshot.error}'))
                  : widget.child;
          }
        });
  }

  Future<void> _connectBT(BluetoothDevice device) async {
    // Check if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty)
      return widget.device.connect();
  }
}
