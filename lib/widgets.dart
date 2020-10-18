import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceTile extends StatelessWidget {
  const BluetoothDeviceTile({Key key, this.device, this.onTap})
      : super(key: key);

  final BluetoothDevice device;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            device.name,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(device.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _buildTitle(context),
      onPressed: onTap,
    );
  }
}
