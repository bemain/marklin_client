import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:marklin_bluetooth/widgets.dart';

class SelectDeviceScreen extends StatefulWidget {
  /// Widget for selecting and connecting to a Bluetooth Device
  ///
  /// Tries to get device automatically using [autoconnectID], if given.
  /// Otherwise, lets user select device from list.
  ///
  /// Also features button for entering debug mode.
  const SelectDeviceScreen({
    Key? key,
    this.onDeviceConnected,
    this.onDebugModeSelected,
    this.autoconnectID,
  }) : super(key: key);

  /// Default callback, called when a device has been selected and connected to.
  final Function(BluetoothDevice device)? onDeviceConnected;

  /// Called when the button for entering debug mode is pressed. In this case,
  /// [onDeviceConnected] is not triggered.
  final Function? onDebugModeSelected;

  /// Is set, tries to automatically connect to device using this as id.
  final DeviceIdentifier? autoconnectID;

  @override
  State<StatefulWidget> createState() => SelectDeviceScreenState();
}

class SelectDeviceScreenState extends State<SelectDeviceScreen> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  BluetoothDevice? selectedDevice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Bluetooth Device"),
        actions: [
          IconButton(
            onPressed: (() => widget.onDebugModeSelected?.call()),
            icon: const Icon(Icons.developer_mode),
          )
        ],
      ),
      body: (selectedDevice == null)
          ? StreamBuilder<List<ScanResult>>(
              stream: flutterBlue.scanResults,
              initialData: const [],
              builder: (c, snapshot) {
                var results = snapshot.data!;
                // Try using autoconnectID to get service automatically
                results = results
                    .where((s) => s.device.id == widget.autoconnectID)
                    .toList();
                if (results.isNotEmpty) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      selectedDevice = results[0].device;
                    });
                  });
                  return const InfoScreen(
                    icon: Icon(Icons.select_all),
                    text: "Device automatically selected",
                  );
                }

                // Otherwise, let user select device from list
                return ListView(
                    children: snapshot.data!
                        .map((result) => TextTile(
                            title: result.device.name,
                            text: result.device.id.toString(),
                            onTap: () {
                              setState(() => selectedDevice = result.device);
                            }))
                        .toList());
              })
          : FutureBuilder(
              future: _connectBT(),
              builder: niceAsyncBuilder(
                loadingText: "Connecting to device...",
                errorText: "Unable to connect to device",
                activeBuilder: (BuildContext c, snapshot) {
                  return const InfoScreen(
                      icon: Icon(Icons.bluetooth_connected),
                      text: "Connected to device");
                },
              ),
            ),
      floatingActionButton: StreamBuilder(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, AsyncSnapshot<bool> snapshot) => FloatingActionButton(
          heroTag: "select_bt_device",
          child:
              Icon(snapshot.data! ? Icons.bluetooth_searching : Icons.search),
          onPressed: () {
            if (!snapshot.data!) {
              flutterBlue.startScan(timeout: const Duration(seconds: 4));
            }
          },
        ),
      ),
    );
  }

  Future<void> _connectBT() async {
    // Don't connect if already connected
    if ((await FlutterBlue.instance.connectedDevices).isEmpty) {
      await selectedDevice!.connect();
    } else {
      debugPrint("BLUETOOTH: Already connected");
    }

    widget.onDeviceConnected?.call(selectedDevice!);
  }
}
