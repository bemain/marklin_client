import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FindDevicesScreen(),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    // Start scan
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    return Scaffold(
      appBar: AppBar(
        title: Text("Find Devices"),
      ),
      body: RefreshIndicator(
        onRefresh: () => flutterBlue.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
            child: Column(children: [
          StreamBuilder<List<ScanResult>>(
              stream: flutterBlue.scanResults,
              initialData: [],
              builder: (c, snapshot) => Column(
                    children: snapshot.data
                        .map((r) => BluetoothDeviceTile(
                              device: r.device,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ControllerScreen(device: r.device)));
                              },
                            ))
                        .toList(),
                  )),
          Container(
            color: Colors.black,
            height: 10,
          ),
          StreamBuilder(
              stream: flutterBlue.isScanning,
              builder: (c, snapshot) => FlatButton(
                  child: Icon(snapshot.data == false
                      ? Icons.bluetooth
                      : Icons.bluetooth_searching),
                  onPressed: () {
                    if (snapshot.data == false)
                      flutterBlue.startScan(timeout: Duration(seconds: 4));
                  })),
        ])),
      ),
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
  Future<void> _connect;
  double speed = 0;

  @override
  void initState() {
    super.initState();

    _connect = widget.device.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Märklin BLE Controller"),
      ),
      body: FutureBuilder(
          future: _connect,
          builder: (c, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(child: Text('Device not found...'));
              case ConnectionState.waiting:
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Connecting to device...')
                    ]));

              default:
                {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Column(children: <Widget>[
                      Expanded(
                          child: RotatedBox(
                              quarterTurns: -1,
                              child: Slider(
                                value: speed,
                                onChanged: (value) {
                                  setState(() {
                                    speed = value;
                                    print("Speed: " + value.toString());
                                  });
                                },
                              ))),
                      FlatButton(
                        child: Icon(Icons.bluetooth_disabled),
                        onPressed: () {
                          widget.device.disconnect();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FindDevicesScreen()));
                        },
                      )
                    ]);
                  }
                }
            }
          }),
    );
  }
}
