import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:args/src/arg_parser.dart';
import 'package:krok/api/api.dart';
import 'package:krok/common/output.dart';
import 'package:krok/common/extensions.dart';
import 'package:krok/common/log.dart';

part 'auto_cache.dart';
part 'command/asset_pairs.dart';
part 'command/assets.dart';
part 'command/system_status.dart';
part 'command/ticker.dart';
part 'options.dart';
part 'tabular.dart';

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
      ..addCommand(AssetPairs())
      ..addCommand(Assets())
      ..addCommand(SystemStatus())
      ..addCommand(TickerCommand());

    await runner.run(args);
  } on UsageException catch (it) {
    print(it);
  }
}

final _logLevels = LogLevel.values.asNameMap();

String _keyFilePath = "~/.config/clikraken/kraken.key";

Duration _cachedDuration = 5.minutes;
