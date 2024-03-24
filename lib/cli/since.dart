part of 'cli.dart';

mixin Since {
  DateTime? since;

  initSinceOption(ArgParser argParser) {
    argParser.addOption(
      "since",
      abbr: "s",
      help: "Either: Timestamp in UNIX format (UTC).\n"
          "Or: RFC3339 datetime.\n"
          "Or: Relative time in seconds/minutes/hours/days, using s/m/h/d suffix.\n"
          "A maximum of 720 values is returned.",
      valueHelp: "timestamp|datetime|relative",
      callback: (it) => _parseSince(it),
    );
  }

  _parseSince(String? it) {
    if (it == null) return null;
    if (RegExp(r"^\d+$").hasMatch(it)) {
      since = DateTime.fromMillisecondsSinceEpoch(int.parse(it), isUtc: true);
    } else if (RegExp(r"^\d+[smhd]$").hasMatch(it)) {
      since = it.toRelativeDateTime();
    } else {
      since = DateTime.parse(it);
    }
  }
}
