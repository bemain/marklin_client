import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/bluetooth/bluetooth.dart';
import 'package:marklin_bluetooth/widgets.dart';

class SelectServiceScreen extends StatelessWidget {
  /// Widget for selecting a Bluetooth Service for [Bluetooth.device].
  ///
  /// Tries to get service automatically using [autoconnectID].
  /// If this fails or id not given, lets user select service from list.
  const SelectServiceScreen({
    Key? key,
    this.autoconnectID,
    this.onServiceSelected,
  }) : super(key: key);

  final String? autoconnectID;
  final Function(String serviceID, BluetoothService service)? onServiceSelected;

  @override
  Widget build(BuildContext context) {
    assert(Bluetooth.device != null); // Needs connected BT device

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bluetooth Service"),
      ),
      body: FutureBuilder<List<BluetoothService>>(
        future: Bluetooth.device!.discoverServices(),
        initialData: const [],
        builder: niceAsyncBuilder(
          loadingText: "Getting services...",
          activeBuilder: (BuildContext c, snapshot) {
            List<BluetoothService> services = snapshot.data!;
            if (autoconnectID != null) {
              // Try using Bluetooth.serviceID to get service automatically
              var sers = services
                  .where((s) => s.uuid == Guid(autoconnectID!))
                  .toList();
              if (sers.isNotEmpty) {
                onServiceSelected?.call(sers[0].uuid.toString(), sers[0]);
                return const InfoScreen(
                  icon: Icon(Icons.select_all),
                  text: "Service automatically selected",
                );
              }
            }

            // Otherwise, let user select service from list
            return ListView(
              children: services
                  .map((serv) => TextTile(
                        title: serv.uuid.toString(),
                        onTap: () {
                          onServiceSelected?.call(serv.uuid.toString(), serv);
                        },
                      ))
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
