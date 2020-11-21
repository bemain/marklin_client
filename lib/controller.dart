import 'dart:async';
import 'dart:typed_data';

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
                builder: (BuildContext c) => QuitDialog());
          },
        ),
        title: Text("Märklin BLE Controller"),
      ),
      body: SpeedSlider(device: widget.device),
    );
  }

  @override
  void dispose() {
    super.dispose();

    widget.device.disconnect();
  }
}

class SpeedSlider extends StatefulWidget {
  SpeedSlider({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => SpeedSliderState();
}

class SpeedSliderState extends State<SpeedSlider> {
  double speed = 50.0;
  int carID = 0;

  bool sendNeeded = false;

  BluetoothCharacteristic speedChar;

  Timer sendLoop;

  @override
  void initState() {
    super.initState();
    sendLoop = Timer.periodic(Duration(milliseconds: 100), sendSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCharacteristic(),
        builder: (c, snapshot) {
          if (!snapshot.hasData)
            return InfoScreen(
                icon: CircularProgressIndicator(),
                text: "Getting Characteristic");
          else {
            speedChar = snapshot.data;

            return Column(children: [
              Expanded(
                  child: RotatedBox(
                      quarterTurns: -1,
                      child: Slider(
                        value: speed,
                        min: 0,
                        max: 255,
                        onChanged: (value) {
                          sendNeeded = true;
                          setState(() {
                            speed = value;
                          });
                        },
                      ))),
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
                            });
                          })))
            ]);
          }
        });
  }

  @override
  void dispose() {
    super.dispose();

    sendLoop.cancel();
  }

  Future<BluetoothCharacteristic> getCharacteristic() async {
    List<BluetoothService> services = await widget.device.discoverServices();

    var service = services.firstWhere(
        (s) => s.uuid == Guid("0000180c-0000-1000-8000-00805f9b34fb"));
    var char = service.characteristics.firstWhere(
        (c) => c.uuid == Guid("0000180c-0000-1000-8000-00805f9b34fb"));

    return char;
  }

  void sendSpeed(Timer timer) async {
    if (sendNeeded) {
      await speedChar.write([carID, speed.toInt()], withoutResponse: true);
      sendNeeded = false;
    }
  }
}
