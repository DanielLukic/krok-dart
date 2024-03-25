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
      assign: (it) => start = it != null ? KrakenTime.fromString(it) : null,
    );
    initKrakenTimeOption(
      argParser,
      name: "end",
      abbr: "e",
      assign: (it) => end = it != null ? KrakenTime.fromString(it) : null,
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
      startTime: startTime,
      expireTime: expireTime,
    ));
    logVerbose(() => result["descr"]["order"]);
    await checkOrder(api, result["txid"].first);
  }
}
