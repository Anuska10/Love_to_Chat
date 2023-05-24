import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:love_to_chat/api/apis.dart';
import 'package:love_to_chat/main.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white,
      ));
      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        // log('\nUserAdditionalInfo :{user.additionalUserInfo}');

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        Positioned(
            top: mq.height * .18,
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset('images/icon1.png')),
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: const Text(
              'Best Chatting App 💚',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, color: Colors.black87, letterSpacing: 0.5),
            )),
      ]),
    );
  }
}
