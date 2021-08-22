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
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
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

  final Function(DocumentSnapshot race) onSelect;

  RacePicker({Key key, this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('races').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          // Sort races after date
          var docs = snapshot.data.docs;
          docs.sort((a, b) {
            var aDate = a.data()["dateTime"].toDate();
            var bDate = b.data()["dateTime"].toDate();
            return -aDate.compareTo(bDate);
          });

          // Build ListView
          return ListView(
            children: docs
                .map((snapshot) => _buildListItem(context, snapshot))
                .toList(),
          );
        });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    var race = snapshot.data();
    DateTime date = race["dateTime"].toDate();

    String dateString = "${date.day}/${date.month} - " +
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
          title: Text(dateString),
          trailing: Text("${race["0"].length} / ${race["1"].length}"),
          onTap: () => onSelect(snapshot),
        ),
      ),
    );
  }
}
