import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

Future<CameraDescription> initCamera() async {
  // Ensure that plugin services are initialized so that `availableCameras()` can be called
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras and return it
  return cameras.first;
}

class BlindSightGuidance extends StatefulWidget {
    const BlindSightGuidance({
            super.key,
            required this.camera,
            });

    final CameraDescription camera;

    @override
        TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<BlindSightGuidance> {
    late CameraController _controller;
    late Future<void> _initializeControllerFuture;

    @override
        void initState() {
            super.initState();
            // To display the current output from the Camera,
            // create a CameraController.
            _controller = CameraController(
                    // Get a specific camera from the list of available cameras.
                    widget.camera,
                    // Define the resolution to use.
                    ResolutionPreset.medium,
                    );

            // Next, initialize the controller. This returns a Future.
            _initializeControllerFuture = _controller.initialize();
        }

    @override
        void dispose() {
            // Dispose of the controller when the widget is disposed.
            _controller.dispose();
            super.dispose();
        }

    @override 
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text("BlindSight Guidance")),
            body: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                        // If the Future is complete, display the preview.
                        return CameraPreview(_controller);
                    } else {
                        // Otherwise, display a loading indicator.
                        return const Center(child: CircularProgressIndicator());
                    }
                },
            ),
            floatingActionButton: FloatingActionButton.large(
                onPressed: () async {
                    // Initialize camera
                    await _initializeControllerFuture;

                    // NOTE: we need to find out how long it takes for AI to analyze an image
                    final serverDelay = 500;

                    // TODO: save serverDelay and serverUrl in env variables
                    final url = "http://10.0.2.2:3000/image";

                    var id = 0;

                    // TODO: change 5 to true when implementing with AI for constant inflow of images
                    while (id < 5) {
                        final image = await _controller.takePicture();
                        sleep(Duration(milliseconds: serverDelay));

                        final image_bytes = await image.readAsBytes();

                        final request = http.MultipartRequest("POST", Uri.parse(url));
                        request.fields["name"] = "guidanceIMG_$id";
                        request.fields["image"] = base64Encode(image_bytes);

                        request.send();

                        id++;
                    }


                },
                child: Icon(Icons.camera_alt),
            ),
        );
    }
}