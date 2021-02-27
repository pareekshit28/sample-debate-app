import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debate/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  final Services services = Services();
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final String title;
  final String id;
  ChatRoom({Key key, this.title, this.id}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(widget.title,
            style: TextStyle(color: Colors.black, fontSize: 25)),
        bottomOpacity: 0,
        toolbarOpacity: 1,
        shadowColor: Colors.white12,
      ),
      backgroundColor: Colors.yellow,
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 40, 5, 12),
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget.db
                        .collection("groups")
                        .doc(widget.id)
                        .collection("chats")
                        .orderBy("date")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());
                      return snapshot.data.size > 0
                          ? ListView.builder(
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex: 4,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 7),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                topLeft: Radius.circular(15),
                                                bottomRight:
                                                    Radius.circular(15)),
                                            color:
                                                // Color.fromRGBO(0, 55, 251, 0.38),
                                                Color.fromRGBO(
                                                    250, 10, 10, 0.54),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                snapshot.data.docs
                                                    .elementAt(index)
                                                    .data()["sender"],
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Wrap(children: [
                                                Text(
                                                  snapshot.data.docs
                                                      .elementAt(index)
                                                      .data()["content"],
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                  ),
                                                  softWrap: true,
                                                ),
                                              ]),
                                            ],
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 7),
                                            child: Text(
                                              readTimestamp(snapshot.data.docs
                                                  .elementAt(index)
                                                  .data()["date"]),
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          flex: 1)
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                'Nothing Here',
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                    }),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40)),
                color: Color.fromRGBO(118, 4, 158, 0.78),
              ),
            ),
          ),
          ListTile(
            title: TextField(
              controller: widget._controller,
              decoration: InputDecoration(hintText: "Type Something..."),
            ),
            trailing: IconButton(
              onPressed: () {
                widget.services
                    .send(widget.id, widget._controller.text, "Pareekshit");
                widget._controller.text = '';
              },
              icon: Icon(Icons.send),
            ),
          )
        ],
      ),
    );
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat.jm('en_IN');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
  }
}
