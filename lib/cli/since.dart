part of 'cli.dart';

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
      callback: (it) => since = it != null ? KrakenTime.fromString(it) : null,
    );
  }
}
