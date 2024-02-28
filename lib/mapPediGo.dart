

import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_routes/google_maps_routes.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


const project = "pedigo-346f0";
const databaseUrl = "https://console.firebase.google.com/u/0/project/pedigo-346f0/database/pedigo-346f0-default-rtdb/data/~2F";
const appId = "";
const apiKey = "AIzaSyAJMkCocyaEQydVY1NLQ1CtsuQjHloM9cM";
const messagingSenderId = "668048187396";
const storageBucket = "pedigo-346f0.appspot.com";

class CustomerMap extends StatefulWidget {
  const CustomerMap({Key? key}) : super(key: key);

  @override
  State<CustomerMap> createState() => _CustomerMapState();
}

class _CustomerMapState extends State<CustomerMap> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  LatLng? _destinationLocation;
  List<LatLng> polylineCoordinates = [];
  final Set<Polyline> _polylines = {};
  String googleAPIKey = "AIzaSyASv9Vf-oeHsnYven-lxCwnQeAD9PiTDWQ";
  CameraPosition? _cameraPosition;
  String location = "What's your destination?";
  final DistanceCalculator _distanceCalculator = DistanceCalculator();
  String totalDistance = "No Distance!";
  String _travelTime = "";

  FirebaseAuth _auth = FirebaseAuth.instance;



  final FirebaseOptions firebaseOptions = const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      databaseURL: databaseUrl,
      projectId: project,
      messagingSenderId: messagingSenderId,
      storageBucket: storageBucket
  );








  void initState() {
    super.initState();
    _getLocation();
    _findShortestPath();

  }

  late FirebaseApp app;


  Future<void> initializeFirebase() async {
    app = await Firebase.initializeApp(options: firebaseOptions);
  }

  Future<String?> _sendMapData(String userLocation, String destination, String polylinePoints) async {
    User? user = _auth.currentUser;

    // Get a reference to the root of your Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.reference().child('commuters');

    // Generate a unique key for the commuter
    String? commuterKey = ref.push().key;

    // Define the data that you want to send to the database
    Map<String, dynamic> data = {
      'user_location': userLocation,
      'destination': destination,
      'polyline_points': polylinePoints,
      'distance': totalDistance.toString(),
      'userId' : user!.uid,
    };

    // Send the data to the database under the commuter key
    await ref.child(commuterKey!).set(data);

    // Return the key that was used to send the data
    return commuterKey;
  }



  Future<void> _getLocation() async {
    LocationPermission permission;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapTap(LatLng point) async{

    setState((){
      _destinationLocation = point;
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),


      ));
      polylineCoordinates.clear();
      _polylines.removeWhere((polyline) => polyline.polylineId.value == "route");


    });

  }




  Future<void> _findShortestPath() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(_userLocation!.latitude, _userLocation!.longitude),
      PointLatLng(_destinationLocation!.latitude, _destinationLocation!.longitude),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear(); // Clear the old points before adding new ones
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      //String travelTime = await _getTravelTime();
      setState(() {
       // _travelTime = travelTime;
        _polylines.add(Polyline(
          color: Colors.blue,
          width: 6,
          points: polylineCoordinates,
          polylineId: const PolylineId("route"),
        ));
        totalDistance = _distanceCalculator.calculateRouteDistance(polylineCoordinates, decimals: 1);

      });
    }
  }








  // Future<String> _getTravelTime() async {
  //   final String url =
  //       'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins='
  //       '$_userLocation&destinations=$_destinationLocation&key=$googleAPIKey';
  //
  //   final response = await http.get(Uri.parse(url));
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final travelTime = data['rows'][0]['elements'][0]['duration']['text'];
  //     return travelTime;
  //   } else {
  //     throw Exception('Failed to load travel time');
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          _userLocation == null
              ? const Center(
            child: CircularProgressIndicator(),

          )

              : GoogleMap(
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _userLocation!,
              zoom: 13,

            ),
            polylines: _polylines,

            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onTap: _onMapTap,
            markers: _markers,
            mapType: MapType.normal,
            onMapCreated: (controller) { //method called when map is created
              setState(() {
                _mapController = controller;
              });
            },
            onCameraMove: (CameraPosition cameraPosition) {
              _cameraPosition = cameraPosition;
            },
            onCameraIdle: () async {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                  _cameraPosition!.target.latitude, _cameraPosition!.target.longitude);
              setState(() {
                location = "${placemarks.first.administrativeArea}, ${placemarks.first.street}";
              });
            },
        ),
            Positioned(
              top: 10,
              child: InkWell(
                onTap: ()async {
                  var place = await PlacesAutocomplete.show(
                      context: context,
                      apiKey: googleAPIKey,
                      mode: Mode.overlay,
                      types: [],
                      strictbounds: false,
                      components: [Component(Component.country, 'ph')],
                      onError: (err){
                        print(err);
                      }
                  );
                  if(place != null){
                      setState(() {
                      location = place.description.toString();
                      });
                      //form google_maps_webservice package
                      final plist = GoogleMapsPlaces(apiKey:googleAPIKey,
                      apiHeaders: await const GoogleApiHeaders().getHeaders(),
                      //from google_api_headers package
                      );
                      String placeid = place.placeId ?? "0";
                      final detail = await plist.getDetailsByPlaceId(placeid);
                      final geometry = detail.result.geometry!;
                      final lat = geometry.location.lat;
                      final lang = geometry.location.lng;
                      var newlatlang = LatLng(lat, lang);

                      //move map camera to selected place with animation
                      _mapController?.animateCamera(CameraUpdate.newCameraPosition
                        (CameraPosition(target: newlatlang, zoom: 17)));
                      }
                },
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: ClipRRect(
                   borderRadius: BorderRadius.circular(20),
                     child: Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width  -40,
                            child: ListTile(

                              title:Text(location, style: TextStyle(fontSize: 18),),
                              trailing: Icon(Icons.search),
                              dense: true,
                            )

                        ),
                      ),

                  ),
                ),





              ),


          ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 200,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(totalDistance, style: TextStyle(fontSize: 18.0),) ,

                          )


                        ),
                      ),
                    ),



        ],
      ),




      floatingActionButton: _destinationLocation == null
          ? null

      :Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                key: const Key('direction_button'),
                onPressed: _findShortestPath,
                mini: false,
                child:  const Icon( Icons.route_sharp),
              ),
              SizedBox(height: 10.0),
              FloatingActionButton(
                key: const Key('Go_Button'),
                onPressed: ()async{
                 var user = _userLocation.toString();
                 var destination = _destinationLocation.toString();
                 var polypoints =  polylineCoordinates.map((point) => point.toString()).toList().join(",");

                 String? result = await _sendMapData(user, destination, polypoints);

                 Navigator.pushNamed(context, 'wait');
                },
                mini: false,
                child: const Icon(Icons.start),
              ),
            ],
          ),
        ),
      )




    );
  }
}