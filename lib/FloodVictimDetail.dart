import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flood_relief_system/pps_list.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'FloodVictim.dart';
import 'Rescuers.dart';
import 'auth/auth_provider.dart';
import 'auth/authenticationService.dart';
import 'auth/login_popup.dart';
import 'home.dart';

class FloodVictimDetail extends StatefulWidget {
  const FloodVictimDetail({Key? key}) : super(key: key);

  @override
  _FloodVictimDetailState createState() => _FloodVictimDetailState();
}

class _FloodVictimDetailState extends State<FloodVictimDetail> {
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
  LatLng? _userBLocation;
  Marker? _userBMarker;
  FloodVictim fvData = FloodVictim();

  void initState() {
    super.initState();
    getCurrentLocation();
    requestLocationPermission();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    // Stop listening to the location updates when the widget is disposed
    _stopLocationUpdates();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Replace 'userBUID' with the actual UID of user B
    String userBUID = 'userBUID';

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

  void _stopLocationUpdates() {
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
          markerId: MarkerId('userB'),
          position: _userBLocation!,
          infoWindow: InfoWindow(title: 'Your Rescuers Location'),
        );
        _markers.add(_userBMarker!);
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

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('User').doc(userId).get();
    return snapshot;
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
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthenticationService>().signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => HomePage()));
                  }, // Reload data on refresh icon pressed
                ),
              ]),
          body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: getUserDetails(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Display a loading indicator while fetching data
                }
                if (snapshot.hasData && snapshot.data != null) {
                  final userDetails = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // -- Form Fields
                      Form(
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['name']), prefixIcon: Icon(Icons.person)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration:  InputDecoration(
                                  label: Text(userDetails.data()?['email']), prefixIcon: Icon(Icons.email)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['phone']), prefixIcon: Icon(Icons.phone)),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['fv_icno']), prefixIcon: Icon(Icons.credit_card)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['fv_address']), prefixIcon: Icon(Icons.home_sharp)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['createAt']), prefixIcon: Icon(Icons.access_time_outlined)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.none,
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['userType']), prefixIcon: Icon(Icons.manage_accounts_sharp)),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.none,
                              decoration: InputDecoration(
                                  label: Text(userDetails.data()?['user_id']), prefixIcon: Icon(Icons.security_sharp)),
                            ),

                            // -- Form Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () { UpdateProfileScreen();},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    side: BorderSide.none,
                                    shape: const StadiumBorder()),
                                child: const Text('Edit Profile', style: TextStyle(color: Colors.blueAccent)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text('Name: ${userDetails.data()?['name']}'),
                      Text('Email: ${userDetails.data()?['email']}'),
                      Text('Phone No: ${userDetails.data()?['phone']}'),
                      Text('IC No: ${userDetails.data()?['fv_icno']}'),
                      Text('Address: ${userDetails.data()?['fv_address']}'),
                      Text('Create At: ${userDetails.data()?['createAt']}'),
                      Text('User Type: ${userDetails.data()?['userType']}'),
                    ],
                  );
                }

                // Handle the case where the user details couldn't be fetched
                return Text('Failed to fetch user details.');
              },
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
                    Icons.account_circle,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => FloodVictimDetail()));
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
    if (user != null) {
      // User is logged in, proceed with sending location data
      // Add location data to Firestore
      CollectionReference locationCollection =
      FirebaseFirestore.instance.collection('user_locations');
      locationCollection.add({
        'userId': user.uid,
        'latitude': currentLocation!.latitude,
        'longitude': currentLocation!.longitude,
        'timestamp': DateTime.now(),
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
    } else {
      // User is not logged in, show a prompt to log in
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Not Logged In'),
            content: Text('Please log in to send help.'),
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

  void UpdateProfileScreen(){

  }

}
