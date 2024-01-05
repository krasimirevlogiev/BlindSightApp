import 'dart:async';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  Location location = Location();


  void getCurrentLocation() async {

    location.getLocation().then(
      (location){
        currentLocation = location;
      },
      );

    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((newLoc) {
      print("Location is changed");
      currentLocation = newLoc;

      if (_controller.isCompleted) {
        _controller.future.then((googleMapController) {
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: 13.5,
                target: LatLng(
                  newLoc.latitude!,
                  newLoc.longitude!,
                ),
              ),
            ),
          );
        });
      }

      setState(() {
      });
    });
  }
    

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty){
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
        LatLng(point.latitude, point.longitude),
      ),
      );
      setState(() {});
    }
  }

@override
  void initState(){
    getCurrentLocation();
    super.initState();
    getPolyPoints();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track the disabled",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          :GoogleMap(
        initialCameraPosition: 
            CameraPosition(
              target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              zoom: 13.5
        ),
        polylines: {
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: primaryColor,
            width: 6,
          ),
        },
        markers: {
          Marker(markerId: const MarkerId("currentLocation"),
          position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          ),
          const Marker(markerId: MarkerId("source"),
          position: sourceLocation,
          ),
          const Marker(markerId: MarkerId("destination"),
          position: destination,
          ),
        },
      ),
    );
  }}
