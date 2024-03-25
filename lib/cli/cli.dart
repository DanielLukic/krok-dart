import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:args/src/arg_parser.dart';
import 'package:krok/api/api.dart';
import 'package:krok/api/kraken_time.dart';
import 'package:krok/cli/output.dart';
import 'package:krok/common/extensions.dart';
import 'package:krok/common/log.dart';

part 'command/asset_pairs.dart';
part 'command/assets.dart';
part 'command/balance.dart';
part 'command/mixin/api_call.dart';
part 'command/mixin/auto_cache.dart';
part 'command/mixin/pair.dart';
part 'command/mixin/since.dart';
part 'command/mixin/tabular.dart';
part 'command/ohlc.dart';
part 'command/orders.dart';
part 'command/spread.dart';
part 'command/system_status.dart';
part 'command/ticker.dart';
part 'command/tradebalance.dart';
part 'command/tradevolume.dart';
part 'options.dart';

run(List<String> args) async {
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
      ..addCommand(AssetPairs())
      ..addCommand(Assets())
      ..addCommand(Balance())
      ..addCommand(ClosedOrders())
      ..addCommand(Ohlc())
      ..addCommand(OpenOrders())
      ..addCommand(QueryOrders())
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

String _keyFilePath = "~/.config/clikraken/kraken.key";

Duration _cachedDuration = 5.minutes;
