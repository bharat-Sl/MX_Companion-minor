import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String email;
  ChatPage(this.name, this.email);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String chatRoomId, messageId = "";
  Stream messageStream;
  String myName, myProfilePic, myEmail;
  TextEditingController messageTextEdittingController = TextEditingController();

  getChatRoomIdByUsernames(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) async {
    if (messageTextEdittingController.text != "") {
      String message = messageTextEdittingController.text;
      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myEmail,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };
      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      await FirebaseFirestore.instance
          .collection("Chat Rooms")
          .doc(chatRoomId)
          .collection("chats")
          .doc(messageId)
          .set(messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendBy": myEmail
        };
        if (sendClicked) {
          setState(() {
            messageTextEdittingController.text = "";
          });
          FirebaseFirestore.instance
              .collection("Chat Rooms")
              .doc(chatRoomId)
              .update(lastMessageInfoMap);

          setState(() {
            messageId = "";
          });
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0),
                ),
                color: sendByMe ? Colors.cyan : Colors.black,
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Chat Rooms")
          .doc(chatRoomId)
          .collection("chats")
          .orderBy("ts", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 70, top: 16),
                itemCount: snapshot.data.docs.length,
                reverse: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatMessageTile(
                      ds["message"], myEmail == ds["sendBy"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    myName = FirebaseAuth.instance.currentUser.displayName;
    myProfilePic = FirebaseAuth.instance.currentUser.photoURL;
    myEmail = FirebaseAuth.instance.currentUser.email;
    chatRoomId = getChatRoomIdByUsernames(myEmail, widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageTextEdittingController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "type a message",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.6))),
                    )),
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
