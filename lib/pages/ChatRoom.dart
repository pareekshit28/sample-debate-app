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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(widget.title, style: TextStyle(color: Colors.black)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.yellow,
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
                                return ListTile(
                                    leading: CircleAvatar(),
                                    title: Text(snapshot.data.docs
                                        .elementAt(index)
                                        .data()["sender"]),
                                    subtitle: Text(snapshot.data.docs
                                        .elementAt(index)
                                        .data()["content"]),
                                    trailing: Text(readTimestamp(snapshot
                                        .data.docs
                                        .elementAt(index)
                                        .data()["date"])));
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
        ));
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
