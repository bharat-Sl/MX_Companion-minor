import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/CustomButton.dart';

class NoteDetails extends StatefulWidget {
  DocumentSnapshot document;
  NoteDetails({this.document});

  @override
  _NoteDetailsState createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  TextEditingController titleController = new TextEditingController();
  TextEditingController bodyController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController =
        new TextEditingController(text: widget.document.data()['Title']);
    bodyController =
        new TextEditingController(text: widget.document.data()['Body']);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Colors.grey[700],
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.document.reference.update({
                  'Title': titleController.text,
                  'Body': bodyController.text,
                });
                Navigator.of(context).pop();
              }
            },
          ),
        ],
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
          'New note',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'PoppinsRegular',
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: TextFormField(
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'Title required';
                      } else {
                        return null;
                      }
                    },
                    cursorColor: Colors.black,
                    controller: titleController,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'PoppinsRegular',
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      errorBorder: InputBorder.none,
                      labelText: 'Title',
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontFamily: 'PoppinsRegular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 230,
                  color: Colors.white,
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: bodyController,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'PoppinsRegular',
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '',
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontFamily: 'PoppinsRegular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
