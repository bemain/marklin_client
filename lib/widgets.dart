import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceTile extends StatelessWidget {
  const BluetoothDeviceTile({Key key, this.device, this.onTap})
      : super(key: key);

  final BluetoothDevice device;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _buildTitle(context),
      onPressed: onTap,
    );
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

            return RotatedBox(
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
                ));
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
    print("(Maybe) sending speed");
    if (sendNeeded) {
      await speedChar.write([speed.toInt()], withoutResponse: true);
      sendNeeded = false;
    }
  }
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key key, this.icon, this.text}) : super(key: key);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[icon, Text(text)]));
  }
}
