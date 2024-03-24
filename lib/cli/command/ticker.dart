part of '../cli.dart';

class TickerCommand extends Command with _AutoCache, _Pairs, _PublicCall, _Tabular {
  @override
  String get name => "ticker";

  @override
  String get description => "Retrieve ticker data. Alias: t";

  @override
  List<String> get aliases => const ["t"];

  TickerCommand() {
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
