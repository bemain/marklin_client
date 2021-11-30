import 'package:cloud_firestore/cloud_firestore.dart';

class Lap {
  /// When this lap was started.
  Timestamp date;

  /// The time this lap took to complete, in seconds.
  double lapTime;

  int lapNumber;

  /// How the speed has varied during [this] lap
  /// The key is the time since [this] lap was started,
  /// and the value is the speed at that time.
  Map<int, int> speedHistory;

  Lap({
    required this.date,
    required this.lapTime,
    required this.lapNumber,
    this.speedHistory = const {},
  });

  Lap.fromJson(Map<String, dynamic> json)
      : this(
          date: json["date"],
          lapTime: json["lapTime"].toDouble(),
          lapNumber: json["lapNumber"],
          speedHistory: Map.from(json["speed"] ?? {})
              .map((k, v) => MapEntry<int, int>(int.parse(k), v)),
        );

  Map<String, dynamic> toJson() => {
        "date": date,
        "lapTime": lapTime,
        "lapNumber": lapNumber,
        "speedHistory": speedHistory
      };
}
