import 'dart:convert';
import 'dart:ffi';
import 'dart:math' as math;


import 'package:firebase_admin/firebase_admin.dart';
import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_routes/google_maps_routes.dart';


const double ZOOM = 13;
const double NEAR_DESTINATION_THRESHOLD = 100.0;

class DriverSide extends StatefulWidget {
  const DriverSide({Key? key}) : super(key: key);



  // final LatLng userLocation;
  //
  // const DriverSide({super.key, required this.userLocation});

  @override
  State<DriverSide> createState() => _DriverSideState();
}

class _DriverSideState extends State<DriverSide> {
  static GoogleMapController? _googleMapController ;
  final Set<Marker> _markers = {};
  final Set<Polyline>_polyline={};
  // Marker _selectedMarker = Marker();
  late List<LatLng> _polyLineCoordinates;
  late String _destinationStr;
  var _destLat;
  var _destLng;
  var _userLocation ;
  var _userId;
  var _destination;
  var showDestMarker = false;
  String _fare = ""; // initially empty
  String roundedStr = "";
  String formattedStr = "";
  String title1 = "pediGo";

  String get userId => "";
  LatLng? _driverLocation;
  bool done = false;
  bool driverNearDestination = false;
  bool showUserLocation = true;


// later on when a marker is tapped, _fare gets a value






  // Future<String?> _getPlaceName(LatLng latLng) async {
  //   // const apiKey = "AIzaSyASv9Vf-oeHsnYven-lxCwnQeAD9PiTDWQ";
  //   // final url =
  //   //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=500&key=$apiKey';
  //   //
  //   // final response = await http.get(Uri.parse(url));
  //   // final data = json.decode(response.body);
  //   //
  //   // if (data['status'] == 'OK') {
  //   //   final result = data['results'][0];
  //   //   return result['name'];
  //   // } else {
  //   //   throw Exception('Failed to get place name');
  //   // }
  //   final apiKey = "AIzaSyASv9Vf-oeHsnYven-lxCwnQeAD9PiTDWQ";
  //   final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey';
  //
  //   final response = await http.get(Uri.parse(url));
  //   final decodedResponse = json.decode(response.body);
  //
  //   if (decodedResponse['status'] == 'OK') {
  //     return decodedResponse['results'][0]['formatted_address'];
  //   } else {
  //     return null;
  //   }
  //
  //
  // }
  // Future<void> _destination(LatLng point) async {
  //   // Create the destination marker
  //   setState(() {
  //   final destinationMarker = Marker(
  //     markerId: const MarkerId('destination'),
  //     position: LatLng(_destLat, _destLng),
  //     infoWindow: InfoWindow(
  //       title: 'Destination',
  //       snippet: _destinationStr,
  //     ),
  //   );
  //
  //   // Create the polyline
  //   final polyline = Polyline(
  //     polylineId: const PolylineId('polyline'),
  //     color: Colors.blue,
  //     width: 5,
  //     points: _polyLineCoordinates,
  //   );
  //
  //   // Add the destination marker and polyline to the map
  //
  //     _markers.add(destinationMarker);
  //     _polyline.add(polyline);
  //   });
  //
  //
  //
  // }

