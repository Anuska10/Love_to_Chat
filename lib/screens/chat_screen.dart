import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:love_to_chat/models/chat_user.dart';
import 'package:love_to_chat/models/message.dart';
import 'package:love_to_chat/screens/view_profile_screen.dart';
import 'package:love_to_chat/widgets/message_card.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
//for storing all mssgs
  List<Message> _list = [];

//for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 211, 240, 254),
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 233, 255, 207),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const SizedBox();
                          //if some or all data is loaded the show it
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;

                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  itemCount: _list.length,
                                  padding:
                                      EdgeInsets.only(top: mq.height * .01),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);
                                  });
                            } else {
                              return const Center(
                                  child: Text(
                                'Say Hello!👋🫂',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w300),
                              ));
                            }
                        }
                      }),
                ),
                //progress indicator for showing uploading
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),

                //chat input field

                _chatInput(),

                //show emojis on keyboard emoji btn and vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 233, 255, 207),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(children: [
              //back button
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black54)),

              //user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),

              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //user name
                  Text(list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(
                    height: 2,
                  ),
                  //last seen time of user
                  Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              )
            ]);
          }),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.width * .025, horizontal: mq.height * .01),
      child: Row(children: [
        //input field and btn
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                //emoji btn
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                  },
                  icon: const Icon(
                    Icons.emoji_emotions,
                    size: 26,
                  ),
                  color: const Color.fromARGB(255, 83, 183, 86),
                ),
                Expanded(
                    child: TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  onTap: () {
                    if (_showEmoji) {
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    }
                  },
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: 'Type Something . . .',
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 43, 232, 140),
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none),
                )),
                //pick image from gallery btn

                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Picking multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      // uploading & sending image one by one
                      for (var i in images) {
                        log('Image Path: ${i.path}');
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(Icons.image,
                        color: Color.fromARGB(255, 83, 183, 86), size: 26)),
                //take image from camera btn
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);

                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(Icons.camera_alt_rounded, size: 26),
                    color: const Color.fromARGB(255, 83, 183, 86)),
                SizedBox(
                  width: mq.width * .02,
                )
              ],
            ),
          ),
        ),
        //send msg btn
        MaterialButton(
          minWidth: 0,
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              //on first message (add user to my_user collection of chat user)
              APIs.sendMessage(widget.user, _textController.text, Type.text);
              _textController.text = '';
            }
          },
          padding:
              const EdgeInsets.only(top: 10, left: 10, right: 5, bottom: 10),
          shape: const CircleBorder(),
          color: const Color.fromARGB(255, 83, 183, 86),
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
        )
      ]),
    );
  }
}
