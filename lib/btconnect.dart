import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class BTConnectScreen extends StatefulWidget {
  BTConnectScreen({Key key, this.device, this.onConnectedRoute})
      : super(key: key);

  final BluetoothDevice device;
  final String onConnectedRoute;

  @override
  State<StatefulWidget> createState() => BTConnectScreenState();
}

class BTConnectScreenState extends State<BTConnectScreen> {
  Future<void> _futureConnect;

  @override
  void initState() {
    super.initState();

    _futureConnect = widget.device.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connecting to device..."),
      ),
      body: FutureBuilder(
          future: _futureConnect,
          builder: (c, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return InfoScreen(
                    icon: Icon(Icons.bluetooth_disabled),
                    text: "Device unavailable");
              case ConnectionState.waiting:
                return InfoScreen(
                    icon: CircularProgressIndicator(),
                    text: "Connecting to device...");

              default:
                return snapshot.hasError
                    ? Center(child: Text('Error: ${snapshot.error}'))
                    : Navigator.pushReplacementNamed(
                        context, widget.onConnectedRoute,
                        arguments: {"device": snapshot.data});
            }
          }),
    );
  }
}
