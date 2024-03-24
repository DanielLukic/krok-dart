part of '../cli.dart';

class OpenOrders extends Command with AutoCache, ApiCall, Tabular {
  @override
  String get name => "openorders";

  @override
  String get description => "Retrieve open orders. Alias: $aliases";

  @override
  List<String> get aliases => const ["oo", "open"];

  OpenOrders() {
    initTabularOptions(argParser);
    argParser.addFlag(
      "trades",
      abbr: "t",
      defaultsTo: false,
      callback: (it) => showTrades = it,
    );
  }

  bool showTrades = false;

  @override
  autoClose(KrakenApi api) async {
    final Result result = (await api.retrieve(KrakenRequest.openOrders(
      trades: showTrades,
    )))["open"];
    processResultMapOfMaps(result, keyColumn: "txid");
  }

  @override
  TabularData postProcessRows(TabularData rows) {
    final modified = modifyDateTimeColumns(rows);
    return super.postProcessRows(modified);
  }
}
