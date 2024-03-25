part of '../cli.dart';

class TradeVolume extends Command with ApiCall, Pairs, Tabular {
  @override
  String get name => "tradevolume";

  @override
  String get description => "Retrieve trade volume data. Alias: $aliases";

  @override
  List<String> get aliases => const ["tv", "tvol"];

  TradeVolume() {
    initPairsOption(argParser);
    initTabularOptions(argParser);
    argParser.addOption(
      "fees",
      abbr: "s",
      help: "Select which data to show.",
      allowed: ["fees", "maker"],
      defaultsTo: fees,
      callback: (it) => fees = it ?? fees,
    );
  }

  String fees = "fees";

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.tradeVolume(
      pairs: pairs ?? List.empty(),
    ));
    if (pairs.isNullOrEmpty) {
      final data = result.asVerticalTableData();
      processResultList(data, ["currency", "volume"]);
    } else {
      final key = fees == "fees" ? fees : "fees_maker";
      processResultMapOfMaps(result[key]);
    }
  }
}
