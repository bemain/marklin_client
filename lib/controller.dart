import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/widgets.dart';

/// Screen for controlling and receiving lap times from the cars.
class ControllerScreen extends StatefulWidget {
  final bool debugMode;

  const ControllerScreen({Key? key, this.debugMode = false}) : super(key: key);

  @override
  _ControllerScreenState createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<ControllerScreen> {
  bool _enableSlowDown = true;
  int carID = 0;

  @override
  Widget build(BuildContext context) {
    return (!widget.debugMode && Bluetooth.device == null)
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
                title: Text("Märklin BLE Controller" +
                    (widget.debugMode ? "(Debug)" : "")),
                actions: [
                  IconButton(
                      icon: const Icon(Icons.plus_one),
                      onPressed: () async => Races.currentRaceRef
                          .addLap(carID) // Add lap to database
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
                debugMode: widget.debugMode,
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
  final bool enableSlowDown;
  final Function(int newID)? onCarIDChange;
  final bool debugMode;

  const SpeedSlider(
      {Key? key,
      this.enableSlowDown = false,
      this.onCarIDChange,
      this.debugMode = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SpeedSliderState();
}

class SpeedSliderState extends State<SpeedSlider> {
  final friction = 10;

  double speed = 0.0;
  int carID = 0;

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
                      Bluetooth.serviceID = sid;
                      Bluetooth.speedCharID = cid;
                      _futureChar = getCharacteristic();
                    });
                  },
                )
              : PageView(
                  children: List.filled(4, _buildSlider()),
                  onPageChanged: (int i) => setState(() {
                    carID = i;
                    sendNeeded = true;
                    widget.onCarIDChange?.call(carID);
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
    if (widget.debugMode) return true;
    assert(Bluetooth.device != null); // Needs connected BT device

    // Discover services
    List<BluetoothService> services =
        await Bluetooth.device!.discoverServices();
    var sers =
        services.where((s) => s.uuid == Guid(Bluetooth.serviceID)).toList();
    if (sers.isEmpty) return false; // Service not found

    // Speed char
    var _speedChars = sers[0]
        .characteristics
        .where((c) => c.uuid == Guid(Bluetooth.speedCharID))
        .toList();
    if (_speedChars.isEmpty) return false; // Characteristic not found
    _speedChar = _speedChars[0];

    // Lap char
    var _lapChars = sers[0]
        .characteristics
        .where((c) => c.uuid == Guid(Bluetooth.lapCharID))
        .toList();
    if (_lapChars.isEmpty) return false; // Characteristic not found
    // Listen to changes
    await _lapChars[0].setNotifyValue(true);
    _lapChars[0].value.listen(valueReceived);

    return true;
  }

  void sendSpeed(Timer timer) async {
    // Send speed to bluetooth device
    if (sendNeeded) {
      Races.currentRaceRef.addSpeedEntry(carID, speed);
      if (!widget.debugMode) {
        await _speedChar?.write(
          [carID, 100 - speed.toInt()],
          withoutResponse: true,
        );
      }
      sendNeeded = false;
    }
  }

  void valueReceived(List<int> event) {
    debugPrint("BLUETOOTH: Value received: $event");
    if (event.isNotEmpty && event[0] % 2 == carID) {
      Races.currentRaceRef.addLap(event[0] % 2);
    }
  }

  void slowDown(Timer timer) {
    // Slow down car
    if (widget.enableSlowDown && willSlowDown && speed != 0) {
      sendNeeded = true;
      setState(() {
        speed -= min(speed, friction);
      });
    }
  }
}
