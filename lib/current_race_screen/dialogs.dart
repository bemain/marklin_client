import 'package:flutter/material.dart';

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
