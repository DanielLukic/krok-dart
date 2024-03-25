part of '../cli.dart';

enum DescriptionMode { expand, hide, keep, noorder, order }

// TODO auto-select descr if mode != hide and columns selected

abstract mixin class Description {
  DescriptionMode descriptionMode = DescriptionMode.hide;

  initDescriptionOption(ArgParser argParser) {
    argParser.addOption(
      "description",
      abbr: "d",
      help: "How to handle the descr(iption) column.",
      allowed: DescriptionMode.values.asNameMap().keys,
      defaultsTo: descriptionMode.name,
      allowedHelp: DescriptionMode.values.asNameMap().mapValues(
            (it) => switch (it as DescriptionMode) {
              DescriptionMode.expand => "Expand description into columns.",
              DescriptionMode.hide => "Remove the description column.",
              DescriptionMode.keep => "Keep description as is.",
              DescriptionMode.order => "Replace description column with its order value.",
              DescriptionMode.noorder => "Expand description into columns, omitting order.",
            },
          ),
      callback: (it) => descriptionMode = DescriptionMode.values.asNameMap()[it] ?? descriptionMode,
    );
  }

  void updateDescription(List<String> header, List<List<dynamic>> rows, DescriptionMode mode) {
    if (!header.contains("descr")) return;

    switch (mode) {
      case DescriptionMode.expand:
        _expand(header, rows, (it) => true);

      case DescriptionMode.hide:
        final column = header.indexOf("descr");
        for (final row in rows) {
          row.removeAt(column);
        }
        header.removeAt(column);

      case DescriptionMode.keep:
        break;

      case DescriptionMode.noorder:
        _expand(header, rows, (it) => it != "order");

      case DescriptionMode.order:
        _expand(header, rows, (it) => it == "order");
    }
  }

  void _expand(List<String> header, List<dynamic> rows, bool Function(String) selectColumn) {
    final column = header.indexOf("descr");
    var headerUpdated = false;
    for (final List row in rows) {
      final description = row.removeAt(column) as Result;
      if (!headerUpdated) header.removeAt(column);

      final columns = description.keys.toList();
      for (var key in columns) {
        if (!selectColumn(key)) continue;
        if (!headerUpdated) header.add("_$key");
        row.add(description[key]);
      }

      headerUpdated = true;
    }
  }
}

mixin Trades {
  bool showTrades = false;

  initTradesOption(ArgParser argParser) {
    argParser.addFlag(
      "trades",
      abbr: "t",
      help: "Include trades in output.",
      defaultsTo: false,
      callback: (it) => showTrades = it,
    );
  }
}

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
