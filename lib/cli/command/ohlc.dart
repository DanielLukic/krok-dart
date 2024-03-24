part of '../cli.dart';

class OhlcCommand extends Command with _AutoCache, _Tabular {
  @override
  String get name => "ohlc";

  @override
  String get description => "Retrieve ohlc data. Alias: o";

  @override
  List<String> get aliases => const ["o"];

  OhlcCommand() {
    initTabularOptions(argParser);
    argParser.addOption(
      "pair",
      abbr: "p",
      help: "The pair to get ohlc data for.",
      mandatory: true,
      valueHelp: "XBTUSD",
      callback: (it) => pair = it!,
    );
    argParser.addOption(
      "interval",
      abbr: "i",
      help: "Interval in minutes.",
      allowed: OhlcInterval.values.map((e) => e.minutes.toString()),
      valueHelp: "minutes",
      defaultsTo: interval.name,
      callback: (it) => interval = it.asOhlcInterval(defaultValue: interval),
    );
    argParser.addOption(
      "since",
      abbr: "s",
      help: "Either: Timestamp in UNIX format (UTC).\n"
          "Or: RFC3339 datetime.\n"
          "Or: Relative time in seconds/minutes/hours/days, using s/m/h/d suffix.\n"
          "A maximum of 720 values is returned.",
      valueHelp: "timestamp|datetime|relative",
      callback: (it) => _parseSince(it),
    );
  }

  _parseSince(String? it) {
    if (it == null) return null;
    if (RegExp(r"^\d+$").hasMatch(it)) {
      since = DateTime.fromMillisecondsSinceEpoch(int.parse(it), isUtc: true);
    } else if (RegExp(r"^\d+[smhd]$").hasMatch(it)) {
      since = it.toRelativeDateTime();
    } else {
      since = DateTime.parse(it);
    }
  }

  late String pair;
  OhlcInterval interval = OhlcInterval.oneMinute;
  DateTime? since;

  @override
  Future<void> run() async {
    final api = KrakenApi.fromFile(_keyFilePath);
    try {
      final Result result = await api.retrieve(KrakenRequest.ohlc(
        pair: pair,
        interval: interval,
        since: since,
      ));
      final raw = result.entries.first.value as List<dynamic>;
      final needsRaw = format == OutputFormat.raw || format == OutputFormat.json;
      if (needsRaw) {
        processResultList(raw.reverse());
      } else {
        final data = raw.castEach<List<dynamic>>();
        final timestamped = data.map_(firstColumnToDateTime);
        processResultList(timestamped.reverse());
      }
    } finally {
      api.close();
    }
  }

  List<dynamic> firstColumnToDateTime(List<dynamic> e) => e.modify<int>(0, (it) => it.toKrakenDateTime());
}
