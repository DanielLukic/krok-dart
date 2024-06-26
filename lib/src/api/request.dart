part of 'api.dart';

/// Implements the available Kraken API requests via named constructors.
class KrakenRequest {
  final String path;
  final Map<String, dynamic> params;
  final Scope scope;

  /// If this is used, [params] must be empty!
  /// TODO use sealed for params vs json? but sealed is so awkward to use in dart.. ‾\_('')_/‾
  Map<String, dynamic>? body;

  KrakenRequest.systemStatus()
      : path = "SystemStatus",
        params = {},
        scope = Scope.public;

  KrakenRequest.assets({List<Pair>? assets})
      : assert(
          assets.isNullOrNotEmpty,
          "null or at least one asset expected: $assets",
        ),
        path = "Assets",
        params = {
          if (assets != null) "asset": assets.join(","),
        },
        scope = Scope.public;

  KrakenRequest.assetPairs({List<Pair>? pairs, AssetPairsInfo? info})
      : assert(
          pairs.isNullOrNotEmpty,
          "null or at least one pair expected: $pairs",
        ),
        path = "AssetPairs",
        params = {
          if (pairs != null) "pair": pairs.join(","),
          if (info != null) "info": info.name,
        },
        scope = Scope.public;

  KrakenRequest.ticker({List<Pair>? pairs})
      : assert(
          pairs.isNullOrNotEmpty,
          "null or at least one pair expected: $pairs",
        ),
        path = "Ticker",
        params = {
          if (pairs != null) "pair": pairs.join(","),
        },
        scope = Scope.public;

  KrakenRequest.ohlc({
    required Pair pair,
    OhlcInterval? interval,
    KrakenTime? since,
  })  : path = "OHLC",
        params = {
          "pair": pair,
          if (interval != null) "interval": interval.minutes,
          if (since != null) "since": since.tm,
        },
        scope = Scope.public;

  KrakenRequest.spread({
    Pair? pair,
    KrakenTime? since,
  })  : path = "Spread",
        params = {
          if (pair != null) "pair": pair,
          if (since != null) "since": since.tm,
        },
        scope = Scope.public;

  KrakenRequest.balance()
      : path = "Balance",
        params = {},
        scope = Scope.private;

  KrakenRequest.balanceEx()
      : path = "BalanceEx",
        params = {},
        scope = Scope.private;

  KrakenRequest.tradeBalance({Asset? baseAsset})
      : path = "TradeBalance",
        params = {if (baseAsset != null) "asset": baseAsset},
        scope = Scope.private;

  KrakenRequest.openOrders({bool? trades, int? userref})
      : path = "OpenOrders",
        params = {
          if (trades != null) "trades": trades,
          if (userref != null) "userref": userref,
        },
        scope = Scope.private;

  KrakenRequest.closedOrders({
    bool? trades,
    KrakenTime? start,
    String? startTxid,
    KrakenTime? end,
    String? endTxid,
    int? offset,
    CloseTime? closeTime,
    bool? consolidateTaker,
    int? userref,
  })  : path = "ClosedOrders",
        params = {
          if (trades != null) "trades": trades,
          if (start != null) "start": start.tm,
          if (startTxid != null) "start": startTxid,
          if (end != null) "end": end.tm,
          if (endTxid != null) "end": endTxid,
          if (offset != null) "ofs": offset,
          if (closeTime != null) "closetime": closeTime.name,
          if (consolidateTaker != null) "consolidate_taker": consolidateTaker,
          if (userref != null) "userref": userref,
        },
        scope = Scope.private;

  KrakenRequest.queryOrders({
    bool? trades,
    required List<String> txids,
    bool? consolidateTaker,
    int? userref,
  })  : assert(txids.isNotEmpty),
        path = "QueryOrders",
        params = {
          if (trades != null) "trades": trades,
          "txid": txids.join(","),
          if (consolidateTaker != null) "consolidate_taker": consolidateTaker,
          if (userref != null) "userref": userref,
        },
        scope = Scope.private;

  KrakenRequest.tradeVolume({
    List<String>? pairs,
  })  : path = "TradeVolume",
        params = {if (pairs?.isNotEmpty == true) "pair": pairs?.join(",")},
        scope = Scope.private;

