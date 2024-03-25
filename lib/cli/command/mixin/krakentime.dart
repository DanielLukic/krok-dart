part of '../../cli.dart';

mixin KrakenTimeOption {
  initKrakenTimeOption(
    ArgParser argParser, {
    required String name,
    String? abbr,
    required Function(String?) assign,
  }) {
    argParser.addOption(
      name,
      abbr: abbr,
      help: "Either: Timestamp in UNIX format (UTC).\n"
          "Or: RFC3339/ISO8601 datetime.\n"
          "Or: Relative time in seconds/minutes/hours/days, using s/m/h/d suffix.\n"
          "Relative examples: 15m, 1h, 30s",
      valueHelp: "timestamp|datetime|relative",
      callback: assign,
    );
  }
}
