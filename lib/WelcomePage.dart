import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A40),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(50),
            child: Text(
              'ZapPoint',
              style: TextStyle(
                color: Color(0xFFFFDD00),
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'ZapPointFont',
              ),
            ),
          ),

          Container(
            height: 624,
            decoration: BoxDecoration(
              color: Color(0xFF21A5BF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Make finding easier\nwith ZapPoint',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFDD00),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ZapPointFont',
                    ),
                  ),

                  SizedBox(height: 50),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color(0xFF1A1A40),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Color(0xFF1A1A40),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
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
