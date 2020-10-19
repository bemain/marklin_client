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

    return Scaffold(
      appBar: AppBar(
        title: Text("Find Devices"),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<List<ScanResult>>(
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
      ),
      floatingActionButton: StreamBuilder(
          stream: flutterBlue.isScanning,
          builder: (c, snapshot) => FloatingActionButton(
              child: Icon(snapshot.hasData
                  ? (snapshot.data ? Icons.bluetooth_searching : Icons.search)
                  : Icons.bluetooth_disabled),
              onPressed: () {
                if (!snapshot.data)
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
        title: Text("Märklin BLE Controller"),
      ),
      body: FutureBuilder(
          future: _futureConnect,
          builder: (c, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      Icon(Icons.device_unknown),
                      Text('Device not found...')
                    ]));
              case ConnectionState.waiting:
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Connecting to device...')
                    ]));

              default:
                return snapshot.hasError
                    ? Center(child: Text('Error: ${snapshot.error}'))
                    : Column(children: <Widget>[
                        SpeedSlider(
                          device: widget.device,
                        ),
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
          }),
    );
  }
}