  KrakenRequest.addOrder({
    required OrderType orderType,
    required OrderDirection direction,
    required double volume,
    double? displayVol,
    required Pair pair,
    KrakenPrice? price,
    KrakenPrice? price2,
    // TODO trigger?
    String? leverage,
    bool? reduceOnly,
    SelfTradePrevention? selfTradePrevention,
    List<OrderFlag>? flags,
    TimeInForce? timeInForce,
    KrakenTime? startTime,
    KrakenTime? expireTime,
    OrderType? closeOrderType,
    double? closePrice,
    double? closePrice2,
    DateTime? deadline,
    bool? validate,
    int? userref,
  })  : assert(closeOrderType?.closeToo != false),
        path = "AddOrder",
        params = {
          "ordertype": orderType.name,
          "type": direction.name,
          "volume": volume,
          if (displayVol != null) "displayvol": displayVol,
          "pair": pair,
          if (price != null) "price": price.toPrice(),
          if (price2 != null) "price2": price2.toPrice2(),
          if (leverage != null) "leverage": leverage,
          if (reduceOnly != null) "reduce_only": reduceOnly,
          if (selfTradePrevention != null) "stptype": selfTradePrevention.name,
          if (flags != null) "oflags": flags.map((f) => f.name).join(","),
          if (timeInForce != null) "timeinforce": timeInForce.name,
          if (startTime != null) "starttm": startTime.toApiString(),
          if (expireTime != null) "expiretm": expireTime.toApiString(),
          if (closeOrderType != null) "close[ordertype]": closeOrderType.name,
          if (closePrice != null) "close[price]": closePrice,
          if (closePrice2 != null) "close[price2]": closePrice2,
          if (deadline != null) "deadline": deadline.toIso8601String(),
          if (validate != null) "validate": validate,
          if (userref != null) "userref": userref,
        },
        scope = Scope.private;

  KrakenRequest.addMarketOrder({
    required OrderDirection direction,
    required Pair pair,
    required double volume,
    KrakenTime? startTime,
    KrakenTime? expireTime,
  })  : path = "AddOrder",
        params = {
          "pair": pair,
          "type": direction.name,
          "ordertype": OrderType.market.name,
          "volume": volume,
          if (startTime != null) "starttm": startTime.toApiString(),
          if (expireTime != null) "expiretm": expireTime.toApiString(),
        },
        scope = Scope.private;

  KrakenRequest.addLimitOrder({
    required OrderDirection direction,
    required Pair pair,
    required KrakenPrice price,
    required double volume,
    KrakenTime? startTime,
    KrakenTime? expireTime,
  })  : path = "AddOrder",
        params = {
          "pair": pair,
          "type": direction.name,
          "ordertype": OrderType.limit.name,
          "price": price,
          "volume": volume,
          if (startTime != null) "starttm": startTime.toApiString(),
          if (expireTime != null) "expiretm": expireTime.toApiString(),
        },
        scope = Scope.private;

  KrakenRequest.cancelOrder({
    required String txidOrUserref,
  })  : assert(txidOrUserref.isNotEmpty),
        path = "CancelOrder",
        params = {"txid": txidOrUserref},
        scope = Scope.private;

  KrakenRequest.cancelBatch({
    required List<String> txids,
  })  : assert(txids.isNotEmpty),
        path = "CancelOrderBatch",
        params = {},
        body = {"orders": txids},
        scope = Scope.private;

  KrakenRequest.cancelAll()
      : path = "CancelAll",
        params = {},
        scope = Scope.private;

  KrakenRequest.editOrder({
    required String txid,
    required Pair pair,
    int? userref,
    double? volume,
    double? displayVol,
    KrakenPrice? price,
    KrakenPrice? price2,
    // TODO oflags
    DateTime? deadline,
    bool? cancelResponse,
    bool? validate,
  })  : path = "EditOrder",
        params = {
          "txid": txid,
          "pair": pair,
          if (userref != null) "userref": userref,
          if (volume != null) "volume": volume,
          if (displayVol != null) "displayvol": displayVol,
          if (price != null) "price": price.toPrice(),
          if (price2 != null) "price2": price2.toPrice2(),
          if (deadline != null) "deadline": deadline.toIso8601String(),
          if (cancelResponse != null) "cancelResponse": cancelResponse,
          if (validate != null) "validate": validate,
        },
        scope = Scope.private;
}
