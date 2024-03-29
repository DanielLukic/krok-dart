part of '../cli.dart';

class Cancel extends Command with ApiCall, Tabular {
  @override
  String get name => "cancel";

  @override
  String get description => "Cancel order(s).\n\n"
      "\$ krok cancel all\n"
      "\$ krok cancel txid\n"
      "\$ krok cancel txid,txid ...\n"
      "\$ krok cancel txid txid ...";

  @override
  String get category => "dsl";

  Cancel() {
    initTabularOptions(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result;

    var args = argResults?.arguments ?? [];
    args = args.join(",").replaceAll(RegExp(r"[\s,]+"), ",").split(",");

    switch (args) {
      case []:
        printUsage();
        return;

      case ["all"]:
        result = await api.retrieve(KrakenRequest.cancelAll());

      case [...var txids] when txids.every(isTxid):
        if (txids.length == 1) {
          result = await api.retrieve(KrakenRequest.cancelOrder(txid: txids.single));
        } else {
          result = await api.retrieve(KrakenRequest.cancelBatch(txids: txids));
        }

      case [...var txids]:
        final bad = txids.where(isBadTxid);
        throw UsageException("Bad order txid(s): ${bad.join(",")}", usage);
    }

    final count = result["count"]?.toString() ?? "";
    final pending = result["pending"]?.toString() ?? "";
    var data = [
      ["count", "pending"],
      [count, pending]
    ];
    dumpTable(data, headerDivider: true);
  }

  bool isBadTxid(it) => !isTxid(it);

  bool isTxid(it) => RegExp(r"^\w{6}-\w{5}-\w{6}$").hasMatch(it);
}
