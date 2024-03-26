part of 'api.dart';

typedef NonceGenerator = int Function();

typedef Asset = String;
typedef Pair = String;
typedef Price = double;
typedef Result = Map<String, dynamic>;
typedef Volume = double;

var defaultNonceGenerator = () => DateTime.now().millisecondsSinceEpoch;

enum AssetPairsInfo { info, leverage, fees, margin }

enum CloseTime { both, open, close }

class KrakenPrice {
  final String it;
  final bool trailingStopPrice;

  KrakenPrice._(this.it, this.trailingStopPrice);

  factory KrakenPrice.fromString(final String value, {required bool trailingStop}) {
    var it = value;
    if (trailingStop) {
      final validPrefix = RegExp(r"^[+\-]").hasMatch(it);
      if (it.endsWith("%")) {
        it = it.substring(0, it.length - 1);
      }
      if (validPrefix && double.tryParse(it.substring(1)) != null) {
        return KrakenPrice._(value, trailingStop);
      }
      throw ArgumentError("Not a trailing stop price ((+-)<value>[%]): $it", "value");
    } else {
      if (it.startsWith("+") || it.startsWith("-") || it.startsWith("#")) {
        it = it.substring(1);
      }
      if (it.endsWith("%")) {
        it = it.substring(0, it.length - 1);
      }
      if (double.tryParse(it) != null) {
        return KrakenPrice._(value, trailingStop);
      }
      throw ArgumentError("Not a valid price ([+-#]<value>[%]): $it", "value");
    }
  }

  String toPrice() => trailingStopPrice ? it.replaceFirst("-", "+") : it;

  String toPrice2() => it;

  @override
  String toString() => it;
}

enum OhlcInterval {
  oneMinute(1),
  fiveMinutes(5),
  fifteenMinutes(15),
  thirtyMinutes(30),
  oneHour(60),
  fourHours(240),
  oneDay(1440),
  oneWeek(10080),
  fifteenDays(21600),
  ;

  final int minutes;

  const OhlcInterval(this.minutes);
}

extension StringToOhlcInterval on String? {
  OhlcInterval asOhlcInterval({
    OhlcInterval defaultValue = OhlcInterval.oneMinute,
  }) =>
      OhlcInterval.values.firstWhere(
        (element) => element.minutes.toString() == this,
        orElse: () => defaultValue,
      );
}

enum OrderDirection { buy, sell }

enum OrderFlag {
  post,
  fcib,
  fciq,
  nompp,
  viqc,
}

enum OrderType {
  market("market", closeToo: false),
  limit("limit"),
  stopLoss("stop-loss"),
  takeProfit("take-profit"),
  stopLossLimit("stop-loss-profit"),
  takeProfitLimit("take-profit-limit"),
  trailingStop("trailing-stop"),
  trailingStopLimit("trailing-stop-limit"),
  settlePosition("settle-position", closeToo: false),
  ;

  final String name;
  final bool closeToo;

  const OrderType(this.name, {this.closeToo = true});
}

enum Scope { public, private }

enum SelfTradePrevention {
  cancelOldest("cancel-oldest"),
  cancelNewest("cancel-newest"),
  cancelBoth("cancel-both"),
  ;

  final String name;

  const SelfTradePrevention(this.name);
}

enum TimeInForce {
  goodTilCancelled("GTC"),
  immediateOrCancel("IOC"),
  goodTilDate("GTD"),
  ;

  final String name;

  const TimeInForce(this.name);
}
