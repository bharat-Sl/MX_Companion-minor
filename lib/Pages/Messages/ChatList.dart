import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/Loading.dart';

import 'ChatListTile.dart';
import 'ChatPage.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  bool isSearching = false;
  String myName, myEmail;
  Stream usersStream, chatRoomsStream;
  TextEditingController searchUserEmailEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    myName = FirebaseAuth.instance.currentUser.displayName;
    myEmail = FirebaseAuth.instance.currentUser.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Messenger",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            searchUserEmailEditingController.text = "";
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUserEmailEditingController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "Email"),
                        )),
                        GestureDetector(
                            onTap: () async {
                              if (searchUserEmailEditingController.text != "") {
                                setState(() {
                                  isSearching = true;
                                });
                                setState(() {
                                  usersStream = FirebaseFirestore.instance
                                      .collection("Profiles")
                                      .where("Email",
                                          isEqualTo:
                                              searchUserEmailEditingController
                                                  .text
                                                  .trim())
                                      .snapshots();
                                });
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching
                ? StreamBuilder(
                    stream: usersStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length != 0) {
                          return Container(
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                DocumentSnapshot ds = snapshot.data.docs[index];
                                return Container(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (myEmail
                                              .compareTo(ds.data()["Email"]) ==
                                          0) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Alert",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily:
                                                        'PoppinsRegular',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content: Text(
                                                  """You cannot message yourself""",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily:
                                                        'PoppinsRegular',
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      "Ok",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      } else {
                                        var chatRoomId;
                                        if (myEmail.compareTo(
                                                ds.data()["Email"]) ==
                                            1) {
                                          chatRoomId =
                                              "${ds.data()["Email"]}\_$myEmail";
                                        } else {
                                          chatRoomId =
                                              "$myEmail\_${ds.data()["Email"]}";
                                        }
                                        Map<String, dynamic> chatRoomInfoMap = {
                                          "users": [myEmail, ds.data()["Email"]]
                                        };
                                        final snapShot = await FirebaseFirestore
                                            .instance
                                            .collection("Chat Rooms")
                                            .doc(chatRoomId)
                                            .get();

                                        if (!snapShot.exists) {
                                          FirebaseFirestore.instance
                                              .collection("Chat Rooms")
                                              .doc(chatRoomId)
                                              .set(chatRoomInfoMap);
                                        }
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                    ds.data()["Name"],
                                                    ds.data()["Email"])));
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      child: ListTile(
                                        tileColor: Colors.black12,
                                        title: Text(
                                          ds.data()["Name"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(ds.data()["Email"]),
                                        leading: CircleAvatar(
                                            backgroundImage: ds.data()[
                                                        "Profile Image"] !=
                                                    null
                                                ? NetworkImage(
                                                    ds.data()["Profile Image"])
                                                : null,
                                            child: ds.data()["Profile Image"] ==
                                                    null
                                                ? Text(
                                                    ds.data()["Name"][0],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : null),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Column(children: [
                            SizedBox(
                              height: 50,
                            ),
                            Text("No user found with this email")
                          ]);
                        }
                      } else {
                        return Container(
                          child: Loading(),
                        );
                      }
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Chat Rooms")
                        .where("users", arrayContains: myEmail)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.docs[index];
                              return ChatListTile(
                                  ds.data()["lastMessage"], ds.id, myEmail);
                            });
                      } else {
                        print(snapshot);
                        return Column(children: [
                          SizedBox(
                            height: 50,
                          ),
                          Text("No chat history yet")
                        ]);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
