part of '../cli.dart';

class SystemStatus extends Command {
  @override
  String get name => "status";

  @override
  String get description => "Retrieve Kraken system status.";

  @override
  List<String> get aliases => const ["s"];

  SystemStatus() {
    argParser.addOption(
      "format",
      abbr: "f",
      help: "Select output format.",
      allowed: ["raw", "json", "csv", "table"],
      defaultsTo: "table",
      callback: (it) => format = it.asOutputFormat(defaultValue: format),
    );
  }

  OutputFormat format = OutputFormat.table;

  @override
  Future<void> run() async {
    final api = KrakenApi.fromFile(_keyFilePath);
    try {
      var result = await api.retrieve(KrakenRequest.systemStatus());
      switch (format) {
        case OutputFormat.raw:
          print(result);
        case OutputFormat.json:
          print(jsonEncode(result));
        case OutputFormat.csv:
          formatCsv(result.asTableData()).forEach(print);
        case OutputFormat.table:
          formatTable(result.asTableData()).forEach(print);
      }
    } finally {
      api.close();
    }
  }
}
