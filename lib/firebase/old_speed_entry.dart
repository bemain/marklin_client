class OldSpeedEntry {
  const OldSpeedEntry(this.time, this.speed);

  /// The duration between the start of the race and when this entry was recorded.
  final Duration time;

  /// The speed recorded.
  final double speed;

  OldSpeedEntry.fromMapEntry(MapEntry<String, dynamic> entry)
      : this(
          Duration(milliseconds: int.parse(entry.key)),
          entry.value,
        );

  MapEntry<String, dynamic> toMapEntry() {
    return MapEntry<String, dynamic>("${time.inMilliseconds}", speed);
  }
}
