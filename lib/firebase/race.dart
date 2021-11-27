import 'package:cloud_firestore/cloud_firestore.dart';

class Race {
  Race({
    required this.date,
    required this.running,
    required this.nCars,
  });

  Race.fromJson(Map<String, dynamic> json)
      : this(
          date: json["date"],
          running: json["running"],
          nCars: json["nCars"],
        );

  Timestamp date;
  bool running;
  int nCars;

  Map<String, dynamic> toJson() => {
        "date": date,
        "running": running,
        "nCars": nCars,
      };
}
