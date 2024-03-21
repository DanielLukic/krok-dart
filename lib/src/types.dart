part of 'api.dart';

typedef NonceGenerator = int Function();

typedef Asset = String;
typedef Price = double;
typedef Volume = double;

var defaultNonceGenerator = () => DateTime.now().millisecondsSinceEpoch;

enum AssetPairsInfo { info, leverage, fees, margin }

enum CloseTime { both, open, close }

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

enum OrderDirection { buy, sell }

enum OrderFlag {
  post,
  fcib,
  fciq,
  nompp,
  viqc,
}

sealed class OrderTime {}

class OrderNow extends OrderTime {}

class OrderDate extends OrderTime {
  final DateTime time;

  OrderDate(this.time);
}

class OrderDuration extends OrderTime {
  final int seconds;

  OrderDuration(this.seconds);
}

String createOrderTime(OrderTime startTime) => switch (startTime) {
      OrderNow() => "0",
      OrderDate(time: var it) => it.millisecondsSinceEpoch.toString(),
      OrderDuration(seconds: var it) => it.toString(),
    };

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

class Pair {
  final Asset left;
  final Asset right;

  Pair(this.left, this.right);

  String get name => "$left$right";
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
