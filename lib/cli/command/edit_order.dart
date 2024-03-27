part of '../cli.dart';

class EditOrder extends Command with Pair, ApiCall, KrakenTimeOption, Since, Tabular {
  @override
  String get name => "editorder";

  @override
  String get description => "Edit open order. Alias: $aliases\n\n"
      "Note that the trailing stop price rules apply here, if changing such an order:\n"
      "- In that case the price has to start with +, both for buy and sell.\n"
      "- The exchange will translate the + into - for buy orders.\n"
      "- Using % suffix is optional.";

  @override
  List<String> get aliases => const ["e", "edit"];

  EditOrder() {
    initTabularOptions(argParser);
    argParser.addOption(
      "txid",
      abbr: "t",
      help: "Order txid or current userref to identify target order.",
      valueHelp: "txid|userref",
      mandatory: true,
      callback: (it) => txid = it!,
    );
    initPairOption(argParser);
    argParser.addOption(
      "userref",
      abbr: "u",
      help: "Set new userref.",
      valueHelp: "integer id",
      callback: (it) => userref = it != null ? userref = int.parse(it) : null,
    );
    argParser.addOption(
      "volume",
      abbr: "v",
      help: "Change volume in asset quantity.",
      valueHelp: "volume",
      callback: (it) => it != null ? volume = double.parse(it) : null,
    );
    argParser.addOption(
      "displayvol",
      abbr: "d",
      help: "Iceberg-only order display part of volume.",
      valueHelp: "volume",
      callback: (it) => it != null ? displayvol = double.parse(it) : null,
    );
    argParser.addOption(
      "price",
      abbr: "1",
      help: "Change trigger price.",
      valueHelp: "price",
      callback: (it) => it != null ? price = KrakenPrice.fromString(it, trailingStop: false) : null,
    );
    argParser.addOption(
      "price2",
      abbr: "2",
      help: "Change limit price.",
      valueHelp: "price",
      callback: (it) =>
          it != null ? price2 = KrakenPrice.fromString(it, trailingStop: false) : null,
    );
    argParser.addOption(
      "deadline",
      abbr: "l",
      help: "Change deadline.",
      valueHelp: "datetime",
      callback: (it) => it != null ? deadline = DateTime.parse(it) : null,
    );
    argParser.addFlag(
      "cancelResponse",
      abbr: "r",
      negatable: false,
      callback: (it) => cancelResponse = it,
    );
    argParser.addFlag(
      "validate",
      abbr: "i",
      help: "Validate only.",
      negatable: false,
      callback: (it) => validate = it,
    );
  }

  late String txid;
  int? userref;
  double? volume;
  double? displayvol;
  KrakenPrice? price;
  KrakenPrice? price2;
  DateTime? deadline;
  bool? cancelResponse;
  bool? validate;

  @override
  autoClose(KrakenApi api) async {
    final Result result = await api.retrieve(KrakenRequest.editOrder(
      txid: txid,
      pair: pair,
      userref: userref,
      volume: volume,
      displayVol: displayvol,
      price: price,
      price2: price2,
      deadline: deadline,
      cancelResponse: cancelResponse,
      validate: validate,
    ));
    result["order"] = result["descr"]?["order"];
    result.remove("descr");
    processResultMap(result);
  }
}
