/// Kraken API uses a timestamp (called "tm" or "time" in the API documentation) that is a double
/// representing seconds since the Unix epoch. This class helps working with those timestamps.
/// Especially when specifying relative dates/times like "1h" or "15m".
///
/// Additionally for orders, time can be specified via short form "+<seconds>". In this case the
/// translation into timestamp/datetime is done inside the exchange. Therefore, a dedicated
/// [seconds] field is used.
///
/// This is somewhat experimental for now... ^^
class KrakenTime {
  /// Absolute datetime as double of seconds since epoch.
  /// "tm" is the suffix used by the Kraken API for timestamps. Otherwise, "time" is used. Just fyi.
  double? tm;

  /// In case of time specified via short form ("+<seconds>"), this holds the seconds.
  int? seconds;

  /// Turn some date/time/duration string into a Kraken API "tm" value. This supports unix
  /// timestamp, RFC3339/ISO8601 datetime, and relative times like "1h" or "15m".
  ///
  /// If [allowShortForm] is 'true', the input can use the "+<seconds>" short form, to have the
  /// relative time be evaluate on the exchange instead of here directly.
  ///
  /// Setting the [since] flag to `false` changes relative times to be added to now. They are
  /// subtracted from now (aka "since") if [since] is `true`.
  KrakenTime.fromString(String? it, {required bool since, required bool allowShortForm}) {
    final (tm, seconds) = it.toKrakenTm(since, allowShortForm);
    this.tm = tm;
    this.seconds = seconds;
  }

  String? toApiString() {
    if (tm != null) return "$tm";
    if (seconds != null) return "+$seconds";
    return null;
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

  (double?, int?) toKrakenTm(bool since, bool allowShortForm) {
    final it = this;
    if (it == null) return (null, null);
    final DateTime result;
    if (RegExp(r"^\+\d+$").hasMatch(it)) {
      // short form case "+<seconds>" returns the seconds directly as 2nd value:
      return (null, int.parse(it.substring(1)));
      // otherwise create a DateTime from the input and return the double variant below...
    } else if (RegExp(r"^\d+$").hasMatch(it)) {
      result = DateTime.fromMillisecondsSinceEpoch(int.parse(it), isUtc: true);
    } else if (RegExp(r"^\d+[smhd]$").hasMatch(it)) {
      result = it.toDateTime(since)!;
    } else {
      result = DateTime.parse(it);
    }
    return (result.millisecondsSinceEpoch / 1000.0, null);
  }
}
