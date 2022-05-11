class SpeedEntry {
  const SpeedEntry(this.time, this.speed);

  /// The duration between the start of the race and when this entry was recorded.
  final Duration time;

  /// The speed recorded.
  final double speed;

  SpeedEntry.fromMapEntry(MapEntry<String, dynamic> entry)
      : this(
          Duration(milliseconds: int.parse(entry.key)),
          entry.value,
        );

  MapEntry<String, dynamic> toMapEntry() {
    return MapEntry<String, dynamic>("${time.inMilliseconds}", speed);
  }
}
