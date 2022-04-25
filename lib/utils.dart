import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marklin_bluetooth/firebase/race.dart';

String dateString(
  DateTime date, {
  bool includeSecond = false,
  String separator = " | ",
}) {
  String day = "${date.day}/${date.month}-${date.year}";
  String hour = "${(date.hour < 10) ? "0" : ""}${date.hour}";
  String time = "$hour:${date.minute}";

  if (includeSecond) {
    time += ":${date.second}";
  }

  return "$time $separator $day";
}

String raceString(DocumentSnapshot<Race> raceSnap) {
  Race race = raceSnap.data()!;
  DateTime date = race.date.toDate();
  return (raceSnap.id == "current") ? "Current" : dateString(date);
}
