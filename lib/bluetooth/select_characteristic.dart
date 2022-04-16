import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/widgets.dart';

class SelectCharacteristicScreen extends StatelessWidget {
  const SelectCharacteristicScreen({
    Key? key,
    this.onCharSelected,
    this.title = const Text("Select Bluetooth Characteristic"),
  }) : super(key: key);

  final Widget title;
  final Function(String charID, BluetoothCharacteristic char)? onCharSelected;

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.service != null); // Needs BT service

    return Scaffold(
      appBar: AppBar(
        title: title,
      ),
      body: ListView(
        children: Bluetooth.service!.characteristics
            .map(
              (char) => TextTile(
                title: char.uuid.toString(),
                onTap: () {
                  onCharSelected?.call(char.uuid.toString(), char);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
