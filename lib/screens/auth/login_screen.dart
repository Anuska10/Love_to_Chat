import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:love_to_chat/main.dart';
import 'package:love_to_chat/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo :{user.additionalUserInfo}');
        if (await APIs.userExists()) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen())));
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInwithGoogle: $e');
      Dialogs.showSnackbar(
          context, 'Something Went Wrong(No Internet Available!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Love_to_Chat'),
      ),
      body: Stack(children: [
        AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon1.png')),
        Positioned(
          bottom: mq.height * .15,
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .06,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 103, 197, 108),
                shape: const StadiumBorder(),
                elevation: 1),
            onPressed: () {
              _handleGoogleBtnClick();
            },
            icon: Image.asset(
              'images/google.png',
              height: mq.height * .035,
            ),
            label: RichText(
              text: const TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w300),
                  children: [
                    TextSpan(text: 'Login with '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w600))
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}
