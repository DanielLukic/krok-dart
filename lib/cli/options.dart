part of 'cli.dart';

_addLogOption(ArgParser parser) => parser.addOption(
      "log",
      abbr: "l",
      help: "Set log level.",
      valueHelp: "level",
      allowed: _logLevels.keys,
      defaultsTo: "info",
      callback: _setLogLevel,
    );

// value checked by parser already
_setLogLevel(String? it) => logLevel = _logLevels[it] ?? logLevel;

_addCachedOption(ArgParser parser) => parser.addOption(
      "cached",
      abbr: "c",
      help: "Set auto-cache duration for public, parameterless commands.",
      valueHelp: "minutes",
      defaultsTo: _cachedDuration.inMinutes.toString(),
      callback: _setCachedDuration,
    );

_setCachedDuration(String? it) {
  var duration = it?.toInt();
  if (duration == null) return;
  if (duration < 0) throw ArgumentError("Duration must be positive", "cached");
  return _cachedDuration = duration.minutes;
}

_addKeyFileOption(ArgParser parser) => parser.addOption(
      "keyfile",
      abbr: "k",
      help: "Path to clikraken.key file.",
      valueHelp: "path",
      defaultsTo: _keyFilePath,
      aliases: const ["key"],
      callback: (it) => _keyFilePath = it ?? _keyFilePath,
    );
