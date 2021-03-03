import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pc_football/components/JoinForm.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinWidget extends StatefulWidget {
  @override
  _JoinWidgetState createState() => _JoinWidgetState();
}

class _JoinWidgetState extends State<JoinWidget> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference pfc = FirebaseFirestore.instance.collection('pfc');
  bool existingUser = true;

  checkExistingUser()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString('username') ?? "";
    if(username.isEmpty){
      setState(() {
        existingUser = false;
      });
    }
  }

  @override
  void initState() {
    checkExistingUser();
    super.initState();
  }


  Future<List<QueryDocumentSnapshot>> _getLatestEvent() async {
    var events = (await pfc.get()).docs;
    TextEditingController _controller = TextEditingController();
    var nextEvents = events.where((element) {
      Timestamp t = element['time'];
      var date = t.toDate();
      var now = new DateTime.now();
      return date.isAfter(now);
    }).toList();

    nextEvents.sort((a, b) {
      Timestamp t1 = a['time'];
      Timestamp t2 = b['time'];

      var d1 = t1.toDate();
      var d2 = t2.toDate();

      return d1.isBefore(d2) ? -1 : 1;
    });

    return nextEvents;
  }



  Future<void> saveUserNameLocally(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> saveUserToFirestore(String username) async{
    var events = await _getLatestEvent();
    var eventId = events.first.id;

    await pfc.doc(eventId).update({
      "who_is_coming":FieldValue.arrayUnion(
          [username]
      ),
    });
  }

  _showJoinFormDialog() async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return JoinForm();
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLatestEvent(),
      builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>>snapshot){

        if(snapshot.hasError){
          return Center(
            child: Text("Oops, something went wrong. Try again later."),
          );
        }

        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.data.isEmpty){
            return Center(
              child: Text("Sorry, no events. Check back later."),
            );
          } else {

            var data = snapshot.data.first.data();
            Timestamp time = data["time"];
            var eventTitle = DateFormat("EEEE, d. MMMM yyyy HH:mm").format(time.toDate());

            return Container(
              child: Center(
                child: SizedBox(
                  height: 500,
                  width: 500,
                  child: Card(
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        print('Card tapped.');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.arrow_drop_down_circle),
                            title: Text("Next Event: $eventTitle"),
                          ),
                          Image(
                            image: AssetImage("./plumstead_common.jpg"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Nice green grass for footie and scoring goals.',
                              style: TextStyle(color: Colors.black.withOpacity(0.6)),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                              TextButton(

                                onPressed: existingUser ? null : () async {
                                  var value = await _showJoinFormDialog();

                                  var n1 = ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('Processing Data $value')));
                                  await saveUserNameLocally(value);
                                  await saveUserToFirestore(value);

                                  n1.close();

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text('You\'re in!')));

                                },
                                child: const Text('JOIN',style: TextStyle(
                                  color: const Color(0xFF6200EE),

                                ),),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

        }

        return Center(
          child: CircularProgressIndicator(),
        );


      }
    );
  }
}
