import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key key, this.icon, this.text}) : super(key: key);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[icon, Text(text)]));
  }
}

class QuitDialog extends StatelessWidget {
  const QuitDialog({Key key, this.onQuit}) : super(key: key);

  final Function onQuit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Quit?"),
      content: Text("Are you sure you want to quit?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Quit"),
          onPressed: () {
            onQuit();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

/// Widget for selecting a race from the database.
/// Runs [onSelect] when user has selected a race.
class RacePicker extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Function(DocumentSnapshot doc) onSelect;
  final bool separateTestRace;

  RacePicker({Key key, this.onSelect, this.separateTestRace = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('races').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          var docs = snapshot.data.docs;

          // Sort races after date
          docs.sort((a, b) {
            var aDate = a.data()["dateTime"].toDate();
            var bDate = b.data()["dateTime"].toDate();
            return -aDate.compareTo(bDate);
          });

          // Build body
          if (separateTestRace) {
            // Extract test doc
            var testDoc = docs.firstWhere((e) => e.id == "test");
            docs.remove(testDoc);

            return Column(children: [
              Expanded(child: _buildListView(docs)),
              FlatButton.icon(
                onPressed: () => onSelect(testDoc),
                icon: Icon(Icons.exit_to_app),
                label: Text("Test mode"),
              ),
            ]);
          } else
            return _buildListView(docs);
        });
  }

  Widget _buildListView(List<DocumentSnapshot> docs) {
    return ListView(
      children: docs
          .map((snapshot) => RaceCard(
                raceDoc: snapshot,
                onTap: () => onSelect(snapshot),
              ))
          .toList(),
    );
  }
}

class RaceCard extends StatelessWidget {
  final DocumentSnapshot raceDoc;
  final Function onTap;

  const RaceCard({@required this.raceDoc, this.onTap});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> race = raceDoc.data();
    DateTime date = race["dateTime"].toDate();
    String titleString = "";

    if (raceDoc.id == "test")
      titleString = "Test mode";
    else
      titleString = "${date.day}/${date.month} - " +
          ((date.hour < 10) ? "0" : "") +
          "${date.hour}:" +
          ((date.minute < 10) ? "0" : "") +
          "${date.minute}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(titleString),
          trailing: Text("${race["0"].length} / ${race["1"].length}"),
          onTap: () {
            if (onTap != null) onTap();
          },
        ),
      ),
    );
  }
}
