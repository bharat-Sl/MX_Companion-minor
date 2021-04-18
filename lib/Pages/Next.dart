import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'Boards/BoardsListPage.dart';
import 'LoginPage.dart';
import 'Messages/ChatList.dart';
import 'Notes/NotesPage.dart';

class Next extends StatefulWidget {
  static const String id = 'Next';
  final User user;
  const Next({Key key, this.user}) : super(key: key);
  @override
  _NextState createState() => _NextState();
}

class _NextState extends State<Next> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<bool> check(snap) async {
    final snapshot = await FirebaseFirestore.instance.collection('Notes').get();
    if (snapshot.docs.length == 0) {
      return false;
    }
  }
  //Doesn't exist

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Image.asset(
          'assets/images/logo.png',
        ),
        title: Opacity(
          opacity: 0.70,
          child: Text(
            'Welcome ${FirebaseAuth.instance.currentUser.displayName.split(' ')[0]}!',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'PoppinsRegular',
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  _scaffoldKey.currentState.openEndDrawer();
                },
                icon: Icon(
                  Icons.storage,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
      body: BoardsList(),
      endDrawer: new Drawer(
        child: new ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountEmail: new Text(
                FirebaseAuth.instance.currentUser.email,
              ),
              accountName: new Text(
                FirebaseAuth.instance.currentUser.displayName,
                style: TextStyle(
                  fontFamily: 'PoppinsRegular',
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: new GestureDetector(
                child: new CircleAvatar(
                  backgroundImage: FirebaseAuth.instance.currentUser.photoURL !=
                          null
                      ? NetworkImage(FirebaseAuth.instance.currentUser.photoURL)
                      : null,
                  child: FirebaseAuth.instance.currentUser.photoURL == null
                      ? Text(
                          FirebaseAuth.instance.currentUser.displayName[0],
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                onTap: () => print("This is your current account."),
              ),
              decoration: new BoxDecoration(color: Colors.cyan),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 8, left: 8, right: 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.cyan[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(24),
                    ),
                    border: Border.all(color: Colors.black, width: 0.5)),
                child: TextButton(
                  onPressed: () {},
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 8, left: 8, right: 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.cyan[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(24),
                    ),
                    border: Border.all(color: Colors.black, width: 0.5)),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => Notes(),
                      ),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.notes,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'My Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2 - 60,
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, bottom: 8, left: 8, right: 0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomRight: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(24),
                    ),
                    border: Border.all(color: Colors.black, width: 0.5)),
                child: TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed(LoginPage.id);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.exit_to_app,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Log Out',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => ChatList(),
            ),
          );
        },
        child: Icon(
          Icons.message,
          color: Colors.white,
        ),
      ),
    );
  }
}
