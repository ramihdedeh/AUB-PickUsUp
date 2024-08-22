import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import '../main.dart';

Future<void> callNumber(String phoneNumber) async {
  //set the number here
  await FlutterPhoneDirectCaller.callNumber(phoneNumber);
}

Future<LatLng?> getPositionFromPlace(String placeName) async {
  try {
    List<Location> locations = await locationFromAddress(placeName);
    if (locations.isNotEmpty) {
      return LatLng(locations.first.latitude, locations.first.longitude);
    } else {
      return null;
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    return null;
  }
}

Future<String?> getRideId(String selectedDriverId) async {
  CollectionReference rides = FirebaseFirestore.instance.collection('rides');

  Query query = rides.where('driverId', isEqualTo: selectedDriverId);

  QuerySnapshot querySnapshot = await query.get();

  if (querySnapshot.docs.isEmpty) {
    return null;
  }
  return querySnapshot.docs[0].id;
}

Future<double> getDriverDistanceFromUser(
    Map<String, dynamic> rideData, Future<LatLng> currentLocationFuture) async {
  GeoPoint driverLocation = rideData['driverLocation'];
  double driverLatitude = driverLocation.latitude;
  double driverLongitude = driverLocation.longitude;

  LatLng currentLocation =
      await currentLocationFuture; // Await the future to get the actual LatLng object

  // Calculate the distance between user and driver using the Haversine formula
  double distanceInMeters = Geolocator.distanceBetween(
    currentLocation.latitude,
    currentLocation.longitude,
    driverLatitude,
    driverLongitude,
  );

  // Convert the distance to kilometers
  double distanceInKilometers = distanceInMeters / 1000;

  // return distance with 2 decimal places
  return double.parse(distanceInKilometers.toStringAsFixed(2));
}

Future<LatLng> getCurrentLocation() async {
  // ask for location permission and get the current location of the user
  final PermissionStatus permission = await Permission.locationWhenInUse.status;
  switch (permission) {
    case PermissionStatus.granted:
      // Permission granted, continue with location retrieval
      break;
    case PermissionStatus.denied:
      // Permission denied, show permission denied dialog
      Fluttertoast.showToast(msg: 'Permission Denied');
      await Permission.locationWhenInUse.request();
      throw Exception('Location permission denied');
    case PermissionStatus.permanentlyDenied:
      // Permission permanently denied, show permission denied dialog and open app settings
      Fluttertoast.showToast(msg: 'Permission permanently denied');
      openAppSettings();
      throw Exception('Location permission permanently denied');
    case PermissionStatus.restricted:
      // Permission restricted, show permission restricted dialog
      Fluttertoast.showToast(msg: 'Permission Restricted');
      openAppSettings();
      throw Exception('Location permission restricted');
    case PermissionStatus.limited:
      Fluttertoast.showToast(msg: 'Permission limited');
      openAppSettings();
      throw Exception('Location permission limited');
  }

  Position? position;
  try {
    position = await Geolocator.getCurrentPosition();
  } on LocationServiceDisabledException {
    Fluttertoast.showToast(msg: 'Location Service Disabled');
    throw Exception('Location service disabled');
  } catch (e) {
    Fluttertoast.showToast(msg: 'Generic Location Error $e');
    throw Exception('Unknown location error');
  }

  return LatLng(position.latitude, position.longitude);
}

class ConfirmedRideInfo extends StatelessWidget {
  final Map<String, dynamic> selectedRideData;
  final VoidCallback onCancelPressed;

  const ConfirmedRideInfo(
      {Key? key, required this.selectedRideData, required this.onCancelPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInTransition(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.22,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.elliptical(70, 40),
            topRight: Radius.elliptical(70, 40),
          ),
          color: Colors.white,
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
              leading: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3.0,
                    color: aubRed,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: aubRed,
                  backgroundImage: selectedRideData['driverProfilePicture'] !=
                          null
                      ? Image.network(selectedRideData['driverProfilePicture'])
                          .image
                      : const AssetImage('assets/logo.png'),
                  radius: 25,
                  onBackgroundImageError: (exception, stackTrace) {
                    Fluttertoast.showToast(
                      msg: 'Error loading profile picture: $exception',
                    );
                  },
                ),
              ),
              title: Text(
                selectedRideData['driverName'],
                style: const TextStyle(
                  color: aubRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${selectedRideData['carModel']} - ${selectedRideData['carColor']}',
                style: const TextStyle(
                  color: aubRed,
                  fontWeight: FontWeight.w300,
                  fontSize: 14,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$ ${double.parse(selectedRideData['price'])}',
                    style: const TextStyle(
                      color: aubRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  FutureBuilder<double>(
                    future: getDriverDistanceFromUser(
                        selectedRideData, getCurrentLocation()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          '${snapshot.data!} km',
                          style: const TextStyle(
                            color: aubRed,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          'Error',
                          style: TextStyle(
                            color: aubRed,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        );
                      } else {
                        return const Text(
                          'Loading...',
                          style: TextStyle(
                            color: aubRed,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement cancel button functionality
                    onCancelPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aubRed,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Implement call button functionality
                    callNumber(selectedRideData['phoneNumber']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: aubRed,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 37,
                      vertical: 13,
                    ),
                  ),
                  child: const Icon(Icons.call),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FadeInTransition extends StatefulWidget {
  final Widget child;

  const FadeInTransition({super.key, required this.child});

  @override
  State<FadeInTransition> createState() => _FadeInTransitionState();
}

class _FadeInTransitionState extends State<FadeInTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
