import 'dart:async';
import 'package:aub_pickusup/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../components/directions_model.dart';
import '../components/directions_repository.dart';
import '../components/global.dart';

class MainScreenRider extends StatefulWidget {
  const MainScreenRider({Key? key}) : super(key: key);

  @override
  State<MainScreenRider> createState() => _MainScreenRiderState();
}

// Main Screen for the Rider user type (the user who is requesting a ride)
class _MainScreenRiderState extends State<MainScreenRider> {
  late GoogleMapController mapController;
  Future<LatLng>? _currentLocation; // Track the current location of the user
  bool _isGoingToAUB =
      true; // Track whether the user is going to AUB or leaving AUB
  final Set<Marker> _markers = {};
  late Directions _info = Directions(
    bounds: LatLngBounds(
      southwest: const LatLng(0, 0),
      northeast: const LatLng(0, 0),
    ), //
    polylinePoints: [],
    totalDistance: '',
    totalDuration: '',
  );
  late Map<String, dynamic> _selectedRideData = {};
  Marker? driverMarker;
  bool _confirmedRide = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser!.reload();
    _currentLocation = getCurrentLocation();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // add AUB marker to the map and set the camera to show the route from the current location to AUB
  void _addAUBMarker() async {
    LatLng? position = await getPositionFromPlace('AUB Main Gate');
    if (position != null) {
      // Create a marker for AUB and add it to the set of markers
      final marker = Marker(
        icon: await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(
            size: Size(256, 256),
          ),
          'assets/logo_icon.png',
        ),
        markerId: const MarkerId('AUB'),
        position: position,
        infoWindow: const InfoWindow(title: 'AUB Main Gate'),
        flat: true,
      );

      setState(() {
        _markers.add(marker);
      });
      // get directions from current location to AUB
      final directions = await DirectionsRepository().getDirections(
        origin: await _currentLocation as LatLng,
        destination: position,
      );
      setState(() {
        _info =
            directions; // update the directions info to show the route on the map and the distance and duration
      });
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_info.bounds, 100),
      ); // set the camera to show the route from the current location to AUB with a padding of 100 pixels
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to retrieve AUB location',
      );
    }
  }

  // Method to cancel the ride
  Future<void> cancelRide() async {
    try {
      // Update the ride status to "cancelled" in Firestore
      String? currentRideId = await getRideId(_selectedRideData['driverId']);
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(currentRideId)
          .update({'rideStatus': 'available'});

      // Perform any other necessary cleanup or UI updates
      setState(() {
        _confirmedRide = false;
        _markers.removeWhere((element) => element.markerId.value == 'driver');
        _info = Directions(
          bounds: LatLngBounds(
            southwest: const LatLng(0, 0),
            northeast: const LatLng(0, 0),
          ),
          polylinePoints: [],
          totalDistance: '',
          totalDuration: '',
        );
      });

      Fluttertoast.showToast(msg: 'Ride cancelled');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Failed to cancel ride');
    }
  }

  void _updateAUBMapMarker() {
    // update the map markers when the user changes the direction (going to AUB or leaving AUB)
    if (_isGoingToAUB) {
      _addAUBMarker();
    } else {
      _markers.removeWhere((marker) => marker.markerId.value == 'AUB');

      setState(() {
        _info = Directions(
          bounds: LatLngBounds(
            southwest: const LatLng(0, 0),
            northeast: const LatLng(0, 0),
          ),
          polylinePoints: [],
          totalDistance: '',
          totalDuration: '',
        );
      });
    }
  }

  void _updateDriverMapMarker(dynamic selectedRideData) {
    // update the map markers when the user changes the direction (going to AUB or leaving AUB)
    if (_isGoingToAUB) {
      _markers.removeWhere((element) => element.markerId.value == 'driver');
      getDriverLocation(selectedRideData);
    } else {
      setState(() {
        _info = Directions(
          bounds: LatLngBounds(
            southwest: const LatLng(0, 0),
            northeast: const LatLng(0, 0),
          ),
          polylinePoints: [],
          totalDistance: '',
          totalDuration: '',
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    // update the map markers when the user changes the direction (going to AUB or leaving AUB)
    super.didChangeDependencies();
    _updateAUBMapMarker();
  }

  void getDriverLocation(selectedRideData) async {
    GeoPoint driverLocation = selectedRideData['driverLocation'];
    double driverLatitude = driverLocation.latitude;
    double driverLongitude = driverLocation.longitude;
    LatLng position = LatLng(driverLatitude, driverLongitude);
    Marker driverMarker = Marker(
      markerId: const MarkerId('driver'),
      position: position,
      flat: false,
      icon: await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          size: Size(20, 20),
        ),
        'assets/logo_icon.png',
      ),
      infoWindow: InfoWindow(title: selectedRideData['driverName']),
      onTap: () {
        Fluttertoast.showToast(
          msg: 'You selected ride with ${selectedRideData['driverName']}',
        );
      },
    );
    setState(() {
      _markers.add(driverMarker); // Add the driver marker to the set of markers
    });

    // get directions from current location to current driver
    final directions = await DirectionsRepository().getDirections(
      origin: await _currentLocation as LatLng,
      destination: position,
    );
    setState(() {
      _info =
          directions; // update the directions info to show the route on the map and the distance and duration
    });
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(_info.bounds, 100),
    ); // set the camera to show the route from the current location
  }

  bool _showRides = false; // Track whether to show the available rides list

  Future<void> _showConfirmationDialog(
      Map<String, dynamic> currentRideData) async {
    bool confirmed = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'CONFIRMATION',
            style: TextStyle(
              color: aubRed,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          content: Text(
              'Are you sure you want to select this ride with ${currentRideData['driverName']}?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: aubRed,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: aubRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.fromLTRB(45, 20, 45, 20),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _confirmedRide = true;
        _showRides = !_showRides;
        _selectedRideData = currentRideData;
      });
      try {
        String? selectedRideId = await getRideId(_selectedRideData['driverId']);
        await FirebaseFirestore.instance
            .collection('rides')
            .doc(selectedRideId)
            .update({'rideStatus': 'confirmed'});
      } on Exception catch (e) {
        Fluttertoast.showToast(msg: '$e');
      }
      _updateDriverMapMarker(_selectedRideData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: _currentLocation,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SafeArea(
            child: Scaffold(
              floatingActionButton: !_confirmedRide
                  ? FadeInTransition(
                      child: FloatingActionButton(
                        heroTag: 's',
                        tooltip: 'Show Available Rides',
                        enableFeedback: true,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            _showRides = !_showRides;
                          });
                        },
                        child: _showRides
                            ? const Icon(Icons.close)
                            : const Icon(
                                Icons.directions_car,
                              ),
                      ),
                    )
                  : null,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              bottomNavigationBar: _showRides
                  ? _buildRidesList(context)
                  : null, // show available rides list when the user taps on the floating action button
              body: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    padding: EdgeInsets.only(
                      top: 150,
                      right: 6,
                      left: 6,
                      bottom: _confirmedRide ? 180 : 6,
                    ),
                    onMapCreated: _onMapCreated,
                    tiltGesturesEnabled: true,
                    buildingsEnabled: true,
                    mapToolbarEnabled: true,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    compassEnabled: true,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: snapshot.data!,
                      zoom: 16.0,
                    ),
                    markers: _markers,
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('aub_polyline'),
                        points: _info.polylinePoints
                            .map((e) => LatLng(e.latitude, e.longitude))
                            .toList(),
                        color: aubRed,
                        width: 6,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                    },
                  ),
                  Positioned(
                    top: 160,
                    child: _info.polylinePoints.isNotEmpty
                        ? FadeInTransition(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: aubRed,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                '${_info.totalDistance}\n${_info.totalDuration}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                  Visibility(
                    visible: _confirmedRide,
                    child: Positioned(
                      bottom: 0,
                      child: ConfirmedRideInfo(
                        selectedRideData: _selectedRideData,
                        onCancelPressed: () {
                          cancelRide();
                          _addAUBMarker();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      padding: const EdgeInsets.only(bottom: 15),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.elliptical(70, 40),
                          bottomRight: Radius.elliptical(70, 40),
                        ),
                        color: aubRed,
                      ),
                      child: FadeInTransition(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  width: 2.0,
                                  color: Colors.white,
                                ),
                              ),
                              child: _confirmedRide
                                  ? const Text(
                                      'CONFIRMED',
                                      style: TextStyle(
                                        color: aubRed,
                                        fontFamily: 'Jost',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )
                                  : DropdownButton<bool>(
                                      underline: Container(
                                        height: 0,
                                      ),
                                      enableFeedback: true,
                                      icon: const Icon(
                                        color: aubRed,
                                        size: 25,
                                        Icons.arrow_drop_down_circle_rounded,
                                      ),
                                      itemHeight: 75,
                                      elevation: 6,
                                      borderRadius: BorderRadius.circular(40),
                                      value: _isGoingToAUB,
                                      onChanged: (newValue) {
                                        if (mounted) {
                                          setState(
                                            () {
                                              _isGoingToAUB = newValue!;
                                              _updateAUBMapMarker();
                                            },
                                          );
                                        }
                                      },
                                      items: [
                                        DropdownMenuItem<bool>(
                                          value: true,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              'Going to AUB',
                                              style: TextStyle(
                                                color: aubRed,
                                                fontFamily: 'Jost',
                                                fontWeight: _isGoingToAUB
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem<bool>(
                                          value: false,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Leaving AUB',
                                              style: TextStyle(
                                                color: aubRed,
                                                fontFamily: 'Jost',
                                                fontWeight: _isGoingToAUB
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 3.0,
                                  color: Colors.white,
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: user!.photoURL != null
                                      ? Image.network(user!.photoURL!)
                                          .image // Use the image from the user's profile picture if it exists
                                      : const AssetImage('assets/logo.png'),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: aubRed.withOpacity(0.8),
                                  highlightColor: Colors.white.withOpacity(0.2),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return SafeArea(
            child: Scaffold(
              backgroundColor: aubRed,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    LoadingAnimationWidget.halfTriangleDot(
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'FETCHING LOCATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        height: 2,
                        fontFamily: 'Jost',
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildRidesList(BuildContext context) {
    dynamic query = FirebaseFirestore.instance
        .collection('rides')
        .where('destination', isEqualTo: 'AUB')
        .where('rideStatus', isEqualTo: 'available');
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LoadingAnimationWidget.halfTriangleDot(
                  color: aubRed,
                  size: 50,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  'FETCHING RIDES',
                  style: TextStyle(
                    color: aubRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          final rides = snapshot.data!.docs;

          return FadeInTransition(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: Colors.white,
              child: ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final ride = rides[index];
                  final rideData = ride.data() as Map<String,
                      dynamic>; // Added cast to Map<String, dynamic>
                  return Container(
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
                    margin: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      color: aubRed,
                    ),
                    child: ListTile(
                      onTap: () {
                        _showConfirmationDialog(rideData);
                      },
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3.0,
                            color: Colors.white,
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: rideData['driverProfilePicture'] !=
                                  null
                              ? Image.network(rideData['driverProfilePicture'])
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
                        rideData['driverName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${rideData['carModel']} - ${rideData['carColor']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$ ${double.parse(rideData['price'])}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          FutureBuilder<double>(
                            future: getDriverDistanceFromUser(
                                rideData, getCurrentLocation()),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  '${snapshot.data!} km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Error',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 14,
                                  ),
                                );
                              } else {
                                return const Text(
                                  'Loading...',
                                  style: TextStyle(
                                    color: Colors.white,
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
                  );
                },
              ),
            ),
          );
        } else {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            child: LoadingAnimationWidget.halfTriangleDot(
              color: aubRed,
              size: 50,
            ),
          );
        }
      },
    );
  }
}
