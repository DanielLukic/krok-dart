part of '../cli.dart';

class Assets extends Command with AutoCache, ApiCall, Tabular {
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
  autoClose(KrakenApi api) async {
    final Result result = await maybeCached(
      cacheName: "assets",
      cacheIf: assets.isNullOrEmpty,
      retrieve: () => api.retrieve(KrakenRequest.assets(assets: assets)),
    );
    processResultMapOfMaps(result);
  }
}
