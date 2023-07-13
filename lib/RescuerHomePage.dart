import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flood_relief_system/home.dart';
import 'package:flood_relief_system/pps_list.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'auth/authenticationService.dart';
import 'auth/login_popup.dart';

class RescuerPage extends StatefulWidget {
  const RescuerPage({Key? key}) : super(key: key);

  @override
  _RescuerPageState createState() => _RescuerPageState();
}

class _RescuerPageState extends State<RescuerPage> {
  Completer<GoogleMapController> _controller = Completer();
  //static final Position position =
  //final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  Position? currentLocation;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final CollectionReference _reference = FirebaseFirestore.instance.collection('User');
  LatLng? _tappedLocation;
  Set<Marker> _markers = {};
  Marker? _currentLocationMarker;
  Marker? _tappedLocationMarker;
  final CollectionReference _placemarkCollection = FirebaseFirestore.instance.collection('PPS');

  void initState() {
    super.initState();
    getCurrentLocation();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    final permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      // Permission granted, proceed with location access
      getCurrentLocation();
    } else if (permissionStatus.isDenied) {
      // Permission denied
      // Handle the denied scenario
      return Future.error(
          'Location permissions are denied, we cannot request permissions.');
    } else if (permissionStatus.isPermanentlyDenied) {
      // Permission permanently denied
      // Handle the permanently denied scenario
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  //Get Current Location from device
  Future<void> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = position;
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
              title: const Text('FlooRS: Flood Relief System Rescuer Page'),
              foregroundColor: Colors.black,
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthenticationService>().signOut();
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
                  }, // Reload data on refresh icon pressed
                ),
              ]),
          body: GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
              target: LatLng(2.2280622, 102.4554915),
              zoom: 15,
            ),
            markers: {
              if (_currentLocationMarker != null) _currentLocationMarker!,
              if (_tappedLocationMarker != null) _tappedLocationMarker!,
              if (currentLocation != null)
                Marker(
                  markerId: MarkerId('currentLocation'),
                  position: LatLng(
                    currentLocation!.latitude,
                    currentLocation!.longitude,
                  ),
                  infoWindow: InfoWindow(title: 'You Are Here!'),
                ),
            },

            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _onMapTapped,
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.blue,
            // this creates a notch in the center of the bottom bar
            shape: const CircularNotchedRectangle(),
            notchMargin: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (BuildContext context) => RescuerPage()));
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.login_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    _showLoginPopup(context);
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.account_circle,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (BuildContext context) => PPSList()));
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          //implement the floating button
          floatingActionButton: FloatingActionButton(
              onPressed: _goToUitm,
              backgroundColor: Colors.black38,
              child: const Icon(Icons.add)),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ));
  }
  //Camera pans to the current location
  Future<void> _goToUitm() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414)));
  }
  //Signin Popup Submit Exit Navigator
  void submit(){
    context.read<AuthenticationService>().signIn(
        email: emailController.text,
        pass: passwordController.text);

    Navigator.of(context).pop();
  }
  //Signin Popup Dialog Box
  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginPopup();
      },
    );
  }

  //Shows the location of the PPS on tapping the map
  void _onMapTapped(LatLng latLng) async{
    setState(() {
      _tappedLocation = latLng;
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String address = placemark.street ?? '';
      String city = placemark.locality ?? '';
      String state = placemark.administrativeArea ?? '';
      String country = placemark.country ?? '';
      String postalCode = placemark.postalCode ?? '';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Tapped Location'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Address: $address'),
                Text('City: $city'),
                Text('State: $state'),
                Text('Country: $country'),
                Text('Postal Code: $postalCode'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _uploadLocationToFirestore();
                },
                child: Text('Add PPS Location'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  //Add PPS Location when tapped on the map
  void _uploadLocationToFirestore() async {
    if (_tappedLocation == null) {
      // No location is selected
      return;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _tappedLocation!.latitude,
      _tappedLocation!.longitude,
    );

    if (placemarks.isNotEmpty) {
      final coll = _placemarkCollection.doc();
      Placemark placemark = placemarks.first;
      String address = placemark.street ?? '';
      String city = placemark.locality ?? '';
      String state = placemark.administrativeArea ?? '';
      String country = placemark.country ?? '';
      String pps_status = 'OPEN';
      int pps_capacity = 100;
      int pps_cur_capacity = 1;
      // Create a map of placemark data
      Map<String, dynamic> placemarkData = {
        'pps_address': address,
        'pps_id': coll.id,
        'pps_name': address,
        'pps_status': pps_status,
        'pps_lat': _tappedLocation!.latitude,
        'pps_long': _tappedLocation!.longitude,
        'pps_capacity': pps_capacity,
        'pps_cur_capacity': pps_cur_capacity,
      };

      // Upload placemark data to Firestore
      await _placemarkCollection.add(placemarkData);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location Added'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Address: $address'),
                Text('City: $city'),
                Text('State: $state'),
                Text('Country: $country'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

}