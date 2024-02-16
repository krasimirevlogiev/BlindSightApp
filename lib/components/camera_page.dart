import 'dart:io';

import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:BlindSightApp/utils/bluetooth.dart';

import 'package:BlindSightApp/utils/camera.dart';
import 'package:flutter_blue/flutter_blue.dart';

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

            (() async {
                //print("starting bluetooth 🧙");
                //BluetoothCharacteristic connection = await initBluetooth();
                await _initializeControllerFuture;

                while (true) {
                    var instruction = await launchCamera(_controller);


                    //sleep(Duration(seconds: 1));
                    //connection.write([1]);
                    
                    var instruction_snackbar = SnackBar(content: Text(instruction));
                    ScaffoldMessenger.of(context).showSnackBar(instruction_snackbar);

                }

            })();

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
            drawer: MenuDrawer(),
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
        );
    }
}
