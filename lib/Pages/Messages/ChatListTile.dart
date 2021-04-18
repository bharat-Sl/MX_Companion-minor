import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/Loading.dart';

import 'ChatPage.dart';

class ChatListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myEmail;
  ChatListTile(this.lastMessage, this.chatRoomId, this.myEmail);

  @override
  _ChatListTileState createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  String profilePicUrl = "", name = "", email = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      email =
          widget.chatRoomId.replaceAll(widget.myEmail, "").replaceAll("_", "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("Profiles")
            .where("Email", isEqualTo: email)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Loading();
            default:
              {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                snapshot.data.docs[0]["Name"], email)));
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: snapshot.data.docs[0]
                                      .data()["Profile Image"] !=
                                  null
                              ? NetworkImage(
                                  snapshot.data.docs[0].data()["Profile Image"])
                              : null,
                          child:
                              snapshot.data.docs[0].data()["Profile Image"] ==
                                      null
                                  ? Text(snapshot.data.docs[0]["Name"][0])
                                  : null,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data.docs[0]["Name"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 3),
                            Text(widget.lastMessage)
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
          }
        });
  }
}
