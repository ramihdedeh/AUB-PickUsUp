// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:aub_pickusup/components/my_textfield.dart';
import 'package:aub_pickusup/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late UserCredential credentials;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullnameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyTextFormField passwordTextField = MyTextFormField(
      formPadding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
      inputType: TextInputType.text,
      obscureText: true,
      specIcon: Icons.password_rounded,
      controller1: passwordController,
      labelText: 'Password',
      validatorCustom: (value) {
        if (value!.isEmpty) {
          return 'Please enter your Password';
        }
        if (value.toString().trim().length < 7) {
          return 'Password must be at least 7 characters';
        }
        return null;
      },
    );

    MyTextFormField emailTextField = MyTextFormField(
      formPadding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
      inputType: TextInputType.emailAddress,
      obscureText: false,
      specIcon: Icons.email_rounded,
      controller1: emailController,
      labelText: 'Email',
      validatorCustom: (value) {
        if (value!.isEmpty) {
          return 'Please enter your Email';
        } else if (!value.toString().trim().endsWith('@mail.aub.edu')) {
          return 'Email must end with @mail.aub.edu';
        }
        return null;
      },
    );

    MyTextFormField fullnameTextField = MyTextFormField(
      formPadding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
      inputType: TextInputType.name,
      obscureText: false,
      specIcon: Icons.person_2_rounded,
      controller1: fullnameController,
      labelText: 'Full Name',
      validatorCustom: (value) {
        if (value.toString().isEmpty) {
          return 'Please enter your Name';
        } else if (value.toString().length < 5) {
          return 'Name must be more than 5 characters';
        } else if (!value.toString().trim().contains(' ')) {
          return 'Please write your Full name';
        }
        return null;
      },
    );

    MyTextFormField phoneTextField = MyTextFormField(
      formPadding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
      inputType: TextInputType.phone,
      obscureText: false,
      specIcon: Icons.phone_rounded,
      controller1: phoneController,
      labelText: 'Phone Number',
      validatorCustom: (value) {
        if (value!.isEmpty) {
          return 'Please enter your Phone Number';
        }
        if (value.toString().trim().replaceAll(' ', '').length != 8) {
          return 'Please enter your Lebanese phone number';
        }
        return null;
      },
    );

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
          'REGISTER',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 10.0,
              color: Colors.white,
              fontFamily: 'JosefinSans'),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              150,
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0.0, 0.0, 30.0),
                ),
                fullnameTextField,
                const SizedBox(
                  height: 15,
                ),
                phoneTextField,
                const SizedBox(
                  height: 15,
                ),
                emailTextField,
                const SizedBox(
                  height: 15,
                ),
                passwordTextField,
                const SizedBox(
                  height: 15,
                ),
                confirmRegisterButton(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'already have an account?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          letterSpacing: 1,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/signin', (route) => false);
                        },
                        child: const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: aubBlue,
                            fontSize: 18,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  MaterialButton confirmRegisterButton(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (_formkey.currentState!.validate()) {
          // showLoadingDialog();
          registerNewUser(
            email: emailController.text,
            password: passwordController.text,
            fullname: fullnameController.text,
            phone: phoneController.text,
            addUserDetails: addUserDetails,
            navigator: Navigator.of(context),
          );
        }
      },
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
        side: BorderSide(
          width: 0,
          color: Colors.white,
        ),
      ),
      highlightColor: Colors.black,
      elevation: 3,
      padding: const EdgeInsets.symmetric(horizontal: 43, vertical: 15),
      child: const Text(
        'CONFIRM',
        style: TextStyle(
            color: aubRed,
            fontSize: 18,
            letterSpacing: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> addUserDetails(
    String fullname,
    String email,
    String phone,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        currentUser.updateDisplayName(fullname.trim());
        final userUid = currentUser.uid;
        await userCollectRef.doc(userUid).set({
          'fullname': fullname.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'role': 'N/A',
          'bio': 'N/A',
          'photoUrl': 'N/A',
        });
      } else {
        throw Exception('Current user not found');
      }
    } catch (e) {
      throw Exception('Failed to add user details: $e');
    }
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> registerNewUser({
    required String email,
    required String password,
    required String fullname,
    required String phone,
    required Future<void> Function(String fullname, String email, String phone)
        addUserDetails,
    required NavigatorState navigator,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await firebaseUser.sendEmailVerification();
        // Show pop-up with loading widget
        await showDialog(
          context: navigator.context,
          barrierColor: aubRed,
          barrierDismissible: false,
          builder: (_) => const VerifyEmailDialog(),
        );

        // Add user details to Firestore
        await addUserDetails(fullname, email, phone);

        Fluttertoast.showToast(msg: 'Account created successfully');

        // Wait for Firestore operation to complete before navigating to home screen
        await Navigator.of(navigator.context)
            .pushNamedAndRemoveUntil('/chooserole', (route) => false);
      } else {
        Fluttertoast.showToast(msg: 'New user has not been created');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
      rethrow;
    } finally {
      // Dismiss loading widget
      Navigator.of(navigator.context, rootNavigator: true).pop();

      // Check if dialog is still open, if it is, cancel registration process
      if (Navigator.of(navigator.context, rootNavigator: true).canPop()) {
        await _firebaseAuth.currentUser?.delete();
        Fluttertoast.showToast(msg: 'Registration canceled');
      }
    }
  }
}

class VerifyEmailDialog extends StatefulWidget {
  const VerifyEmailDialog({Key? key}) : super(key: key);

  @override
  State<VerifyEmailDialog> createState() => _VerifyEmailDialogState();
}

class _VerifyEmailDialogState extends State<VerifyEmailDialog> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkIfEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void checkIfEmailVerified() async {
    final User user = FirebaseAuth.instance.currentUser!;
    await user.reload();
    if (user.emailVerified) {
      Fluttertoast.showToast(msg: 'Email Verified!');
      Navigator.of(context).pop();
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userEmailText =
        FirebaseAuth.instance.currentUser?.email.toString().trim();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LoadingAnimationWidget.halfTriangleDot(
            color: Colors.white,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(60, 20, 60, 0),
            child: Column(
              children: [
                const Text(
                  'A verification email has been sent to:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 1,
                    height: 2,
                    fontFamily: 'Jost',
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$userEmailText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                    letterSpacing: 1,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
