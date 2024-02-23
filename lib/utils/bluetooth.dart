import 'dart:async';
import 'dart:io';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleDeviceManager {
  final FlutterReactiveBle flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanStream;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  final Uuid serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final Uuid characteristicUuid = Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  // Callbacks for UI updates or state management
  Function(DiscoveredDevice)? onDeviceFound;
  Function(bool)? onConnectionChanged;

  BleDeviceManager({this.onDeviceFound, this.onConnectionChanged});

  Future<void> startScan() async {
    bool permGranted = await _requestPermissions();
    if (permGranted) {
      _scanStream = flutterReactiveBle.scanForDevices(withServices: [serviceUuid]).listen((device) {
        if (device.name == 'BlindSight_LEFT') {
          onDeviceFound?.call(device);
          _scanStream?.cancel(); // Optional: stop scanning once the device is found
        }
      });
    } else {
      print('Bluetooth scanning permission not granted');
    }
  }

  void connectToDevice(String deviceId) {
    _scanStream?.cancel(); // We're done scanning, we can cancel it

    _connectionSubscription = flutterReactiveBle.connectToAdvertisingDevice(
      id: deviceId,
      withServices: [serviceUuid],
      prescanDuration: const Duration(seconds: 10),
    ).listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          onConnectionChanged?.call(true);
          break;
        case DeviceConnectionState.disconnected:
          onConnectionChanged?.call(false);
          break;
        default:
          break;
      }
    }, onError: (dynamic error) { 
      print("Connection error: $error"); 
      onConnectionChanged?.call(false);
      _connectionSubscription?.cancel();
          });
      }

  Future<bool> _requestPermissions() async {
    var status = await Permission.location.request();
    return status.isGranted;
  }

  void dispose() {
    _scanStream?.cancel();
    _connectionSubscription?.cancel();
  }
}
