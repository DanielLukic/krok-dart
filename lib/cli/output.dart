// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:convert';

import 'package:krok/common/extensions.dart';

/// Pad data from inner list to same length, with single space plus | as table
/// divider around each cell. Insert a - line after the first row if [headerDivider].
List<String> formatTable(List<List<String>> rows, {bool headerDivider = true}) {
  int toStringLength(String it) => it.length;

  final allColumns = rows.first; // pair + dataColumns
  final columnLengths = List.generate(
    allColumns.length,
    (column) => rows.extractColumn(column).map(toStringLength).toMax(),
  );

  String reformat(List<String> row, List<int> columnLengths) =>
      [for (var i = 0; i < allColumns.length; i++) " ${row[i].padRight(columnLengths[i])} |"].join("");

  final formatted = rows
      .map(
        (row) => "|${reformat(row, columnLengths)}",
      )
      .toList();

  if (headerDivider) {
    formatted.insert(1, "".padLeft(formatted.first.length, "-"));
  }

  return formatted;
}

List<String> formatCsv(List<List<String>> rows) => rows.map((row) => row.join(",")).toList();

dumpJson(Map<String, dynamic> resultMap) {
  for (final entry in resultMap.entries) {
    final key = entry.key;
    final json = jsonEncode(entry.value);
    print("$key: $json");
  }
}

/// Dumb output of [resultMap] by printing each key plus the value in a line.
dumpByKey(Map<String, dynamic> resultMap) {
  for (var entry in resultMap.entries) {
    print("${entry.key}: ${resultMap[entry.key]}");
  }
}
