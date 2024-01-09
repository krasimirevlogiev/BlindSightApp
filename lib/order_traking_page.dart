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

List<LatLng> polylineCoordinates = [];
LocationData? currentLocation;
Location location = Location();
Map<MarkerId, Marker> markers = {};
GoogleMapController? googleMapController;
bool _cameraShouldFollowLocation = false;
GoogleMapController? _controller;
Set<Marker> _markers = {};
Polyline _polyline = Polyline(polylineId: PolylineId('route1'), visible: false);
LatLng? _selectedPlace;
LatLng _userLocation = LatLng(0, 0); // Replace with the user's actual location

class LocationSearchDelegate extends SearchDelegate<String> {
  final OrderTrackingPageState mapState;

  LocationSearchDelegate(this.mapState);

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

  void setSelectedPlace(String place) {
    // TODO: Replace with the actual LatLng of the place
    _selectedPlace = LatLng(0, 0);
    if (_selectedPlace != null) {
      _markers.add(Marker(
          markerId: MarkerId('selectedPlace'), position: _selectedPlace!));
      _polyline = Polyline(
        polylineId: PolylineId('route1'),
        visible: true,
        points: [
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          _selectedPlace!
        ],
        color: Colors.blue,
      );
      _controller?.moveCamera(CameraUpdate.newLatLng(_selectedPlace!));
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
  LatLng? sourceLocation;
  LatLng? destination;
  bool _suggestionSelected = false;

  void setSelectedPlace(String place) {
    // ...
    _suggestionSelected = true;
  }

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

  @override
  void initState() {
    super.initState();

    getCurrentLocation();
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
                delegate: LocationSearchDelegate(this),
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
                Listener(
                  onPointerDown: (_) {
                    _cameraShouldFollowLocation = false;
                  },
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                      zoom: 13.5,
                    ),
                    polylines: {_polyline},
                    markers: Set<Marker>.of(markers.values),
                    myLocationButtonEnabled: false,
                  ),
                ),
                if (_suggestionSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FloatingActionButton(
                      child: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _markers.removeWhere((marker) =>
                              marker.markerId == MarkerId('selectedPlace'));
                          _polyline = Polyline(
                              polylineId: PolylineId('route1'), visible: false);
                          _suggestionSelected = false;
                        });
                      },
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
