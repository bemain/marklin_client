import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Märklin BLE Car Controller",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FindDevicesScreen(),
    );
  }
}

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

    print(widget.device.toString());
    _futureConnect = widget.device.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      bottomNavigationBar: FlatButton(
        child: Icon(Icons.bluetooth_disabled),
        onPressed: () {
          widget.device.disconnect();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => FindDevicesScreen()),
              (Route<dynamic> route) => false);
        },
      ),
    );
  }
}
