import 'package:flutter/material.dart';

class NewRaceDialog extends StatefulWidget {
  /// Popup dialog for selecting whether to save or discard the current race.
  /// Also allows you to select the number of cars racing.
  const NewRaceDialog({super.key, this.onCancel, this.onDiscard, this.onSave});

  final Function()? onCancel;
  final Function(int nCars)? onDiscard;
  final Function(int nCars)? onSave;

  @override
  State<StatefulWidget> createState() => NewRaceDialogState();
}

class NewRaceDialogState extends State<NewRaceDialog> {
  int nCars = 2;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            Navigator.of(context).pop();
            widget.onDiscard?.call(nCars);
          },
        ),
        TextButton(
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).primaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSave?.call(nCars);
          },
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
