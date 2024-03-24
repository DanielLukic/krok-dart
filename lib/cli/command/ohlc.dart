part of '../cli.dart';

class OhlcCommand extends Command with _AutoCache, _Since, _Tabular {
  @override
  String get name => "ohlc";

  @override
  String get description => "Retrieve ohlc data. Alias: o";

  @override
  List<String> get aliases => const ["o"];

  OhlcCommand() {
    initTabularOptions(argParser);
    initSinceOption(argParser);
    argParser.addOption(
      "pair",
      abbr: "p",
      help: "The pair to get data for.",
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
  }

  late String pair;
  OhlcInterval interval = OhlcInterval.oneMinute;

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
