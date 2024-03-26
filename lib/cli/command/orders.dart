part of '../cli.dart';

class OpenOrders extends Command with ApiCall, Description, Tabular, Trades {
  @override
  String get name => "openorders";

  @override
  String get description => "Retrieve open orders. Alias: $aliases";

  @override
  List<String> get aliases => const ["oo", "open"];

  OpenOrders() {
    initTabularOptions(argParser);
    initDescriptionOption(argParser);
    initTradesOption(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = (await api.retrieve(KrakenRequest.openOrders(
      trades: showTrades,
    )))["open"];
    processResultMapOfMaps(result, keyColumn: "txid");
  }

  @override
  List<List<String>> preProcessRows(List<String> header, List<List> unprocessed) {
    updateDescription(header, unprocessed, descriptionMode);
    return super.preProcessRows(header, unprocessed);
  }
}

class ClosedOrders extends Command with ApiCall, Description, KrakenTimeOption, Tabular, Trades {
  @override
  String get name => "closedorders";

  @override
  String get description => "Retrieve closed orders. Alias: $aliases";

  @override
  List<String> get aliases => const ["co", "closed"];

  ClosedOrders() {
    initTabularOptions(argParser);
    initDescriptionOption(argParser);
    initKrakenTimeOption(
      argParser,
      name: "start",
      abbr: "s",
      since: true,
      allowShortForm: false,
      assign: _assignStart,
    );
    initKrakenTimeOption(
      argParser,
      name: "end",
      abbr: "e",
      since: true,
      allowShortForm: false,
      assign: _assignEnd,
    );
    argParser.addOption(
      "startTxid",
      aliases: ["st", "stxid", "stid", "sid"],
      help: "Define start via order txid. Use only one of start or startTxid.\n"
          "Behavior is undefined if both options are used at the same time.\n"
          "Note that this option is not tested properly for now.\n"
          "Aliases: [st, stxid, stid, sid]",
      valueHelp: "order-tx-id",
      callback: (it) => startTxid = it,
    );
    argParser.addOption(
      "endTxid",
      aliases: ["et", "etxid", "etid", "eid"],
      help: "Define end via order txid. Use only one of end or endTxid.\n"
          "Behavior is undefined if both options are used at the same time.\n"
          "Note that this option is not tested properly for now.\n"
          "Aliases: [st, stxid, stid, sid]",
      valueHelp: "order-tx-id",
      callback: (it) => startTxid = it,
    );
    argParser.addOption(
      "offset",
      abbr: "o",
      help: "Pagination offset. Not tested, yet.",
      valueHelp: "count",
      callback: (it) => offset = it != null ? int.parse(it) : offset,
    );
    argParser.addFlag(
      "consolidate",
      aliases: ["ct"],
      help: "Consolidate taker fees by order. Defaults to false. Alias: ct",
      defaultsTo: false,
      callback: (it) => consolidateTaker = it,
    );
  }

  _assignStart(it) =>
      start = it != null ? KrakenTime.fromString(it, since: true, allowShortForm: false) : null;

  _assignEnd(it) =>
      end = it != null ? KrakenTime.fromString(it, since: true, allowShortForm: false) : null;

  KrakenTime? start;
  String? startTxid;
  KrakenTime? end;
  String? endTxid;
  int? offset;
  CloseTime? closeTime;
  bool? consolidateTaker;

  @override
  autoClose(KrakenApi api) async {
    final Result result = (await api.retrieve(KrakenRequest.closedOrders(
      trades: showTrades,
      start: start,
      startTxid: startTxid,
      end: end,
      endTxid: endTxid,
      offset: offset,
      closeTime: closeTime,
      consolidateTaker: consolidateTaker,
    )))["closed"];
    processResultMapOfMaps(result, keyColumn: "txid");
  }

  @override
  List<List<String>> preProcessRows(List<String> header, List<List> unprocessed) {
    updateDescription(header, unprocessed, descriptionMode);
    return super.preProcessRows(header, unprocessed);
  }
}

class QueryOrders extends Command with ApiCall, Description, Tabular, Trades {
  @override
  String get name => "queryorders";

  @override
  String get description => "Retrieve order data via txid. Alias: $aliases";

  @override
  List<String> get aliases => const ["q", "qo", "query"];

  QueryOrders() {
    initTabularOptions(argParser);
    initDescriptionOption(argParser);
    initTradesOption(argParser);
    argParser.addMultiOption(
      "txids",
      abbr: "x",
      help: "One ore more (comma-separated) txids for which to query order info.",
      valueHelp: "order-tx-id",
      callback: (it) =>
          txids = it.isNotEmpty ? it : throw UsageException("At least one txid required!", usage),
    );
  }

