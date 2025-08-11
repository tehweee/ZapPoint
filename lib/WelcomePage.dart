import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A40),
      body: Column(
        children: <Widget>[
          // ZapPoint title section
          Padding(
            // Adjust top padding to position the title
            padding: EdgeInsets.all(50),
            child: Text(
              'ZapPoint',
              style: TextStyle(
                color: const Color(0xFFFFDD00), // Yellow font
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                // You can add a custom font family here if configured in pubspec.yaml
                // fontFamily: 'Montserrat',
              ),
            ),
          ),

          Container(
            height: 624,
            decoration: const BoxDecoration(
              color: Color(0xFF21A5BF), // Light blue background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0), // Rounded top-left corner
                topRight: Radius.circular(50.0), // Rounded top-right corner
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Main text
                  const Text(
                    'Make finding easier\nwith ZapPoint',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1A1A40), // Dark blue text for contrast
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Montserrat',
                    ),
                  ),

                  const SizedBox(
                    height: 50.0,
                  ), // Space between text and buttons
                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ), // Pill-shaped corners
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

                  const SizedBox(height: 20.0), // Space between buttons
                  // Register button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          30.0,
                        ), // Pill-shaped corners
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
    );
  }
}
