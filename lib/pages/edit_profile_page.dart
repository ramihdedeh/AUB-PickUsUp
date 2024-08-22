import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aub_pickusup/components/my_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({Key? key}) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  User? currentActiveUser = FirebaseAuth.instance.currentUser;
  String? userBio;
  String? fullName;
  String? phoneNumber;
  final _formkey = GlobalKey<FormState>();
  ImageProvider logo = const AssetImage('assets/logo.png');

  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> changeProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File file = File(image.path);
      final String fileName = '${currentActiveUser!.uid} ${DateTime.now()}';

      try {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child(fileName);

        final UploadTask uploadTask = storageRef.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'picked-file-path': image.path},
          ),
        );

        final TaskSnapshot snapshot = await uploadTask;
        final photoUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentActiveUser!.uid)
            .update({'photoUrl': photoUrl});

        currentActiveUser!.updatePhotoURL(photoUrl);
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      }
    }
  }

  Future<void> getUserData() async {
    final userDataDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentActiveUser!.uid);
    final userDataSnapshot = await userDataDoc.get();

    if (userDataSnapshot.exists) {
      setState(() {
        fullName = userDataSnapshot.get('fullname');
        phoneNumber = userDataSnapshot.get('phone');
        userBio = userDataSnapshot.get('bio');

        fullNameController.text = fullName ?? '';
        phoneNumberController.text = phoneNumber ?? '';
        bioController.text = userBio ?? '';
      });
    }
  }

  Future<void> updateProfile() async {
    final userDataDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentActiveUser!.uid);

    await userDataDoc.update({
      'fullname': fullNameController.text.trim(),
      'phone': phoneNumberController.text.trim(),
      'bio': bioController.text.trim(),
    });

    currentActiveUser!.updateDisplayName(fullNameController.text.trim());

    Fluttertoast.showToast(msg: 'Profile updated successfully!');
  }

  @override
  Widget build(BuildContext context) {
    MyTextFormField phoneTextField = MyTextFormField(
      formPadding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
      inputType: TextInputType.phone,
      obscureText: false,
      specIcon: Icons.phone_rounded,
      controller1: phoneNumberController,
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

    MyTextFormField fullNameTextField = MyTextFormField(
      inputType: TextInputType.name,
      formPadding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
      obscureText: false,
      specIcon: Icons.person_rounded,
      controller1: fullNameController,
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

    MyTextFormField bioTextField = MyTextFormField(
      inputType: TextInputType.text,
      formPadding: const EdgeInsets.fromLTRB(45, 0, 45, 0),
      obscureText: false,
      specIcon: Icons.book_rounded,
      controller1: bioController,
      labelText: 'Bio',
      validatorCustom: (value) {
        if (value!.isEmpty) {
          return 'Please enter your Bio';
        } else if (value.toString().length < 4 ||
            value.toString().length > 90) {
          return 'Bio must be between 4 and 90 characters';
        }
        return null;
      },
    );

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
          'EDIT PROFILE',
          softWrap: true,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 10.0,
            color: Colors.white,
            fontFamily: 'JosefinSans',
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
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
                      foregroundImage: currentActiveUser?.photoURL != null &&
                              currentActiveUser?.photoURL != ''
                          ? NetworkImage(currentActiveUser!.photoURL! +
                              '?v=${DateTime.now().millisecondsSinceEpoch}')
                          : logo,
                      radius: 70,
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      color: aubRed,
                    ),
                    child: IconButton(
                      splashColor: aubRed,
                      splashRadius: 40,
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 25,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await changeProfilePhoto();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    fullNameTextField,
                    const SizedBox(
                      height: 15,
                    ),
                    phoneTextField,
                    const SizedBox(
                      height: 15,
                    ),
                    bioTextField,
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
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
                  if (_formkey.currentState!.validate()) {
                    await updateProfile();
                    await Navigator.pushReplacementNamed(context, '/profile');
                  }
                },
                child: const Text(
                  'SAVE',
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
                  await Navigator.pushReplacementNamed(context, '/profile');
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
