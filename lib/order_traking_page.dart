import 'dart:async';
//import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: Implement your logic to search for a location and return the result
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Start typing...'));
    } else {
      return FutureBuilder<List<String>>(
        future: _getPlaceSuggestions(query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<String> suggestions = snapshot.data!;
            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: Colors.black),
                    title: Text(suggestions[index],
                        style: TextStyle(color: Colors.black)),
                    trailing:
                        Icon(Icons.arrow_forward_ios, color: Colors.black),
                    onTap: () {
                      close(context, suggestions[index]);
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }

  Future<List<String>> _getPlaceSuggestions(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyBPg4rFcszsTpNmd0mSjSMKye20SrGlhD8',
      ),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> predictions = data['predictions'];
      return predictions
          .map<String>((prediction) => prediction['description'] as String)
          .toList();
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to load place suggestions');
    }
  }
}

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
  Map<MarkerId, Marker> markers = {};
  GoogleMapController? googleMapController;
  bool _cameraShouldFollowLocation = false;

  void _onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    _controller.complete(controller);
  }

  void getCurrentLocation() async {
    location.getLocation().then((locationData) {
      currentLocation = locationData;

      location.onLocationChanged.listen((newLoc) async {
        currentLocation = newLoc;

        if (_cameraShouldFollowLocation && googleMapController != null) {
          await googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(newLoc.latitude!, newLoc.longitude!),
                zoom: 13.5,
              ),
            ),
          );
        }

        MarkerId markerId = const MarkerId("currentLocation");
        Marker currentLocationMarker = Marker(
          markerId: markerId,
          position: LatLng(newLoc.latitude!, newLoc.longitude!),
        );
        setState(() {
          markers[markerId] = currentLocationMarker;
        });
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

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    markers[const MarkerId("source")] = const Marker(
      markerId: MarkerId("source"),
      position: sourceLocation,
    );
    markers[const MarkerId("destination")] = const Marker(
      markerId: MarkerId("destination"),
      position: destination,
    );

    getCurrentLocation();
    getPolyPoints();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Track the disabled",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: LocationSearchDelegate(),
              ); // Manually request the keyboard to show up
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: primaryColor,
                      width: 6,
                    ),
                  },
                  markers: Set<Marker>.of(markers.values),
                  myLocationButtonEnabled: false,
                ),
                GestureDetector(
                  onTap: () {
                    _cameraShouldFollowLocation = false;
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 30,
                  child: FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: () async {
                      if (currentLocation != null &&
                          googleMapController != null) {
                        _cameraShouldFollowLocation = true;
                        await googleMapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(currentLocation!.latitude!,
                                  currentLocation!.longitude!),
                              zoom: 13.5,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.navigation, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
