import 'package:BlindSightApp/components/blindsense.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:BlindSightApp/utils/camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();
  final camera = await initCamera();
  runApp(BlindSightApp(camera: camera));
}

class BlindSightApp extends StatelessWidget {
  const BlindSightApp({super.key, required this.camera});

  final CameraDescription camera;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlindSight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      home: BlindSense(camera: camera),
    );
  }
}
