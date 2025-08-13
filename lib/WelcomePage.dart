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
          Padding(
            padding: EdgeInsets.all(50),
            child: Text(
              'ZapPoint',
              style: TextStyle(
                color: const Color(0xFFFFDD00),
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'ZapPointFont',
              ),
            ),
          ),

          Container(
            height: 624,
            decoration: const BoxDecoration(
              color: Color(0xFF21A5BF),
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
                  const Text(
                    'Make finding easier\nwith ZapPoint',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1A1A40),
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ZapPointFont',
                    ),
                  ),

                  const SizedBox(height: 50.0),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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

                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
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
    );
  }
}
