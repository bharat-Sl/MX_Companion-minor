import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Pages/Boards/GroupChat.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/Loading.dart';

import 'TaskWidget.dart';

class ListCards extends StatefulWidget {
  String BoardId;
  String BoardName;
  ListCards({this.BoardId, this.BoardName});
  @override
  _ListCardsState createState() => _ListCardsState();
}

class _ListCardsState extends State<ListCards> {
  TextEditingController CardTextController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List Cards;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("All Boards")
            .doc(widget.BoardId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                key: _scaffoldKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.cyan[200],
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  backgroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.storage),
                      onPressed: () {
                        _scaffoldKey.currentState.openEndDrawer();
                      },
                    )
                  ],
                  title: Text(
                    widget.BoardName,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'PoppinsRegular',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                body: Loading(),
              );
            default:
              return Scaffold(
                key: _scaffoldKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.cyan[200],
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  backgroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.storage),
                      onPressed: () {
                        _scaffoldKey.currentState.openEndDrawer();
                      },
                    )
                  ],
                  title: Text(
                    widget.BoardName,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'PoppinsRegular',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                body: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.data()['Card Names'].length + 1,
                  itemBuilder: (context, index) {
                    if (index == snapshot.data.data()['Card Names'].length)
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return Dialog(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Add Card",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontFamily: 'PoppinsRegular',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "Task Title",
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'PoppinsRegular',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            controller: CardTextController,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30.0,
                                        ),
                                        Center(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              print(CardTextController.text);
                                              Navigator.of(context).pop();
                                              FirebaseFirestore.instance
                                                  .collection("All Boards")
                                                  .doc(widget.BoardId)
                                                  .update({
                                                'Card Names':
                                                    FieldValue.arrayUnion([
                                                  CardTextController.text
                                                ]),
                                              });
                                              setState(() {
                                                CardTextController =
                                                    new TextEditingController();
                                              });
                                            },
                                            child: Text("Add Task"),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Row(
                            children: <Widget>[
                              snapshot.data.data()['Card Names'].length == 0
                                  ? SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 3)
                                  : SizedBox(),
                              Icon(
                                Icons.add,
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                "Add Card",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'PoppinsRegular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 20.0),
                            ],
                          ),
                        ),
                      );
                    else
                      return TaskWidget(
                        CardName: snapshot.data.data()['Card Names'][index],
                        BoardSnapshot: snapshot.data,
                        BoardId: widget.BoardId,
                      );
                  },
                ),
                endDrawer: new Drawer(
                  child: new ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      new UserAccountsDrawerHeader(
                        accountEmail:
                            new Text(FirebaseAuth.instance.currentUser.email),
                        accountName: new Text(
                          FirebaseAuth.instance.currentUser.displayName,
                          style: TextStyle(
                            fontFamily: 'PoppinsRegular',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        currentAccountPicture: new GestureDetector(
                          child: new CircleAvatar(
                            backgroundImage: FirebaseAuth
                                        .instance.currentUser.photoURL !=
                                    null
                                ? NetworkImage(
                                    FirebaseAuth.instance.currentUser.photoURL)
                                : null,
                            child: FirebaseAuth.instance.currentUser.photoURL ==
                                    null
                                ? Text(
                                    FirebaseAuth
                                        .instance.currentUser.displayName[0],
                                    style: TextStyle(fontSize: 30),
                                  )
                                : null,
                          ),
                          onTap: () => print("This is your current account."),
                        ),
                        decoration: new BoxDecoration(color: Colors.cyan),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text(
                              "Participants",
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'PoppinsRegular',
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            snapshot.data.data()["User Participants"].length > 1
                                ? ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GroupChatPage(
                                                snapshot.data.id,
                                                snapshot.data
                                                    .data()['Project Name'])),
                                      );
                                    },
                                    child: Text(
                                      "Group Chat",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'PoppinsRegular',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      Container(
                        height:
                            MediaQuery.of(context).size.height * 5 / 11 + 30,
                        child: ListView.builder(
                          itemCount:
                              snapshot.data.data()["User Participants"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(
                                      color: Colors.black, width: 0.5)),
                              margin: EdgeInsets.all(3),
                              child: ListTile(
                                trailing: snapshot.data.data()["Author"] ==
                                            FirebaseAuth
                                                .instance.currentUser.uid &&
                                        snapshot.data.data()["Author"] !=
                                            snapshot.data
                                                    .data()["User Participants"]
                                                [index]
                                    ? IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "Confirm Remove",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontFamily:
                                                          'PoppinsRegular',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    """Are you sure you want to remove this person?""",
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
                                                        "Cancel",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'PoppinsRegular',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        QuerySnapshot ds =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "Profiles")
                                                                .doc(snapshot
                                                                            .data
                                                                            .data()[
                                                                        "User Participants"]
                                                                    [index])
                                                                .collection(
                                                                    'Boards')
                                                                .where(
                                                                    "Board Id",
                                                                    isEqualTo:
                                                                        widget
                                                                            .BoardId)
                                                                .get();
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Profiles")
                                                            .doc(snapshot.data
                                                                        .data()[
                                                                    "User Participants"]
                                                                [index])
                                                            .collection(
                                                                'Boards')
                                                            .doc(ds
                                                                .docs.first.id)
                                                            .delete();
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "All Boards")
                                                            .doc(widget.BoardId)
                                                            .update({
                                                          'User Participants':
                                                              FieldValue
                                                                  .arrayRemove([
                                                            snapshot.data
                                                                        .data()[
                                                                    "User Participants"]
                                                                [index]
                                                          ]),
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        "Remove",
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontFamily:
                                                              'PoppinsRegular',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                        icon: Icon(Icons.cancel),
                                      )
                                    : SizedBox(),
                                subtitle: snapshot.data.data()["Author"] ==
                                        snapshot.data
                                            .data()["User Participants"][index]
                                    ? Text(
                                        "  Owner",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontFamily: 'PoppinsRegular',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        "  Member",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                          fontFamily: 'PoppinsRegular',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                title: Text(
                                  "> " +
                                      (snapshot.data
                                                  .data()["User Participants"]
                                                      [index]
                                                  .toString() ==
                                              FirebaseAuth
                                                  .instance.currentUser.uid
                                          ? "You"
                                          : snapshot.data
                                              .data()["User Participants Name"]
                                                  [index]
                                              .toString()),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'PoppinsRegular',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      snapshot.data.data()["Author"] ==
                              FirebaseAuth.instance.currentUser.uid
                          ? new ListTile(
                              title: new Text(
                                "+  Add New Member",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'PoppinsRegular',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Add Member",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'PoppinsRegular',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          """Share this Unique Id with the person you want to add""",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'PoppinsRegular',
                                          ),
                                        ),
                                        actions: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                100,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 0.5)),
                                                  child: Text(
                                                    widget.BoardId,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'PoppinsRegular',
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    FlutterClipboard.copy(
                                                        widget.BoardId);
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                      "Unique Id copied to clipboard",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'PoppinsRegular',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )));
                                                  },
                                                  child: Text(
                                                    "Copy",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontFamily:
                                                          'PoppinsRegular',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                              },
                            )
                          : new ListTile(),
                      snapshot.data.data()["Author"] !=
                              FirebaseAuth.instance.currentUser.uid
                          ? new ListTile(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Leave",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'PoppinsRegular',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Confirm Leave",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'PoppinsRegular',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          """Are you sure you want to Leave this board?""",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'PoppinsRegular',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontFamily: 'PoppinsRegular',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              QuerySnapshot ds =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("Profiles")
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser.uid)
                                                      .collection('Boards')
                                                      .where("Board Id",
                                                          isEqualTo:
                                                              widget.BoardId)
                                                      .get();
                                              FirebaseFirestore.instance
                                                  .collection("Profiles")
                                                  .doc(FirebaseAuth
                                                      .instance.currentUser.uid)
                                                  .collection('Boards')
                                                  .doc(ds.docs.first.id)
                                                  .delete();
                                              FirebaseFirestore.instance
                                                  .collection("All Boards")
                                                  .doc(widget.BoardId)
                                                  .update({
                                                'User Participants':
                                                    FieldValue.arrayRemove([
                                                  FirebaseAuth
                                                      .instance.currentUser.uid
                                                ]),
                                              });
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Leave",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontFamily: 'PoppinsRegular',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              },
                            )
                          : new ListTile(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Delete ",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'PoppinsRegular',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Confirm Delete ",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'PoppinsRegular',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: Text(
                                          """Are you sure you want to delete this board?[You will not be able to undo this delete in the future.]""",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'PoppinsRegular',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                fontFamily: 'PoppinsRegular',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection("All Boards")
                                                  .doc(widget.BoardId)
                                                  .delete();
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontFamily: 'PoppinsRegular',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                              },
                            ),
                    ],
                  ),
                ),
              );
          }
        });
  }
}
