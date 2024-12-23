import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/firebase/races.dart';

class SpeedSlider extends StatefulWidget {
  /// Slider for controlling the speed of a car.
  /// Also receives lap times from the server for the currently selected car.
  const SpeedSlider(
      {super.key,
      this.enableSlowDown = false,
      this.onCarIDChange,
      this.debugMode = false});

  /// If true, will automatically decrease speed if slider is let go of.
  final bool enableSlowDown;

  /// Callback for when the currently selected car changes.
  final Function(int newID)? onCarIDChange;

  /// If true, will not send speed to or receive lap times from the server.
  /// Will still log speed history.
  final bool debugMode;

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

  @override
  void initState() {
    super.initState();

    if (!widget.debugMode) {
      // Listen for lap notifies
      assert(
        Bluetooth.lapChar != null,
        "No BT Lap Characteristic has been selected",
      );
      Bluetooth.lapChar?.setNotifyValue(true).then((value) {
        Bluetooth.lapChar?.lastValueStream.listen(valueReceived);
      });
    }

    sendLoop = Timer.periodic(const Duration(milliseconds: 100), sendSpeed);
    slowDownLoop = Timer.periodic(const Duration(milliseconds: 10), slowDown);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: List.filled(4, _buildSlider()),
      onPageChanged: (int i) => setState(() {
        carID = i;
        sendNeeded = true;
        widget.onCarIDChange?.call(carID);
      }),
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

  void sendSpeed(Timer timer) async {
    if (sendNeeded) {
      Races.currentRaceRef.addSpeedEntry(carID, speed); // Record speed
      if (!widget.debugMode) {
        // Send speed to bluetooth device
        assert(
          Bluetooth.speedChar != null,
          "No BT Speed Characteristic has been selected",
        );
        await Bluetooth.speedChar?.write(
          [carID, 100 - speed.toInt()],
          withoutResponse: true,
        );
      }
    }
    sendNeeded = false;
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
