import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class GroupChatPage extends StatefulWidget {
  final String BoardId;
  final String BoardName;
  GroupChatPage(this.BoardId, this.BoardName);
  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  String messageId = "";
  Stream messageStream;
  String previousEmail = "";
  String myName, myProfilePic, myEmail;
  TextEditingController messageTextEdittingController = TextEditingController();

  addMessage(bool sendClicked) async {
    if (messageTextEdittingController.text != "") {
      String message = messageTextEdittingController.text;
      var lastMessageTs = DateTime.now();
      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendById": FirebaseAuth.instance.currentUser.uid,
        "sendByName": FirebaseAuth.instance.currentUser.displayName,
        "sendByEmail": FirebaseAuth.instance.currentUser.email,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };
      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      await FirebaseFirestore.instance
          .collection("All Boards")
          .doc(widget.BoardId)
          .collection("Chats")
          .doc(messageId)
          .set(messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMessageTs,
          "lastMessageSendById": FirebaseAuth.instance.currentUser.uid,
          "lastMessageSendByName":
              FirebaseAuth.instance.currentUser.displayName,
          "lastMessageSendByEmail": FirebaseAuth.instance.currentUser.email,
        };
        if (sendClicked) {
          setState(() {
            messageTextEdittingController.text = "";
          });
          FirebaseFirestore.instance
              .collection("All Boards")
              .doc(widget.BoardId)
              .update(lastMessageInfoMap);
          setState(() {
            messageId = "";
          });
        }
      });
    }
  }

  Widget chatMessageTile(String email, String message, bool sendByMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ),
        (!sendByMe && email.length != 0)
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text(email),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("All Boards")
          .doc(widget.BoardId)
          .collection("Chats")
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
                  var name;
                  if (previousEmail == ds["sendByEmail"]) {
                    name = "";
                  } else {
                    name = ds["sendByEmail"];
                    previousEmail = name;
                  }
                  return chatMessageTile(
                      name, ds["message"], myEmail == ds["sendByEmail"]);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      myName = FirebaseAuth.instance.currentUser.displayName;
      myProfilePic = FirebaseAuth.instance.currentUser.photoURL;
      myEmail = FirebaseAuth.instance.currentUser.email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.BoardName),
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
