var logLevel = LogLevel.info;

enum LogLevel { verbose, debug, info, warn, error, none }

extension on LogLevel {
  tag() => name.substring(0, 1).toUpperCase();
}

log(Object? message, [LogLevel? level]) {
  level ??= LogLevel.info;
  if (level.index < logLevel.index) return;
  var (name, where) = StackTrace.current.caller;
  print("[${level.tag()}] $message [$name] $where");
}

logInfo(Object? message) => log(message, LogLevel.info);

logWarn(Object? message) => log(message, LogLevel.warn);

logError(Object? message) => log(message, LogLevel.error);

logDebug(Object? message) => log(message, LogLevel.debug);

logVerbose(Object? message) => log(message, LogLevel.verbose);

extension on StackTrace {
  (String function, String location) get caller {
    caller(String it) => !it.contains("log.dart");
    var lines = toString().split("\n");
    var trace = lines.firstWhere(caller, orElse: () => "");
    var parts = trace.replaceAll(RegExp(r"#\d\s+"), "").split(" ");
    return (parts[0], parts[1]);
  }
}
