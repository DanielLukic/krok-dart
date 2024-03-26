part of '../../cli.dart';

mixin Since implements KrakenTimeOption {
  KrakenTime? since;

  initSince(ArgParser argParser) {
    initKrakenTimeOption(
      argParser,
      name: "since",
      abbr: "s",
      since: true,
      allowShortForm: false,
      assign: _assignSince,
    );
  }

  KrakenTime? _assignSince(String? it) =>
      since = it != null ? KrakenTime.fromString(it, since: true, allowShortForm: false) : since;
}

mixin KrakenTimeOption {
  initKrakenTimeOption(
    ArgParser argParser, {
    required String name,
    String? abbr,

    /// "direction" of relative values. if true, duration is subtracted from "now". added otherwise.
    /// this is passed into [assign] along the value given.
    required bool since,

    /// allow "+<seconds>"?
    required bool allowShortForm,

    /// callback receiving the value specified on the command line.
    required Function(String?) assign,
  }) {
    final help = [
      "Either: Timestamp in UNIX format (UTC).",
      "Or: RFC3339/ISO8601 datetime.",
      "Or: Relative time in seconds/minutes/hours/days, using s/m/h/d suffix.",
      if (allowShortForm) "Or: +seconds with a leading plus sign.",
      "Relative examples: 15m, 1h, 30s",
    ];
    argParser.addOption(
      name,
      abbr: abbr,
      help: help.join("\n"),
      valueHelp: "timestamp|datetime|relative",
      callback: assign,
    );
  }
}
