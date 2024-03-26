part of '../../cli.dart';

enum DescriptionMode { expand, hide, keep, noorder, order }

mixin Description {
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

mixin CheckOrder {
  bool check = false;

  initCheckOrderFlag(ArgParser argParser) {
    argParser.addFlag(
      "check",
      abbr: "k",
      help: "Check for cancellation immediately. Otherwise, use the queryorders command.",
      defaultsTo: false,
      callback: (it) => check = it,
    );
  }

  Future<void> checkOrder(KrakenApi api, String txid) async {
    String? status;
    String? reason;
    if (check) {
      try {
        final Result result = (await api.retrieve(KrakenRequest.queryOrders(
          txids: [txid],
        )))[txid];
        status = result["status"]?.toString().toUpperCase();
        reason = result["reason"];
      } catch (it, trace) {
        logError(it, trace); // log only - more important to provide the order txid below!
      }
      if (status == "CANCELED") {
        throw KrakenException("$txid ($status) $reason");
      }
    }
    if (status != null) {
      print("$txid ($status) ${reason ?? ""}");
    } else {
      print(txid);
    }
  }
}

mixin OrderDirectionOption {
  late OrderDirection direction;

  initOrderDirectionOption(ArgParser argParser) {
    argParser.addOption(
      "type",
      abbr: "t",
      help: "Buy or sell order.",
      allowed: ["buy", "sell"],
      mandatory: true,
      callback: (it) => direction = OrderDirection.values.asNameMap()[it]!,
    );
  }
}

mixin OrderVolume {
  late double volume;

  initOrderVolumeOption(ArgParser argParser) {
    argParser.addOption(
      "volume",
      abbr: "v",
      help: "Volume in asset quantity.",
      mandatory: true,
      callback: (it) => volume = double.parse(it!),
    );
  }
}

// TODO implements? seems odd...
mixin OrderStartAndExpire implements KrakenTimeOption {
  KrakenTime? start;
  KrakenTime? expire;

  initOrderStartAndExpire(ArgParser argParser) {
    initKrakenTimeOption(
      argParser,
      name: "start",
      abbr: "s",
      since: false,
      allowShortForm: true,
      assign: (it) => start = it,
    );
    initKrakenTimeOption(
      argParser,
      name: "expire",
      abbr: "e",
      since: false,
      allowShortForm: true,
      assign: (it) => expire = it,
    );
  }
}

mixin OrderLimit {
  late KrakenPrice limit;

  initOrderLimitOption(ArgParser argParser) {
    argParser.addOption(
      "limit",
      abbr: "l",
      help: "Limit price in target currency or percentage. Relative values allowed:\n"
          "0.01, 10100, +100, -10, 5%, +5%, -5%\n"
          "Special case: #10 or #10% will choose + or - depending on order direction.\n",
      mandatory: true,
      callback: (it) => limit = KrakenPrice.fromString(it!, trailingStop: false),
    );
  }
}
