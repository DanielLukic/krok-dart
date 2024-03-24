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

mixin Tabular {
  OutputFormat format = OutputFormat.table;
  List<String>? columns;
  bool allColumns = false;
  bool full = false;

  bool get tabular => format == OutputFormat.table || format == OutputFormat.csv;

  List<dynamic> firstColumnToDateTime(List<dynamic> e) => e.modify<int>(0, (it) => it.toKrakenDateTime());

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

  processResultList(List<dynamic> result) {
    if (result.isEmpty) {
      print("no data");
      return;
    }
    final raw = result.map((e) => e as List<dynamic>);
    final data = raw.map((e) => e.map((e) => e.toString()).toList()).toList();
    switch (format) {
      case OutputFormat.raw:
        result.forEach(print);
      case OutputFormat.json:
        for (final row in result) {
          print(jsonEncode(row));
        }
      case OutputFormat.csv:
        formatCsv(data).forEach(print);
      case OutputFormat.table:
        formatTable(data, headerDivider: false).forEach(print);
    }
  }

  processResultMap(Result result) {
    switch (format) {
      case OutputFormat.raw:
        print(result);
      case OutputFormat.json:
        print(jsonEncode(result));
      case OutputFormat.csv:
        formatCsv(result.asTableData()).forEach(print);
      case OutputFormat.table:
        formatTable(result.asTableData(), headerDivider: false).forEach(print);
    }
  }

  processVerticalResultMap(Result result, List<String> columns) {
    switch (format) {
      case OutputFormat.raw:
        print(result);
      case OutputFormat.json:
        print(jsonEncode(result));
      case OutputFormat.csv:
        formatCsv(result.asTableData()).forEach(print);
      case OutputFormat.table:
        formatTable(result.asTableData(), headerDivider: false).forEach(print);
    }
  }

  processResultMapOfMaps(
    Result result, {
    String keyColumn = "pair",
    bool autoFormatDateTime = true,
    bool primaryListValueOnly = true,
  }) {
    // this is crazy... revisit ^^

    // auto-select all columns if "--table" without "--columns":
    if (columns == null && tabular) allColumns = true;

    var selected = columns;
    if (allColumns) selected = _findAllColumns(result);

    if (format case OutputFormat.json) {
      dumpJson(result);
      return;
    } else if (format case OutputFormat.raw) {
      dumpByKey(result);
      return;
    }

    final convert = primaryListValueOnly ? _primaryValueOnly : (it) => it.toString();
    var rows = asTableData(keyColumn, selected!, result, convert);
    if (autoFormatDateTime) rows = modifyDateTimeColumns(rows);

    if (format case OutputFormat.csv) {
      formatCsv(rows).forEach(print);
    } else if (format case OutputFormat.table) {
      formatTable(rows).forEach(print);
    }
  }

  List<List<String>> modifyDateTimeColumns(List<List<String>> rows) {
    final columns = rows.first.indexWhere_((it) => it.endsWith("tm"));
    final header = rows.removeAt(0);
    rows = [header, ...rows.map((row) => modifyDateTimeInPlace(columns, row))];
    return rows;
  }

  List<String> modifyDateTimeInPlace(List<int> todo, List<String> row) {
    for (final column in todo) {
      if (row[column] == "0") {
        row.modify(column, (p0) => "");
      } else {
        row.modify(column, (p0) => _toKrakenDateTime(p0) ?? "");
      }
    }
    return row;
  }

  String? _toKrakenDateTime(dynamic it) => double.tryParse(it)?.toKrakenDateTime().toString();

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
