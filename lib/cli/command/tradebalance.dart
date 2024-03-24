part of '../cli.dart';

class TradeBalance extends Command with ApiCall, Tabular {
  @override
  String get name => "tradebalance";

  @override
  String get description => "Retrieve trade balance data. Alias: tb or tbal";

  @override
  List<String> get aliases => const ["tb", "tbal"];

  TradeBalance() {
    initTabularOptions(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.tradeBalance());
    final data = result.asVerticalTableData(["kind", "volume"]);
    processResultList(data);
  }
}
