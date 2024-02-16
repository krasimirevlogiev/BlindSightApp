import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

Future<CameraDescription> initCamera() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras and return it
  return cameras.first;
}

Future<String> launchCamera(CameraController _controller) async {

    // NOTE: we need to find out how long it takes for AI to analyze an image
    final serverDelay = 1500;

    final uri = Uri.parse("http://" + FlutterConfig.get("BACKEND_HOST") + "/image");

    final id = DateTime.now().millisecondsSinceEpoch;

    final image = await _controller.takePicture();
    sleep(Duration(milliseconds: serverDelay));

    final image_bytes = await image.readAsBytes();

    final request = http.MultipartRequest("POST", uri);
    request.fields["name"] = "guidanceIMG_$id";
    request.fields["image"] = base64Encode(image_bytes);

    final response = await request.send();

    // TODO: Implement TTS functionality and remove the temporary snackbar below 👇

    final responseText = await response.stream.bytesToString();
    print(responseText);
    var instruction = responseText;

    return instruction;

}

