import 'package:cloud_firestore/cloud_firestore.dart';

class Lap {
  Lap({
    required this.date,
    required this.lapTime,
    required this.lapNumber,
  });

  Timestamp date;
  double lapTime;
  int lapNumber;

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
