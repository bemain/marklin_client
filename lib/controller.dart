import 'dart:async';
import 'dart:math';

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
  int carID = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          primarySwatch: [
            Colors.green,
            Colors.purple,
            Colors.orange,
            Colors.grey,
          ][carID],
        ),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => _showQuitDialog(context),
              icon: Icon(Icons.bluetooth_disabled, color: Colors.white),
            ),
            title: Text("Märklin BLE Controller"),
          ),
          body: SpeedSlider(
            device: widget.device,
            onCarIDChange: (id) {
              setState(() {
                carID = id;
              });
            },
          ),
        ));
  }

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => QuitDialog(
        onQuit: () => widget.device.disconnect(),
      ),
    );
  }
}

class SpeedSlider extends StatefulWidget {
  SpeedSlider({Key key, this.device, this.onCarIDChange}) : super(key: key);

  final BluetoothDevice device;
  final Function(int newID) onCarIDChange;

  @override
  State<StatefulWidget> createState() => SpeedSliderState();
}

class SpeedSliderState extends State<SpeedSlider> {
  final friction = 10;

  double speed = 0.0;
  int carID = 0;

  bool enableSlowDown = true;
  bool willSlowDown = false;
  Timer slowDownLoop;

  bool sendNeeded = false;
  Timer sendLoop;

  Future<bool> _futureChar;
  BluetoothCharacteristic speedChar;

  // Methods
  @override
  void initState() {
    super.initState();
    _futureChar = getCharacteristic();

    sendLoop = Timer.periodic(Duration(milliseconds: 100), sendSpeed);
    slowDownLoop = Timer.periodic(Duration(milliseconds: 10), slowDown);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureChar,
        builder: (c, snapshot) {
          if (!snapshot.hasData)
            return InfoScreen(
                icon: CircularProgressIndicator(),
                text: "Getting Characteristic");
          else
            return Column(children: [
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event) => willSlowDown = false,
                  onPointerUp: (event) => willSlowDown = true,
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Slider(
                      value: speed,
                      onChanged: (value) {
                        sendNeeded = true;
                        setState(() {
                          speed = value;
                        });
                      },
                      min: 0,
                      max: 100,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => Radio(
                    value: index,
                    groupValue: carID,
                    onChanged: (value) {
                      setState(() {
                        carID = value;
                        sendNeeded = true;
                        widget.onCarIDChange(carID);
                      });
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    enableSlowDown = !enableSlowDown;
                  });
                },
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor)),
                child: Text("Slow down? ${enableSlowDown ? "YES" : "NO"}"),
              ),
            ]);
        });
  }

  @override
  void dispose() {
    super.dispose();

    sendLoop.cancel();
  }

  Future<bool> getCharacteristic() async {
    List<BluetoothService> services = await widget.device.discoverServices();

    var service = services.firstWhere(
        (s) => s.uuid == Guid("0000180c-0000-1000-8000-00805f9b34fb"));
    var char = service.characteristics.firstWhere(
        (c) => c.uuid == Guid("0000180c-0000-1000-8000-00805f9b34fb"));

    speedChar = char;
    return true;
  }

  void sendSpeed(Timer timer) async {
    // Send speed to bluetooth device
    if (sendNeeded) {
      await speedChar
          .write([carID, 100 - speed.toInt()], withoutResponse: true);
      sendNeeded = false;
    }
  }

  void slowDown(Timer timer) {
    // Slow down car
    if (enableSlowDown && willSlowDown && speed != 0) {
      sendNeeded = true;
      setState(() {
        speed -= min(speed, friction);
      });
    }
  }
}
