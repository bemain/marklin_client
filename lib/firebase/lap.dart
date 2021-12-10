import 'package:cloud_firestore/cloud_firestore.dart';

class Lap {
  /// When this lap was started.
  final Timestamp date;

  /// The time this lap took to complete, in seconds.
  final double lapTime;

  final int lapNumber;

  /// How the speed has varied during [this] lap
  /// The key is the time since [this] lap was started,
  /// and the value is the speed at that time.
  final Map<int, double> speedHistory;

  const Lap({
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
          speedHistory: Map.from(json["speedHistory"] ?? {})
              .map((k, v) => MapEntry<int, double>(int.parse(k), v)),
        );

  /// Create a copy of [other], but with some paramaters set (optional).
  Lap.from(
    Lap other, {
    Timestamp? date,
    double? lapTime,
    int? lapNumber,
    Map<int, double>? speedHistory,
  }) : this(
          date: date ?? other.date,
          lapTime: lapTime ?? other.lapTime,
          lapNumber: lapNumber ?? other.lapNumber,
          speedHistory: speedHistory ?? other.speedHistory,
        );

  Map<String, dynamic> toJson() => {
        "date": date,
        "lapTime": lapTime,
        "lapNumber": lapNumber,
        "speedHistory": Map.from(speedHistory)
            .map((k, v) => MapEntry<String, dynamic>("$k", v)),
      };
}
