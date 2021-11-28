import 'package:cloud_firestore/cloud_firestore.dart';

class Lap {
  /// When this lap was started.
  Timestamp date;

  /// The time this lap took to complete, in seconds.
  double lapTime;

  int lapNumber;

  Lap({
    required this.date,
    required this.lapTime,
    required this.lapNumber,
  });

  Lap.fromJson(Map<String, dynamic> json)
      : this(
          date: json["date"],
          lapTime: json["lapTime"].toDouble(),
          lapNumber: json["lapNumber"],
        );

  Map<String, dynamic> toJson() => {
        "date": date,
        "lapTime": lapTime,
        "lapNumber": lapNumber,
      };
}
