part of 'cli.dart';

mixin _Tabular {
  List<String>? columns;
  bool allColumns = false;
  String format = "table";

  bool get tabular => format == "table" || format == "csv";

  initTabularOptions(ArgParser argParser) {
    argParser.addMultiOption(
      "columns",
      abbr: "c",
      help: "Format primary values of the specified columns as CSV list.\n"
          "If nothing specified, the raw output will be shown.\n"
          "Please see the Kraken API documentation for details about the columns.",
      callback: (it) => columns = it.isNullOrEmpty ? null : it,
    );
    argParser.addFlag(
      "all",
      help: "Select all columns.",
      negatable: false,
      callback: (it) => allColumns = it,
    );
    argParser.addOption(
      "format",
      abbr: "f",
      help: "Select output format. Note that raw and json show all columns.",
      allowed: ["raw", "json", "csv", "table"],
      defaultsTo: "table",
      callback: (it) => format = it ?? format,
    );
  }

  processTabularData(Result result) {
    // auto-select all columns if "--table" without "--columns":
    if (columns == null && tabular) allColumns = true;

    var selected = columns;
    if (allColumns) selected = _findAllColumns(result);

    if (selected != null) {
      if (format == "table") {
        dumpTable("pair", selected, result, _primaryValueOnly);
        return;
      } else if (format == "csv") {
        dumpCsv("pair", selected, result, _primaryValueOnly);
        return;
      }
    }

    if (format == "json") {
      for (final entry in result.entries) {
        final key = entry.key;
        final json = jsonEncode(entry.value);
        print("$key: $json");
      }
    } else {
      dumpByKey(result);
    }
  }

  List<String>? _findAllColumns(Result result) {
    final merged = result.entries.map((e) => e.value.keys);
    return {
      for (final Iterable<String> columns in merged) ...columns,
    }.toList();
  }

  String _primaryValueOnly(dynamic it) {
    if (it is List) {
      return it[0].toString();
    } else {
      return it.toString();
    }
  }
}
