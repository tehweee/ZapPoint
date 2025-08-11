import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing_rapidapi_2/ChargingListPage.dart';
import 'package:testing_rapidapi_2/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print(userCredential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChargerListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print('Failed to login user: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A40), // Dark blue background
      resizeToAvoidBottomInset:
          false, // Prevents screen from resizing when keyboard appears
      body: Column(
        children: <Widget>[
          // Login title section
          Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.15),
            child: const Text(
              'Login',
              style: TextStyle(
                color: Color(0xFFFFDD00), // Yellow font
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                // fontFamily: 'Montserrat', // Ensure this font is configured
              ),
            ),
          ),

          const Spacer(), // Pushes the content to the bottom
          // Main content container with text fields and button
          Container(
            width: screenSize.width,
            height: screenSize.height * 0.65, // Responsive height
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: const BoxDecoration(
              color: Color(0xFF21A5BF), // Light blue background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Email text field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                    child: Text(
                      'Email',
                      style: TextStyle(
                        color: Color(0xFF1A1A40),
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),

                const SizedBox(height: 30.0), // Space between fields
                // Password text field
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                    child: Text(
                      'Password',
                      style: TextStyle(
                        color: Color(0xFF1A1A40),
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true, // Hides the password
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),

                const SizedBox(height: 50.0), // Space before button
                // Login button
                ElevatedButton(
                  onPressed: () async {
                    await loginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), // Full width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigates to the Register page and replaces the current page in the stack
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        label: const Text(
          'Register',
          style: TextStyle(
            color: Color(0xFF1A1A40),
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.login),
        backgroundColor: const Color(0xFFFFDD00), // Yellow background
        foregroundColor: const Color(0xFF1A1A40), // Dark blue icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
