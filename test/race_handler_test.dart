import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marklin_bluetooth/race_handler.dart';

void main() {
  test("RaceHandler add lap", () async {
    await Firebase.initializeApp();
    final RaceHandler handler = RaceHandler();
    await handler.addLap(0, 13.37);
  });
}
