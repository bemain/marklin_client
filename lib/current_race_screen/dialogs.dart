import 'package:flutter/material.dart';

/// Popup dialog for selecting whether to save or discard the current race.
/// Also allows you to select the number of cars racing.
class NewRaceDialog extends StatefulWidget {
  final Function()? onCancel;
  final Function(int nCars)? onDiscard;
  final Function(int nCars)? onSave;

  const NewRaceDialog({Key? key, this.onCancel, this.onDiscard, this.onSave})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => NewRaceDialogState();
}

class NewRaceDialogState extends State<NewRaceDialog> {
  int nCars = 2;
  bool _discardDialog = false;

  @override
  Widget build(BuildContext context) {
    return (!_discardDialog)
        ? AlertDialog(
            title: const Text("Create new race"),
            content: Wrap(
              children: [
                const Text(
                    "You are about to start a new race.\nPlease choose the number of cars for the new race:"),
                Slider(
                  min: 1,
                  max: 4,
                  divisions: 3,
                  label: "$nCars",
                  value: nCars.toDouble(),
                  onChanged: (value) => setState(() {
                    nCars = value.toInt();
                  }),
                ),
                const Text("Save the current race to the database?"),
              ],
            ),
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
                  widget.onSave?.call(nCars);
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
                  widget.onDiscard?.call(nCars);
                },
              ),
            ],
          );
  }
}
