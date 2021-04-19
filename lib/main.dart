import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

 main() async{
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
   runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
          accentColor: Colors.orange
        ),
        home: NotesApp()
      )
  );
}

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  List notes = [];
  String input = '';

  createNotes(){
    DocumentReference documentReference =
      FirebaseFirestore.instance.collection("MyNotes").doc(input);
    Map<String, String> notes = {
      "noteTitle": input
    };

    documentReference.set(notes).whenComplete(() => print('$input created'));
  }

  deleteNotes(item){
    DocumentReference documentReference =
      FirebaseFirestore.instance.collection("MyNotes").doc(item);
    documentReference.delete().whenComplete(() => print('deleted'));
  }

  @override
  void initState() {
    super.initState();
    notes.add('Item1');
    notes.add('Item2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  ),
                  title: Text('Add Note'),
                  content: TextField(
                    onChanged: (String value){
                      input = value;
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: (){
                          createNotes();
                          Navigator.of(context).pop();
                        },
                        child: Text('Add'))
                  ],
                );
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
     body: StreamBuilder(
       stream: FirebaseFirestore.instance.collection('MyNotes').snapshots(),
       builder: (context, snapshots){
         return ListView.builder(
           shrinkWrap: true,
           itemCount: snapshots.data.docs.length,
             itemBuilder: (context, index){
             DocumentSnapshot documentSnapshot = snapshots.data.docs[index];
              return Dismissible(
                onDismissed: (direction){
                  deleteNotes(documentSnapshot['noteTitle']);
                },
                  key: Key(documentSnapshot['noteTitle']),
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: ListTile(
                      title: Text(documentSnapshot['noteTitle']),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: (){
                          deleteNotes(documentSnapshot['noteTitle']);
                        },
                      ),
                    ),
                  ));
             });
       },
     ),
    );
  }
}


