import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  List<int> laps = [0, 0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Lap Counter"),
        ),
        body: Row(
          //direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _lapViewer(0),
            VerticalDivider(
              thickness: 1.0,
            ),
            _lapViewer(1),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();

    widget.device.disconnect();
  }

  Widget _lapViewer(int carIndex) {
    return Text(
      "${laps[carIndex]}",
      textScaleFactor: 5.0,
    );
  }
}
