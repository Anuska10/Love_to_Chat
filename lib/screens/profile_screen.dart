// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:love_to_chat/screens/auth/login_screen.dart';

import '../api/apis.dart';

import 'package:love_to_chat/models/chat_user.dart';

import '../helper/dialogs.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),

        //floating button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 5),
          child: FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(255, 104, 231, 79),
            onPressed: () async {
              //for showing progress dialog

              Dialogs.showProgressbar(context);

              await APIs.updateActiveStatus(false);
              //sign out from app

              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog

                  Navigator.pop(context);

                  //for moving to home screen

                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;

                  //replacing home screen with login screen

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  //user profile picture
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      //edit image
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 58, 167, 62),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  //user email label
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  //name input field
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required',
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefix: const Icon(Icons.person,
                            color: Color.fromARGB(255, 55, 192, 255)),
                        hintText: 'eg: Raj Roy',
                        label: const Text('Name')),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  //about input field
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required',
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefix: const Icon(
                          Icons.info_outline,
                          color: Color.fromARGB(255, 55, 192, 255),
                          size: 20,
                        ),
                        hintText: 'eg: Busy',
                        label: const Text('About')),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  //update profile button
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: const StadiumBorder(),
                          backgroundColor:
                              const Color.fromARGB(255, 92, 216, 96),
                          minimumSize: Size(mq.width * .45, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) => {
                                Dialogs.showSnackbar(
                                    context, 'Updated Successfully!')
                              });
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 29,
                      ),
                      label: const Text(
                        'UPDATE',
                        style: TextStyle(fontSize: 17),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              const Text(
                //profile pic label
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: mq.height * .02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick picture from gallery
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        // Pick an image.
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File('_image!'));
                          //for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_image.png')),
                  //take picture from camera
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File('_image!'));
                          //for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera1.png'))
                ],
              )
            ],
          );
        });
  }
}
