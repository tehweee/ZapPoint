import 'dart:async';
import 'package:flutter/material.dart';
import 'WelcomePage.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => WelcomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A40),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ZapPoint',
              style: TextStyle(
                color: Color(0xFFFFDD00),
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'ZapPointFont',
              ),
            ),
            SizedBox(height: 20),
            Image.asset('assets/ZapPoint_Logo_Transparent.png', height: 150),
          ],
        ),
      ),
    );
  }
}
