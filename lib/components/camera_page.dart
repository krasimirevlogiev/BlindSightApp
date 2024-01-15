import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:BlindSightApp/utils/camera.dart';

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
                await _initializeControllerFuture;

                launchCamera(_controller);

                return _initializeControllerFuture;
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
