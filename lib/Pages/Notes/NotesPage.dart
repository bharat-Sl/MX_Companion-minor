import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/CustomButton.dart';

import 'AddNotes.dart';
import 'NoteTile.dart';

class Notes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          'Manage your notes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'PoppinsRegular',
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Profiles')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection('Notes')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading...');
              default:
                if (snapshot.data.docs.length != 0) {
                  return Column(
                    children: <Widget>[
                      ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            ...snapshot.data.docs
                                .map((DocumentSnapshot document) {
                              bool check = false;
                              return NoteTile(
                                document: document,
                              );
                            }).toList(),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 10,
                            ),
                          ]),
                    ],
                  );
                } else {
                  return Center(
                    heightFactor: 10.0,
                    child: Opacity(
                      opacity: 0.50,
                      child: Text(
                        'No notes yet',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PoppinsRegular',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }
            }
          },
        ),
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => AddNotes(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.cyan[300],
                  blurRadius: 3.0,
                  offset: Offset.fromDirection(1.0)),
            ],
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width - 50,
          height: 60,
          child: Center(
            child: Text(
              "Write more",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'PoppinsRegular',
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
