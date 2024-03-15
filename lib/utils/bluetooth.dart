//import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> sendInstruction() async {

    final flutterReactiveBle = FlutterReactiveBle();

    //final _serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
    //final characteristicUuid = Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8"); 
    //var deviceId;

    String devices = "";

    var status = await Permission.location.request();

    if (status.isGranted) {

        flutterReactiveBle.scanForDevices(withServices: [], requireLocationServicesEnabled: false ).listen((device) {
                devices += device.id;
                }, onError: (e) {
                print("👋 " + e.toString());
                return e.toString();

                });

    }

    return devices;
    //flutterReactiveBle.connectToDevice(id: deviceId);


    //final characteristic = QualifiedCharacteristic(
    //        serviceId: serviceUuid,
    //        characteristicId: characteristicUuid,
    //        deviceId: deviceId,
    //        );

    //flutterReactiveBle.writeCharacteristicWithoutResponse(characteristic, value: Utf8Encoder().convert("LEFT"));

}

