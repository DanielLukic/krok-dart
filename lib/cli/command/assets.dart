part of '../cli.dart';

class Assets extends Command with _AutoCache, _Tabular {
  @override
  String get name => "assets";

  @override
  String get description => "Retrieve asset information. Alias: a";

  @override
  List<String> get aliases => const ["a"];

  Assets() {
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
