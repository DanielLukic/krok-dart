/// Kraken API uses a timestamp (called "tm" or "time" in the API documentation) that is a double
/// representing seconds since the Unix epoch. This class helps working with those timestamps.
/// Especially when specifying relative dates/times like "1h" or "15m".
///
/// This is somewhat experimental for now... ^^
///
/// The primary issue is the missing distinction between since/until for relative dates/times. Will
/// have to revisit this at some point. For now the important step would be to have everything
/// related to date/time handling in this one place.
class KrakenTime {
  double? tm; // "tm" is the suffix used by the Kraken API

  KrakenTime.none();

  KrakenTime.now() //
      : tm = DateTime.now().millisecondsSinceEpoch / 1000.0;

  /// Turn some date/time/duration string into a Kraken API "tm" value. This supports unix
  /// timestamp, RFC3339/ISO8601 datetime, and relative times like "1h" or "15m".
  ///
  /// Setting the [since] flag to false changes relative times to be added to now. By default they
  /// are subtracted from now (aka "since").
  KrakenTime.fromString(String? it, {bool since = true}) //
      : tm = it.toKrakenTm(since);

  KrakenTime.fromTimestamp(int unixTimestamp) //
      : tm = unixTimestamp / 1000.0;

  KrakenTime.fromDatetime(DateTime dateTime) //
      : tm = dateTime.millisecondsSinceEpoch / 1000.0;

  KrakenTime.since(Duration duration)
      : tm = DateTime.now().subtract(duration).millisecondsSinceEpoch / 1000.0;

  KrakenTime.duration(Duration duration)
      : tm = DateTime.now().add(duration).millisecondsSinceEpoch / 1000.0;

  KrakenTime.sinceFromString(String it)
      : tm = DateTime.now().subtract(it.toDuration()!).millisecondsSinceEpoch / 1000.0;

  KrakenTime.durationFromString(String it)
      : tm = DateTime.now().add(it.toDuration()!).millisecondsSinceEpoch / 1000.0;

  KrakenTime.fromApi(this.tm);

  DateTime? asDateTime() {
    final it = tm;
    if (it == null) return null;
    return DateTime.fromMillisecondsSinceEpoch((it * 1000).toInt());
  }
}

extension on String? {
  Duration? toDuration() {
    final it = this;
    if (it == null) return null;
    final modifier = it.substring(it.length - 1);
    final value = int.parse(it.substring(0, it.length - 1));
    final duration = switch (modifier) {
      's' => Duration(seconds: value),
      'm' => Duration(minutes: value),
      'h' => Duration(hours: value),
      'd' => Duration(days: value),
      _ => null,
    };
    return duration;
  }

  DateTime? toDateTime(since) {
    final duration = toDuration();
    if (duration == null) return null;
    var now = DateTime.now();
    if (since) {
      return now.subtract(duration);
    } else {
      return now.add(duration);
    }
  }

  double? toKrakenTm(bool since) {
    final it = this;
    if (it == null) return null;
    final DateTime result;
    if (RegExp(r"^\d+$").hasMatch(it)) {
      result = DateTime.fromMillisecondsSinceEpoch(int.parse(it), isUtc: true);
    } else if (RegExp(r"^\d+[smhd]$").hasMatch(it)) {
      result = it.toDateTime(since)!;
    } else {
      result = DateTime.parse(it);
    }
    return result.millisecondsSinceEpoch / 1000.0;
  }
}
