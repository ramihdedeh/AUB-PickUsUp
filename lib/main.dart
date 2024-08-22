import 'package:aub_pickusup/pages/auth_page.dart';
import 'package:aub_pickusup/pages/choose_type.dart';
import 'package:aub_pickusup/pages/edit_profile_page.dart';
import 'package:aub_pickusup/pages/main_screen_rider.dart';
import 'package:aub_pickusup/pages/profile_page.dart';
import 'package:aub_pickusup/pages/register_page.dart';
import 'package:aub_pickusup/pages/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const Color aubRed = Color.fromRGBO(106, 19, 44, 1);
const Color aubGrey = Color.fromRGBO(120, 120, 120, 1);
const Color aubBlue = Color.fromRGBO(58, 136, 198, 1);

final FirebaseFirestore db = FirebaseFirestore.instance;
final CollectionReference userCollectRef = db.collection('users');
User? user = FirebaseAuth.instance.currentUser;
String? userDisplayName = user!.displayName;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const AUBPickUsUp(),
  );
}

class AUBPickUsUp extends StatelessWidget {
  const AUBPickUsUp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Jost',
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.white,
        onPrimary: aubRed,
        secondary: aubRed,
        onSecondary: Colors.white,
        error: Colors.lightBlue,
        onError: Colors.white,
        background: Colors.black,
        onBackground: Colors.white,
        surface: Colors.black,
        onSurface: Colors.white,
        outline: aubRed,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      title: 'AUB PickUsUp',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/chooserole': (context) => const ChooseUserType(),
        '/signin': (context) => const SignInPage(),
        '/register': (context) => const RegisterPage(),
        '/rider': (context) => const MainScreenRider(),
        '/profile': (context) => const ProfilePage(),
        '/editprofile': (context) => const ProfileEditPage(),
      },
    );
  }
}
