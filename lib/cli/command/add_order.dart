part of '../cli.dart';

abstract class AddOrder extends Command
    with ApiCall, CheckOrder, KrakenTimeOption, OrderStartAndExpire, Tabular {
  @override
  String get description => "Add $name order.";

  @override
  String? get usageFooter {
    final examples = [
      "buy \"8.0 CFGUSD @ market\"",
      "buy \"8.0 CFGUSD @ limit 0.80\"",
      "buy \"8.0 CFGUSD @ stop loss 0.80\"",
      "buy \"8.0 CFGUSD @ stop loss 1.0 -> limit 1.0\"",
      "buy \"8.0 CFGUSD @ take profit 0.8 -> limit 0.8\"",
      "buy \"8.0 CFGUSD @ take profit 0.8\"",
      "buy \"8.0 CFGUSD @ trailing stop -5%\"",
      "buy \"8.0 CFGUSD @ trailing stop -5% -> +0%\"",
      "sell \"8.0 CFGUSD @ market\"",
      "sell \"8.0 CFGUSD @ limit 1.0\"",
      "sell \"8.0 CFGUSD @ stop loss 0.8 -> limit 0.8\"",
      "sell \"8.0 CFGUSD @ stop loss 0.8\"",
      "sell \"8.0 CFGUSD @ take profit 1.0 -> limit 1.0\"",
      "sell \"8.0 CFGUSD @ take profit 1.0\"",
      "sell \"8.0 CFGUSD @ trailing stop +5.0%\"",
      "sell \"8.0 CFGUSD @ trailing stop +5.0% -> -0%\"",
    ];
    final shelled = examples.map((e) => "\$ krok $e");
    final all = [
      "",
      "Note the quotes around the buy or sell arguments. These are required to avoid shell",
      "redirection or misinterpretation of negative (-) values. Single or double quotes are supported.",
      "",
      "Use the assetpairs command to determine the allowed decimals.",
      "",
      ...shelled,
      "",
      "Note that the rules for trailing stop prices are somewhat complicated:",
      "",
      "The trigger price has to be a percentage. It must be + for buy and - for sell.",
      "# is not supported in this case.",
      "",
      "The optional limit price will be relative to the trigger price. It has to use + or -.",
      "The % suffix is allowed. +0 is valid. So is +0%. This will set the limit price to the",
      "trigger price.",
      "",
      "Caveat: In the Kraken API trailing stop trigger price has to use +. Krok allows this, too.",
      "Both are mapped properly onto the Kraken API."
    ];
    return all.join("\n");
  }

  @override
  String get category => "dsl";

  AddOrder() {
    initTabularOptions(argParser);
    initCheckOrderFlag(argParser);
    initOrderStartAndExpire(argParser);
  }

  bool isPrice(String it, {required bool trailingStop}) {
    try {
      KrakenPrice.fromString(it, trailingStop: trailingStop);
      return true;
    } catch (it) {
      return false;
    }
  }

  bool isPair(String it) => RegExp(r"[A-Z]+").hasMatch(it);

  @override
  autoClose(KrakenApi api) async {
    var args = argResults?.rest ?? [];
    args = args
        .join(" ")
        .replaceFirst("stop loss", "stop-loss")
        .replaceFirst("take profit", "take-profit")
        .replaceFirst("trailing stop", "trailing-stop")
        .split(RegExp(r"\s+"));

    final check = args.join(" ");
    final usage = usageFooter?.substring(1) ?? this.usage;

    final volume = double.tryParse(args[0]);
    if (volume == null) {
      throw UsageException("Invalid volume ${args[0]} in $check", usage);
    }

    final pair = args[1];
    if (!isPair(pair)) {
      throw UsageException("Invalid pair $pair in $check", usage);
    }
    if (args[2] != "@") {
      throw UsageException("Missing @ after pair in $check", usage);
    }

    args = args.sublist(3);

    final direction = OrderDirection.values.asNameMap()[name]!;

    final Result result;

    Future<Result> execute(
      OrderType type, {
      String? price,
      String? price2,
      bool trailing = false,
    }) async =>
        await api.retrieve(KrakenRequest.addOrder(
          orderType: type,
          direction: direction,
          volume: volume,
          pair: pair,
          price: price != null ? KrakenPrice.fromString(price, trailingStop: trailing) : null,
          price2: price2 != null ? KrakenPrice.fromString(price2, trailingStop: trailing) : null,
          startTime: start,
          expireTime: expire,
        ));

    switch (args) {
      case ["market"]:
        result = await execute(OrderType.market);

      case ["limit", var price] when isPrice(price, trailingStop: false):
        result = await execute(OrderType.limit, price: price);

      case ["stop-loss", var price] when isPrice(price, trailingStop: false):
        result = await execute(OrderType.stopLoss, price: price);

      case ["stop-loss", var price, "->", var price2]
          when isPrice(price, trailingStop: false) && isPrice(price2, trailingStop: false):
        result = await execute(OrderType.stopLossLimit, price: price, price2: price2);

      case ["take-profit", var price] when isPrice(price, trailingStop: false):
        result = await execute(OrderType.takeProfit, price: price);

      case ["take-profit", var price, "->", var price2]
          when isPrice(price, trailingStop: false) && isPrice(price2, trailingStop: false):
        result = await execute(OrderType.takeProfitLimit, price: price, price2: price2);

      case ["trailing-stop", var price] when isPrice(price, trailingStop: true):
        result = await execute(OrderType.trailingStop, price: price, trailing: true);

      case ["trailing-stop", var price, "->", var price2]
          when isPrice(price, trailingStop: true) && isPrice(price2, trailingStop: true):
        result = await execute(OrderType.trailingStopLimit,
            price: price, price2: price2, trailing: true);

      default:
        throw UsageException("Unexpected order arguments: $check", usage);
    }

    logVerbose(() => result["descr"]["order"]);
    await checkOrder(api, result["txid"].first);
  }
}

class Buy extends AddOrder {
  @override
  String get name => "buy";
}

class Sell extends AddOrder {
  @override
  String get name => "sell";
}
