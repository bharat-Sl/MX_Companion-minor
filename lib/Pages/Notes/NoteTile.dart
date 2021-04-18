import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Pages/Notes/NoteDetails.dart';

class NoteTile extends StatefulWidget {
  DocumentSnapshot document;
  NoteTile({this.document});

  @override
  _NoteTileState createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  bool check = false;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      check = widget.document.data()['Check'] ?? false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.90,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => NoteDetails(
                document: widget.document,
              ),
            ),
          );
        },
        child: Card(
          elevation: 10.0,
          color: check ? Colors.grey[300] : Colors.white,
          shadowColor: Colors.cyan[300],
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 7.0),
            child: ListTile(
              leading: Checkbox(
                checkColor: Colors.grey[800],
                activeColor: Colors.cyan,
                value: check,
                onChanged: (bool value) async {
                  setState(() {
                    check = value;
                  });
                  await widget.document.reference.update({'Check': check});
                },
              ),
              title: Text(
                widget.document['Title'],
                style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'PoppinsRegular',
                  color: Colors.black,
                ),
              ),
              subtitle: Opacity(
                opacity: 0.70,
                child: Text(
                  widget.document['Body'],
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'PoppinsRegular',
                    color: Colors.black,
                  ),
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('Profiles')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .collection('Notes')
                      .doc(widget.document.id)
                      .delete();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
