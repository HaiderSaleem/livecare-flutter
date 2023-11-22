import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livecare/screens/login/login.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1500), () {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/splash4.jpg',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/logo_livecare.png',
                height: 50,
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/logo_onseen_small.png',
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
