import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/CustomButton.dart';

class AddNotes extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection('Profiles')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("Notes")
      .doc();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
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
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height - 230,
                  child: TextFormField(
                    maxLines: 20,
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
      floatingActionButton: CustomButton(
        callback: () async {
          if (_formKey.currentState.validate()) {
            documentReference.set({
              'Title': titleController.text,
              'Body': bodyController.text,
              'Check': false,
            });
            Navigator.of(context).pop();
          }
        },
        lol: Text(
          'Add Note',
          style: TextStyle(
              fontFamily: 'PoppinsRegular',
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        Height: 0,
        colour: Colors.cyan[100],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}
