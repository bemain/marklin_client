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
