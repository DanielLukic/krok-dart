import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:cli_util/cli_util.dart';
import 'package:dart_minilog/dart_minilog.dart';
import 'package:krok/src/api/api.dart';
import 'package:krok/src/cli/output.dart';
import 'package:krok/src/common/extensions.dart';
import 'package:path/path.dart' as path;

part 'command/add_order.dart';
part 'command/asset_pairs.dart';
part 'command/assets.dart';
part 'command/balance.dart';
part 'command/cancel.dart';
part 'command/edit_order.dart';
part 'command/mixin/api_call.dart';
part 'command/mixin/auto_cache.dart';
part 'command/mixin/kraken_time_option.dart';
part 'command/mixin/order_options.dart';
part 'command/mixin/pair.dart';
part 'command/mixin/tabular.dart';
part 'command/ohlc.dart';
part 'command/orders.dart';
part 'command/spread.dart';
part 'command/system_status.dart';
part 'command/ticker.dart';
part 'command/tradebalance.dart';
part 'command/tradevolume.dart';
part 'options.dart';

cli(List<String> args) async {
  try {
    final runner = CommandRunner(
      "krok",
      "Execute Kraken API commands.",
      usageLineLength: 80,
    );

    runner
      ..addLogOption()
      ..addCachedOption()
      ..addKeyFileOption()
      ..addCommand(AddMarketOrder())
      ..addCommand(AddLimitOrder())
      ..addCommand(AssetPairs())
      ..addCommand(Assets())
      ..addCommand(Balance())
      ..addCommand(Buy())
      ..addCommand(Cancel())
      ..addCommand(CancelOrder())
      ..addCommand(CancelAllOrders())
      ..addCommand(ClosedOrders())
      ..addCommand(EditOrder())
      ..addCommand(Ohlc())
      ..addCommand(OpenOrders())
      ..addCommand(QueryOrders())
      ..addCommand(Sell())
      ..addCommand(Spread())
      ..addCommand(SystemStatus())
      ..addCommand(Ticker())
      ..addCommand(TradeBalance())
      ..addCommand(TradeVolume());

    await runner.run(args);
  } on UsageException catch (it) {
    print(it);
    exit(2);
  } on KrakenException catch (it) {
    print(it.message);
    exit(1);
  }
}

final _logLevels = LogLevel.values.asNameMap();

String _keyFilePath =
    path.join(applicationConfigHome("clikraken"), "kraken.key");

Duration _cachedDuration = 5.minutes;
