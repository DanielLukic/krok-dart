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

class ClosedOrders extends Command with ApiCall, Description, Tabular, Trades {
  @override
  String get name => "closedorders";

  @override
  String get description => "Retrieve closed orders. Alias: $aliases";

  @override
  List<String> get aliases => const ["co", "closed"];

  ClosedOrders() {
    initTabularOptions(argParser);
    initDescriptionOption(argParser);
  }

  @override
  autoClose(KrakenApi api) async {
    final Result result = (await api.retrieve(KrakenRequest.closedOrders(
      trades: showTrades,
    )))["closed"];
    processResultMapOfMaps(result, keyColumn: "txid");
  }

  @override
  List<List<String>> preProcessRows(List<String> header, List<List> unprocessed) {
    updateDescription(header, unprocessed, descriptionMode);
    return super.preProcessRows(header, unprocessed);
  }
}
