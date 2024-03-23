part of '../cli.dart';

class _AssetPairs extends Command with _AutoCache, _Tabular {
  @override
  String get name => "assetpairs";

  @override
  String get description => "Retrieve asset pairs. Alias: ap";

  @override
  List<String> get aliases => const ["ap"];

  _AssetPairs() {
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
        cacheName: "assetpairs",
        cacheIf: pairs.isNullOrEmpty,
        retrieve: () => api.retrieve(KrakenRequest.assetPairs(pairs: pairs)),
      );
      processTabularData(result);
    } finally {
      api.close();
    }
  }
}
