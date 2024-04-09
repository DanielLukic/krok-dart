part of 'cli.dart';

extension on CommandRunner<dynamic> {
  addLogOption() => argParser.addOption(
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

  addLogFileOption() => argParser.addOption(
    "logfile",
    abbr: "f",
    help: "Set log file instead of console logging",
    valueHelp: "filename",
    callback: _setLogFile,
  );

  _setLogFile(String? it) => sink = it != null ? fileSink(it) : print;

  addCachedOption() => argParser.addOption(
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
    if (duration < 0) {
      throw ArgumentError("Duration must be positive", "cached");
    }
    return _cachedDuration = duration.minutes;
  }

  addKeyFileOption() => argParser.addOption(
        "keyfile",
        abbr: "k",
        help: "Path to clikraken.key file.",
        valueHelp: "path",
        defaultsTo: _keyFilePath,
        aliases: const ["key"],
        callback: (it) => _keyFilePath = it ?? _keyFilePath,
      );
}
