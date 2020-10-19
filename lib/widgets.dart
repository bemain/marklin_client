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
  Future<void> _futureSpeed;
  double speed = 0;

  @override
  void initState() {
    super.initState();
    _futureSpeed = sendSpeed(widget.device, speed);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureSpeed,
        builder: (c, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("Device not found..."));
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());

            default:
              return snapshot.hasError
                  ? Center(child: Text('Error: ${snapshot.error}'))
                  : Expanded(
                      child: RotatedBox(
                          quarterTurns: -1,
                          child: Slider(
                            value: speed,
                            onChanged: (value) {
                              setState(() {
                                speed = value;
                                _futureSpeed = sendSpeed(widget.device, speed);
                                print("Speed: " + value.toString());
                              });
                            },
                          )));
          }
        });
  }

  Future<void> sendSpeed(BluetoothDevice device, double speed) async {
    List<BluetoothService> services = await device.discoverServices();

    for (var s in services) {
      print("Service: " + s.uuid.toString());
    }

    BluetoothService service = services.firstWhere(
        (s) => s.uuid == Guid("0000180c-0000-1000-8000-00805f9b34fb"));

    for (var s in service.characteristics) {
      print("Char: " + s.uuid.toString());
    }

    var char = service.characteristics.firstWhere(
        (c) => c.uuid == Guid("0000180c-0000-1000-8000-00805f9b34fb"));
    print(char);

    await char.write([1]);
    print("Write done.");
  }
}
