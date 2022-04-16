import 'package:flutter_blue/flutter_blue.dart';

class Bluetooth {
  static BluetoothDevice? device;

  static String serviceID = "0000181c-0000-1000-8000-00805f9b34fb";
  static BluetoothService? service;

  static String speedCharID = "0000180c-0000-1000-8000-00805f9b34fb";
  static BluetoothCharacteristic? speedChar;
  static String lapCharID = "0000181c-0000-1000-8000-00805f9b34fb";
  static BluetoothCharacteristic? lapChar;
}
