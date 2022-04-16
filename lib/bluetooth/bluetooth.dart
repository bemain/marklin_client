import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class Bluetooth {
  static BluetoothDevice? device;

  static String serviceID = "0000181c-0000-1000-8000-00805f9b34fb";
  static BluetoothService? service;

  static String speedCharID = "0000180c-0000-1000-8000-00805f9b34fb";
  static BluetoothCharacteristic? speedChar;
  static String lapCharID = "0000181c-0000-1000-8000-00805f9b34fb";
  static BluetoothCharacteristic? lapChar;
}

class CharacteristicSelectorScreen extends StatefulWidget {
  const CharacteristicSelectorScreen({Key? key, this.onCharSelected})
      : super(key: key);

  final Function(String serviceID, String charID)? onCharSelected;

  @override
  State<StatefulWidget> createState() {
    return CharacteristicSelectorScreenState();
  }
}

class CharacteristicSelectorScreenState
    extends State<CharacteristicSelectorScreen> {
  BluetoothService? _service;
  String serviceID = "";
  String charID = "";

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.device != null); // Needs connected BT device

    if (_service == null) {
      return FutureBuilder<List<BluetoothService>>(
        future: Bluetooth.device!.discoverServices(),
        initialData: const [],
        builder: niceAsyncBuilder(
          loadingText: "Getting services...",
          activeBuilder: (BuildContext c, snapshot) {
            return ListView(
              children: snapshot.data!
                  .map(
                    (serv) => TextTile(
                      title: serv.uuid.toString(),
                      onTap: () {
                        setState(() {
                          serviceID = serv.uuid.toString();
                          _service = serv;
                        });
                      },
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );
    }

    return ListView(
      children: _service!.characteristics
          .map(
            (char) => TextTile(
              title: char.uuid.toString(),
              onTap: () {
                setState(() {
                  charID = char.uuid.toString();
                });
                widget.onCharSelected?.call(serviceID, charID);
              },
            ),
          )
          .toList(),
    );
  }
}
