part of 'cli.dart';

class _Assets extends Command with _AutoCache, _Tabular {
  @override
  String get name => "assets";

  @override
  String get description => "Retrieve asset information. Alias: a";

  @override
  List<String> get aliases => const ["a"];

  _Assets() {
    initTabularOptions(argParser);
    argParser.addMultiOption(
      "asset",
      abbr: "a",
      help: "One ore more assets to get info for. Or all assets if empty.",
      valueHelp: "XBT,ETH",
      callback: (it) => assets = it.isNullOrEmpty ? null : it,
    );
  }

  List<String>? assets;

  @override
  Future<void> run() async {
    final api = KrakenApi.fromFile(_keyFilePath);
    try {
      final Result result = await maybeCached(
        cacheName: "assets",
        cacheIf: assets.isNullOrEmpty,
        retrieve: () => api.retrieve(KrakenRequest.assets(assets: assets)),
      );
      processTabularData(result);
    } finally {
      api.close();
    }
  }
}

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
