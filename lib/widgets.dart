import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.icon, required this.text});

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
  const ErrorScreen({super.key, required this.text});

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
  const LoadingScreen({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return InfoScreen(
      icon: const CircularProgressIndicator(),
      text: text,
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.text,
    this.onConfirm,
  });

  final String text;
  final Function? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Continue?"),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Continue"),
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class TextTile extends StatelessWidget {
  const TextTile({super.key, required this.title, this.text, this.onTap});

  final String title;
  final String? text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: TextButton(
        onPressed: onTap,
        child: _buildTitle(context),
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
            style: Theme.of(context).textTheme.bodySmall,
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

  const TimerText({super.key, required this.stopwatch, this.decimalPlaces = 1});

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
