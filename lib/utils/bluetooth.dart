
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
class BleController extends GetxController {

  // This method now returns a Future<BluetoothDevice?>
  Future<BluetoothDevice?> scanAndConnectToDevice() async {
  // Replace 'your_uuid_here' with the actual UUID you're looking for
  final Guid targetUuid = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
    BluetoothDevice? connectedDevice;
    var blePermission = await Permission.bluetoothScan.status;
    if (blePermission.isDenied) {
      blePermission = await Permission.bluetoothScan.request();
    }
    if (blePermission.isGranted) {
      await Permission.bluetoothConnect.request();
      // Start scanning with filters for the specific UUID
      await FlutterBluePlus.startScan(
        withServices: [targetUuid],
        timeout: Duration(seconds: 10),
      );

      // Listen for scan results
      await for (var scanResult in FlutterBluePlus.scanResults) {
        for (ScanResult result in scanResult) {
          var device = result.device;
          print('Found device: ${device.advName} [${device.remoteId}]');

          // Check if the device has the target UUID
          if (result.advertisementData.serviceUuids.contains(targetUuid.toString())) {
            print('Device with target UUID found, connecting...');
            await FlutterBluePlus.stopScan();
            connectedDevice = await connectToDevice(device);
            return connectedDevice; // Return the connected device
          }
        }
      }

      // Make sure to stop the scan after the timeout
      await Future.delayed(Duration(seconds: 10));
      FlutterBluePlus.stopScan();
    } else {
      print('BLE scan permission is denied');
    }
    return connectedDevice; // Return null if no device was connected
  }

  // Modify connectToDevice to return the BluetoothDevice upon successful connection
  Future<BluetoothDevice?> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      return device; // Return the device after successful connection
    } catch (e) {
      print("Failed to connect to the device: $e");
      return null; // Return null if the connection fails
    }
  }}
