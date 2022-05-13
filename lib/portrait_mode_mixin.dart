import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Locks rotation to portrait mode on initState() and unlocks it on dispose().
mixin PortraitModeMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    // Lock rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    // Unlock rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
