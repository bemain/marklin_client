import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/speed_entry.dart';

class Lap {
  /// When this lap was started.
  DateTime date;

  /// The time this lap took to complete, in seconds.
  Duration lapTime;

  int lapNumber;

  /// How the speed has varied during [this] lap
  /// The key is the time since [this] lap was started,
  /// and the value is the speed at that time.
  List<SpeedEntry> speedHistory;

  Lap({
    required this.date,
    required this.lapTime,
    required this.lapNumber,
    List<SpeedEntry>? speedHistory,
  }) : speedHistory = speedHistory ?? [];

  Lap.fromJson(Map<String, dynamic> json)
      : this(
          date: json["date"].toDate(),
          lapTime: Duration(milliseconds: (json["lapTime"] * 1000).toInt()),
          lapNumber: json["lapNumber"],
          speedHistory: Map<String, dynamic>.of(json["speedHistory"] ?? {})
              .entries
              .map((e) => SpeedEntry.fromMapEntry(e))
              .toList(),
        );

  Map<String, dynamic> toJson() => {
        "date": Timestamp.fromDate(date),
        "lapTime": lapTime.inMilliseconds / 1000,
        "lapNumber": lapNumber,
        "speedHistory": Map.fromEntries(
          speedHistory.map((entry) => entry.toMapEntry()),
        ),
      };
}
