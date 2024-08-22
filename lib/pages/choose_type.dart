// ignore_for_file: use_build_context_synchronously

import 'package:aub_pickusup/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'main_screen_driver.dart';
import 'main_screen_rider.dart';

Future<void> setUserRole(String role) async {
  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;

  try {
    if (user != null) {
      // Get a reference to the user's document in Firestore
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Update the user's role in Firestore
      await userDocRef.update({'role': role});

      Fluttertoast.showToast(msg: 'User role updated successfully');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Failed to update user role: $e');
  }
}

class ChooseUserType extends StatelessWidget {
  const ChooseUserType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        elevation: 0,
        centerTitle: true,
        backgroundColor: aubRed,
        toolbarHeight: 150,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(70, 40),
            bottomRight: Radius.elliptical(70, 40),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: aubRed,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'WHAT ARE\nYOU?',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 35.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 10.0,
              color: Colors.white,
              fontFamily: 'JosefinSans'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkResponse(
              highlightColor: aubRed,
              highlightShape: BoxShape.rectangle,
              onTap: () async {
                await setUserRole('rider');
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const MainScreenRider(),
                    transitionsBuilder: (_, animation, __, child) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 310.0,
                    height: 240.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        25.0,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/choose-user.gif'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Hero(
                      tag: 'rider',
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25.0),
                            bottomRight: Radius.circular(25.0),
                          ),
                          color: aubRed,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                        ),
                        child: const Text(
                          'Rider',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 45.0),
            InkResponse(
              highlightColor: aubBlue,
              highlightShape: BoxShape.rectangle,
              onTap: () async {
                await setUserRole("driver");
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const MainScreenDriver(),
                    transitionsBuilder: (_, animation, __, child) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 310.0,
                    height: 240.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      image: const DecorationImage(
                        image: AssetImage('assets/choose-driver.gif'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Hero(
                      tag: 'driver',
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(25.0),
                              bottomRight: Radius.circular(25.0)),
                          color: aubBlue,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                        ),
                        child: const Text(
                          'Driver',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
