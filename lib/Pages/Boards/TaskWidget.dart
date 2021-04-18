import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_list_drag_and_drop/drag_and_drop_list.dart';
import 'file:///C:/Users/bhara/AndroidStudioProjects/Success/mx_companion/lib/Shared/Loading.dart';

class TaskWidget extends StatefulWidget {
  String CardName;
  String BoardId;
  DocumentSnapshot BoardSnapshot;
  TaskWidget({this.BoardId, this.CardName, this.BoardSnapshot});

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  TextEditingController taskTextController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            width: 300.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    blurRadius: 8,
                    offset: Offset(0, 0),
                    color: Color.fromRGBO(127, 140, 141, 0.5),
                    spreadRadius: 1)
              ],
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Text(
                    widget.CardName,
                    style: TextStyle(
                      fontFamily: 'PoppinsRegular',
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),
                SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7 - 50,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('All Boards')
                            .doc(widget.BoardId)
                            .collection(widget.CardName)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return new Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Loading();
                            default:
                              List Tiles_Names =
                                  snapshot.data.docs.map((document) {
                                return document.data()['Field Name'].toString();
                              }).toList();
                              List Tiles_id =
                                  snapshot.data.docs.map((document) {
                                return document.id;
                              }).toList();
                              return DragAndDropList<String>(
                                Tiles_Names,
                                itemBuilder: (BuildContext context, item) {
                                  return Container(
                                    width: 300.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    child: Draggable<dynamic>(
                                      feedback: Material(
                                        elevation: 5.0,
                                        child: Container(
                                          width: 284.0,
                                          padding: const EdgeInsets.all(5.0),
                                          color: Colors.grey[100],
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'PoppinsRegular',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(),
                                      child: Container(
                                        padding: const EdgeInsets.all(5.0),
                                        color: Colors.grey[200],
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'PoppinsRegular',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      data: {
                                        "id":
                                            Tiles_id[Tiles_Names.indexOf(item)],
                                        "from": widget.CardName,
                                        "data": snapshot.data
                                            .docs[Tiles_Names.indexOf(item)]
                                            .data()
                                      },
                                    ),
                                  );
                                },
                                onDragFinish: (oldIndex, newIndex) {
                                  var oldValue = Tiles_Names[oldIndex];
                                  Tiles_Names[oldIndex] = Tiles_Names[newIndex];
                                  Tiles_Names[newIndex] = oldValue;
                                  setState(() {});
                                },
                                canBeDraggedTo: (one, two) => true,
                                dragElevation: 8.0,
                              );
                          }
                        }),
                  ),
                ),
                TextButton(
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
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Add field",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.black,
                                        fontFamily: 'PoppinsRegular',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      decoration: InputDecoration(
                                          hintText: "Field Title"),
                                      controller: taskTextController,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30.0,
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        FirebaseFirestore.instance
                                            .collection("All Boards")
                                            .doc(widget.BoardId)
                                            .collection(widget.CardName)
                                            .doc()
                                            .set({
                                          'Field Name': taskTextController.text,
                                        });
                                        setState(() {
                                          taskTextController =
                                              new TextEditingController();
                                        });
                                      },
                                      child: Text(
                                        "Add Field",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'PoppinsRegular',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                    child: Container(
                      child: Center(
                          child: Text(
                        "+ Add field",
                        style: TextStyle(
                          fontFamily: 'PoppinsRegular',
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ))
              ],
            ),
          ),
          Positioned.fill(
            child: DragTarget<dynamic>(
              onWillAccept: (data) {
                return true;
              },
              onLeave: (data) {},
              onAccept: (data) async {
                if (data['from'] == widget.CardName) {
                  return;
                }
                await FirebaseFirestore.instance
                    .collection('All Boards')
                    .doc(widget.BoardId)
                    .collection(data['from'])
                    .doc(data['id'])
                    .delete();
                await FirebaseFirestore.instance
                    .collection('All Boards')
                    .doc(widget.BoardId)
                    .collection(widget.CardName)
                    .doc()
                    .set(data['data']);
                // childres[data['from']].remove(data['string']);
                // childres[index].add(data['string']);
                // setState(() {});
              },
              builder: (context, accept, reject) {
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
