import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final username = usernameController.text.trim();
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.reload();
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      print('Failed to create user: ${e.message}');
    }
  }

  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A40), // Dark blue background
      resizeToAvoidBottomInset:
          false, // Prevents screen from resizing when keyboard appears
      body: Column(
        children: <Widget>[
          // Register title section
          Padding(
            padding: EdgeInsets.only(top: screenSize.height * 0.15),
            child: const Text(
              'Register',
              style: TextStyle(
                color: Color(0xFFFFDD00), // Yellow font
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Spacer(), // Pushes the content to the bottom
          // Main content container with text fields and button
          Container(
            width: screenSize.width,
            height: screenSize.height * 0.65, // Responsive height
            decoration: const BoxDecoration(
              color: Color(0xFF21A5BF), // Light blue background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                  // Username text field
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12.0, bottom: 8.0),
                      child: Text(
                        'Username',
                        style: TextStyle(
                          color: Color(0xFF1A1A40),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: usernameController,
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
                  // Register button
                  ElevatedButton(
                    onPressed: () async {
                      await createUser();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Full width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigates to the Login page and replaces the current page in the stack
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        label: const Text(
          'Have an account? Login now!',
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
