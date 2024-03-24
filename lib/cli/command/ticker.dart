part of '../cli.dart';

class Ticker extends Command with AutoCache, Pairs, ApiCall, Tabular {
  @override
  String get name => "ticker";

  @override
  String get description => "Retrieve ticker data. Alias: t";

  @override
  List<String> get aliases => const ["t"];

  Ticker() {
    initTabularOptions(argParser);
    initPairsOption(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await maybeCached(
      cacheName: "ticker",
      cacheIf: pairs.isNullOrEmpty,
      retrieve: () => api.retrieve(KrakenRequest.ticker(pairs: pairs)),
    );
    processResultMapOfMaps(result);
  }
}
