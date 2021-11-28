import 'dart:async';
import 'dart:math';

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
      icon: const Icon(Icons.error),
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
      icon: const CircularProgressIndicator(),
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
      title: const Text("Quit?"),
      content: const Text("Are you sure you want to quit?"),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Quit"),
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
    if (title.isNotEmpty && text != null) {
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
    } else {
      return Text(
        text ?? title,
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

class TimerText extends StatefulWidget {
  final Stopwatch stopwatch;
  final int decimalPlaces;

  const TimerText({Key? key, required this.stopwatch, this.decimalPlaces = 1})
      : super(key: key);

  @override
  State<TimerText> createState() => TimerTextState();
}

class TimerTextState extends State<TimerText> {
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(
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
    _timer?.cancel();
    super.dispose();
  }
}

/// Returns a builder that returns [activeBuilder] when future is active or done,
/// and error or loading screens as applicable otherwise.
Widget Function(BuildContext, AsyncSnapshot<T>) niceAsyncBuilder<T>({
  required Function(BuildContext, AsyncSnapshot<T>) activeBuilder,
  String? loadingText,
  String? errorText,
}) {
  return (BuildContext c, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasError) {
      return ErrorScreen(text: errorText ?? "Error: ${snapshot.error}");
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingScreen(text: loadingText ?? "Loading...");
    }

    return activeBuilder(c, snapshot);
  };
}
