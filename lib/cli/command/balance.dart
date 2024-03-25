part of '../cli.dart';

class Balance extends Command with ApiCall, Tabular {
  @override
  String get name => "balance";

  @override
  String get description => "Retrieve account balance data. Alias: $aliases";

  @override
  List<String> get aliases => const ["b"];

  Balance() {
    initTabularOptions(argParser);
    argParser.addFlag(
      "small",
      abbr: "s",
      help: "Show small balances.",
      defaultsTo: false,
      callback: (it) => small = it,
    );
  }

  bool small = false;

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.balance());
    final filtered = result.where((p0, p1) => small || double.parse(p1) >= 0.000001);
    final data = filtered.asVerticalTableData(["pair", "volume"]);
    processResultList(data);
  }
}
