import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WhoIsComing extends StatelessWidget {

  CollectionReference pfc = FirebaseFirestore.instance.collection('pfc');

  Future<QuerySnapshot> _getEvents(){
    return pfc.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getEvents(),
      builder: (context, AsyncSnapshot<QuerySnapshot>snapshot){

        if(snapshot.connectionState == ConnectionState.done){
          final events = snapshot.data.docs;

          var nextEvents = events.where((element) {
            Timestamp t = element['time'];
            var date = t.toDate();
            var now = new DateTime.now();
            return date.isAfter(now);
          }).toList();

          nextEvents.sort((a,b) {
            Timestamp t1 = a['time'];
            Timestamp t2 = b['time'];

            var d1 = t1.toDate();
            var d2 = t2.toDate();

            return d1.isBefore(d2) ? -1 : 1;
          });

          Map<String, dynamic> d = nextEvents.first.data();
          print(d["who_is_coming"]);
          List<Widget> peopleWidget = d["who_is_coming"].map<Widget>((e) {
            return Container(
              margin: EdgeInsets.all(20),
              height: 50,
              color: Colors.amber[500],
              child: ListTile(
            title: Center(child: Text(e),),
            ),
            );
          }).toList();

          return peopleWidget.isEmpty ? Center(
            child: Text("Looks like no one joined yet"),
          ) : ListView(
            children: peopleWidget,
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
