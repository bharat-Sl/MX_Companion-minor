import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'BoardPage.dart';

class BoardsList extends StatelessWidget {
  TextEditingController TableTitle = new TextEditingController();

  bool Check(QuerySnapshot document, String Type) {
    if (document.docs.length == 0) {
      return false;
    }
    List ListType = document.docs.map((doc) {
      return doc.data()['Type'];
    }).toList();
    if (ListType.contains(Type)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Profiles')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection('Boards')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.cyan),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Personal Boards",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PoppinsRegular',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) {
                                      return Dialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Add Board",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                    hintText: "Title"),
                                                controller: TableTitle,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30.0,
                                            ),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  DocumentReference Boardref =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "All Boards")
                                                          .doc();
                                                  DocumentReference Userref =
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              "Profiles")
                                                          .doc(FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              .uid)
                                                          .collection("Boards")
                                                          .doc();
                                                  await Boardref.set({
                                                    'Author': FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        .uid,
                                                    'Card Names': [],
                                                    'Project Name':
                                                        TableTitle.text,
                                                    'User Participants': [
                                                      FirebaseAuth.instance
                                                          .currentUser.uid
                                                    ],
                                                    'User Participants Name': [
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser
                                                          .displayName
                                                    ],
                                                    'User Participants Email': [
                                                      FirebaseAuth.instance
                                                          .currentUser.email
                                                    ],
                                                  });
                                                  await Userref.set({
                                                    'Board Id': Boardref.id,
                                                    'Type': "Private"
                                                  });
                                                  TableTitle =
                                                      new TextEditingController();
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("Add Table"),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Text(
                                "+ Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PoppinsRegular',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Check(snapshot.data, "Private")
                          ? Container(
                              height: 270,
                              width: MediaQuery.of(context).size.width - 20,
                              child: ListView(children: [
                                ...snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                                  if (document.data()['Type'] == 'Private') {
                                    return StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('All Boards')
                                            .doc(document.data()['Board Id'])
                                            .snapshots(),
                                        builder: (context, snap) {
                                          if (snap.hasError)
                                            return new Text(
                                                'Error: ${snap.error}');
                                          switch (snap.connectionState) {
                                            case ConnectionState.waiting:
                                              return Text('Loading...');
                                            default:
                                              if (!snap.data.exists) {
                                                document.reference.delete();
                                                return SizedBox();
                                              } else {
                                                return Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      border: Border.all(
                                                          color: Colors.grey)),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ListCards(
                                                            BoardName: snap.data
                                                                    .data()[
                                                                "Project Name"],
                                                            BoardId:
                                                                snap.data.id,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          child: Text(
                                                            snap.data.data()[
                                                                'Project Name'][0],
                                                            style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'PoppinsRegular',
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          snap.data.data()[
                                                              'Project Name'],
                                                          softWrap: true,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'PoppinsRegular',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                          }
                                        });
                                  } else {
                                    return SizedBox();
                                  }
                                }).toList(),
                              ]),
                            )
                          : Container(
                              height: 100,
                              child: Center(
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    'No boards yet',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'PoppinsRegular',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Container(
                      decoration: BoxDecoration(color: Colors.cyan),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Added Workspace",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PoppinsRegular',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) {
                                      return Dialog(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                "Enter Unique Id",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextField(
                                                decoration: InputDecoration(
                                                    hintText: "Id"),
                                                controller: TableTitle,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30.0,
                                            ),
                                            Center(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  DocumentSnapshot Boardsnap =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "All Boards")
                                                          .doc(TableTitle.text)
                                                          .get();
                                                  if (Boardsnap.exists &&
                                                      Boardsnap.data()[
                                                              "Author"] !=
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              .uid &&
                                                      !Boardsnap.data()[
                                                              "User Participants"]
                                                          .contains(FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              .uid)) {
                                                    DocumentReference Userref =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "Profiles")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid)
                                                            .collection(
                                                                "Boards")
                                                            .doc();
                                                    await Userref.set({
                                                      'Board Id':
                                                          TableTitle.text,
                                                      'Type': "Public"
                                                    });
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            "All Boards")
                                                        .doc(TableTitle.text)
                                                        .update({
                                                      'User Participants':
                                                          FieldValue
                                                              .arrayUnion([
                                                        FirebaseAuth.instance
                                                            .currentUser.uid
                                                      ]),
                                                      'User Participants Name':
                                                          FieldValue
                                                              .arrayUnion([
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            .displayName
                                                      ]),
                                                      'User Participants Email':
                                                          FieldValue
                                                              .arrayUnion([
                                                        FirebaseAuth.instance
                                                            .currentUser.email
                                                      ]),
                                                    });
                                                    TableTitle =
                                                        new TextEditingController();
                                                    Navigator.of(context).pop();
                                                  } else {
                                                    TableTitle =
                                                        new TextEditingController();
                                                    Navigator.of(context).pop();
                                                    showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            true,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                              "Joining Error",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    'PoppinsRegular',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            content: Text(
                                                              """You are not able to join this currently, because you might already have this Board""",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'PoppinsRegular',
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  "Ok",
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'PoppinsRegular',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  }
                                                },
                                                child: Text("Add Table"),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Text(
                                "+ Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PoppinsRegular',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Check(snapshot.data, "Public")
                          ? Container(
                              height: 270,
                              width: MediaQuery.of(context).size.width - 20,
                              child: ListView(children: [
                                ...snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                                  if (document.data()['Type'] == 'Public') {
                                    return StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('All Boards')
                                            .doc(document.data()['Board Id'])
                                            .snapshots(),
                                        builder: (context, snap) {
                                          if (snap.hasError)
                                            return new Text(
                                                'Error: ${snap.error}');
                                          switch (snap.connectionState) {
                                            case ConnectionState.waiting:
                                              return Text('Loading...');
                                            default:
                                              if (!snap.data.exists) {
                                                document.reference.delete();
                                                return SizedBox();
                                              } else {
                                                return Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      border: Border.all(
                                                          color: Colors.grey)),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ListCards(
                                                            BoardName: snap.data
                                                                    .data()[
                                                                "Project Name"],
                                                            BoardId:
                                                                snap.data.id,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          child: Text(
                                                            snap.data.data()[
                                                                'Project Name'][0],
                                                            style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'PoppinsRegular',
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          snap.data.data()[
                                                              'Project Name'],
                                                          softWrap: true,
                                                          overflow:
                                                              TextOverflow.fade,
                                                          style: TextStyle(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'PoppinsRegular',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                          }
                                        });
                                  } else {
                                    return SizedBox();
                                  }
                                }).toList(),
                              ]),
                            )
                          : Container(
                              height: 100,
                              child: Center(
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    'No boards yet',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'PoppinsRegular',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
          }
        });
  }
}
