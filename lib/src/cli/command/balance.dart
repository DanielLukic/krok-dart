part of '../cli.dart';

class Balance extends Command with ApiCall, Tabular {
  @override
  String get name => "balance";

  @override
  String get description => "Retrieve account balance data. Alias: $aliases";

  @override
  List<String> get aliases => const ["b", "bal"];

  Balance() {
    initTabularOptions(argParser);
    argParser.addFlag(
      "small",
      abbr: "s",
      help: "Show small balances.",
      defaultsTo: false,
      callback: (it) => small = it,
    );
    argParser.addFlag(
      "extended",
      abbr: "x",
      help: "Retrieve extended balances.",
      defaultsTo: false,
      callback: (it) => extended = it,
    );
  }

  bool small = false;
  bool extended = false;

  @override
  autoClose(KrakenApi api) async {
    final request =
        extended ? KrakenRequest.balanceEx() : KrakenRequest.balance();
    final Result result = await api.retrieve(request);
    if (extended) {
      final filtered = result
          .where((p0, p1) => small || double.parse(p1['balance']) > 0.00001);

      final rows = filtered.entries
          .map((e) => [e.key, e.value['balance'], e.value['hold_trade']]
              .map((e) => e.toString())
              .toList())
          .toList();

      processResultList(rows, ['asset', 'balance', 'hold_trade']);
    } else {
      final filtered =
          result.where((p0, p1) => small || double.parse(p1) > 0.00001);
      final data = filtered.asVerticalTableData();
      processResultList(data, ["pair", "volume"]);
    }
  }
}
