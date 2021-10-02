import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({Key? key, required this.icon, required this.text})
      : super(key: key);

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

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return InfoScreen(
      icon: Icon(Icons.error),
      text: text,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return InfoScreen(
      icon: CircularProgressIndicator(),
      text: text,
    );
  }
}

class QuitDialog extends StatelessWidget {
  const QuitDialog({Key? key, this.onQuit}) : super(key: key);

  final Function? onQuit;

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
            onQuit?.call();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class TextTile extends StatelessWidget {
  const TextTile({Key? key, required this.title, this.text, this.onTap})
      : super(key: key);

  final String title;
  final String? text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
        child: _buildTitle(context),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (title.length > 0 && text != null)
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            text!,
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    else
      return Text(
        text ?? title,
        overflow: TextOverflow.ellipsis,
      );
  }
}

/// Widget for selecting a race from the database.
///
/// Executes [onSelect] whenever user selects a race.
///
/// Excludes the 'current' race by default.
/// This can be changed by setting the [ignoreCurrentRace] option.
class RacePicker extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  RacePicker({Key? key, this.onSelect, this.includeCurrentRace = false})
      : super(key: key);

  final Function(DocumentSnapshot raceDoc)? onSelect;
  final bool includeCurrentRace;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('races').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          var docs = snapshot.data!.docs;

          if (!includeCurrentRace)
            // Remove current race
            docs.remove(docs.firstWhere((e) => e.id == "current"));

          // Sort races after date
          docs.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            var aDate = aData["date"].toDate();
            var bDate = bData["date"].toDate();
            return -aDate.compareTo(bDate);
          });

          // Build body
          return ListView(
            children: docs
                .map((snapshot) => RaceCard(
                      raceDoc: snapshot,
                      onTap: () => onSelect?.call(snapshot),
                    ))
                .toList(),
          );
        });
  }
}

class RaceCard extends StatelessWidget {
  const RaceCard({required this.raceDoc, this.onTap});

  final DocumentSnapshot raceDoc;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> race = raceDoc.data() as Map<String, dynamic>;
    DateTime date = race["date"].toDate();
    String titleString = "";

    if (raceDoc.id == "current")
      titleString = "Current";
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
            onTap?.call();
          },
        ),
      ),
    );
  }
}

class TimerText extends StatefulWidget {
  final Stopwatch stopwatch;
  final int decimalPlaces;

  TimerText({required this.stopwatch, this.decimalPlaces = 1});

  @override
  State<TimerText> createState() => TimerTextState();
}

class TimerTextState extends State<TimerText> {
  Timer? timer;

  @override
  void initState() {
    timer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ pow(10, widget.decimalPlaces)),
      callback,
    );
    super.initState();
  }

  void callback(Timer t) {
    if (widget.stopwatch.isRunning) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double seconds = widget.stopwatch.elapsedMilliseconds / 1000;
    return Text("${seconds.toStringAsFixed(widget.decimalPlaces)}s");
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