  void _showDialog(BuildContext context) {
    // Call the _inventory function and store the returned values
    // Call the _inventory function and store the returned values

    List<dynamic> inventoryValues = _inventory(
        formattedStr, _userId, _userLocation.toString());
    String retrievedEarned = inventoryValues[0];
    String retrievedCommuter = inventoryValues[1];
    String retrievedUserLocation = inventoryValues[2];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Inventory"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Earned: $retrievedEarned"),
              Text("Commuter: $retrievedCommuter"),
              Text("User Location: $retrievedUserLocation"),
            ],
          ),
          actions: [
            MaterialButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

  }

  Future<void> _getPlaceName(LatLng latLng) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    Placemark place = placemarks[0];
    setState(() {
      _destinationStr = place.name! + ", " + place.thoroughfare!;
    });
  }

  double calculateFare(double distanceInKm) {
    const double baseFare = 12.0; // Base fare in PHP
    const double farePerKm = 2.0; // Fare per kilometer in PHP

    return baseFare + farePerKm * distanceInKm;
  }

  double calculateDistanceInKm(LatLng pickup, LatLng destination) {
    const int radiusOfEarth = 6371;
    double lat1 = pickup.latitude;
    double lat2 = destination.latitude;
    double lon1 = pickup.longitude;
    double lon2 = destination.longitude;

    double latDistance = (lat2 - lat1) * (math.pi / 180);
    double lonDistance = (lon2 - lon1) * (math.pi / 180);
    double a = math.sin(latDistance / 2) * math.sin(latDistance / 2) +
        math.cos((lat1) * (math.pi / 180)) *
            math.cos((lat2) * (math.pi / 180)) *
            math.sin(lonDistance / 2) *
            math.sin(lonDistance / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = radiusOfEarth * c;

    return distance;
  }

  Marker _driverMarker =  Marker(
    markerId: const MarkerId("driver_marker"),
    position: const LatLng(0, 0), // Initial position
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),

    infoWindow: const InfoWindow(
      title: 'Driver',
    ),

  );

  // void _doSomething(){
  //   Navigator.pushNamed(context, 'driversInventory');
  // }

  List<dynamic> _inventory(String earned, String commuter, String userLocation){
    earned = formattedStr;
    userLocation = _userLocation.toString();
    commuter = _userId;

    return [earned, commuter, userLocation];
  }

  bool isDriverNearDestination() {
    if (_driverLocation != null && _destination != null) {
      double distance = Geolocator.distanceBetween(
        _driverLocation!.latitude,
        _driverLocation!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );

      return distance <= NEAR_DESTINATION_THRESHOLD;
    }
    return false;
  }

  void handleFloatingActionButtonClick() {
    // Action to be performed when the floating action button is clicked
    // Only execute this action if the driver is near the destination
    if (isDriverNearDestination()) {
      // Perform your desired action here
      print('Floating action button clicked!');
    }

  }




  @override
  void initState() {
    super.initState();

    // Get the driver's location using Geolocator package
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        _driverLocation = LatLng(position.latitude, position.longitude);


        // Update the driver's marker position
        _driverMarker = _driverMarker.copyWith(
          positionParam: _driverLocation,
        );
      });
    });

    // Listen to Geolocator position changes to update the driver's location
    Geolocator.getPositionStream().listen((position) {
      setState(() {
        _driverLocation = LatLng(position.latitude, position.longitude);
        driverNearDestination = isDriverNearDestination();


        // Update the driver's marker position
        _driverMarker = _driverMarker.copyWith(
          positionParam: _driverLocation,
        );
      });
    });

    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        _driverLocation = LatLng(position.latitude, position.longitude);
        driverNearDestination = isDriverNearDestination();

        // ...
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text (title1),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              // PopupMenuItem 1
              PopupMenuItem(
                value: 1,
                // row with 2 children
                child: Row(
                  children: const [
                    Icon(Icons.inventory,
                      color: Colors.blue,),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Earnings")
                  ],
                ),
              ),
              // PopupMenuItem 2

            ],
            offset: Offset(0, 100),
            color: Colors.white,
            elevation: 2,
            // on selected we show the dialog box
            onSelected: (value) {
              // if value 1 show dialog

              if (value == 1 && done) {
                _showDialog(context);
                // if value 2 show dialog
              }
            },
          ),
        ],


      ),

      body: SafeArea(


        child: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseDatabase.instance.ref().child('commuters').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  // Extract the location and other data from snapshot
                  DataSnapshot dataValues = snapshot.data!.snapshot;
                  Map<dynamic, dynamic>? values = dataValues.value as Map?;
                  List<Marker> markers = [];
                  values!.forEach((key, value) async {
                    // Parse the latitude and longitude strings
                    List<String> userLocation = value['user_location'].replaceAll('LatLng(', '').replaceAll(')', '').split(', ');
                    double latitude = double.parse(userLocation[0]);
                    double longitude = double.parse(userLocation[1]);
                    LatLng latLng = LatLng(latitude, longitude);
                    _userLocation = latLng;

                    // Parse the destination location and calculate the distance
                    String destinationStr = value['destination'].replaceAll('LatLng(', '').replaceAll(')', '');
                    List<String> destination = destinationStr.split(', ');
                    double destLat = double.parse(destination[0]);
                    double destLng = double.parse(destination[1]);
                    LatLng destLatLng = LatLng(destLat, destLng);
                    String distance = value['distance'];
                    _destinationStr = destinationStr;
                    _destLat = destLat;
                    _destLng = destLng;
                    _destination = destLatLng;






                    // Parse the polyline points
                    String polylineStr = value['polyline_points'];
                    List<String> polylinePoints = polylineStr.split('),');
                    List<LatLng> polylineCoordinates = [];
                    for (int i = 0; i < polylinePoints.length; i++) {
                      String pointStr = polylinePoints[i].replaceAll('LatLng(', '').replaceAll(')', '');
                      List<String> point = pointStr.split(', ');
                      double lat = double.parse(point[0]);
                      double lng = double.parse(point[1]);
                      LatLng latLng = LatLng(lat, lng);
                      polylineCoordinates.add(latLng);
                      _polyLineCoordinates = polylineCoordinates ;
                    }



                    String userID = value['userId'];
                    _userId = userID;

                    double distanceInKm = calculateDistanceInKm(_userLocation, destLatLng);
                    double fare = calculateFare(distanceInKm);
                    fare.round();
                    _fare = fare.toString();

                    // print('The fare is \$${fare.toStringAsFixed(2)}');

                    if (_fare.isNotEmpty) {
                      double num = double.parse(_fare);
                      roundedStr = num.toStringAsFixed(2);
                      String outputStr = "PHP: $roundedStr";
                      formattedStr = outputStr;
                    }







                    // String? destinationName;
                    // _getPlaceName(destLatLng).then((value) {
                    //   setState(() {
                    //     destinationName = value;
                    //   });
                    // }).catchError((error) {
                    //   print('Error: _getPlaceName() returned null.');

                    // });
                    Marker destinationMarker = Marker(
                      markerId: const MarkerId('destination'),
                      position: destLatLng,

                      infoWindow: InfoWindow(
                        title: 'Destination',
                        snippet: 'Payment: ${fare.toStringAsFixed(2)}',
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),

                    );



                    final polyline = Polyline(
                      polylineId: const PolylineId('polyline'),
                      color: Colors.blue,
                      width: 5,
                      points: _polyLineCoordinates,
                    );









                    //Create the marker with the necessary information

                    if(showUserLocation) {
                      Marker marker = Marker(
                        markerId: const MarkerId('user_location'),
                        position: latLng,
                        onTap: () {
                          setState(() {
                            //  showDestMarker = true;
                            double distanceInKm = calculateDistanceInKm(
                                _driverLocation!, destLatLng);
                            driverNearDestination =
                                distanceInKm <= NEAR_DESTINATION_THRESHOLD;


                            _polyline.add(polyline);
                            _markers.add(destinationMarker);
                          });
                        },


                        infoWindow: InfoWindow(
                          title: distance,
                          snippet: 'User ID: $userID',

                        ),

                      );
                      _markers.add(marker);
                    }














                  });

                  // If google map is already created then update camera position with animation
                  if (_googleMapController != null && markers.isNotEmpty) {
                    _googleMapController!.animateCamera(CameraUpdate.newLatLngZoom(
                      _driverLocation!,
                      ZOOM,




                    ));
                  }

                  Set<Marker> allMarkers = Set.from(_markers); // create a new set to hold all markers
                  allMarkers.add(_driverMarker); // add the _driverMarker to the set



                  return GoogleMap(
                    zoomControlsEnabled: false,
                    initialCameraPosition:  CameraPosition(
                      target: _userLocation,
                      zoom: ZOOM,

                    ),
                    // Markers to be pointed
                    markers:  allMarkers,


                    polylines:  _polyline,

                    onMapCreated: (controller) {
                      // Assign the controller value to use it later
                      _googleMapController = controller;







                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          key: const Key('direction_button'),
                          onPressed:()async{
                            // Update the waiting screen text in Realtime Database
                            final DatabaseReference waitingScreenRef = FirebaseDatabase.instance
                                .ref()
                                .child("users")
                                .child(userId)
                                .child("waiting_screen");
                            await waitingScreenRef.set("Driver is coming...");
                          },
                          mini: false,
                          child:  const Icon( Icons.start_rounded),
                        ),
                        SizedBox(height: 10.0),

                        Visibility(
                          visible: isDriverNearDestination(),
                          child: FloatingActionButton(
                            key: const Key('Go_Button'),
                            onPressed: ()  {
                              if (isDriverNearDestination()) {
                                setState(()  {
                                  showUserLocation = false;



                                  _markers.clear();
                                  _polyline.clear();
                                  _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
                                  done = true;

                                  final DatabaseReference waitingScreenRef = FirebaseDatabase.instance
                                      .ref()
                                      .child("users")
                                      .child(userId)
                                      .child("waiting_screen");
                                   waitingScreenRef.set("Done");

                                });
                              }
                            },
                            mini: false,
                            child: const Text('Done'),
                          ),
                        ),


                      ],
                    ),

                  ),

                ],

              ),

            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Align(
            //     alignment: Alignment.topCenter,
            //     child: Container(
            //         width: 200,
            //         height: 50,
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(20),
            //         ),
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: Text(formattedStr, style: TextStyle(fontSize: 18.0),) ,
            //
            //         )
            //
            //
            //     ),
            //   ),
            // ),
          ],
        ),

      ),
    );

  }
}
