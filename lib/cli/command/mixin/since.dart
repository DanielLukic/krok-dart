part of '../../cli.dart';

@Deprecated("Use KrakenTimeOption instead.")
mixin Since {
  KrakenTime? since;

  initSinceOption(ArgParser argParser) {
    argParser.addOption(
      "since",
      abbr: "s",
      help: "Either: Timestamp in UNIX format (UTC).\n"
          "Or: RFC3339 datetime.\n"
          "Or: Relative time in seconds/minutes/hours/days, using s/m/h/d suffix.\n"
          "A maximum of 720 values is returned.",
      valueHelp: "timestamp|datetime|relative",
      callback: (it) => since = it != null ? KrakenTime.fromString(it, since: true) : null,
    );
  }
}

mixin KrakenTimeOption {
  initKrakenTimeOption(
    ArgParser argParser, {
    required String name,
    required Function(String?) assign,
    String? abbr,
  }) {
    argParser.addOption(
      name,
      abbr: abbr,
      help: "Either: Timestamp in UNIX format (UTC).\n"
          "Or: RFC3339/ISO8601 datetime.\n"
          "Or: Relative time in seconds/minutes/hours/days, using s/m/h/d suffix.\n"
          "A maximum of 720 values is returned.\n"
          "Relative examples: 15m, 1h, 30s",
      valueHelp: "timestamp|datetime|relative",
      callback: assign,
    );
  }
}
