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

  /// If true, will try to automatically connect to device.
  ///
  /// Is false until scan button is pressed, to block autoconnect until there
  /// has been user input.
  bool tryAutoConnect = false;

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
                // Try using autoconnectID to get device automatically.
                // Otherwise, let user select device from list
                return tryAutoconnect(results) ?? buildDeviceList(results);
              })
          : FutureBuilder(
              future: connectBT(),
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
        builder: (c, AsyncSnapshot<bool> snapshot) => buildFAB(snapshot.data!),
      ),
    );
  }

  /// If device with id [widget.autoconnectID] is in [scanResults], connects to it.
  /// Otherwise, returns null.
  Widget? tryAutoconnect(List<ScanResult> scanResults) {
    scanResults =
        scanResults.where((s) => s.device.id == widget.autoconnectID).toList();
    if (tryAutoConnect && scanResults.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedDevice = scanResults[0].device;
        });
      });
      return const InfoScreen(
        icon: Icon(Icons.select_all),
        text: "Device automatically selected",
      );
    }
    return null;
  }

  /// Displays [scanResults] as a list and allows the user to select one of them.
  Widget buildDeviceList(List<ScanResult> scanResults) {
    return ListView(
      children: scanResults.map((result) {
        return TextTile(
          title: result.device.name,
          text: result.device.id.toString(),
          onTap: () {
            setState(() => selectedDevice = result.device);
          },
        );
      }).toList(),
    );
  }

  /// FloatingActionButton that shows whether we are scanning or not.
  /// When pressed, starts scanning and enables autoconnect.
  Widget buildFAB(bool isScanning) {
    return FloatingActionButton(
      heroTag: "select_bt_device",
      child: Icon(isScanning ? Icons.bluetooth_searching : Icons.search),
      onPressed: () {
        // Enable autoconnect since user input has now been given
        tryAutoConnect = true;
        if (!isScanning && selectedDevice == null) {
          // Start scan
          flutterBlue.startScan(timeout: const Duration(seconds: 4));
        }
      },
    );
  }

  /// Connect to [selectedDevice], then call [widget.onDeviceConnected].
  Future<void> connectBT() async {
    await flutterBlue.stopScan();

    if ((await flutterBlue.connectedDevices).isEmpty) {
      // Connect to device
      await selectedDevice!.connect();
    } else {
      // Don't connect if already connected
      debugPrint("BLUETOOTH: Already connected");
    }

    widget.onDeviceConnected?.call(selectedDevice!);
  }
}
