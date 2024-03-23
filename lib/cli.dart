import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:args/src/arg_parser.dart';
import 'package:krok/src/api.dart';
import 'package:krok/src/csv.dart';
import 'package:krok/src/extensions.dart';
import 'package:krok/src/log.dart';

part 'auto_cache.dart';
part 'commands.dart';
part 'options.dart';
part 'tabular.dart';

run(List<String> args) async {
  final runner = CommandRunner(
    "krok",
    "Execute Kraken API commands.",
    usageLineLength: 80,
  );

  _addLogOption(runner.argParser);
  _addCachedOption(runner.argParser);
  _addKeyFileOption(runner.argParser);

  runner.addCommand(_Assets());
  runner.addCommand(_TickerCommand());

  try {
    await runner.run(args);
  } on UsageException catch (it) {
    print(it);
  }
}

final _logLevels = LogLevel.values.asNameMap();

String _keyFilePath = "~/.config/clikraken/kraken.key";

Duration _cachedDuration = 5.minutes;
