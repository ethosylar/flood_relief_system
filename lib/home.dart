import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_relief_system/FloodVictimDetail.dart';
import 'package:flood_relief_system/pps_list.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'auth/auth_provider.dart';
import 'auth/authenticationService.dart';
import 'auth/login_popup.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();
  //static final Position position =
  //final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  Position? currentLocation;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('User');
  LatLng? _tappedLocation;
  Set<Marker> _markers = {};
  Marker? _currentLocationMarker;
  Marker? _tappedLocationMarker;
  final CollectionReference _placemarkCollection =
      FirebaseFirestore.instance.collection('PPS');
  StreamSubscription<DocumentSnapshot>? _locationSubscription;
  LatLng? _userALocation;
  LatLng? _userBLocation;
  Marker? _userBMarker;
  StreamSubscription<DocumentSnapshot>? _userALocationSubscription;
  StreamSubscription<QuerySnapshot>? _userBLocationSubscription;

  void initState() {
    super.initState();
    getCurrentLocation();
    requestLocationPermission();
    //_startLocationUpdates();
    _startUserALocationUpdates();
    _startUserBLocationUpdates();
  }

  @override
  void dispose() {
    // Stop listening to the location updates when the widget is disposed
    _stopLocationUpdates();
    super.dispose();
  }

  void _startLocationUpdates(String userId) {
    String userBUID = userId;

    _locationSubscription = FirebaseFirestore.instance
        .collection('user_locations')
        .doc(userBUID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        // Retrieve the live location data of user B from the snapshot
        double latitude = snapshot.data()?['latitude'];
        double longitude = snapshot.data()?['longitude'];

        if (latitude != null && longitude != null) {
          // Update the user B location
          setState(() {
            _userBLocation = LatLng(latitude, longitude);
          });

          // Update the marker for user B's location
          _updateUserBMarker();
        }
      }
    });
  }

  void _startUserBLocationUpdates() {
    _userBLocationSubscription = FirebaseFirestore.instance
        .collection('help_rescuers')
        .snapshots()
        .listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        // Retrieve the live location data of user B from the query snapshot
        double latitude = change.doc.data()!['latitude'];
        double longitude = change.doc.data()!['longitude'];

        if (latitude != null && longitude != null) {
          // Update the user B location
          setState(() {
            _userBLocation = LatLng(latitude, longitude);
          });

          // Update the markers on the map
          _updateMarkers();
        }
      });
    });
  }

  void _stopLocationUpdates() {
    _userALocationSubscription?.cancel();
    _userBLocationSubscription?.cancel();
    _userALocation = null;
    _userBLocation = null;
    _markers.clear();
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();

      if (_userALocation != null) {
        // Add a marker for User A's location
        _markers.add(
          Marker(
            markerId: MarkerId('userA'),
            position: _userALocation!,
            infoWindow: InfoWindow(title: 'User A Location'),
          ),
        );
      }

      if (_userBLocation != null) {
        // Add a marker for User B's location
        _markers.add(
          Marker(
            markerId: MarkerId('userB'),
            position: _userBLocation!,
            infoWindow: InfoWindow(title: 'User B Location'),
          ),
        );
      }
    });
  }

  void _stopLocationUpdate() {
    _locationSubscription?.cancel();
    _userBLocation = null;
    _userBMarker = null;
  }

  void _updateUserBMarker() {
    setState(() {
      if (_userBMarker != null) {
        // Remove the previous marker for user B's location
        _markers.remove(_userBMarker!);
      }

      if (_userBLocation != null) {
        // Add a new marker for user B's location
        _userBMarker = Marker(
          markerId: MarkerId('Rescuer'),
          position: _userBLocation!,
          infoWindow: InfoWindow(title: 'Your Rescuers Location'),
        );
        _markers.add(_userBMarker!);
      }
    });
  }

  void _startUserALocationUpdates() {
    // Replace 'userAUID' with the actual UID of user A
    String userAUID = 'userAUID';

    _userALocationSubscription = FirebaseFirestore.instance
        .collection('help_fv')
        .doc(userAUID)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        // Retrieve the live location data of user A from the snapshot
        double latitude = snapshot.data()?['latitude'];
        double longitude = snapshot.data()?['longitude'];

        if (latitude != null && longitude != null) {
          // Update the user A location
          setState(() {
            _userALocation = LatLng(latitude, longitude);
          });

          // Update the markers on the map
          _updateMarkers();
        }
      }
    });
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

  Future<void> _findClosestRescuerLocation(String userId) async {
    // Retrieve User A's location
    double userALatitude = currentLocation?.latitude ?? 0.0;
    double userALongitude = currentLocation?.longitude ?? 0.0;

    // Retrieve the rescuers' locations from the "help_rescuers" collection
    QuerySnapshot rescuersSnapshot =
    await FirebaseFirestore.instance.collection('help_rescuers').get();

    // Filter the rescuers based on their online status
    List<QueryDocumentSnapshot> onlineRescuers = rescuersSnapshot.docs
        .where((rescuerDoc) => rescuerDoc['status'] == "ONLINE")
        .toList();

    if (onlineRescuers.isEmpty) {
      // No online rescuers found
      return;
    }

    // Calculate the distances between User A and each rescuer's location
    List<Map<String, dynamic>> distances = rescuersSnapshot.docs
        .map((rescuerDoc) {
      double rescuerLatitude = rescuerDoc['location_res_lat'];
      double rescuerLongitude = rescuerDoc['location_res_long'];
      double distance = Geolocator.distanceBetween(
        userALatitude,
        userALongitude,
        rescuerLatitude,
        rescuerLongitude,
      );
      return {
        'rescuerId': rescuerDoc.id,
        'distance': distance,
      };
    })
        .toList();

    // Sort the distances in ascending order
    distances.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // Retrieve the ID of the closest rescuer
    String closestRescuerId = distances.isNotEmpty ? distances.first['rescuerId'] : '';

    if (closestRescuerId.isNotEmpty) {
      // Retrieve the closest rescuer's location from the "help_rescuers" collection
      DocumentSnapshot closestRescuerSnapshot = await FirebaseFirestore.instance
          .collection('help_rescuers')
          .doc(closestRescuerId)
          .get();

      if (closestRescuerSnapshot.exists) {
        double closestRescuerLatitude = closestRescuerSnapshot['latitude'];
        double closestRescuerLongitude = closestRescuerSnapshot['longitude'];

        // Update User B's location in the "help_livelocation" collection
        await FirebaseFirestore.instance
            .collection('help_livelocation')
            .doc(userId) // Replace with the actual UID of user B
            .set({
          'latitude': closestRescuerLatitude,
          'longitude': closestRescuerLongitude,
        });
      }
    }
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userId;
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
          title: const Text('FlooRS: Flood Relief System'),
          foregroundColor: Colors.black,
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: Icon(Icons.location_off_sharp),
              onPressed: () {
                _stopLocationUpdates();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()));
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
          if (_userBMarker != null) _userBMarker!,
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
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()));
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
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => PPSList()));
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const FloodVictimDetail()));
              },
            ),
          ],
        ),
      ),
      //implement the floating button
      floatingActionButton: FloatingActionButton(
          onPressed: _sendHelp,
          backgroundColor: Colors.black38,
          child: const Icon(Icons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    ));
  }

  //Camera pans to the current location
  Future<void> _sendHelp() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    //final authProvider = Provider.of<AuthProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? uid = user?.uid;
    authProvider.login(uid!);
    if (authProvider.isLoggedIn) {
      if (user != null) {
        // User is logged in, proceed with sending location data
        // Add location data to Firestore
        CollectionReference locationCollection =
            FirebaseFirestore.instance.collection('help_fv');
        locationCollection.add({
          'userId': user.uid,
          'latitude': currentLocation!.latitude,
          'longitude': currentLocation!.longitude,
          'timestamp': DateTime.now(),
          'status': 'ACTIVE',
          'helpdetails': 'Im Trapped'
        });

        // Animate the camera to the current location
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(
            currentLocation!.latitude,
            currentLocation!.longitude,
          ),
          tilt: 59.440717697143555,
          zoom: 19.151926040649414,
        )));
        setState(() {
          _currentLocationMarker = Marker(
            markerId: MarkerId('currentLocation'),
            position: LatLng(
              currentLocation!.latitude,
              currentLocation!.longitude,
            ),
            infoWindow: InfoWindow(title: 'You Are Here!'),
          );
          _markers.add(_currentLocationMarker!);
        });
        // Start the timer to periodically find the closest rescuer location
        Timer.periodic(Duration(seconds: 5), (_) {
          _findClosestRescuerLocation(user.uid);
        });
      } else {
        // User is not logged in, navigate to the login page
        Navigator.pop(context);
      }
    } else {
      // User is not logged in, navigate to the login page
      Navigator.pop(context);
    }
  }

  //Signin Popup Submit Exit Navigator
  void submit() {
    context
        .read<AuthenticationService>()
        .signIn(email: emailController.text, pass: passwordController.text);

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
  void _onMapTapped(LatLng latLng) async {
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
