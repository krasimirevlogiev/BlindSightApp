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

void launchCamera(CameraController _controller) async {

    // NOTE: we need to find out how long it takes for AI to analyze an image
    final serverDelay = 500;

    final url = Uri.parse("https://" + FlutterConfig.get("BACKEND_HOST") + "/image");

    var id = 0;

    // TODO: change 5 to true when implementing with AI for constant inflow of images
    while (id < 5) {
        final image = await _controller.takePicture();
        sleep(Duration(milliseconds: serverDelay));

        final image_bytes = await image.readAsBytes();

        final request = http.MultipartRequest("POST", url);
        request.fields["name"] = "guidanceIMG_$id";
        request.fields["image"] = base64Encode(image_bytes);

        request.send();

        id++;
    }

}

