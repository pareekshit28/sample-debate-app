import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debate/pages/ChatRoom.dart';
import 'package:debate/pages/CreateDebate.dart';
import 'package:debate/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Services services = Services();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text(
          'Debate',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: Colors.yellow,
        child: StreamBuilder<QuerySnapshot>(
            stream: widget.db.collection("groups").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return snapshot.data.size > 0
                  ? ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                              snapshot.data.docs.elementAt(index)["title"]),
                          subtitle: Text(snapshot.data.docs
                              .elementAt(index)["description"]),
                          trailing: Icon(
                            Icons.arrow_right_alt,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) => ChatRoom(
                                title: snapshot.data.docs
                                    .elementAt(index)["title"],
                                id: snapshot.data.docs.elementAt(index)["id"],
                              ),
                            ));
                          },
                        );
                      })
                  : Center(
                      child: Text(
                        'Nothing Here',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        label: Text("Create a Discussion"),
        icon: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => CreateDebate(),
          ));
        },
      ),
    );
  }
}
