part of '../cli.dart';

class SpreadCommand extends Command with _AutoCache, _Pair, _Since, _Tabular {
  @override
  String get name => "spread";

  @override
  String get description => "Retrieve spread data. Alias: sp";

  @override
  List<String> get aliases => const ["sp"];

  SpreadCommand() {
    initTabularOptions(argParser);
    initSinceOption(argParser);
    initPairOption(argParser);
  }

  @override
  Future<void> run() async {
    final api = KrakenApi.fromFile(_keyFilePath);
    try {
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
        final timestamped = data.map_(firstColumnToDateTime);
        processResultList(timestamped.reverse());
      }
    } finally {
      api.close();
    }
  }

  List<dynamic> firstColumnToDateTime(List<dynamic> e) => e.modify<int>(0, (it) => it.toKrakenDateTime());
}