  late List<String> txids;
  bool? consolidateTaker;

  @override
  autoClose(KrakenApi api) async {
    final Result result = (await api.retrieve(KrakenRequest.queryOrders(
      trades: showTrades,
      txids: txids,
      consolidateTaker: consolidateTaker,
    )));
    processResultMapOfMaps(result, keyColumn: "txid");
  }

  @override
  List<List<String>> preProcessRows(List<String> header, List<List> unprocessed) {
    updateDescription(header, unprocessed, descriptionMode);
    return super.preProcessRows(header, unprocessed);
  }
}

// TODO is this the way? seems odd...
abstract class OrderBase extends Command
    with
        ApiCall,
        CheckOrder,
        OrderDirectionOption,
        OrderStartAndExpire,
        OrderVolume,
        KrakenTimeOption,
        Pair,
        Tabular {}

class AddMarketOrder extends OrderBase {
  @override
  String get name => "marketorder";

  @override
  String get description => "Add basic market order. Alias: $aliases";

  @override
  List<String> get aliases => const ["mo", "market"];

  AddMarketOrder() {
    initTabularOptions(argParser);
    initPairOption(argParser);
    initCheckOrderFlag(argParser);
    initOrderDirectionOption(argParser);
    initOrderVolumeOption(argParser);
    initOrderStartAndExpire(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.addMarketOrder(
      direction: direction,
      pair: pair,
      volume: volume,
      startTime: start,
      expireTime: expire,
    ));
    logVerbose(() => result["descr"]["order"]);
    await checkOrder(api, result["txid"].first);
  }
}

class AddLimitOrder extends OrderBase with OrderLimit {
  @override
  String get name => "limitorder";

  @override
  String get description => "Add basic limit order. Alias: $aliases";

  @override
  List<String> get aliases => const ["lo", "limit"];

  AddLimitOrder() {
    initTabularOptions(argParser);
    initPairOption(argParser);
    initCheckOrderFlag(argParser);
    initOrderDirectionOption(argParser);
    initOrderVolumeOption(argParser);
    initOrderStartAndExpire(argParser);
    initOrderLimitOption(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.addLimitOrder(
      direction: direction,
      pair: pair,
      price: limit,
      volume: volume,
      startTime: start,
      expireTime: expire,
    ));
    logVerbose(() => result["descr"]["order"]);
    await checkOrder(api, result["txid"].first);
  }
}

class CancelOrder extends Command with ApiCall, Tabular {
  @override
  String get name => "cancelorder";

  @override
  String get description => "Cancel order via txid. Alias: $aliases";

  @override
  List<String> get aliases => const ["c"];

  CancelOrder() {
    initTabularOptions(argParser);
    argParser.addOption(
      "txid",
      abbr: "x",
      help: "Order txid for cancellation. Aliases: $aliases",
      valueHelp: "order-tx-id",
      mandatory: true,
      callback: (it) => txid = it!,
    );
  }

  late String txid;

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.cancelOrder(txid: txid));
    final count = result["count"]?.toString() ?? "";
    final pending = result["pending"]?.toString() ?? "";
    var data = [
      ["count", "pending"],
      [count, pending]
    ];
    dumpTable(data, headerDivider: true);
  }
}

class CancelAllOrders extends Command with ApiCall, Tabular {
  @override
  String get name => "cancelallorders";

  @override
  String get description => "Cancel all orders. Alias: $aliases";

  @override
  List<String> get aliases => const ["ca", "cao", "cancelall"];

  CancelAllOrders() {
    initTabularOptions(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.cancelAll());
    final count = result["count"]?.toString() ?? "";
    final pending = result["pending"]?.toString() ?? "";
    var data = [
      ["count", "pending"],
      [count, pending]
    ];
    dumpTable(data, headerDivider: true);
  }
}

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

    final args = argResults?.arguments ?? [];
    if (args.singleOrNull == "all") {
      result = await api.retrieve(KrakenRequest.cancelAll());
    } else if (args.isNotEmpty) {
      final txids = args.join(",").replaceAll(RegExp(r"[\s,]+"), ",").split(",");
      final bad = txids.where(isBadTxid);
      if (bad.isEmpty) {
        if (txids.length == 1) {
          result = await api.retrieve(KrakenRequest.cancelOrder(txid: txids.single));
        } else {
          result = await api.retrieve(KrakenRequest.cancelBatch(txids: txids));
        }
      } else {
        throw ArgumentError("bad order txid(s): ${bad.join(",")}");
      }
    } else {
      printUsage();
      return;
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
