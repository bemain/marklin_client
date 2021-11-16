import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/race_handler.dart';

import 'package:marklin_bluetooth/widgets.dart';

/// Screen for watching and restarting the current race.
class LapCounterScreen extends StatefulWidget {
  const LapCounterScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LapCounterScreenState();
}

class LapCounterScreenState extends State<LapCounterScreen> {
  RaceHandler raceHandler = RaceHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lap Counter"),
        actions: [
          IconButton(
              onPressed: () => showNewDialog(context),
              icon: const Icon(Icons.add, color: Colors.white)),
        ],
      ),
      body: FutureBuilder<int>(
        future: raceHandler.nCars,
        builder: niceAsyncBuilder(
          loadingText: "Determining number of cars...",
          activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
            return Row(
              children: List.generate(
                snapshot.data! * 2 - 1,
                (i) => i.isEven
                    ? Expanded(child: lapViewer(i ~/ 2))
                    : const VerticalDivider(thickness: 1.0),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget lapViewer(int carID) {
    return StreamBuilder<QuerySnapshot>(
      stream: raceHandler
          .carCollection(carID)
          .orderBy("date", descending: true)
          .snapshots(),
      builder: niceAsyncBuilder(
        loadingText: "Getting lap times...",
        activeBuilder: (BuildContext c, AsyncSnapshot snapshot) {
          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          return ListView(
            children: docs
                .map(
                  (doc) => TextTile(
                    title: "${doc.get("lapNumber")}  |  ${doc.get("lapTime")}s",
                    text: (doc.get("date") as Timestamp).toDate().toString(),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  void showNewDialog(BuildContext context) async {
    bool ret = false;
    await showDialog(
      context: context,
      builder: (c) => SaveRaceDialog(
        onCancel: () {
          ret = true;
        },
        onSave: () {
          raceHandler.saveCurrentRace().then((_) => setState(() {}));
        },
        onDiscard: () {
          raceHandler.clearCurrentRace();
        },
      ),
    );
    if (ret) return;

    await showDialog(
      context: context,
      builder: (c) => NewRaceDialog(
        onNew: (nCars) {
          raceHandler.nCars = nCars;
        },
      ),
    );

    setState(() {});
  }
}

/// Popup dialog for selecting whether to save or discard the current race
class SaveRaceDialog extends StatefulWidget {
  final Function? onCancel;
  final Function? onDiscard;
  final Function? onSave;

  const SaveRaceDialog({Key? key, this.onCancel, this.onDiscard, this.onSave})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SaveRaceDialogState();
}

class SaveRaceDialogState extends State<SaveRaceDialog> {
  bool _discardDialog = false;

  @override
  Widget build(BuildContext context) {
    return (!_discardDialog)
        ? AlertDialog(
            title: const Text("Save old race"),
            content: const Text(
                "You are about to start a new race.\nSave the current race to the database?"),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onCancel?.call();
                },
              ),
              TextButton(
                child: const Text("Discard"),
                onPressed: () {
                  setState(() {
                    _discardDialog = true;
                  });
                },
              ),
              TextButton(
                child:
                    const Text("Save", style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onSave?.call();
                },
              ),
            ],
          )
        : AlertDialog(
            title: const Text("Discard race?"),
            content: const Text(
                "You are about to restart the race and clear all laps. \nThis action can't be undone."),
            actions: [
              TextButton(
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.white)),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  setState(() {
                    _discardDialog = false;
                  });
                },
              ),
              TextButton(
                child: const Text("Discard"),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDiscard?.call();
                },
              ),
            ],
          );
  }
}

/// Popup dialog for starting a new race.
class NewRaceDialog extends StatefulWidget {
  const NewRaceDialog({Key? key, this.onNew}) : super(key: key);

  final Function(int nCars)? onNew;

  @override
  State<StatefulWidget> createState() => NewRaceDialogState();
}

class NewRaceDialogState extends State<NewRaceDialog> {
  int nCars = 2;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Start new race"),
      content: Wrap(children: [
        Slider(
          min: 1,
          max: 4,
          divisions: 3,
          label: "$nCars",
          value: nCars.toDouble(),
          onChanged: (value) => setState(() {
            nCars = value.toInt();
          }),
        )
      ]),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Start", style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onNew?.call(nCars);
          },
        ),
      ],
    );
  }
}
