import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class InitScreen extends StatefulWidget {
  InitScreen({Key key, this.device, this.createConnectedScreen})
      : super(key: key);

  final BluetoothDevice device;
  final Widget Function(BluetoothDevice device) createConnectedScreen;

  @override
  State<StatefulWidget> createState() => InitScreenState();
}

class InitScreenState extends State<InitScreen> {
  Future<void> _futureInit;

  @override
  void initState() {
    super.initState();

    _futureInit = () async {
      if (widget.device != null) await widget.device.connect();
      await Firebase.initializeApp();
      await changeScreen();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Initializing screen..."),
      ),
      body: FutureBuilder(
          future: _futureInit,
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
                  text: "Initializing...",
                );

              default:
                return Center(
                  child: snapshot.hasError
                      ? Text('Error: ${snapshot.error}')
                      : Text("Initialization done"),
                );
            }
          }),
    );
  }

  Future<void> changeScreen() async {
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => widget.createConnectedScreen(widget.device)));
  }
}
