import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:io';

Future<void> main() async {
  // first, check if bluetooth is supported by your hardware
  if (await FlutterBluePlus.isSupported == false) {
    print("Bluetooth not supported by this device");
    return;
  }

  // handle bluetooth on & off
  var adapterStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
    print(state);
    if (state == BluetoothAdapterState.on) {
      // usually start scanning, connecting, etc
    } else {
      // show an error to the user, etc
    }
  });

  // listen to scan results
  var scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
    if (results.isNotEmpty) {
      ScanResult r = results.last; // the most recently found device
      print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
    }
  },
    onError: (e) => print(e),
  );

  // Wait for Bluetooth enabled & permission granted
  await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

  // Start scanning w/ timeout
  await FlutterBluePlus.startScan(
    withServices:[Guid("180D")],
    withNames:["Bluno"],
    timeout: Duration(seconds:15));

  // wait for scanning to stop
  await FlutterBluePlus.isScanning.where((val) => val == false).first;

  // Connect to the device
  // Replace `device` with the actual BluetoothDevice instance you want to connect to
  // await device.connect();

  // Disconnect from device
  // await device.disconnect();

  // cancel subscriptions when done
  adapterStateSubscription.cancel();
  scanResultsSubscription.cancel();
}
