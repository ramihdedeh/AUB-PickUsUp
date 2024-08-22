// ignore_for_file: use_build_context_synchronously

import 'package:aub_pickusup/components/my_textfield.dart';
import 'package:aub_pickusup/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formkey = GlobalKey<FormState>();
  late final TextEditingController emailController = TextEditingController();
  late final TextEditingController passwordController = TextEditingController();
  late UserCredential credentials;

  Future<void> userSignIn(BuildContext context) async {
    final userEmail = emailController.text.trim();
    final userPassword = passwordController.text.trim();

    if (userEmail.isNotEmpty && userPassword.isNotEmpty) {
      showLoadingDialog();
      try {
        final credentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: userEmail, password: userPassword);

        if (credentials.user?.emailVerified == true) {
          Fluttertoast.showToast(msg: 'Signed in Successfully');
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
              context, '/choose_type', (route) => false);
        } else {
          // show error message if email is not verified
          Fluttertoast.showToast(msg: 'Email not verified');
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);

        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(msg: e.code.toString());
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(msg: e.code.toString());
        } else {
          Fluttertoast.showToast(msg: e.code.toString());
        }
      } on Exception catch (e) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        centerTitle: true,
        backgroundColor: aubRed,
        elevation: 0,
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
          'SIGN IN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 10.0,
            color: Colors.white,
            fontFamily: 'JosefinSans',
          ),
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
                  padding: EdgeInsets.fromLTRB(0, 0.0, 0.0, 120.0),
                ),
                emailTextField,
                const SizedBox(
                  height: 10,
                ),
                passwordTextField,
                const SizedBox(
                  height: 10,
                ),
                confirmSignIn(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'don\'t have an account?',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            letterSpacing: 1,
                            fontWeight: FontWeight.normal),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/register', (route) => false);
                        },
                        child: const Text(
                          'REGISTER',
                          style: TextStyle(
                              color: aubBlue,
                              fontSize: 18,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold),
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

  MaterialButton confirmSignIn() {
    return MaterialButton(
      elevation: 3,
      onPressed: () {
        if (_formkey.currentState!.validate()) {
          userSignIn(context);
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
      padding: const EdgeInsets.symmetric(horizontal: 43, vertical: 15),
      child: const Text(
        'CONFIRM',
        style: TextStyle(
          color: aubRed,
          fontSize: 18,
          letterSpacing: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<dynamic> showLoadingDialog() {
    return showDialog(
      barrierColor: aubRed,
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LoadingAnimationWidget.halfTriangleDot(
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'SIGNING IN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
