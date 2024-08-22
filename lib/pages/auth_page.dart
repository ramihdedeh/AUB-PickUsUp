import 'package:aub_pickusup/pages/choose_type.dart';
import 'package:aub_pickusup/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: _authStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            if (user.emailVerified) {
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data!.exists) {
                    return const ChooseUserType();
                  } else {
                    FirebaseAuth.instance.signOut();
                    return const SignInPage();
                  }
                },
              );
            } else {
              FirebaseAuth.instance.signOut();
              return const SignInPage();
            }
          }
          return const SignInPage();
        },
      ),
    );
  }
}
