import 'package:cloud_firestore/cloud_firestore.dart';

class OldRace {
  /// When this race was started.
  Timestamp date;

  /// Whether this race is running or not.
  bool running;

  /// The number of cars in this race.
  int nCars;

  OldRace({
    required this.date,
    required this.running,
    required this.nCars,
  });

  OldRace.fromJson(Map<String, dynamic> json)
      : this(
          date: json["date"],
          running: json["running"],
          nCars: json["nCars"],
        );

  Map<String, dynamic> toJson() => {
        "date": date,
        "running": running,
        "nCars": nCars,
      };
}
