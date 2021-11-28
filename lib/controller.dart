import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Screen for controlling and receiving lap times from the cars.
class ControllerScreen extends StatefulWidget {
  const ControllerScreen({Key? key}) : super(key: key);

  @override
  _ControllerScreenState createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  bool _enableSlowDown = true;
  int carID = 0;

  @override
  Widget build(BuildContext context) {
    return (Bluetooth.device == null)
        ? SelectDeviceScreen(onDeviceConnected: (device) => setState(() {}))
        : Theme(
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
                title: const Text("Märklin BLE Controller"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.plus_one),
                    onPressed: () async {
                      if ((await Races.currentRaceRef.race).running) {
                        Races.currentRaceRef
                            .addLap(carID); // Add lap to database
                      }
                    },
                  ),
                  IconButton(
                      icon: Icon(_enableSlowDown
                          ? Icons.toggle_on
                          : Icons.toggle_off_outlined),
                      onPressed: () {
                        setState(() {
                          _enableSlowDown = !_enableSlowDown; // Toggle slowdown
                        });
                      })
                ],
              ),
              body: SpeedSlider(
                enableSlowDown: _enableSlowDown,
                onCarIDChange: (id) {
                  setState(() {
                    carID = id;
                  });
                },
              ),
            ));
  }
}

class SpeedSlider extends StatefulWidget {
  const SpeedSlider({Key? key, this.enableSlowDown = false, this.onCarIDChange})
      : super(key: key);

  final bool enableSlowDown;
  final Function(int newID)? onCarIDChange;

  @override
  State<StatefulWidget> createState() => SpeedSliderState();
}

class SpeedSliderState extends State<SpeedSlider> {
  final friction = 10;

  String serviceID = "0000181c-0000-1000-8000-00805f9b34fb";
  String charID = "0000181c-0000-1000-8000-00805f9b34fb";

  double _speed = 0.0;
  int _carID = 0;

  bool willSlowDown = false;
  Timer? slowDownLoop;

  bool sendNeeded = false;
  Timer? sendLoop;

  Future<bool>? _futureChar;
  BluetoothCharacteristic? _speedChar;

  @override
  void initState() {
    super.initState();
    _futureChar = getCharacteristic();

    sendLoop = Timer.periodic(const Duration(milliseconds: 100), sendSpeed);
    slowDownLoop = Timer.periodic(const Duration(milliseconds: 10), slowDown);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _futureChar,
      builder: niceAsyncBuilder(
        loadingText: "Getting characteristic...",
        activeBuilder: (BuildContext c, snapshot) {
          return (!snapshot.data!) // Characteristic not found
              ? CharacteristicSelectorScreen(
                  onCharSelected: (sid, cid) {
                    setState(() {
                      serviceID = sid;
                      charID = cid;
                      _futureChar = getCharacteristic();
                    });
                  },
                )
              : PageView(
                  children: List.filled(4, _buildSlider()),
                  onPageChanged: (int i) => setState(() {
                    _carID = i;
                    sendNeeded = true;
                    widget.onCarIDChange?.call(_carID);
                  }),
                );
        },
      ),
    );
  }

  Widget _buildSlider() {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => willSlowDown = false,
      onPointerUp: (event) => willSlowDown = true,
      child: RotatedBox(
        quarterTurns: -1,
        child: Slider(
          value: _speed,
          onChanged: (value) {
            sendNeeded = true;
            setState(() {
              _speed = value;
            });
          },
          min: 0,
          max: 100,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    sendLoop?.cancel();
    slowDownLoop?.cancel();
  }

  /// Tries to get the given characteristic from [Bluetooth.device].
  /// Requires [Bluetooth.device] to be a connected BluetoothDevice
  /// Returns true if successful, false otherwise
  Future<bool> getCharacteristic() async {
    assert(Bluetooth.device != null); // Needs connected BT device

    List<BluetoothService> services =
        await Bluetooth.device!.discoverServices();
    var sers = services.where((s) => s.uuid == Guid(serviceID)).toList();
    if (sers.isEmpty) return false; // Service not found

    var chars = sers[0]
        .characteristics
        .where((c) => c.serviceUuid == Guid(charID))
        .toList();
    if (chars.isEmpty) return false; // Characteristic not found

    _speedChar = chars[0];
    return true;
  }

  void sendSpeed(Timer timer) async {
    // Send speed to bluetooth device
    if (sendNeeded) {
      await _speedChar
          ?.write([_carID, 100 - _speed.toInt()], withoutResponse: true);
      sendNeeded = false;
    }
  }

  void slowDown(Timer timer) {
    // Slow down car
    if (widget.enableSlowDown && willSlowDown && _speed != 0) {
      sendNeeded = true;
      setState(() {
        _speed -= min(_speed, friction);
      });
    }
  }
}
