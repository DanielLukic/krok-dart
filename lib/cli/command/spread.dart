part of '../cli.dart';

class Spread extends Command with AutoCache, Pair, ApiCall, Since, Tabular {
  @override
  String get name => "spread";

  @override
  String get description => "Retrieve spread data. Alias: $aliases";

  @override
  List<String> get aliases => const ["sp"];

  Spread() {
    initTabularOptions(argParser);
    initSinceOption(argParser);
    initPairOption(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.spread(
      pair: pair,
      since: since,
    ));
    final raw = result.entries.first.value as List<dynamic>;
    final needsRaw = format == OutputFormat.raw || format == OutputFormat.json;
    if (needsRaw) {
      processResultList(raw.reverse());
    } else {
      final data = raw.castEach<List<dynamic>>();
      final header = ["time", "bid", "ask"];
      processResultList(data.reverse(), header, columns);
    }
  }
}
