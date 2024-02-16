import 'package:flutter_blue/flutter_blue.dart';


Future<BluetoothCharacteristic> initBluetooth() async {
    print("HELLO🚀🚀🚀");
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    BluetoothDevice? device = null;

    flutterBlue.scanResults.listen((event) {
        for (ScanResult r in event) {
            print("New device: ${r.device.name}");
            if (r.device.name == "BlindSight_LEFT") {
                device = r.device;
            }
        }
    });

    await device!.connect();

    List<BluetoothService> services = await device!.discoverServices();

    late BluetoothCharacteristic characteristic;

    services.forEach((service) {
            for (BluetoothCharacteristic c in service.characteristics) {
                print("New characteristic: ${c.serviceUuid}");
                if (c.serviceUuid == "4fafc201-1fb5-459e-8fcc-c5c9c331914b") {
                    characteristic = c;
                    break;
                }
            }
    });

    return characteristic;
}
