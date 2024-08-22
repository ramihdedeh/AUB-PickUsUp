import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  ImageProvider logo = const AssetImage('assets/logo.png');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: aubRed,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
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
          'PROFILE',
          style: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 10.0,
            color: Colors.white,
            fontFamily: 'JosefinSans',
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingAnimationWidget.halfTriangleDot(
                color: Colors.white,
                size: 60,
              );
            } else if (snapshot.hasError) {
              return const Text('Failed to load user data');
            } else if (snapshot.hasData) {
              final userDataSnapshot = snapshot.data!.data() as Map?;
              final fullName =
                  userDataSnapshot?['fullname'] ?? 'Full Name Not Available';
              final userBio = userDataSnapshot?['bio'] ?? 'No bio yet';
              final userEmail =
                  userDataSnapshot?['email'] ?? 'Email Not Available';
              final userRole =
                  userDataSnapshot?['role'] ?? 'Role Not Available';
              final currentPhotoURL = userDataSnapshot?['photoUrl'] ?? '';

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: aubRed,
                        width: 4.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      foregroundImage:
                          currentPhotoURL != null && currentPhotoURL != ''
                              ? NetworkImage(currentPhotoURL)
                              : logo,
                      radius: 70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$fullName ',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: userRole == 'driver' ? 'Driver' : 'Rider',
                          style: TextStyle(
                            letterSpacing: 1,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                            color: userRole == 'driver' ? aubBlue : aubRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$userEmail',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      userBio,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.07),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aubRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(300, 60),
                    ),
                    onPressed: () async {
                      // Handle edit profile button action
                      await Navigator.pushReplacementNamed(
                          context, '/editprofile');
                    },
                    child: const Text(
                      'EDIT PROFILE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: aubRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(300, 60),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Text(
                      'SIGN OUT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fixedSize: const Size(300, 60),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'GO BACK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Text('Failed to load user data');
            }
          },
        ),
      ),
    );
  }
}
