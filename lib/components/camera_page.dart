import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:audioplayers/audioplayers.dart';
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

            final audioplayer = AudioPlayer();

            Future.delayed(Duration.zero, () async {
                //print("starting bluetooth 🧙");
                //BluetoothCharacteristic connection = await initBluetooth();
                await _initializeControllerFuture;

                while (true) {
                    var instruction = await launchCamera(_controller);

                    instruction = instruction.trim();

                    if (instruction == "LEFT" ||
                        instruction == "RIGHT" ||
                        instruction == "STOP" ) {

                        await audioplayer.play(AssetSource("sounds/" + instruction.toLowerCase() + ".mp3"));
                        var instruction_snackbar = SnackBar(content: Text(instruction));
                        ScaffoldMessenger.of(context).showSnackBar(instruction_snackbar);
                    }
                }

                });

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
        drawer: MenuDrawer(), // Keeps the drawer accessible
        body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                    // Use a Column to layout the CameraPreview to take all available space
                    return Column(
                      children: <Widget>[
                        Expanded(
                          // The Expanded widget makes the CameraPreview expand to fill the available space
                          child: CameraPreview(_controller),
                        ),
                      ],
                    );
                } else {
                    // Display a loading indicator while the camera is initializing
                    return const Center(child: CircularProgressIndicator());
                }
            },
        ),
    );
}
}
