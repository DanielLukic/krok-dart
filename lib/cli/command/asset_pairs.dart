part of '../cli.dart';

class AssetPairs extends Command with AutoCache, Pairs, ApiCall, Tabular {
  @override
  String get name => "assetpairs";

  @override
  String get description => "Retrieve asset pairs. Alias: ap";

  @override
  List<String> get aliases => const ["ap"];

  AssetPairs() {
    initTabularOptions(argParser);
    initPairsOption(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await maybeCached(
      cacheName: "assetpairs",
      cacheIf: pairs.isNullOrEmpty,
      retrieve: () => api.retrieve(KrakenRequest.assetPairs(pairs: pairs)),
    );
    processResultMapOfMaps(result);
  }
}
