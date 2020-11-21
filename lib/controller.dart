import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _ControllerScreenState createState() => new _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
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
        leading: IconButton(
          icon: Icon(Icons.bluetooth_disabled, color: Colors.white),
          onPressed: () {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext c) => QuitDialog(
                      onBack: () {
                        Navigator.of(context).pop();
                      },
                      onQuit: () {
                        widget.device.disconnect();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ));
          },
        ),
        title: Text("Märklin BLE Controller"),
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
                    : SpeedSlider(device: widget.device);
            }
          }),
    );
  }
}
