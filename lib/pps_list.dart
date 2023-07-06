import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'PPS.dart';
import 'auth/authenticationService.dart';
import 'auth/login_popup.dart';
import 'home.dart';

class PPSList extends StatefulWidget {
  const PPSList({Key? key}) : super(key: key);

  @override
  _PPSListState createState() => _PPSListState();
}

class _PPSListState extends State<PPSList> {
  Completer<GoogleMapController> _controller = Completer();
  Position? currentLocation;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final CollectionReference _reference = FirebaseFirestore.instance.collection('User');
  LatLng? _tappedLocation;
  Set<Marker> _markers = {};
  Marker? _currentLocationMarker;
  Marker? _tappedLocationMarker;
  final CollectionReference _placemarkCollection = FirebaseFirestore.instance.collection('PPS');
  List<PPS> locationList = [];

  void initState() {
    super.initState();
    getCurrentLocation();
    requestLocationPermission();
    //fetchLocationData();
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
              title: const Text('FlooRS: Flood Relief System'),
              foregroundColor: Colors.black,
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {

                    context.read<AuthenticationService>().signOut();
                  }, // Reload data on refresh icon pressed
                ),
              ]),
          body: FutureBuilder<QuerySnapshot>(
            future: _placemarkCollection.get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong.'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                QuerySnapshot querySnapshot = snapshot.data!;
                List<QueryDocumentSnapshot> documents = querySnapshot.docs;
                List<PPS> pps = querySnapshot.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return PPS(
                    pps_id: doc.id,
                    pps_long: data['pps_long'],
                    pps_name: data['pps_name'],
                    pps_status: data['pps_status'],
                    pps_lat: data["pps_lat"],
                    pps_cur_capacity: data["pps_cur_capacity"],
                    pps_capacity: data["pps_capacity"],
                    pps_address: data["pps_address"],
                  );
                }).toList();
                return _getBody(pps);
              } else {
                return const Center(
                  child: Text('No staff'),
                );
              }
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
                        context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
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

  void submit(){
    context.read<AuthenticationService>().signIn(
        email: emailController.text,
        pass: passwordController.text);

    Navigator.of(context).pop();
  }

  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginPopup();
      },
    );
  }

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
/*
    // Remove previous tapped location marker if any
    if (_tappedLocationMarker != null) {
      _markers.remove(_tappedLocationMarker!);
    }

    // Create new tapped location marker
    _tappedLocationMarker = Marker(
      markerId: MarkerId('tappedLocation'),
      position: latLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    _markers.add(_tappedLocationMarker!);
    _showLocationInfoDialog();*/
  }

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
      Placemark placemark = placemarks.first;

      String address = placemark.street ?? '';
      String city = placemark.locality ?? '';
      String state = placemark.administrativeArea ?? '';
      String country = placemark.country ?? '';

      // Create a map of placemark data
      Map<String, dynamic> placemarkData = {
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'latitude': _tappedLocation!.latitude,
        'longitude': _tappedLocation!.longitude,
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
/*
  void fetchLocationData() {
    QuerySnapshot querySnapshot = snapshot.data!;
    FirebaseFirestore.instance
        .collection('PPS')
        .get()
        .then((QuerySnapshot querySnapshot) {
      List<PPS> locations = [];
      querySnapshot.docs.forEach((doc) {
        locations.add(PPS.fromJson(doc.data()));
      });
      setState(() {
        locationList = locations;
      });
    });
  }*/

  Widget _getBody(List<PPS> pps) {
    return pps.isEmpty
        ? const Center(
      child: Text(
        'No PPS',
        textAlign: TextAlign.center,
      ),
    )
        : ListView.builder(
      itemCount: pps.length,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          title: Text(pps[index].pps_name ?? ''),
          subtitle: Text('Address: ${pps[index].pps_address}'),
          leading: Icon(Icons.school_rounded),
          trailing: SizedBox(
            width: 60,
            child: Row(
              children: [
                InkWell(
                  child: const Icon(Icons.delete),
                  onTap: () {
                    _placemarkCollection.doc(pps[index].pps_id).delete();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PPSList(),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}