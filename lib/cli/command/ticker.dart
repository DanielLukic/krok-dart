part of '../cli.dart';

class _TickerCommand extends Command with _AutoCache, _Tabular {
  @override
  String get name => "ticker";

  @override
  String get description => "Retrieve ticker data. Alias: t";

  @override
  List<String> get aliases => const ["t"];

  _TickerCommand() {
    initTabularOptions(argParser);
    argParser.addMultiOption(
      "pair",
      abbr: "p",
      help: "One ore more pairs to get ticker info for. Or all pairs if empty.",
      valueHelp: "XBTUSD,ETHUSD",
      callback: (it) => pairs = it.isNullOrEmpty ? null : it,
    );
  }

  List<String>? pairs;

  @override
  Future<void> run() async {
    final api = KrakenApi.fromFile(_keyFilePath);
    try {
      final Result result = await maybeCached(
        cacheName: "ticker",
        cacheIf: pairs.isNullOrEmpty,
        retrieve: () => api.retrieve(KrakenRequest.ticker(pairs: pairs)),
      );
      processTabularData(result);
    } finally {
      api.close();
    }
  }
}
