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
class RaceSelector extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Function(DocumentSnapshot race) onSelect;

  RaceSelector({Key key, this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('races').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return ListView(
            children: snapshot.data.docs
                .map((snapshot) => _buildListItem(context, snapshot))
                .toList(),
          );
        });
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    var race = snapshot.data();

    return Padding(
      key: ValueKey(race["dateTime"]),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(race["dateTime"].toDate().toString()),
          trailing: Text("${race["0"].length} / ${race["1"].length}"),
          onTap: () => onSelect(snapshot),
        ),
      ),
    );
  }
}
