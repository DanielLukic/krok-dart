part of '../cli.dart';

class Ohlc extends Command with Pair, ApiCall, Since, Tabular {
  @override
  String get name => "ohlc";

  @override
  String get description => "Retrieve ohlc data. Alias: $aliases";

  @override
  List<String> get aliases => const ["o"];

  Ohlc() {
    initTabularOptions(argParser);
    initSinceOption(argParser);
    initPairOption(argParser);
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

  OhlcInterval interval = OhlcInterval.oneMinute;

  @override
  autoClose(KrakenApi api) async {
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
      final header = ["time", "open", "high", "low", "close", "vwap", "volume", "count"];
      processResultList(data.reverse(), header, columns);
    }
  }
}
