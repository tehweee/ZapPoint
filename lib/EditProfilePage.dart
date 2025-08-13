import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChargingListPage.dart';
import 'IntroPage.dart';
import 'EditEmailPage.dart';
import 'EditPasswordPage.dart';
import 'EditUsernamePage.dart';
import 'SelectVehicle.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({Key? key}) : super(key: key);

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  PlatformFile? pickedFile;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<dynamic> getUserVehicle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final info = await FirebaseFirestore.instance
        .collection("account")
        .doc(uid)
        .get();
    final data = info.data();
    final vehicle = data!['vehicle'];
    return vehicle['title'];
  }

  Future<String?> getUserEmail() async {
    return FirebaseAuth.instance.currentUser?.email;
  }

  Future<String?> getUserDisplayName() async {
    return FirebaseAuth.instance.currentUser?.displayName;
  }

  @override
  Widget build(BuildContext context) {
    const Color _primaryColor = Color(0xFF00BFFF);
    const Color _darkTextColor = Color(0xFF1A1A40);
    const Color _accentColor = Color(0xFFFFDD00);
    const Color _logoutButtonColor = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkTextColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChargerListScreen()),
            );
          },
        ),
        title: const Text(
          'Edit Account',
          style: TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _darkTextColor,
                    child: pickedFile != null
                        ? ClipOval(
                            child: Image.file(
                              File(pickedFile!.path!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.pin_drop,
                                size: 90,
                                color: _darkTextColor,
                              ),
                              Icon(Icons.bolt, size: 35, color: _accentColor),
                            ],
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: selectFile,
                    child: const Text(
                      'Edit Profile Picture',
                      style: TextStyle(color: _darkTextColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Email",
                        style: const TextStyle(
                          color: _darkTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.userChanges(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const Text("Loading...");
                              final user = snapshot.data!;
                              return Text(
                                user.email ?? 'N/A',
                                style: const TextStyle(
                                  color: _darkTextColor,
                                  fontSize: 18,
                                ),
                              );
                            },
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeEmailScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_right_alt),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: _darkTextColor, height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Username",
                        style: const TextStyle(
                          color: _darkTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          FutureBuilder<String?>(
                            future: getUserDisplayName(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              } else if (snapshot.hasError) {
                                return const Text('Error');
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return const Text('N/A');
                              } else {
                                return Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                    color: _darkTextColor,
                                    fontSize: 18,
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeUsernameScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_right_alt),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: _darkTextColor, height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Password",
                        style: const TextStyle(
                          color: _darkTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "********",
                            style: const TextStyle(
                              color: _darkTextColor,
                              fontSize: 18,
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_right_alt),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: _darkTextColor, height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Vehicle",
                        style: const TextStyle(
                          color: _darkTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          FutureBuilder<dynamic?>(
                            future: getUserVehicle(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              } else if (snapshot.hasError) {
                                return const Text('Error');
                              } else if (!snapshot.hasData ||
                                  snapshot.data == null) {
                                return const Text('N/A');
                              } else {
                                return Text(
                                  snapshot.data!,
                                  style: const TextStyle(
                                    color: _darkTextColor,
                                    fontSize: 18,
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectVehiclePage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_right_alt),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: _darkTextColor, height: 20),
                ],
              ),
            ),
            const SizedBox(height: 60),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoadingScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _logoutButtonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
