import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/widgets.dart';

class SelectCharacteristicScreen extends StatelessWidget {
  /// Widget for selecting a Bluetooth Characteristic for [Bluetooth.service].
  ///
  /// Tries to get characteristic automatically using [autoconnectID], if given.
  /// Otherwise, lets user select characteristic from list.
  const SelectCharacteristicScreen({
    super.key,
    this.title = const Text("Select Bluetooth Characteristic"),
    this.autoconnectID,
    this.onCharSelected,
  });

  /// The title to use in the AppBar.
  final Widget title;

  /// Called when a characteristic has been selected.
  final Function(String charID, BluetoothCharacteristic char)? onCharSelected;

  /// Is set, tries to automatically connect to device using this as id.
  final String? autoconnectID;

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.service != null); // Needs BT service

    if (autoconnectID != null) {
      // Try using autoconnectID to get service automatically
      List<BluetoothCharacteristic> chars = Bluetooth.service!.characteristics
          .where((c) => c.uuid == Guid(autoconnectID!))
          .toList();
      if (chars.isNotEmpty) {
        onCharSelected?.call(chars[0].uuid.toString(), chars[0]);
        return const InfoScreen(
          icon: Icon(Icons.select_all),
          text: "Characteristic automatically selected",
        );
      }
    }

    // Otherwise, let user select characteristic from list
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
