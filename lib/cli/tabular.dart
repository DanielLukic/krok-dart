part of 'cli.dart';

enum OutputFormat { csv, json, raw, table }

extension on String? {
  OutputFormat asOutputFormat({
    OutputFormat defaultValue = OutputFormat.table,
  }) =>
      OutputFormat.values.firstWhere(
        (it) => it.name.toLowerCase() == this?.toLowerCase(),
        orElse: () => defaultValue,
      );
}

mixin _Tabular {
  OutputFormat format = OutputFormat.table;
  List<String>? columns;
  bool allColumns = false;
  bool full = false;

  bool get tabular =>
      format == OutputFormat.table || format == OutputFormat.csv;

  initTabularOptions(ArgParser argParser) {
    argParser.addOption(
      "format",
      abbr: "f",
      help: "Select output format. Note that raw and json show all columns.",
      allowed: ["raw", "json", "csv", "table"],
      defaultsTo: "table",
      callback: (it) => format = it.asOutputFormat(defaultValue: format),
    );
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
    argParser.addFlag(
      "full",
      help: "Extract full values of selected columns.\n"
          'Otherwise, only the first ("primary") value is extracted.\n'
          "Applies only if a column contains list data.",
      negatable: false,
      callback: (it) => full = it,
    );
  }

  processTabularData(Result result) {
    // auto-select all columns if "--table" without "--columns":
    if (columns == null && tabular) allColumns = true;

    var selected = columns;
    if (allColumns) selected = _findAllColumns(result);

    switch (format) {
      case OutputFormat.csv:
        dumpCsv("pair", selected!, result, _primaryValueOnly);
      case OutputFormat.json:
        dumpJson(result);
      case OutputFormat.raw:
        dumpByKey(result);
      case OutputFormat.table:
        dumpTable("pair", selected!, result, _primaryValueOnly);
    }
  }

  List<String>? _findAllColumns(Result result) {
    final merged = result.entries.map((e) => e.value.keys);
    return {
      for (final Iterable<String> columns in merged) ...columns,
    }.toList();
  }

  String _primaryValueOnly(dynamic it) {
    if (it is List && it.isNotEmpty && !full) {
      return it[0].toString();
    } else {
      return it.toString();
    }
  }
}
