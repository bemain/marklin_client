String dateString(
  DateTime date, {
  bool includeSecond = false,
  String separator = " | ",
}) {
  String day = "${date.day}/${date.month}-${date.year}";
  String hour = ((date.hour < 10) ? "0" : "") + "${date.hour}";
  String time = "$hour:${date.minute}";

  if (includeSecond) {
    time += ":${date.second}";
  }

  return "$time $separator $day";
}
