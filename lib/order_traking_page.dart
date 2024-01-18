import 'dart:async';
//import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:BlindSightApp/components/camera_page.dart';
import 'package:BlindSightApp/components/menu_drawer.dart';
import 'package:BlindSightApp/utils/camera.dart';
import 'package:BlindSightApp/constants.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
double? deviceOrientation;

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
                return ListTile(
                  leading: Icon(Icons.location_on, color: Colors.black),
                  title: Text(suggestions[index],
                      style: TextStyle(color: Colors.black)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
                  onTap: () {
                    close(context, suggestions[index]);
                  },
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
    _suggestionSelected = true;
  }

  void _onMapCreated(GoogleMapController controller) async {
    googleMapController = controller;
    _controller.complete(controller);

    String mapStyle = await rootBundle.loadString('assets/map_dark_theme.json');

    googleMapController!.setMapStyle(mapStyle);
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
                zoom: 15.5,
              ),
            ),
          );
        }

        final ImageConfiguration imageConfiguration =
            createLocalImageConfiguration(context);
        final BitmapDescriptor bitmapDescriptor =
            await BitmapDescriptor.fromAssetImage(
                imageConfiguration, 'assets/currentLocation.png');

        MarkerId markerId = const MarkerId("currentLocation");
        Marker currentLocationMarker = Marker(
          markerId: markerId,
          position: LatLng(newLoc.latitude!, newLoc.longitude!),
          icon: bitmapDescriptor,
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
    FlutterCompass.events?.listen((CompassEvent direction) {
      setState(() {
        deviceOrientation = direction.heading;
      });
    });
    getCurrentLocation();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Track",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              showSearch(
                context: context,
                delegate: LocationSearchDelegate(this),
              );
            },
          )
        ],
      ),
      drawer: MenuDrawer(),
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
                    backgroundColor: Colors.transparent,
                    onPressed: () async {
                      if (currentLocation != null &&
                          googleMapController != null) {
                        _cameraShouldFollowLocation = true;
                        await googleMapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(currentLocation!.latitude!,
                                  currentLocation!.longitude!),
                              zoom: 15.5,
                            ),
                          ),
                        );
                      }
                    },
                    child: ClipOval(
                      child: Container(
                        color: Colors
                            .white, // This will fill the transparent background inside the SVG with white
                        child: SvgPicture.asset(
                          'assets/icons/navigation-15.svg',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
